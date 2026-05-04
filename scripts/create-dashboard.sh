#!/bin/bash

##############################################################################
# create-dashboard.sh
# Purpose: Create CloudWatch Dashboard for portfolio contact form monitoring
# Author: Brian Lasky
# Date: May 4, 2026
##############################################################################

set -e

# Configuration
REGION="${AWS_REGION:-us-east-1}"
DASHBOARD_NAME="portfolio-contact-form-monitoring"
LAMBDA_FUNCTION="portfolio-contact-form"
API_GATEWAY_ID="3skxu9j6v8"

echo "📊 Creating CloudWatch Dashboard..."
echo "Dashboard: $DASHBOARD_NAME"
echo "Region: $REGION"

# Create Dashboard JSON
DASHBOARD_JSON=$(cat <<'JSON_EOF'
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [ "AWS/Lambda", "Duration", { "stat": "Average" } ],
          [ ".", "Errors", { "stat": "Sum" } ],
          [ ".", "Invocations", { "stat": "Sum" } ],
          [ ".", "Throttles", { "stat": "Sum" } ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Lambda Metrics",
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [ "AWS/ApiGateway", "Count", { "stat": "Sum" } ],
          [ ".", "4XXError", { "stat": "Sum" } ],
          [ ".", "5XXError", { "stat": "Sum" } ],
          [ ".", "Latency", { "stat": "Average" } ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "API Gateway Metrics",
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          [ "AWS/Route53", "HealthCheckStatus", { "stat": "Minimum" } ],
          [ ".", "HealthCheckPercentageHealthy", { "stat": "Average" } ]
        ],
        "period": 60,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Route 53 Health Status"
      }
    },
    {
      "type": "log",
      "properties": {
        "query": "fields @timestamp, @message, @duration | stats count() by bin(5m)",
        "region": "us-east-1",
        "title": "Lambda Log Insights"
      }
    }
  ]
}
JSON_EOF
)

# Create the dashboard
echo "🔨 Creating dashboard with CloudWatch API..."
aws cloudwatch put-dashboard \
  --dashboard-name "$DASHBOARD_NAME" \
  --dashboard-body "$DASHBOARD_JSON" \
  --region "$REGION"

echo "✅ Dashboard Created Successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Dashboard Details:"
echo "   Name: $DASHBOARD_NAME"
echo "   Region: $REGION"
echo "   Widgets: 4 (Lambda, API Gateway, Route 53, Logs)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 View Dashboard:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGION#dashboards:name=$DASHBOARD_NAME"

