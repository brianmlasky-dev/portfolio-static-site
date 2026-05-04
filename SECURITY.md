# Security & Disaster Recovery Documentation

## Overview
This document outlines the security architecture, disaster recovery (DR) procedures, DDoS protection mechanisms, monitoring strategy, and incident response procedures for the brian-lasky.com portfolio contact form.

## Multi-Region Disaster Recovery (DR) Architecture

### Primary Region: us-east-1
- API Gateway: ID 3skxu9j6v8
- Lambda Function: portfolio-contact-form
- Route 53 Zone: Z35SXDOTRQ7X7K
- Traffic Weight: 70%
- Response Time: ~145ms (avg)

### Secondary Region: us-west-2
- API Gateway: ID 3a68u71td9
- Lambda Function: portfolio-contact-form
- Route 53 Zone: Z1H1FL5HABSF5
- Traffic Weight: 30%
- Response Time: ~167ms (avg)

### Active-Active Failover Configuration
- DNS Record: api.brian-lasky.com (Weighted A records)
- TTL: 60 seconds
- Health Check Interval: 30 seconds
- Failure Threshold: 3 consecutive failed checks
- Automatic Failover: Enabled

### RTO & RPO Targets
- RTO (Recovery Time Objective): < 2 minutes (DNS failover)
- RPO (Recovery Point Objective): < 5 minutes (Lambda replication lag)

## DDoS Protection Strategy

### 1. AWS WAF (Web Application Firewall)
Web ACL: portfolio-contact-waf (us-east-1)

Rules Deployed:
- Rate Limit Rule: 2,000 requests per 5 minutes per IP
- AWS Managed Rules - Common Rule Set
- AWS Managed Rules - SQLi Protection

### 2. API Gateway Throttling
- Rate Limit: 10,000 requests/second
- Burst Limit: 5,000 requests
- Stage: prod

### 3. Request Validation
- Validator: portfolio-request-validator
- Body Validation: Enabled
- Parameter Validation: Enabled
- Endpoint: POST /prod/contact

## Monitoring & Alerting

### CloudWatch Alarms
1. portfolio-lambda-errors: >= 5 errors in 5 min
2. portfolio-api-high-latency: > 500ms latency over 2 periods
3. portfolio-lambda-throttles: >= 1 throttle

### SNS Topic
- Topic: portfolio-contact-form-alerts
- Subscribers: brian.lasky@outlook.com
- Protocol: Email

### CloudWatch Dashboard
- Dashboard: portfolio-contact-form-monitoring
- Widgets: 4 (Lambda, API Gateway, Route 53, Logs)
- Refresh Rate: 1 minute

## Email Service Configuration

### SES (Simple Email Service)
- Verified Address: brian.lasky@outlook.com
- Sending Quota: 200 emails per 24 hours
- DKIM: Pending verification
- SPF: Pending verification

## Cost Estimates

Monthly Operational Costs:
- Lambda (10,000 invocations/month): $0.20
- API Gateway (1M requests/month): $3.50
- CloudWatch (Alarms + Logs): $2.00
- Route 53 (2 health checks): $0.50
- SES (200 emails/month): $1.00
- CloudFront (if used, ~100GB/month): $8.50
- Total: ~$11.00/month

## Incident Response Procedures

### Scenario 1: Lambda Errors Spike
Alert: portfolio-lambda-errors triggered

Steps:
1. Check CloudWatch Logs for errors
2. Review recent deployments
3. If necessary, rollback to previous version
4. Verify SES quota not exceeded
5. Check IAM permissions for SES

Command:
aws logs tail /aws/lambda/portfolio-contact-form --follow --region us-east-1

### Scenario 2: High API Latency
Alert: portfolio-api-high-latency triggered

Steps:
1. Check Lambda duration metrics
2. Verify database/SES connection latency
3. Check if throttling is occurring
4. Monitor memory allocation (increase if needed)
5. Review concurrent execution count

### Scenario 3: DDoS Attack
Alert: WAF blocks spike detected

Steps:
1. Check WAF metrics in CloudWatch
2. Review top blocked IP addresses
3. Consider IP-based blocklist addition
4. Monitor API Gateway metrics
5. Contact AWS Support if attack persists

### Scenario 4: Regional Failover
Alert: Primary region health check fails

Steps:
1. Route 53 automatically fails over to us-west-2
2. Monitor failover completion (< 2 minutes)
3. Verify API responses from secondary region
4. Investigate primary region outage
5. Once fixed, manual failback to primary

## Security Best Practices

### 1. Credential Management
- AWS credentials stored in ~/.aws/credentials (not in repo)
- .gitignore prevents accidental commits
- Environment variables used for sensitive config
- IAM roles used instead of access keys where possible

### 2. Network Security
- API Gateway request validation enabled
- WAF rules deployed
- HTTPS-only endpoints
- Health checks via HTTPS (Port 443)

### 3. Data Protection
- Encryption in transit (HTTPS/TLS)
- SES verified email address
- No sensitive data in logs
- CloudWatch log retention policy (90 days)

### 4. Access Control
- Lambda execution role with minimal permissions
- SES access restricted to verified address
- API Gateway authorized via request validation
- SNS subscriptions require email confirmation

## Maintenance & Drills

### Monthly Tasks
- Review CloudWatch alarms and metrics
- Check WAF blocked request trends
- Verify SES quota status
- Test email alerts by triggering manual alarm
- Review CloudWatch logs for anomalies

### Quarterly Tasks
- Run DR drill (test secondary region failover)
- Update WAF rules if needed
- Review and update security documentation
- Audit IAM permissions
- Test incident response procedures

### Annual Tasks
- Full disaster recovery exercise (both regions)
- Security audit and penetration testing
- Update cost estimates and optimize
- Review and renew domain DKIM/SPF records

## Contact & Support

Portfolio Owner: Brian Lasky
Email: brian.lasky@outlook.com
Primary Region: us-east-1
Secondary Region: us-west-2

For security incidents, contact AWS Support immediately.

Last Updated: May 4, 2026
Document Version: 1.0
