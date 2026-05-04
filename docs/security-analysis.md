\# Security Analysis



\## Overview



This document analyzes the IAM and access control risks identified in the NovaCloud Analytics S.r.l. IAM Least Privilege Lab.



The project simulates a security consulting engagement where an initially over-permissive IAM environment is reviewed, documented, and remediated using least privilege principles.



The analysis focuses on:



\- excessive IAM permissions;

\- overly broad S3 access;

\- unnecessary write/delete access;

\- unsafe role trust relationships;

\- insufficient separation between development, data, and production environments;

\- lack of clear audit-only permissions;

\- temporary access through AWS STS;

\- MFA enforcement for sensitive access flows;

\- IAM Access Analyzer usage.



\---



\## Security Objectives



The security objectives of the remediation are:



1\. Restrict each team to the minimum permissions required for its job function.

2\. Separate development, data, and production resources.

3\. Avoid direct administrative access for non-administrative users.

4\. Use temporary credentials through IAM roles where appropriate.

5\. Require MFA for sensitive role assumption flows.

6\. Preserve audit visibility without granting audit users administrative control.

7\. Validate the final configuration through positive and negative access tests.

8\. Manage all infrastructure with Terraform.



\---



\## Business Context



NovaCloud Analytics S.r.l. has three simulated teams:



| Team | Business Function | Security Requirement |

|---|---|---|

| Developer | Build and test application workflows | Read/write only in the development bucket and read application logs |

| Data Analyst | Review business reports | Read-only access to approved reports |

| Security Auditor | Review IAM and Access Analyzer configuration | Read-only security visibility without administrative control |



The original insecure baseline would have made it difficult to enforce separation of duties between these teams.



The remediation introduces clear access boundaries and validates them through IAM Policy Simulator, STS tests, MFA tests, Access Analyzer validation, and CloudTrail review.



\---



\## High-Level Risk Summary



| Risk | Insecure Configuration | Impact | Remediation |

|---|---|---|---|

| Developers have excessive S3 access | `s3:\*` on `Resource: "\*"` | Developers could access production data, delete buckets, or modify S3 security settings | Restrict developers to read/write object access only in the development bucket |

| Data analysts have unnecessary write access | `s3:PutObject` and `s3:DeleteObject` on `Resource: "\*"` | Analysts could modify or delete datasets and access data outside their role | Use an MFA-protected read-only role scoped to the `reports/` prefix |

| Security auditors have administrative IAM access | `iam:\*` and `access-analyzer:\*` on `Resource: "\*"` | Auditors could create users, attach admin policies, pass roles, or weaken monitoring | Grant read-only IAM and controlled Access Analyzer permissions |

| Role trust is too broad | Trust policy with wildcard principal | Unauthorized principals could attempt role assumption | Restrict trusted principals and require MFA |

| Production data is not isolated | Shared or broadly accessible S3 resources | Developers or analysts could access protected data | Create a dedicated production bucket and deny access by omission |

| Long-lived credentials increase exposure | IAM users with permanent access keys | Credential leakage could lead to persistent unauthorized access | Do not create access keys or console passwords through Terraform |

| Audit users can modify what they review | Security auditor has write permissions | Separation of duties is broken | Auditor gets visibility, not modification rights |

| CloudTrail evidence may expose metadata | Raw CloudTrail payloads published | Sensitive operational details may leak | Store only sanitized evidence |

| Policy validation is missing | Policies are not reviewed before use | Overly broad policies may go unnoticed | Use IAM Access Analyzer validate-policy and document findings |

| Terraform state may expose secrets | State or tfvars committed | Sensitive values may be exposed publicly | Use `.gitignore` and avoid generating secrets in Terraform |



\---



\## Detailed Risk Analysis



\## Risk 1 — Developer S3 Over-Permissioning



\### Insecure Configuration



The insecure developer baseline policy allows:



```json

{

&#x20; "Action": "s3:\*",

&#x20; "Resource": "\*"

}

```



\### Why This Is Risky



This grants developers full S3 access across the account.



A developer could potentially:



\- list all buckets;

\- read production data;

\- delete objects;

\- delete buckets;

\- modify bucket policies;

\- weaken encryption or lifecycle controls;

\- access unrelated datasets.



This violates least privilege and increases the blast radius of a compromised developer identity.



\### Remediation



The final developer policy restricts access to:



