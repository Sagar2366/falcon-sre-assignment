resource "aws_lambda_function" "cost_notifier" {
  function_name = "cost-notifier"
  handler       = "lambda_function.handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec.arn
  filename      = var.lambda_zip_path # Path to zipped code
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      SES_SENDER    = var.ses_sender
      SES_RECIPIENT = var.ses_recipient
      AWS_REGION    = var.aws_region
    }
  }
} 