# Project Scope Status

## Project Overview

This document tracks the implementation status of the **IAM Least Privilege Lab** project for NovaCloud Analytics S.r.l.

The goal of this lab is to demonstrate how an initially insecure IAM setup can be analyzed, remediated, and converted into a least privilege AWS environment managed with Terraform.

The project is designed for cloud security and AWS portfolio purposes. It includes IAM users, groups, roles, policies, MFA enforcement, temporary credentials through AWS STS, IAM Access Analyzer, S3 access boundaries, CloudTrail evidence, detection notes, and incident response documentation.

---

## Original Scope

The original scope requires the project to demonstrate:

- an initially insecure IAM configuration;
- risk analysis of the insecure configuration;
- remediation through least privilege IAM policies;
- MFA usage for sensitive access flows;
- temporary access through IAM roles and AWS STS;
- IAM Access Analyzer usage;
- Terraform-based infrastructure management;
- documentation and evidence suitable for a public GitHub portfolio.

---

## Current Implementation Status

### Completed

The following components have already been implemented.

| Area | Status | Notes |
|---|---:|---|
| Project structure | Completed | Repository structure, documentation folders, evidence folders, Terraform folders, and Git hygiene are in place. |
| Git initialization | Completed | Repository initialized on the `main` branch. |
| Terraform bootstrap | Completed | Remote state bootstrap has been implemented. |
| Terraform backend for dev | Completed | The dev environment uses a remote backend through `backend.hcl`. |
| Secure S3 data bucket | Completed | A secure data bucket exists with public access blocked, server-side encryption, versioning, and controlled prefixes. |
| Data analyst IAM role | Completed | A least privilege read-only role for data analysts has been created. |
| Data analyst S3 policy | Completed | The role can only list and read the allowed `reports/` prefix. |
| STS AssumeRole flow | Completed | Temporary credentials have been tested through AWS STS. |
| MFA enforcement | Completed | The data analyst role trust policy requires MFA for role assumption. |
| IAM Access Analyzer | Completed | An account-level analyzer has been created. |
| IAM Access Analyzer policy validation | Completed | The final data analyst policy has been validated with no findings. |
| CloudTrail management event review | Completed | `AssumeRole` events have been queried from CloudTrail Event History. |
| Sanitized evidence | Completed | A sanitized CloudTrail evidence file has been saved. |
| Detection notes | Completed | Detection documentation for suspicious `AssumeRole` activity exists. |
| Incident response runbook | Completed | A runbook for suspicious role assumption has been created. |
| Documentation foundation | Completed | README, architecture notes, security notes, evidence notes, detection notes, and incident response notes exist. |

---

## Implemented AWS Resources

### S3

The following S3 bucket has been created:

| Resource | Purpose | Status |
|---|---|---:|
| `novacloud-iam-lab-dev-606895006811` | Data bucket used for the data analyst least privilege scenario | Completed |

Security controls already implemented:

- S3 Block Public Access enabled;
- server-side encryption with AES256;
- versioning enabled;
- controlled prefixes:
  - `reports/`
  - `evidence/`

The `reports/` prefix is used for allowed data analyst access.

The `evidence/` prefix is intentionally not accessible by the data analyst role and was used for negative access tests.

---

### IAM

The following IAM role has been created:

| Resource | Purpose | Status |
|---|---|---:|
| `novacloud-iam-lab-dev-data-analyst-readonly` | Read-only temporary access role for data analysts | Completed |

The following IAM policy has been created:

| Resource | Purpose | Status |
|---|---|---:|
| `novacloud-iam-lab-dev-data-analyst-s3-readonly` | Allows restricted read-only access to the `reports/` prefix only | Completed |

The data analyst role currently allows:

- `s3:GetBucketLocation` on the data bucket;
- `s3:ListBucket` only for the `reports`, `reports/`, and `reports/*` prefixes;
- `s3:GetObject` only on `reports/*`.

