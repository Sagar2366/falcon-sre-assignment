import json
import boto3
import os
from datetime import datetime, timedelta
from botocore.exceptions import ClientError
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
ce_client = boto3.client('ce')
ses_client = boto3.client('ses')

def get_cost_data(start_date, end_date):
    """
    Query AWS Cost Explorer for cost data
    """
    try:
        response = ce_client.get_cost_and_usage(
            TimePeriod={
                'Start': start_date,
                'End': end_date
            },
            Granularity='DAILY',
            Metrics=['UnblendedCost'],
            GroupBy=[
                {'Type': 'DIMENSION', 'Key': 'SERVICE'},
                {'Type': 'DIMENSION', 'Key': 'LINKED_ACCOUNT'}
            ]
        )
        return response
    except ClientError as e:
        logger.error(f"Error getting cost data: {e}")
        raise

def format_cost_report(cost_data):
    """
    Format cost data into a readable report
    """
    report = []
    total_cost = 0
    
    for result in cost_data['ResultsByTime']:
        date = result['TimePeriod']['Start']
        groups = result['Groups']
        
        daily_total = 0
        services = []
        
        for group in groups:
            service = group['Keys'][0]
            cost = float(group['Metrics']['UnblendedCost']['Amount'])
            daily_total += cost
            
            if cost > 0.01:  # Only include services with significant cost
                services.append({
                    'service': service,
                    'cost': cost,
                    'currency': group['Metrics']['UnblendedCost']['Unit']
                })
        
        total_cost += daily_total
        
        report.append({
            'date': date,
            'daily_total': daily_total,
            'services': sorted(services, key=lambda x: x['cost'], reverse=True)
        })
    
    return {
        'total_cost': total_cost,
        'daily_breakdown': report
    }

def create_email_content(report):
    """
    Create HTML email content from cost report
    """
    html_content = f"""
    <html>
    <head>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 20px; }}
            .header {{ background-color: #f8f9fa; padding: 20px; border-radius: 5px; }}
            .cost-summary {{ background-color: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }}
            .daily-breakdown {{ margin: 20px 0; }}
            .service-item {{ margin: 5px 0; padding: 5px; background-color: #f5f5f5; }}
            .high-cost {{ color: #d32f2f; font-weight: bold; }}
            .medium-cost {{ color: #f57c00; }}
            .low-cost {{ color: #388e3c; }}
        </style>
    </head>
    <body>
        <div class="header">
            <h1>AWS Cost Report</h1>
            <p>Daily cost summary for {datetime.now().strftime('%Y-%m-%d')}</p>
        </div>
        
        <div class="cost-summary">
            <h2>Total Cost: ${report['total_cost']:.2f}</h2>
        </div>
        
        <div class="daily-breakdown">
            <h3>Daily Breakdown</h3>
    """
    
    for day in report['daily_breakdown']:
        html_content += f"""
            <div style="margin: 15px 0; padding: 10px; border: 1px solid #ddd; border-radius: 5px;">
                <h4>{day['date']}</h4>
                <p><strong>Daily Total: ${day['daily_total']:.2f}</strong></p>
                <h5>Services:</h5>
        """
        
        for service in day['services']:
            cost_class = 'low-cost'
            if service['cost'] > 10:
                cost_class = 'high-cost'
            elif service['cost'] > 5:
                cost_class = 'medium-cost'
                
            html_content += f"""
                <div class="service-item">
                    <span class="{cost_class}">{service['service']}: ${service['cost']:.2f}</span>
                </div>
            """
        
        html_content += "</div>"
    
    html_content += """
        </div>
        
        <div style="margin-top: 30px; padding: 15px; background-color: #f8f9fa; border-radius: 5px;">
            <h4>Cost Optimization Recommendations:</h4>
            <ul>
                <li>Review unused resources and terminate them</li>
                <li>Consider Reserved Instances for predictable workloads</li>
                <li>Implement auto-scaling to optimize resource usage</li>
                <li>Set up cost alerts for budget monitoring</li>
            </ul>
        </div>
    </body>
    </html>
    """
    
    return html_content

def send_email(html_content, subject):
    """
    Send email via Amazon SES
    """
    try:
        # Get recipient email from environment variable
        recipient_email = os.environ.get('RECIPIENT_EMAIL', 'admin@crowdstrike.com')
        sender_email = os.environ.get('SENDER_EMAIL', 'cost-reports@crowdstrike.com')
        
        response = ses_client.send_email(
            Source=sender_email,
            Destination={
                'ToAddresses': [recipient_email]
            },
            Message={
                'Subject': {
                    'Data': subject,
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Html': {
                        'Data': html_content,
                        'Charset': 'UTF-8'
                    }
                }
            }
        )
        
        logger.info(f"Email sent successfully: {response['MessageId']}")
        return response['MessageId']
        
    except ClientError as e:
        logger.error(f"Error sending email: {e}")
        raise

def lambda_handler(event, context):
    """
    Main Lambda handler function
    """
    try:
        # Calculate date range (last 7 days by default)
        end_date = datetime.now().date()
        start_date = end_date - timedelta(days=7)
        
        # Get cost data
        logger.info(f"Fetching cost data from {start_date} to {end_date}")
        cost_data = get_cost_data(start_date.isoformat(), end_date.isoformat())
        
        # Format the report
        report = format_cost_report(cost_data)
        
        # Create email content
        html_content = create_email_content(report)
        
        # Send email
        subject = f"AWS Cost Report - {start_date} to {end_date}"
        message_id = send_email(html_content, subject)
        
        # Return success response
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Cost report sent successfully',
                'messageId': message_id,
                'totalCost': report['total_cost'],
                'dateRange': {
                    'start': start_date.isoformat(),
                    'end': end_date.isoformat()
                }
            })
        }
        
    except Exception as e:
        logger.error(f"Error in lambda_handler: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }

# For local testing
if __name__ == "__main__":
    lambda_handler({}, {}) 