\- `s3:GetBucketLocation` on the development bucket;

\- `s3:ListBucket` only for selected development prefixes;

\- `s3:GetObject` and `s3:PutObject` only under:

&#x20; - `uploads/`

&#x20; - `logs/`



The developer does not receive access to:



\- the production bucket;

\- the data bucket;

\- bucket deletion actions;

\- IAM administrative actions.



\### Validation



Developer tests confirmed:



| Action | Result |

|---|---:|

| `s3:ListBucket` on authorized development prefix | allowed |

| `s3:GetObject` on development object | allowed |

| `s3:PutObject` on development object | allowed |

| `s3:GetObject` on production object | implicitDeny |

| `s3:DeleteBucket` on development bucket | implicitDeny |

| `iam:CreateUser` | implicitDeny |



\---



\## Risk 2 — Data Analyst Unnecessary Write Access



\### Insecure Configuration



The insecure data analyst baseline policy grants:



```json

\[

&#x20; "s3:PutObject",

&#x20; "s3:DeleteObject"

]

```



and applies permissions to:



```json

"Resource": "\*"

```



\### Why This Is Risky



Data analysts only need to read approved reports.



Write and delete permissions create risks such as:



\- accidental report modification;

\- dataset deletion;

\- data tampering;

\- unauthorized access to internal evidence or production data;

\- violation of separation of duties.



\### Remediation



The final design does not grant broad S3 permissions directly to the data analyst group.



Instead, the data analyst group can only call:



```text

sts:AssumeRole

```



on the MFA-protected role:



```text

novacloud-iam-lab-dev-data-analyst-readonly

```



The role itself grants only:



\- `s3:GetBucketLocation` on the data bucket;

\- `s3:ListBucket` only for the `reports/` prefix;

\- `s3:GetObject` only under `reports/\*`.



\### Validation



Previous tests confirmed:



| Action | Result |

|---|---:|

| Assume role without MFA | AccessDenied |

| Assume role with MFA | allowed |

| Read object under `reports/` | allowed |

| Write object to data bucket | AccessDenied |

| Delete object from data bucket | AccessDenied |

| Read object under `evidence/` | AccessDenied |

| List bucket root | AccessDenied |



\---



\## Risk 3 — Security Auditor Over-Permissioning



\### Insecure Configuration



The insecure security auditor baseline policy grants:



```json

\[

&#x20; "iam:\*",

&#x20; "access-analyzer:\*"

]

```



on:



```json

"Resource": "\*"

```



\### Why This Is Risky



A security auditor should review IAM configuration, not modify it.



With administrative IAM permissions, the auditor could:



\- create IAM users;

\- create IAM roles;

\- attach privileged policies;

\- pass roles to services;

\- delete IAM resources;

\- modify Access Analyzer settings;

\- weaken or hide security visibility.



This breaks separation of duties.



\### Remediation



The final security auditor policy grants read-oriented permissions only:



\- `iam:Get\*`;

\- `iam:List\*`;

\- `iam:GetAccountSummary`;

\- `iam:GenerateCredentialReport`;

\- `iam:GetCredentialReport`;

\- `access-analyzer:Get\*`;

\- `access-analyzer:List\*`;

\- `access-analyzer:ValidatePolicy`.



The policy does not grant:



\- `iam:CreateUser`;

\- `iam:CreatePolicy`;

\- `iam:AttachUserPolicy`;

\- `iam:PassRole`;

\- `access-analyzer:DeleteAnalyzer`;

\- `iam:\*`.



\### Validation



Security auditor tests confirmed:



| Action | Result |

|---|---:|

| `iam:ListUsers` | allowed |

| `iam:ListGroups` | allowed |

| `iam:ListRoles` | allowed |

| `iam:GetUser` | allowed |

| `iam:GetPolicy` | allowed |

| `access-analyzer:ListAnalyzers` | allowed |

| `access-analyzer:ValidatePolicy` | allowed |

| `iam:CreateUser` | implicitDeny |

| `iam:CreatePolicy` | implicitDeny |

| `iam:AttachUserPolicy` | implicitDeny |

| `iam:PassRole` | implicitDeny |

| `access-analyzer:DeleteAnalyzer` | implicitDeny |



\---



\## Risk 4 — Overly Broad Trust Policy



\### Insecure Configuration



The insecure trust policy example allows:



```json

"Principal": {

&#x20; "AWS": "\*"

}

```