The data analyst role does not allow:

- writing objects;
- deleting objects;
- reading the `evidence/` prefix;
- listing the bucket root;
- modifying IAM;
- performing administrative actions.

---

### MFA and STS

The data analyst role trust policy requires:

- `aws:MultiFactorAuthPresent = true`

The following tests have been completed:

| Test | Expected Result | Status |
|---|---|---:|
| Assume role without MFA | Access denied | Passed |
| Assume role with MFA | Access allowed | Passed |
| Read allowed object under `reports/` | Access allowed | Passed |
| Write object to bucket | Access denied | Passed |
| Delete object from bucket | Access denied | Passed |
| Read object under `evidence/` | Access denied | Passed |
| List bucket root | Access denied | Passed |
| Run IAM administrative actions | Access denied | Passed |

---

### IAM Access Analyzer

The following analyzer has been created:

| Resource | Type | Status |
|---|---|---:|
| `novacloud-iam-lab-dev-access-analyzer` | Account analyzer | Completed |

Current result:

```json
{
  "findings": []
}
```

The final data analyst identity policy was validated with IAM Access Analyzer and returned no findings.

---

### CloudTrail Evidence

CloudTrail Event History was used to review `AssumeRole` management events related to the data analyst role.

A sanitized evidence file was saved under:

```text
evidence/checkpoint-08-cloudtrail-assume-role-events.json
```

The project intentionally avoids publishing full raw CloudTrail event payloads because they can be verbose and may contain sensitive operational metadata.

---

## Partially Completed Scope

The following items are partially covered but not yet complete.

| Area | Status | Notes |
|---|---:|---|
| Least privilege IAM design | Partial | Fully implemented for the data analyst role only. Developer and security auditor still need full implementation. |
| Temporary access through roles | Partial | Implemented and tested for the data analyst role. Developer and security auditor role flows are still missing. |
| MFA | Partial | Enforced on the data analyst role assumption flow. Other sensitive flows still need to be reviewed. |
| S3 environment | Partial | Data bucket exists. Dedicated development and production buckets are still missing. |
| Evidence | Partial | Evidence exists for data analyst access, MFA, Access Analyzer, and CloudTrail. More evidence is needed for developer and security auditor scenarios. |
| Documentation | Partial | Core documentation exists, but security analysis, remediation plan, cost control, and final README polish are still missing. |

---

## Missing Scope

The following items still need to be implemented to fully satisfy the original project requirements.

### IAM Users

The following IAM users are still missing:

- `developer-user`
- `data-analyst-user`
- `security-auditor-user`

These users should be created carefully and should not rely on long-lived access keys unless there is a documented reason.

---

### IAM Groups

The following IAM groups are still missing:

- `developers-group`
- `data-analysts-group`
- `security-auditors-group`

Each user should be assigned to the appropriate group.

---

### IAM Roles

The following IAM roles are still missing:

- `developer-temporary-role`
- `security-audit-role`

The existing role below is already implemented:

- `novacloud-iam-lab-dev-data-analyst-readonly`

Future role trust policies must be restrictive and should avoid broad principals or unnecessary assumptions.

---

### S3 Buckets

The following S3 buckets still need to be added:

- development bucket;
- production bucket.

The existing data bucket should be preserved or carefully refactored without breaking the current tested scenario.

The final S3 environment should clearly separate:

| Bucket Type | Purpose |
|---|---|
| Development bucket | Used by developers for read/write application work. |
| Data bucket | Used by data analysts for read-only access to business reports. |
| Production bucket | Protected bucket that should not be accessible by developers or analysts. |

---

### Developer Scenario

The developer scenario still needs to be implemented.

Developers should be able to:

- read objects from the development bucket;
- upload objects to the development bucket;
- read selected CloudWatch logs;
- assume an authorized temporary role when required;
- use MFA for sensitive flows where applicable.

Developers should not be able to:

- delete buckets;
- access the production bucket;
- modify IAM users, roles, groups, or policies;
- manage IAM policies;
- assume unauthorized roles.

---

### Security Auditor Scenario

The security auditor scenario still needs to be implemented.

Security auditors should be able to:

- list IAM users;
- list IAM groups;
- list IAM roles;
- view IAM policies;
- use IAM Access Analyzer;
- review security-relevant IAM configuration.

Security auditors should not be able to:

- create IAM users;
- modify IAM policies;
- attach administrative policies;
- create privileged roles;
- delete IAM resources.

---

### Insecure Baseline

The project still needs an explicit insecure baseline.

This baseline should document examples such as:

- overly broad S3 access for developers;
- unnecessary write access for data analysts;
- overly permissive trust policies;
- excessive IAM permissions for security auditors;
- policies using broad combinations such as `Action: "*"` and `Resource: "*"`.

These insecure policies should preferably be stored as documented examples under a dedicated folder such as:

```text
policies/insecure-examples/
```

They should not be applied permanently to the AWS account unless there is a controlled, temporary, and well-documented reason.

---

### Remediation Documentation

The project still needs before-and-after remediation documentation.

Required documents:

```text
docs/security-analysis.md
docs/remediation-plan.md
```

These documents should explain:

- the insecure configuration;
- the associated risk;
- the business impact;
- the least privilege correction;
- the final expected behavior.

---

### CloudWatch Logs

The developer scenario still requires CloudWatch Logs access.

The project should include:

- a CloudWatch log group;
- at least one log stream or documented test log;
- IAM permissions allowing developers to read logs;
- negative tests proving developers cannot manage unrelated CloudWatch or IAM resources.

---

### Cost Control and Cleanup

The project still needs cost control documentation.

Required document:

```text
docs/cost-control.md
```

This document should explain:

- which resources may generate costs;
- how to destroy the dev environment;
- how to handle versioned S3 buckets before destruction;
- when to destroy or preserve the Terraform bootstrap backend;
- why CloudTrail data events should be used carefully;
- how to avoid leaving unnecessary resources active.

---

## Remaining Checkpoints

The remaining work should continue through the following checkpoints.

| Checkpoint | Title | Goal |
|---:|---|---|
| 12 | Project Scope Status | Create this status document and realign the project with the original scope. |
| 13 | Multi-bucket S3 Environment | Add development, data, and production S3 bucket structure. |
| 14 | IAM Users and Groups | Add users, groups, and group memberships for the three teams. |
| 15 | Insecure Baseline Policies | Create and document intentionally insecure IAM examples. |
| 16 | Least Privilege Remediation | Implement final least privilege policies for all teams. |
| 17 | Developer Tests | Prove allowed and denied developer actions. |
| 18 | Security Auditor Tests | Prove allowed and denied security auditor actions. |
| 19 | Security Analysis and Remediation Plan | Document risk, impact, and before/after remediation. |
| 20 | Cost Control and Cleanup | Document cost control and safe teardown procedures. |
| 21 | Final Polish and GitHub Push | Review docs, evidence, secrets, README, and publish only when ready. |

---

## Current Risk Position

At this stage, the project is in a safe intermediate state.

The currently deployed data analyst scenario follows least privilege and has been validated through positive and negative tests.

However, the full project scope is not yet complete because the developer and security auditor scenarios are not implemented yet, and the insecure baseline has not been explicitly documented.

Before publishing the project as portfolio-ready, the missing scope should be completed and the repository should be reviewed for:

- secrets;
- sensitive account details;
- excessive CloudTrail output;
- Terraform state files;
- real access keys;
- MFA codes;
- unnecessary local files.

---

## Next Step

The next implementation step is:

```text
Checkpoint 13 — Multi-bucket S3 Environment
```

Before modifying Terraform, the existing S3 module and dev environment files should be reviewed carefully to avoid breaking the already tested data analyst scenario.