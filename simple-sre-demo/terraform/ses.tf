resource "aws_ses_email_identity" "sender" {
  email = var.ses_sender
}

# Note: For production, verify domain and set up DKIM/SPF as needed. 