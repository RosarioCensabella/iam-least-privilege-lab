# IAM Least Privilege Lab

## Overview

This project is a hands-on AWS security lab focused on IAM least privilege, Terraform, temporary credentials, and access validation.

The scenario simulates a consulting engagement for **NovaCloud Analytics S.r.l.**, a company that wants to reduce the risk of excessive AWS permissions for its analytics workloads.

The lab provisions a secure S3 data bucket and an IAM role that allows data analysts to read only the authorized reports prefix.

---

## Business Scenario

NovaCloud Analytics stores internal analytics reports in Amazon S3.

Data analysts need read-only access to report files, but they must not be able to:

- modify objects;
- delete objects;
- access internal evidence files;
- browse unrelated bucket paths;
- administer bucket settings.

The goal is to implement and validate a least privilege access model.

---

## What This Project Demonstrates

This project demonstrates:

- Terraform project structure with environments and modules;
- Terraform remote state using an S3 backend;
- S3 security baseline controls;
- IAM role design;
- custom IAM policies;
- AWS STS role assumption;
- temporary credentials;
- positive and negative access testing;
- evidence-based security validation.

---

## Current Architecture

    AWS Account
    │
    ├── Terraform Remote State Bucket
    │
    └── IAM Least Privilege Lab
        │
        ├── S3 Data Bucket
        │   ├── reports/
        │   │   └── sample-report.txt
        │   └── evidence/
        │       └── internal-evidence.txt
        │
        └── IAM Role
            └── data-analyst-readonly

Detailed architecture documentation:

    docs/architecture.md
	docs/incident-response-runbook.md

---

## Implemented AWS Resources

### S3 Data Bucket

Bucket:

    novacloud-iam-lab-dev-606895006811

Security controls:

- public access blocked;
- server-side encryption enabled;
- versioning enabled;
- Terraform-managed configuration;
- logical prefixes for reports and evidence.

### IAM Data Analyst Role

Role:

    novacloud-iam-lab-dev-data-analyst-readonly

Policy:

    novacloud-iam-lab-dev-data-analyst-s3-readonly

The role allows:

- `s3:GetBucketLocation`;
- `s3:ListBucket` only for the `reports/` prefix;
- `s3:GetObject` only for objects under `reports/*`.

The role does not allow:

- object uploads;
- object deletion;
- reading `evidence/`;
- unrestricted bucket listing;
- bucket administration.

---

## Terraform Structure

    terraform/
    ├── bootstrap/
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    │   └── versions.tf
    │
    ├── envs/
    │   └── dev/
    │       ├── backend.hcl
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── providers.tf
    │       ├── variables.tf
    │       └── versions.tf
    │
    └── modules/
        ├── s3_data_bucket/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        │
        └── iam_data_analyst_role/
            ├── main.tf
            ├── outputs.tf
            └── variables.tf

---

## Terraform Workflow

### Bootstrap phase

The `terraform/bootstrap` folder creates the infrastructure required for Terraform remote state.

This phase prepares the S3 backend used by the `dev` environment.

### Dev environment

The `terraform/envs/dev` folder provisions the actual lab resources.

Common commands:

    cd terraform\envs\dev
    terraform init -reconfigure "-backend-config=backend.hcl"
    terraform validate
    terraform plan
    terraform apply

---

## Validation Summary

The IAM role was tested using AWS STS temporary credentials.

Positive tests:

| Action | Result |
|---|---|
| Assume role | Allowed |
| List `reports/` | Allowed |
| Download report file | Allowed |

Negative tests:

| Action | Result |
|---|---|
| List bucket root | Denied |
| Read `evidence/` | Denied |
| Upload object | Denied |
| Delete object | Denied |

Evidence:

    evidence/checkpoint-04-iam-readonly-tests.md
    docs/evidence.md

---

## Example STS Test

The data analyst role was assumed using AWS STS:

    $roleArn = terraform output -raw data_analyst_role_arn

    $assumeRole = aws sts assume-role `
      --role-arn $roleArn `
      --role-session-name data-analyst-readonly-test `
      --profile iam-lab | ConvertFrom-Json

Temporary credentials were exported into the PowerShell session:

    $env:AWS_ACCESS_KEY_ID = $assumeRole.Credentials.AccessKeyId
    $env:AWS_SECRET_ACCESS_KEY = $assumeRole.Credentials.SecretAccessKey
    $env:AWS_SESSION_TOKEN = $assumeRole.Credentials.SessionToken
    $env:AWS_DEFAULT_REGION = "eu-west-1"

Caller identity after assuming the role:

    arn:aws:sts::606895006811:assumed-role/novacloud-iam-lab-dev-data-analyst-readonly/data-analyst-readonly-test

---

## Security Notes

Security design notes are available in:

    docs/security-notes.md

Main security principle:

> Grant only the minimum permissions required, only on the required resources, and validate the result with both allowed and denied tests.

---

## Evidence Collected

The project includes evidence for:

- Terraform environment validation;
- S3 data bucket creation;
- S3 public access block;
- S3 server-side encryption;
- S3 versioning;
- IAM role creation;
- IAM custom policy creation;
- STS role assumption;
- positive read-only tests;
- negative denied-access tests.

Evidence index:

    docs/evidence.md

Detailed IAM test evidence:

    evidence/checkpoint-04-iam-readonly-tests.md

---

## Current Status

Completed:

- Terraform environment setup;
- remote state bootstrap;
- S3 data bucket module;
- S3 baseline security controls;
- IAM read-only role module;
- STS assume-role testing;
- positive and negative least privilege validation;
- initial project documentation;
- MFA requirement for role assumption;
- IAM Access Analyzer account-level review;
- IAM custom policy validation with no findings;
- CloudTrail Event History review for STS AssumeRole events;
- detection evidence for role assumption activity;
- detection notes for IAM and S3 access monitoring;
- incident response runbook for suspicious IAM and S3 activity;

Planned next steps:

- add CloudTrail data events for S3 object-level detection;
- add SIEM-style queries;
- add incident response runbook;
- add cost control and teardown instructions;


---

## Security Limitations

This is a learning lab and not a full production architecture.

Current limitations:

- the trusted principal is a lab IAM user;
- MFA enforcement is not implemented yet;
- IAM Identity Center is not implemented yet;
- CloudTrail detection and alerting are not implemented yet;
- IAM Access Analyzer review is not implemented yet;
- KMS customer-managed keys are not used yet;
- CI/CD validation is not implemented yet.

---

## Cleanup

To avoid unnecessary AWS costs, destroy the lab environment when it is no longer needed:

    cd terraform\envs\dev
    terraform destroy

The bootstrap remote state infrastructure should be destroyed only when the project is fully finished and the remote state is no longer needed.