with:



```json

"Action": "sts:AssumeRole"

```



\### Why This Is Risky



A wildcard trust principal allows any AWS principal to attempt role assumption.



If combined with identity-side misconfiguration, this could lead to:



\- unauthorized role assumption;

\- cross-account exposure;

\- privilege escalation;

\- confused deputy style risks.



\### Remediation



The implemented data analyst trust policy restricts role assumption to known IAM principals and requires MFA:



```json

"Condition": {

&#x20; "Bool": {

&#x20;   "aws:MultiFactorAuthPresent": "true"

&#x20; }

}

```



The current trusted principals are:



\- `terraform-lab-admin`;

\- `novacloud-iam-lab-dev-data-analyst-user`.



\### Validation



The lab confirmed:



| Test | Result |

|---|---:|

| Assume role without MFA | AccessDenied |

| Assume role with MFA | allowed |



\---



\## Risk 5 — Lack of Environment Separation



\### Insecure Configuration



A flat or shared S3 design can cause development, data, and production access to overlap.



\### Why This Is Risky



Without separate buckets, IAM policies become harder to reason about.



A single mistake could expose:



\- production data to developers;

\- internal evidence to analysts;

\- business reports to unrelated users.



\### Remediation



The final lab environment uses separate buckets:



| Bucket | Purpose |

|---|---|

| `novacloud-iam-lab-dev-development-606895006811` | Developer read/write testing |

| `novacloud-iam-lab-dev-606895006811` | Data analyst reports |

| `novacloud-iam-lab-dev-production-606895006811` | Protected production test data |



\### Validation



Developer tests confirmed that development access works and production access is denied.



Data analyst tests confirmed that only the approved `reports/` prefix is accessible.



\---



\## Risk 6 — Long-Lived Credentials



\### Insecure Configuration



Creating access keys for IAM users can create persistent credential exposure risk.



\### Why This Is Risky



Long-lived access keys may be:



\- accidentally committed to Git;

\- leaked through local files;

\- exposed in terminal history;

\- reused beyond the intended test period.



\### Remediation



Terraform does not create:



\- IAM access keys;

\- IAM login profiles;

\- console passwords.



Users are created as identities for policy structure and simulation.



STS is used for temporary access in the data analyst role flow.



\### Validation



Previous checks confirmed that lab IAM users have no access keys:



```json

{

&#x20; "AccessKeyMetadata": \[]

}

```



\---



\## Risk 7 — Unsafe Evidence Handling



\### Insecure Configuration



Publishing full CloudTrail events can expose excessive operational metadata.



\### Why This Is Risky



Raw CloudTrail records can include verbose fields and context that should not be published in a portfolio repository.



\### Remediation



The project stores sanitized CloudTrail evidence only.



The evidence includes:



\- event time;

\- event ID;

\- source;

\- username.



It does not include session tokens, credentials, or full raw event payloads.



\---



\## Risk 8 — Missing Policy Review



\### Insecure Configuration



Policies deployed without validation may contain broad access or syntax problems.



\### Why This Is Risky



A policy can be syntactically valid but still violate least privilege.



A policy can also be malformed due to encoding or JSON issues.



\### Remediation



IAM Access Analyzer was used to validate policy documents.



The project also documents an important lesson:



\- Access Analyzer is useful;

\- Access Analyzer does not replace business-context security analysis.



\### Validation



The final data analyst policy returned no findings.



Insecure policy examples were also validated after fixing UTF-8 encoding issues.



\---



\## Final Security Position



The project now demonstrates a controlled least privilege IAM design:



| Team | Final Access Model |

|---|---|

| Developer | Read/write only in development S3 prefixes and read authorized CloudWatch logs |

| Data Analyst | MFA-protected temporary role with read-only access to approved reports |

| Security Auditor | IAM and Access Analyzer read-only visibility without modification rights |



The final configuration avoids:



\- broad `Action: "\*"` and `Resource: "\*"` combinations;

\- `s3:\*` in final policies;

\- `iam:\*` in final policies;

\- access keys created by Terraform;

\- direct administrative access for non-admin teams;

\- production bucket access for developers and analysts.



\---



\## Conclusion



The remediation reduces blast radius, enforces separation of duties, and creates a clear before-and-after IAM security story.



The project is now positioned to support final documentation, cost control, cleanup guidance, and GitHub portfolio publication review.

