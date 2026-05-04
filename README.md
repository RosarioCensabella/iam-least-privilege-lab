# IAM Least Privilege Lab

## Overview

This project is a hands-on AWS security lab focused on IAM least privilege, Terraform, temporary credentials, MFA, IAM Access Analyzer, CloudTrail evidence, and access validation.

The lab simulates a security consulting engagement for a fictional company:

```text
NovaCloud Analytics S.r.l.
```

The goal is to move from risky IAM access patterns to a controlled least privilege model and document the before-and-after remediation process in a portfolio-ready format.

---

## Project Goals

This lab demonstrates:

- insecure IAM baseline examples;
- risk analysis of over-permissive IAM permissions;
- least privilege remediation with scoped IAM policies;
- IAM users, groups, roles, and policy attachments;
- MFA-protected role assumption;
- temporary credentials through AWS STS;
- S3 environment separation;
- IAM Access Analyzer usage;
- CloudTrail Event History review for `AssumeRole` activity;
- positive and negative access testing;
- Terraform-managed infrastructure;
- cost control and cleanup guidance.

---

## Scenario

NovaCloud Analytics has three simulated teams:

| Team | Business Need | Final Access Model |
|---|---|---|
| Developer | Work with development assets and read application logs | Read/write access only to selected prefixes in the development S3 bucket and read-only access to a dedicated CloudWatch log group |
| Data Analyst | Read approved business reports | MFA-protected temporary role with read-only access to the `reports/` prefix |
| Security Auditor | Review IAM and Access Analyzer configuration | IAM and Access Analyzer read-only visibility without administrative control |

---

## Implemented Architecture

The lab currently includes:

### IAM

- IAM users:
  - `novacloud-iam-lab-dev-developer-user`
  - `novacloud-iam-lab-dev-data-analyst-user`
  - `novacloud-iam-lab-dev-security-auditor-user`

- IAM groups:
  - `novacloud-iam-lab-dev-developers-group`
  - `novacloud-iam-lab-dev-data-analysts-group`
  - `novacloud-iam-lab-dev-security-auditors-group`

- IAM role:
  - `novacloud-iam-lab-dev-data-analyst-readonly`

- IAM managed policies:
  - Developer least privilege policy
  - Data analyst assume-role policy
  - Data analyst S3 read-only role policy
  - Security auditor read-only policy

### S3

The lab uses separate S3 buckets for access-boundary testing:

| Bucket | Purpose |
|---|---|
| `novacloud-iam-lab-dev-development-606895006811` | Development bucket for developer read/write tests |
| `novacloud-iam-lab-dev-606895006811` | Data bucket for data analyst report access |
| `novacloud-iam-lab-dev-production-606895006811` | Protected production bucket for negative access tests |

Security controls include:

- S3 Block Public Access;
- server-side encryption with AES256;
- versioning;
- Terraform-managed configuration.

### CloudWatch Logs

The lab includes a dedicated CloudWatch log group for developer log-read testing:

```text
/novacloud/iam-lab/dev/developer-app
```

### IAM Access Analyzer

An account-level IAM Access Analyzer is enabled:

```text
novacloud-iam-lab-dev-access-analyzer
```

It is used for:

- listing findings;
- validating IAM policies;
- documenting policy validation results.

### CloudTrail

CloudTrail Event History is used to review management events related to:

```text
sts:AssumeRole
```

Only sanitized evidence is stored in the repository.

---

## Terraform Structure

```text
terraform/
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── terraform.tfvars.example
│
├── envs/
│   └── dev/
│       ├── backend.hcl.example
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── versions.tf
│
└── modules/
    ├── cloudwatch_app_logs/
    ├── iam_access_analyzer/
    ├── iam_data_analyst_role/
    ├── iam_least_privilege_policies/
    ├── iam_users_groups/
    ├── s3_data_bucket/
    └── s3_secure_bucket/
```

---

## Documentation

| Document | Purpose |
|---|---|
| `docs/architecture.md` | Architecture notes |
| `docs/security-notes.md` | Security design notes |
| `docs/project-scope-status.md` | Scope alignment and implementation status |
| `docs/security-analysis.md` | Risk analysis and security interpretation |
| `docs/remediation-plan.md` | Before-and-after remediation plan |
| `docs/detection.md` | Detection logic and CloudTrail review notes |
| `docs/incident-response-runbook.md` | Incident response workflow for suspicious role assumption |
| `docs/evidence.md` | Evidence index and testing notes |
| `docs/cost-control.md` | Cost control and cleanup guide |

---

## Evidence

Evidence files are stored under:

```text
evidence/
```

Key evidence includes:

| Evidence | Purpose |
|---|---|
| `checkpoint-04-iam-readonly-tests.md` | Initial IAM read-only and denied access tests |
| `checkpoint-06-mfa-assume-role-tests.md` | MFA and STS AssumeRole validation |
| `checkpoint-07-access-analyzer-review.md` | Access Analyzer review |
| `checkpoint-08-cloudtrail-assume-role-events.json` | Sanitized CloudTrail AssumeRole event evidence |
| `checkpoint-08-cloudtrail-detection.md` | Detection notes for AssumeRole activity |
| `checkpoint-13-multi-bucket-s3-environment.md` | Multi-bucket S3 evidence |
| `checkpoint-14-iam-users-groups.md` | IAM users and groups evidence |
| `checkpoint-15-insecure-baseline-policies.md` | Insecure policy baseline evidence |
| `checkpoint-16-least-privilege-remediation.md` | Least privilege remediation evidence |
| `checkpoint-17-developer-tests.md` | Developer positive and negative tests |
| `checkpoint-18-security-auditor-tests.md` | Security auditor positive and negative tests |

