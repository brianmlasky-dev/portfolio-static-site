#!/usr/bin/env python3
"""
Generate professional resume PDF for Brian Lasky
Using ReportLab for reliable PDF generation
"""

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from datetime import datetime

# Create PDF
pdf_filename = "resume.pdf"
doc = SimpleDocTemplate(pdf_filename, pagesize=letter,
                       rightMargin=0.6*inch, leftMargin=0.6*inch,
                       topMargin=0.6*inch, bottomMargin=0.6*inch)

# Container for the 'Flowable' objects
elements = []

# Define styles
styles = getSampleStyleSheet()
title_style = ParagraphStyle(
    'CustomTitle',
    parent=styles['Heading1'],
    fontSize=18,
    textColor=colors.HexColor('#1a73e8'),
    spaceAfter=6,
    alignment=TA_CENTER,
    fontName='Helvetica-Bold'
)

subtitle_style = ParagraphStyle(
    'Subtitle',
    parent=styles['Normal'],
    fontSize=11,
    textColor=colors.HexColor('#5f6368'),
    alignment=TA_CENTER,
    spaceAfter=12
)

heading_style = ParagraphStyle(
    'SectionHeading',
    parent=styles['Heading2'],
    fontSize=12,
    textColor=colors.HexColor('#1a73e8'),
    spaceAfter=8,
    spaceBefore=10,
    fontName='Helvetica-Bold',
    borderColor=colors.HexColor('#dadce0'),
    borderWidth=0,
    borderPadding=5
)

# Title
elements.append(Paragraph("BRIAN LASKY", title_style))
elements.append(Paragraph("Cloud Solutions Architect | AWS & Google Cloud Certified", subtitle_style))

# Contact info
contact_data = [
    ["📧 Brian.lasky@outlook.com", "🔗 linkedin.com/in/brian-lasky-67464086"],
    ["💻 github.com/brianmlasky-dev", "🌐 https://brian-lasky.com"]
]
contact_table = Table(contact_data, colWidths=[3.25*inch, 3.25*inch])
contact_table.setStyle(TableStyle([
    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
    ('FONTNAME', (0, 0), (-1, -1), 'Helvetica'),
    ('FONTSIZE', (0, 0), (-1, -1), 9),
    ('TEXTCOLOR', (0, 0), (-1, -1), colors.HexColor('#5f6368')),
]))
elements.append(contact_table)
elements.append(Spacer(1, 0.15*inch))

# Professional Summary
elements.append(Paragraph("PROFESSIONAL SUMMARY", heading_style))
summary_text = """
Cloud Solutions Architect with AWS Solutions Architect Associate and Google Cloud Professional Cloud Architect certifications. Proven expertise designing and implementing scalable, secure infrastructure across AWS and Google Cloud. Specialized in Infrastructure as Code using Terraform, automated CI/CD pipelines with GitHub Actions, and disaster recovery architecture. Security-first mindset with focus on cost optimization and high-availability systems.
"""
elements.append(Paragraph(summary_text, styles['Normal']))
elements.append(Spacer(1, 0.1*inch))

# Certifications
elements.append(Paragraph("CERTIFICATIONS & CREDENTIALS", heading_style))
cert_data = [
    ["AWS Certified Solutions Architect – Associate", "Active | Validates: AWS cloud architecture & cost optimization"],
    ["Google Cloud Certified Professional Cloud Architect", "Active | Validates: GCP services & enterprise solutions"]
]
cert_table = Table(cert_data, colWidths=[2.5*inch, 3.75*inch])
cert_table.setStyle(TableStyle([
    ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, -1), 9),
    ('TEXTCOLOR', (0, 0), (0, -1), colors.HexColor('#1a73e8')),
    ('TOPPADDING', (0, 0), (-1, -1), 4),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#dadce0')),
]))
elements.append(cert_table)
elements.append(Spacer(1, 0.1*inch))

# Technical Skills
elements.append(Paragraph("TECHNICAL SKILLS", heading_style))

skills_data = [
    ["Cloud Platforms", "AWS (EC2, Lambda, S3, CloudFront, RDS, IAM, CloudWatch), Google Cloud (Compute Engine, Cloud Storage, Cloud Run)"],
    ["Infrastructure as Code", "Terraform 1.5.7+ (HCL, state management, modular design, remote backends)"],
    ["CI/CD & DevOps", "GitHub Actions, OIDC Authentication, Git, Bash scripting, automated deployments"],
    ["Security & Compliance", "TLS 1.3, IAM, ACM certificates, encryption (KMS, S3), network design, compliance auditing"],
    ["Monitoring & Observability", "CloudWatch (dashboards, metrics, alarms), cost analysis, performance optimization"],
    ["Architecture Patterns", "Disaster Recovery, High Availability, Auto-scaling, Cost optimization, Zero-trust security"]
]

