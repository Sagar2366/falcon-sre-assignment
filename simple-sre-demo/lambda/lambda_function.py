import os
import boto3
import json
from datetime import datetime, timedelta

# Set these as environment variables in Lambda or for local test
SES_SENDER = os.environ.get('SES_SENDER', 'admin@company.com')
SES_RECIPIENT = os.environ.get('SES_RECIPIENT', 'admin@company.com')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')

# Initialize boto3 clients
ce = boto3.client('ce', region_name=AWS_REGION)
ses = boto3.client('ses', region_name=AWS_REGION)

def get_yesterday_cost():
    """Query AWS Cost Explorer for yesterday's total cost."""
    end = datetime.utcnow().date()
    start = end - timedelta(days=1)
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': start.strftime('%Y-%m-%d'),
            'End': end.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost']
    )
    amount = response['ResultsByTime'][0]['Total']['UnblendedCost']['Amount']
    return float(amount), start.strftime('%Y-%m-%d')

def send_email(cost, date):
    """Send a cost summary email via SES."""
    subject = f"AWS Daily Cost Report: {date}"
    body = f"Your AWS cost for {date} was ${cost:.2f}."
    ses.send_email(
        Source=SES_SENDER,
        Destination={'ToAddresses': [SES_RECIPIENT]},
        Message={
            'Subject': {'Data': subject},
            'Body': {'Text': {'Data': body}}
        }
    )

def handler(event, context):
    cost, date = get_yesterday_cost()
    send_email(cost, date)
    return {
        'statusCode': 200,
        'body': json.dumps({'date': date, 'cost': cost})
    }

if __name__ == "__main__":
    # Local test: just print the cost summary, do not send email
    cost, date = get_yesterday_cost()
    print(f"Your AWS cost for {date} was ${cost:.2f}.") 