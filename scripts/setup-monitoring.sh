#!/bin/bash

##############################################################################
# setup-monitoring.sh
# Purpose: Create CloudWatch alarms and SNS topic for portfolio contact form
# Author: Brian Lasky
# Date: May 4, 2026
##############################################################################

set -e

# Configuration
REGION="${AWS_REGION:-us-east-1}"
SNS_TOPIC_NAME="portfolio-contact-form-alerts"
EMAIL="${ALERT_EMAIL:-brian.lasky@outlook.com}"
LAMBDA_FUNCTION="portfolio-contact-form"
API_GATEWAY_ID="3skxu9j6v8"

echo "🔧 Starting CloudWatch Monitoring Setup..."
echo "Region: $REGION"
echo "SNS Email: $EMAIL"

# 1. Create SNS Topic
echo "📢 Creating SNS Topic: $SNS_TOPIC_NAME"
SNS_TOPIC_ARN=$(aws sns create-topic \
  --name "$SNS_TOPIC_NAME" \
  --region "$REGION" \
  --query 'TopicArn' \
  --output text)

echo "✅ SNS Topic Created: $SNS_TOPIC_ARN"

# 2. Subscribe Email to SNS Topic
echo "📧 Subscribing $EMAIL to SNS Topic..."
SUBSCRIPTION_ARN=$(aws sns subscribe \
  --topic-arn "$SNS_TOPIC_ARN" \
  --protocol email \
  --notification-endpoint "$EMAIL" \
  --region "$REGION" \
  --query 'SubscriptionArn' \
  --output text)

echo "✅ Subscription pending confirmation at: $EMAIL"

# 3. Create CloudWatch Alarm: Lambda Errors
echo "🚨 Creating Lambda Error Alarm..."
aws cloudwatch put-metric-alarm \
  --alarm-name "portfolio-lambda-errors" \
  --alarm-description "Alert when Lambda errors exceed threshold" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions "$SNS_TOPIC_ARN" \
  --dimensions Name=FunctionName,Value="$LAMBDA_FUNCTION" \
  --region "$REGION"

echo "✅ Lambda Error Alarm Created"

# 4. Create CloudWatch Alarm: API Gateway High Latency
echo "🐌 Creating API Gateway Latency Alarm..."
aws cloudwatch put-metric-alarm \
  --alarm-name "portfolio-api-high-latency" \
  --alarm-description "Alert when API latency exceeds 500ms" \
  --metric-name Latency \
  --namespace AWS/ApiGateway \
  --statistic Average \
  --period 300 \
  --threshold 500 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions "$SNS_TOPIC_ARN" \
  --dimensions Name=ApiName,Value=portfolio-api \
  --region "$REGION"

echo "✅ API Gateway Latency Alarm Created"

# 5. Create CloudWatch Alarm: Lambda Throttles
echo "⚡ Creating Lambda Throttle Alarm..."
aws cloudwatch put-metric-alarm \
  --alarm-name "portfolio-lambda-throttles" \
  --alarm-description "Alert when Lambda is throttled" \
  --metric-name Throttles \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions "$SNS_TOPIC_ARN" \
  --dimensions Name=FunctionName,Value="$LAMBDA_FUNCTION" \
  --region "$REGION"

echo "✅ Lambda Throttle Alarm Created"

# 6. Save configuration
mkdir -p ~/.config/portfolio
cat > ~/.config/portfolio/.monitoring-config.sh << 'CONFIG_EOF'
#!/bin/bash
# Monitoring Configuration - Keep Secure
export SNS_TOPIC_ARN="$SNS_TOPIC_ARN"
export ALERT_EMAIL="$EMAIL"
export LAMBDA_FUNCTION="$LAMBDA_FUNCTION"
export API_GATEWAY_ID="$API_GATEWAY_ID"
CONFIG_EOF

chmod 600 ~/.config/portfolio/.monitoring-config.sh

echo ""
echo "✅ Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary:"
echo "   SNS Topic ARN: $SNS_TOPIC_ARN"
echo "   Email Alert: $EMAIL"
echo "   Alarms Created: 3 (Errors, Latency, Throttles)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📧 Action Required: Confirm SNS subscription email"
echo "🔗 Check: $EMAIL for confirmation link"

