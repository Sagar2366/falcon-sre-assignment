const https = require("https");
const url = require("url");

exports.handler = async (event) => {
  const webhookUrl = process.env.SLACK_WEBHOOK_URL;
  const environment = process.env.ENVIRONMENT;

  if (!webhookUrl) {
    console.error("SLACK_WEBHOOK_URL not configured");
    return { statusCode: 500, body: "Webhook URL not configured" };
  }

  try {
    // Parse SNS message
    const snsMessage = JSON.parse(event.Records[0].Sns.Message);
    const alarmName = snsMessage.AlarmName;
    const alarmDescription = snsMessage.AlarmDescription;
    const newState = snsMessage.NewStateValue;
    const oldState = snsMessage.OldStateValue;
    const timestamp = snsMessage.StateChangeTime;

    // Create Slack message
    const slackMessage = {
      text: `AWS CloudWatch Alarm`,
      attachments: [
        {
          color: newState === "ALARM" ? "#ff0000" : "#36a64f",
          fields: [
            {
              title: "Alarm Name",
              value: alarmName,
              short: true,
            },
            {
              title: "Environment",
              value: environment,
              short: true,
            },
            {
              title: "Status",
              value: `${oldState} → ${newState}`,
              short: true,
            },
            {
              title: "Description",
              value: alarmDescription || "No description provided",
              short: false,
            },
            {
              title: "Time",
              value: new Date(timestamp).toISOString(),
              short: true,
            },
          ],
          footer: "AWS CloudWatch",
          ts: Math.floor(Date.now() / 1000),
        },
      ],
    };

    // Send to Slack
    await sendToSlack(webhookUrl, slackMessage);

    return { statusCode: 200, body: "Notification sent to Slack" };
  } catch (error) {
    console.error("Error processing notification:", error);
    return { statusCode: 500, body: "Error processing notification" };
  }
};

function sendToSlack(webhookUrl, message) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(message);
    const parsedUrl = url.parse(webhookUrl);

    const options = {
      hostname: parsedUrl.hostname,
      port: 443,
      path: parsedUrl.path,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(postData),
      },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => {
        data += chunk;
      });
      res.on("end", () => {
        if (res.statusCode === 200) {
          resolve(data);
        } else {
          reject(
            new Error(
              `Slack API responded with status ${res.statusCode}: ${data}`
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
