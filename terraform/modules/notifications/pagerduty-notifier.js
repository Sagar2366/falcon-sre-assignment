const https = require("https");

exports.handler = async (event) => {
  const apiKey = process.env.PAGERDUTY_API_KEY;
  const serviceId = process.env.PAGERDUTY_SERVICE_ID;
  const environment = process.env.ENVIRONMENT;

  if (!apiKey || !serviceId) {
    console.error("PAGERDUTY_API_KEY or PAGERDUTY_SERVICE_ID not configured");
    return { statusCode: 500, body: "PagerDuty credentials not configured" };
  }

  try {
    // Parse SNS message
    const snsMessage = JSON.parse(event.Records[0].Sns.Message);
    const alarmName = snsMessage.AlarmName;
    const alarmDescription = snsMessage.AlarmDescription;
    const newState = snsMessage.NewStateValue;
    const oldState = snsMessage.OldStateValue;
    const timestamp = snsMessage.StateChangeTime;

    // Create PagerDuty incident
    const incidentData = {
      incident: {
        type: "incident",
        title: `AWS CloudWatch Alarm: ${alarmName}`,
        service: {
          id: serviceId,
          type: "service_reference",
        },
        urgency: newState === "ALARM" ? "high" : "low",
        body: {
          type: "incident_body",
          details: `
**Alarm Details:**
- **Name:** ${alarmName}
- **Environment:** ${environment}
- **Status:** ${oldState} → ${newState}
- **Description:** ${alarmDescription || "No description provided"}
- **Time:** ${new Date(timestamp).toISOString()}

**AWS CloudWatch Alarm triggered. Please investigate.**
                    `.trim(),
        },
      },
    };

    // Send to PagerDuty
    await sendToPagerDuty(apiKey, incidentData);

    return { statusCode: 200, body: "Notification sent to PagerDuty" };
  } catch (error) {
    console.error("Error processing notification:", error);
    return { statusCode: 500, body: "Error processing notification" };
  }
};

function sendToPagerDuty(apiKey, incidentData) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(incidentData);

    const options = {
      hostname: "api.pagerduty.com",
      port: 443,
      path: "/incidents",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Token token=${apiKey}`,
        Accept: "application/vnd.pagerduty+json;version=2",
        "Content-Length": Buffer.byteLength(postData),
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(data));
        } else {
          reject(
            new Error(
              `PagerDuty API responded with status ${res.statusCode}: ${data}`
            )
          );
        }
      });
    });

    req.on("error", (error) => {
      reject(error);
    });

    req.write(postData);
    req.end();
  });
}