skills_table = Table(skills_data, colWidths=[1.8*inch, 4.45*inch])
skills_table.setStyle(TableStyle([
    ('ALIGN', (0, 0), (0, -1), 'LEFT'),
    ('ALIGN', (1, 0), (1, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, -1), 8.5),
    ('TEXTCOLOR', (0, 0), (0, -1), colors.HexColor('#1a73e8')),
    ('VALIGN', (0, 0), (-1, -1), 'TOP'),
    ('TOPPADDING', (0, 0), (-1, -1), 4),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
]))
elements.append(skills_table)
elements.append(Spacer(1, 0.1*inch))

# Featured Projects
elements.append(Paragraph("FEATURED PROJECTS", heading_style))

elements.append(Paragraph("<b>Portfolio Static Site</b> – AWS S3, CloudFront, Terraform, GitHub Actions, TLS 1.3", styles['Normal']))
elements.append(Paragraph("Production-grade static site demonstrating modern cloud best practices: global edge delivery via CloudFront, TLS 1.3 encryption, automated CI/CD with OIDC, infrastructure-as-code provisioning, and real-time GA4 analytics.", ParagraphStyle('Normal2', parent=styles['Normal'], fontSize=8.5, textColor=colors.HexColor('#5f6368'))))
elements.append(Spacer(1, 0.06*inch))

elements.append(Paragraph("<b>Multi-Cloud Disaster Recovery Platform</b> – AWS, Google Cloud, Terraform, CloudWatch", styles['Normal']))
elements.append(Paragraph("Comprehensive DR solution enabling automated failover across multiple cloud providers with cross-region replication, real-time monitoring dashboards, and documented RTO/RPO targets.", ParagraphStyle('Normal2', parent=styles['Normal'], fontSize=8.5, textColor=colors.HexColor('#5f6368'))))
elements.append(Spacer(1, 0.06*inch))

elements.append(Paragraph("<b>CI/CD Automation Framework</b> – GitHub Actions, OIDC, Terraform, Bash, AWS", styles['Normal']))
elements.append(Paragraph("Reusable framework enabling secure, automated cloud deployments with OIDC-based authentication, modular workflows, environment-specific configurations, and comprehensive documentation.", ParagraphStyle('Normal2', parent=styles['Normal'], fontSize=8.5, textColor=colors.HexColor('#5f6368'))))
elements.append(Spacer(1, 0.1*inch))

# Professional Experience
elements.append(Paragraph("PROFESSIONAL EXPERIENCE", heading_style))
elements.append(Paragraph("<b>Cloud Solutions Architect / DevOps Engineer</b>", styles['Normal']))
exp_text = """
• Designed and deployed scalable cloud infrastructure on AWS and Google Cloud<br/>
• Architected disaster recovery solutions with multi-region failover capabilities<br/>
• Implemented infrastructure-as-code using Terraform for reproducible deployments<br/>
• Established CI/CD pipelines with GitHub Actions and OIDC authentication<br/>
• Optimized cloud costs through resource analysis and rightsizing<br/>
• Implemented comprehensive monitoring with CloudWatch and custom dashboards<br/>
• Established security best practices including IAM, encryption, and network design
"""
elements.append(Paragraph(exp_text, ParagraphStyle('Bullets', parent=styles['Normal'], fontSize=8.5, leftIndent=0.2*inch, bulletIndent=0.15*inch)))
elements.append(Spacer(1, 0.1*inch))

# Additional Info
elements.append(Paragraph("ADDITIONAL INFORMATION", heading_style))
additional_data = [
    ["Work Authorization:", "Authorized to work in the United States"],
    ["Availability:", "Available for Cloud Engineer / Solutions Architect roles"],
    ["Preferred Work:", "Remote, hybrid, or on-site positions"],
    ["References:", "Available upon request"]
]
add_table = Table(additional_data, colWidths=[1.5*inch, 4.75*inch])
add_table.setStyle(TableStyle([
    ('ALIGN', (0, 0), (0, -1), 'LEFT'),
    ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, -1), 8.5),
    ('TEXTCOLOR', (0, 0), (0, -1), colors.HexColor('#1a73e8')),
    ('TOPPADDING', (0, 0), (-1, -1), 2),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
]))
elements.append(add_table)

# Build PDF
doc.build(elements)
print(f"✅ Resume PDF generated successfully: {pdf_filename}")
print(f"📄 File size: {__import__('os').path.getsize(pdf_filename)} bytes")

