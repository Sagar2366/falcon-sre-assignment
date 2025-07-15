# Simple Lambda Function: AWS Daily Cost Reporter

This is a minimal AWS Lambda function in Python that queries yesterday's AWS cost using Cost Explorer and (in Lambda) sends a summary email via SES.

---

## Prerequisites

- Python 3.7+
- [boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) (`pip install -r requirements.txt`)
- AWS credentials with permissions for Cost Explorer and SES
- (For Lambda email) Verified SES sender and recipient emails in your AWS region

---

## Local Test

1. **Install dependencies:**
   ```sh
   pip install -r requirements.txt
   ```
2. **Configure AWS credentials:**
   - Run `aws configure` or set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` as environment variables.
   - The credentials must have `ce:GetCostAndUsage` permission.
3. **Run the script:**
   ```sh
   python3 lambda_function.py
   ```
   - This will print yesterday's AWS cost to the console.
   - **No email is sent in local mode.**

**Expected output:**
```
Your AWS cost for 2024-06-18 was $1.23.
```

---

## Deploy to AWS Lambda

1. **Zip the function:**
   ```sh
   zip function.zip lambda_function.py
   ```
2. **Create a new Lambda function** (Python 3.8+ runtime) and upload the zip.
3. **Set environment variables** in the Lambda console:
   - `SES_SENDER` (must be a verified SES sender email)
   - `SES_RECIPIENT` (recipient email, must be verified in sandbox)
   - `AWS_REGION` (e.g., `us-east-1`)
4. **Attach an IAM role** with these permissions:
   - `ce:GetCostAndUsage`
   - `ses:SendEmail`
5. **(SES Sandbox)**: Both sender and recipient must be verified in SES sandbox mode. Move to production SES to send to any email.

---

## Example IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage",
        "ses:SendEmail"
      ],
      "Resource": "*"
    }
  ]
}
```

---

## Environment Variables

- `SES_SENDER`: Email address to send from (must be verified in SES)
- `SES_RECIPIENT`: Email address to send to (must be verified in SES sandbox)
- `AWS_REGION`: AWS region (default: `us-east-1`)

You can set these in the Lambda console or as environment variables for local test.

---

## Troubleshooting

- **Cost Explorer API errors:**
  - Make sure Cost Explorer is enabled in your AWS account.
  - Ensure your IAM user/role has `ce:GetCostAndUsage` permission.
- **SES email not sent:**
  - Both sender and recipient must be verified in SES sandbox.
  - Check Lambda logs for error messages.
- **boto3 not found:**
  - Run `pip install -r requirements.txt`.
- **AWS credentials not found:**
  - Run `aws configure` or set environment variables.

---

## Customization & Maintenance

- Edit `lambda_function.py` to change cost query logic, email formatting, or add features.
- Update `requirements.txt` if you add dependencies.
- Rotate credentials and review IAM permissions regularly.

---

## Cost & Security Notes

- This script queries Cost Explorer once per run (minimal cost).
- SES may incur charges if sending large volumes of email.
- Restrict Lambda IAM permissions to least privilege.
- Never hardcode credentials in the script.

---

## References
- [AWS Cost Explorer API](https://docs.aws.amazon.com/aws-cost-management/latest/APIReference/API_GetCostAndUsage.html)
- [AWS SES Getting Started](https://docs.aws.amazon.com/ses/latest/dg/send-email-set-up.html)
- [boto3 SES Docs](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ses.html) 