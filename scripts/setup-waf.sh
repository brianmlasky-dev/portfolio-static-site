#!/bin/bash

##############################################################################
# setup-waf.sh
# Purpose: Deploy AWS WAF Web ACL for API Gateway protection
# Author: Brian Lasky
# Date: May 4, 2026
##############################################################################

set -e

# Configuration
REGION="${AWS_REGION:-us-east-1}"
WAF_NAME="portfolio-contact-waf"
API_GATEWAY_ID="3skxu9j6v8"
RATE_LIMIT="2000"
RATE_WINDOW="300"

echo "🛡️  Starting AWS WAF Setup..."
echo "Region: $REGION"
echo "WAF Name: $WAF_NAME"
echo "API Gateway ID: $API_GATEWAY_ID"

# 1. Create IP Set for Rate Limiting
echo "📋 Creating IP Set for rate limiting..."
IP_SET_ARN=$(aws wafv2 create-ip-set \
  --name "portfolio-rate-limit-ips" \
  --scope REGIONAL \
  --region "$REGION" \
  --ip-address-version IPV4 \
  --addresses [] \
  --query 'Summary.ARN' \
  --output text 2>/dev/null || echo "")

if [ -z "$IP_SET_ARN" ]; then
  echo "⚠️  IP Set may already exist (continuing...)"
fi

# 2. Create Web ACL
echo "🔐 Creating Web ACL: $WAF_NAME"
WEB_ACL=$(aws wafv2 create-web-acl \
  --name "$WAF_NAME" \
  --scope REGIONAL \
  --region "$REGION" \
  --default-action Block={} \
  --rules '[
    {
      "Name": "RateLimitRule",
      "Priority": 1,
      "Statement": {
        "RateBasedStatement": {
          "Limit": '$RATE_LIMIT',
          "AggregateKeyType": "IP"
        }
      },
      "Action": { "Block": {} },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "RateLimitRule"
      }
    },
    {
      "Name": "AWSManagedRulesCommonRuleSet",
      "Priority": 2,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "Name": "AWSManagedRulesCommonRuleSet",
          "VendorName": "AWS"
        }
      },
      "OverrideAction": { "None": {} },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesCommonRuleSet"
      }
    },
    {
      "Name": "AWSManagedRulesSQLiProtection",
      "Priority": 3,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "Name": "AWSManagedRulesSQLiRuleSet",
          "VendorName": "AWS"
        }
      },
      "OverrideAction": { "None": {} },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesSQLiProtection"
      }
    }
  ]' \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName="$WAF_NAME" \
  --query 'Summary.ARN' \
  --output text)

echo "✅ Web ACL Created: $WEB_ACL"

# 3. Associate WAF with API Gateway
echo "🔗 Associating WAF with API Gateway..."
WEB_ACL_ID=$(echo "$WEB_ACL" | awk -F'/' '{print $(NF-1)}')

aws wafv2 associate-web-acl \
  --web-acl-arn "$WEB_ACL" \
  --resource-arn "arn:aws:apigateway:$REGION::/restapis/$API_GATEWAY_ID/stages/prod" \
  --region "$REGION" 2>/dev/null || echo "⚠️  WAF may already be associated (continuing...)"

echo "✅ WAF Associated with API Gateway"

# 4. Save configuration
mkdir -p ~/.config/portfolio
cat > ~/.config/portfolio/.waf-config.sh << 'CONFIG_EOF'
#!/bin/bash
# WAF Configuration - Keep Secure
export WAF_NAME="portfolio-contact-waf"
export WEB_ACL_ARN="$WEB_ACL"
export API_GATEWAY_ID="3skxu9j6v8"
export RATE_LIMIT="2000"
CONFIG_EOF

chmod 600 ~/.config/portfolio/.waf-config.sh

echo ""
echo "✅ WAF Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🛡️  WAF Details:"
echo "   Web ACL Name: $WAF_NAME"
echo "   Web ACL ARN: $WEB_ACL"
echo "   Rate Limit: $RATE_LIMIT requests per $RATE_WINDOW seconds"
echo "   Rules: RateLimitRule, CommonRuleSet, SQLi Protection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 View WAF in Console:"
echo "   https://console.aws.amazon.com/wafv2/homev2/region/$REGION?region=$REGION#/web-acl/$WAF_NAME/overview"

