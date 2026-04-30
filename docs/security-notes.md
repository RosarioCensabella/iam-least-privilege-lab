\# IAM Least Privilege Lab



\## Overview



This project is a hands-on AWS security lab focused on IAM least privilege, Terraform, temporary credentials, and access validation.



The scenario simulates a consulting engagement for \*\*NovaCloud Analytics S.r.l.\*\*, a company that wants to reduce the risk of excessive AWS permissions for its analytics workloads.



The lab provisions a secure S3 data bucket and an IAM role that allows data analysts to read only the authorized reports prefix.



\---



\## Business Scenario



NovaCloud Analytics stores internal analytics reports in Amazon S3.



Data analysts need read-only access to report files, but they must not be able to:



\- modify objects;

\- delete objects;

\- access internal evidence files;

\- browse unrelated bucket paths;

\- administer bucket settings.



The goal is to implement and validate a least privilege access model.



\---



\## What This Project Demonstrates



This project demonstrates:



\- Terraform project structure with environments and modules;

\- Terraform remote state using an S3 backend;

\- S3 security baseline controls;

\- IAM role design;

\- custom IAM policies;

\- AWS STS role assumption;

\- temporary credentials;

\- positive and negative access testing;

\- evidence-based security validation.



\---



\## Current Architecture



```text

AWS Account

│

├── Terraform Remote State Bucket

│

└── IAM Least Privilege Lab

&#x20;   │

&#x20;   ├── S3 Data Bucket

&#x20;   │   ├── reports/

&#x20;   │   │   └── sample-report.txt

&#x20;   │   └── evidence/

&#x20;   │       └── internal-evidence.txt

&#x20;   │

&#x20;   └── IAM Role

&#x20;       └── data-analyst-readonly

