\# IAM Least Privilege Lab



\## Project Overview



This project is a hands-on AWS security lab focused on Identity and Access Management, least privilege design, temporary access, logging, and detection.



The lab simulates a consulting engagement for \*\*NovaCloud Analytics S.r.l.\*\*, a small cloud analytics company that needs to reduce excessive AWS permissions and improve visibility over identity-based access.



The goal is to design and implement a secure AWS IAM environment using Terraform, following cloud security best practices and documenting the reasoning behind each architectural and security decision.



\## Business Scenario



NovaCloud Analytics S.r.l. uses AWS to store and process internal analytics data. Over time, IAM permissions have become too broad, with users and roles having access beyond what they actually need.



The company wants to:



\- Reduce excessive permissions

\- Enforce least privilege access

\- Use temporary credentials where appropriate

\- Improve auditability through logging

\- Detect risky IAM configurations

\- Produce evidence for security review and portfolio documentation



\## Security Focus



This lab focuses on the following areas:



\- IAM users, groups, roles, and policies

\- Least privilege permissions

\- MFA-aware access design

\- Temporary access through role assumption

\- IAM Access Analyzer findings

\- CloudTrail-based visibility

\- Detection logic and incident response notes

\- Terraform-based infrastructure as code



\## Repository Structure



```text

iam-least-privilege-lab/

├── docs/

├── evidence/

├── policies/

├── scripts/

└── terraform/

&#x20;   ├── bootstrap/

&#x20;   ├── envs/

&#x20;   │   └── dev/

&#x20;   └── modules/



Planned Deliverables

Deliverable	Purpose

README.md	Project overview, business scenario, architecture, and security goals

Terraform	Infrastructure as Code for IAM, logging, Access Analyzer, and supporting resources

Architecture Diagram	Cloud architecture and trust boundaries

Security Notes	Threats, controls, limitations, and production improvements

Detection	Log sources, SIEM-style queries, alerts, and runbook

Evidence	CLI outputs, screenshots, findings, and remediation proof

Cost Control	Cleanup process and cost awareness



Status

This project is currently under active development.



Current phase:

Repository initialization and Terraform remote state bootstrap

