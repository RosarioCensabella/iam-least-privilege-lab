\# Evidence Index



This document tracks evidence collected during the IAM Least Privilege Lab.



\---



\## Checkpoint 01 - Terraform Environment Validation



Evidence:



\- Terraform initialized successfully.

\- AWS provider authenticated successfully.

\- Current AWS account, caller ARN, region, and environment were exposed through Terraform outputs.



Relevant outputs:



```text

aws\_account\_id

aws\_caller\_arn

aws\_region

environment



---

## Checkpoint 06 - MFA Requirement for Role Assumption

Evidence file:

    evidence/checkpoint-06-mfa-assume-role-tests.md

Validated behavior:

| Test | Result |
|---|---|
| Assume role without MFA | Denied |
| Assume role with MFA | Allowed |
| List `reports/` after MFA role assumption | Allowed |
| Delete object after MFA role assumption | Denied |

Security conclusion:

The data analyst role can only be assumed when MFA is present, and the role still preserves least privilege permissions after assumption.



---

## Checkpoint 07 - IAM Access Analyzer Review

Evidence file:

    evidence/checkpoint-07-access-analyzer-review.md

Validated behavior:

| Check | Result |
|---|---|
| Access Analyzer created | Passed |
| Analyzer type | ACCOUNT |
| External access findings | None |
| IAM policy validation findings | None |

Security conclusion:

IAM Access Analyzer confirmed that the account-level analyzer is active and that the custom data analyst read-only policy has no validation findings.



---

## Checkpoint 08 - CloudTrail Detection Evidence

Evidence files:

    evidence/checkpoint-08-cloudtrail-detection.md
    evidence/checkpoint-08-cloudtrail-assume-role-events.json

Validated behavior:

| Check | Result |
|---|---|
| CloudTrail Event History queried | Passed |
| `AssumeRole` events found | Passed |
| Events filtered for data analyst role | Passed |
| Sanitized JSON evidence exported | Passed |

Security conclusion:

CloudTrail can be used to detect and investigate `sts:AssumeRole` activity for the data analyst role.


---

## Checkpoint 09 - Detection Notes

Documentation file:

    docs/detection.md

Covered detection areas:

| Area | Status |
|---|---|
| STS AssumeRole monitoring | Documented |
| Failed role assumption detection | Documented |
| IAM policy change monitoring | Documented |
| Access Analyzer findings review | Documented |
| S3 object-level detection | Planned |

Security conclusion:

The lab now includes detection logic for role assumption activity, IAM policy changes, Access Analyzer findings, and future S3 object-level monitoring.

---

## Checkpoint 10 - Incident Response Runbook

Documentation file:

    docs/incident-response-runbook.md

Covered response areas:

| Area | Status |
|---|---|
| Unexpected role assumption triage | Documented |
| MFA requirement validation | Documented |
| IAM policy validation | Documented |
| Access Analyzer findings review | Documented |
| Emergency containment | Documented |
| Terraform drift check | Documented |
| Recovery validation | Documented |

Security conclusion:

The project now includes an operational response workflow for suspicious IAM role assumption and least privilege boundary violations.