---

## Insecure Baseline Examples

The insecure baseline examples are stored under:

```text
policies/insecure-examples/
```

These examples are intentionally not attached to IAM users, groups, or roles.

They demonstrate:

- developer over-permissive S3 access;
- data analyst unnecessary write/delete access;
- security auditor excessive IAM permissions;
- unsafe wildcard role trust policy.

This allows the project to show realistic risk analysis without leaving dangerous permissions active in the AWS account.

---

## Least Privilege Remediation Summary

| Area | Insecure Baseline | Final Remediation |
|---|---|---|
| Developer S3 access | `s3:*` on `Resource: "*"` | Read/write only on selected prefixes in the development bucket |
| Data Analyst access | Direct S3 read/write/delete access | MFA-protected temporary role with read-only access to `reports/` |
| Security Auditor access | `iam:*` and `access-analyzer:*` | IAM and Access Analyzer read-only permissions |
| Role trust policy | Wildcard principal without MFA | Restricted principals with MFA required |
| Environment separation | Shared or unclear S3 boundaries | Dedicated development, data, and production buckets |
| Credentials | Potential long-lived access keys | No access keys or console passwords created by Terraform |

---

## Validation Summary

### Developer

Developer tests confirmed:

- can list authorized development prefixes;
- can read and write authorized development objects;
- can read authorized CloudWatch log data;
- cannot read production S3 data;
- cannot delete S3 buckets;
- cannot create IAM users;
- cannot delete CloudWatch log groups.

### Data Analyst

Data analyst tests confirmed:

- cannot assume role without MFA;
- can assume role with MFA;
- can read approved `reports/` objects;
- cannot write objects;
- cannot delete objects;
- cannot read the `evidence/` prefix;
- cannot list the bucket root.

### Security Auditor

Security auditor tests confirmed:

- can list IAM users, groups, and roles;
- can read IAM user and policy metadata;
- can use IAM Access Analyzer read and validation actions;
- cannot create IAM users;
- cannot create IAM policies;
- cannot attach policies to users;
- cannot pass IAM roles;
- cannot delete Access Analyzer resources.

---

## Security Notes

This project intentionally avoids creating long-lived user credentials through Terraform.

The IAM users exist to model team identities and support policy simulation.

The data analyst role demonstrates temporary access through AWS STS and MFA-protected role assumption.

The final policies avoid broad combinations such as:

```json
{
  "Action": "*",
  "Resource": "*"
}
```

The final project also avoids final policies with:

```text
s3:*
iam:*
```

---

## Local Files Not Committed

The following local files are intentionally ignored and must not be committed:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
terraform.tfvars
backend.hcl
bootstrap.tfplan
*.tfplan
```

The following values must never be committed:

```text
AWS access keys
AWS secret keys
AWS session tokens
MFA codes
Full raw CloudTrail payloads with sensitive metadata
Terraform state files
```

---

## Running Terraform

### Bootstrap

The bootstrap layer creates the remote state infrastructure.

```powershell
cd terraform\bootstrap
terraform init
terraform plan
terraform apply
```

Use `terraform.tfvars.example` as a reference.

Do not commit a real `terraform.tfvars`.

### Dev Environment

The dev environment uses a remote backend configuration.

```powershell
cd terraform\envs\dev
terraform init -reconfigure "-backend-config=backend.hcl"
terraform validate
terraform plan
terraform apply
```

Do not commit the real `backend.hcl`.

Use:

```text
terraform/envs/dev/backend.hcl.example
```

as a safe template.

---

## Cleanup

See:

```text
docs/cost-control.md
```

for the full cleanup and cost control guide.

Typical dev environment teardown:

```powershell
cd terraform\envs\dev
terraform init -reconfigure "-backend-config=backend.hcl"
terraform plan -destroy
terraform destroy
```

Be careful with versioned S3 buckets. Object versions and delete markers may need to be removed before bucket deletion succeeds.

Destroy the Terraform bootstrap backend only when all environments are destroyed and no future Terraform work is planned.

---

## Current Status

Implemented:

- Terraform remote state bootstrap;
- secure data bucket;
- development and production S3 buckets;
- IAM users and groups;
- data analyst MFA-protected role;
- least privilege policies for Developer, Data Analyst, and Security Auditor;
- IAM Access Analyzer;
- CloudWatch Logs test target;
- CloudTrail AssumeRole evidence;
- insecure baseline policy examples;
- security analysis;
- remediation plan;
- cost control guide;
- positive and negative access tests.

Known future improvements:

- add a dedicated `developer-temporary-role`;
- add a dedicated `security-audit-role`;
- add runtime CloudWatch log events for live log-read testing;
- add controlled Access Analyzer external-access examples;
- polish architecture diagrams further if needed.

---

## Disclaimer

This is a learning and portfolio lab, not a full production architecture.

The project is intentionally scoped to demonstrate IAM least privilege concepts in a controlled AWS account.

Before adapting this design to production, review:

- organizational IAM standards;
- AWS account structure;
- SCPs and AWS Organizations controls;
- centralized logging requirements;
- KMS requirements;
- monitoring and alerting requirements;
- incident response procedures;
- current AWS pricing and service quotas.