\# Remediation Plan



\## Overview



This document describes the remediation plan implemented for the NovaCloud Analytics S.r.l. IAM Least Privilege Lab.



The goal of the remediation was to move from an insecure IAM baseline to a least privilege AWS access model managed with Terraform.



The remediation focuses on:



\- reducing excessive permissions;

\- separating team responsibilities;

\- restricting S3 access by bucket and prefix;

\- enforcing MFA for sensitive role assumption;

\- using temporary credentials through AWS STS;

\- preserving audit visibility without administrative control;

\- validating access with positive and negative tests.



\---



\## Remediation Principles



The remediation follows these principles:



1\. Grant permissions to groups and roles instead of directly to users.

2\. Avoid long-lived credentials where possible.

3\. Use temporary credentials for sensitive access flows.

4\. Require MFA for role assumption.

5\. Scope S3 permissions to specific buckets and prefixes.

6\. Separate development, data, and production resources.

7\. Provide auditors with read-only visibility.

8\. Validate the final behavior with explicit tests.

9\. Keep insecure examples as documentation only.

10\. Manage infrastructure through Terraform.



\---



\## Remediation Summary



| Area | Before | After |

|---|---|---|

| Developer S3 access | `s3:\*` on `Resource: "\*"` | Object read/write only in selected development bucket prefixes |

| Data Analyst S3 access | Read/write/delete access across S3 | MFA-protected temporary role with read-only access to `reports/` |

| Security Auditor IAM access | `iam:\*` on `Resource: "\*"` | IAM and Access Analyzer read-only permissions |

| Trust policies | Wildcard principal without MFA | Restricted principals with MFA required |

| S3 architecture | Unclear separation of environments | Dedicated development, data, and production buckets |

| Credentials | Potential long-lived keys | No access keys or console passwords created by Terraform |

| Evidence | Potentially raw CloudTrail payloads | Sanitized evidence only |

| Policy validation | Not consistently documented | IAM Access Analyzer used and findings documented |



\---



\## Phase 1 — Establish Secure Terraform Foundation



\### Problem



Manual AWS changes are hard to track, review, and reproduce.



They increase the risk of configuration drift and undocumented permissions.



\### Remediation



Terraform was used to define and manage the lab infrastructure.



The project includes:



```text

terraform/bootstrap/

terraform/envs/dev/

terraform/modules/

```



A remote backend was configured for the dev environment.



Sensitive local Terraform files are excluded from Git.



\### Outcome



The lab has a reproducible infrastructure foundation suitable for review and portfolio demonstration.



\---



\## Phase 2 — Create Secure S3 Buckets



\### Problem



A single shared bucket or overly broad bucket access makes least privilege difficult to enforce.



\### Remediation



The S3 environment was separated into:



| Bucket | Purpose |

|---|---|

| Development bucket | Developer read/write testing |

| Data bucket | Data analyst report access |

| Production bucket | Protected negative test target |



Each bucket includes:



\- S3 Block Public Access;

\- server-side encryption with AES256;

\- versioning;

\- Terraform-managed configuration.



\### Outcome



Teams can be granted access to only the resources required for their function.



The production bucket provides a clear negative test target.



\---



\## Phase 3 — Create IAM Users and Groups



\### Problem



Permissions attached directly to individual users are harder to manage and audit.



\### Remediation



The following IAM users were created:



\- `novacloud-iam-lab-dev-developer-user`;

\- `novacloud-iam-lab-dev-data-analyst-user`;

\- `novacloud-iam-lab-dev-security-auditor-user`.



The following groups were created:



\- `novacloud-iam-lab-dev-developers-group`;

\- `novacloud-iam-lab-dev-data-analysts-group`;

\- `novacloud-iam-lab-dev-security-auditors-group`.



Each user was assigned to the appropriate group.



Terraform does not create access keys or login profiles for these users.



\### Outcome



The lab now has a clean team-based identity model.



Policies can be attached to groups instead of individual users.



\---



\## Phase 4 — Document Insecure Baseline



\### Problem



A least privilege project needs a clear before-and-after story.



Without an insecure baseline, the remediation has less context.



\### Remediation



Intentionally insecure examples were created under:



```text

policies/insecure-examples/

```



These examples include:



\- developer over-permissive S3 access;

\- data analyst unnecessary write/delete access;

\- security auditor excessive IAM access;

\- unsafe wildcard trust policy.



The insecure examples are not attached to AWS identities.



\### Outcome



The project demonstrates realistic IAM risks without leaving dangerous permissions active.



\---



\## Phase 5 — Implement Developer Least Privilege



\### Problem



Developers need to work with development resources, but should not access production or administer IAM.



\### Remediation



The developer group receives a scoped policy that allows:



\- `s3:GetBucketLocation` on the development bucket;

\- `s3:ListBucket` on selected development prefixes;

\- `s3:GetObject` and `s3:PutObject` under selected prefixes;

\- read-only access to the dedicated CloudWatch application log group.



The developer group does not receive:



\- production bucket access;

\- data bucket access;

\- `s3:DeleteBucket`;

\- IAM administrative permissions.



\### Outcome



Developer tests confirmed that allowed actions work and forbidden actions are denied.



\---



\## Phase 6 — Implement Data Analyst Least Privilege



\### Problem



Data analysts need to read approved reports but should not write, delete, or access unrelated prefixes.



\### Remediation



The data analyst group can assume a dedicated read-only role:



```text

novacloud-iam-lab-dev-data-analyst-readonly

```



The role trust policy requires MFA.



The role permissions allow:



\- `s3:GetBucketLocation` on the data bucket;

\- `s3:ListBucket` only for `reports/`;

\- `s3:GetObject` only under `reports/\*`.



The role does not allow:



\- object upload;

\- object deletion;

\- access to `evidence/`;

\- access to production data;

\- IAM administration.



\### Outcome



STS and MFA tests confirmed:



\- role assumption without MFA is denied;

\- role assumption with MFA is allowed;

\- data access remains read-only and prefix-scoped after assumption.



\---



\## Phase 7 — Implement Security Auditor Least Privilege



\### Problem



Security auditors need visibility into IAM and Access Analyzer, but should not be able to modify the environment.



\### Remediation



The security auditors group receives read-oriented permissions:



\- `iam:Get\*`;

\- `iam:List\*`;

\- `iam:GetAccountSummary`;

\- `iam:GenerateCredentialReport`;

\- `iam:GetCredentialReport`;

\- `access-analyzer:Get\*`;

\- `access-analyzer:List\*`;

\- `access-analyzer:ValidatePolicy`.



The group does not receive:



\- `iam:CreateUser`;

\- `iam:CreatePolicy`;

\- `iam:AttachUserPolicy`;

\- `iam:PassRole`;

\- `access-analyzer:DeleteAnalyzer`;

\- `iam:\*`.



\### Outcome



Security auditor tests confirmed that read and validation actions are allowed, while IAM modification and privilege escalation actions are denied.



\---



\## Phase 8 — Enforce MFA for Sensitive Role Assumption



\### Problem



Role assumption can create powerful temporary credentials.



Without MFA, compromised credentials could be used to assume sensitive roles.



\### Remediation



The data analyst role trust policy requires:



```text

aws:MultiFactorAuthPresent = true

```



Trusted principals are explicitly listed.



\### Outcome



AssumeRole testing confirmed:



| Test | Result |

|---|---:|

| Assume role without MFA | AccessDenied |

| Assume role with MFA | allowed |



This creates a stronger control around temporary access.



\---



\## Phase 9 — Enable IAM Access Analyzer



\### Problem



External access and risky IAM patterns can be missed without policy analysis tooling.



\### Remediation



An account-level IAM Access Analyzer was created:



```text

novacloud-iam-lab-dev-access-analyzer

```



Policy validation was run against final and insecure example policies.



\### Outcome



The final data analyst policy validated successfully.



The insecure examples supported risk analysis and showed that policy validation must be combined with business-context review.



\---



\## Phase 10 — Review CloudTrail Evidence



\### Problem



Sensitive role assumption should be observable.



Without audit evidence, it is difficult to detect or investigate suspicious access.



\### Remediation



CloudTrail Event History was used to review `AssumeRole` events related to the data analyst role.



Sanitized evidence was stored in the repository.



\### Outcome



The project demonstrates that STS role assumption is visible through CloudTrail and can be used as a detection source.



\---



\## Validation Matrix



| Team | Allowed Tests | Denied Tests |

|---|---|---|

| Developer | Development S3 list/read/write; CloudWatch log read | Production S3 read; S3 bucket delete; IAM create user; CloudWatch log group delete |

| Data Analyst | Assume MFA-protected role; read approved reports | Assume without MFA; write/delete data; read evidence prefix; list bucket root |

| Security Auditor | List/read IAM; validate policies; list Access Analyzer | Create user; create policy; attach policy; pass role; delete analyzer |



\---



\## Final State



The final IAM model is:



| Identity | Access Model |

|---|---|

| Developer user | Member of developers group with scoped development and log-read permissions |

| Data analyst user | Member of data analysts group with permission to assume MFA-protected read-only role |

| Security auditor user | Member of security auditors group with IAM and Access Analyzer read-only permissions |

| Data analyst role | Temporary read-only access to approved reports |

| Access Analyzer | Enabled for account-level review |



\---



\## Acceptance Criteria Mapping



| Requirement | Status |

|---|---:|

| Resources managed with Terraform | Completed |

| IAM users created | Completed |

| IAM groups created | Completed |

| IAM roles created | Partially completed; data analyst role implemented, additional optional roles can be added later |

| Insecure baseline documented | Completed |

| Least privilege remediation implemented | Completed for Developer, Data Analyst, and Security Auditor access models |

| MFA documented and enforced | Completed for data analyst role assumption |

| STS temporary access tested | Completed for data analyst role |

| IAM Access Analyzer enabled | Completed |

| Access Analyzer policy validation documented | Completed |

| Developer tests completed | Completed |

| Security auditor tests completed | Completed |

| Documentation explains before/after | Completed in this remediation plan and security analysis |

| No final `Action: "\*"` with `Resource: "\*"` | Completed |

| Evidence sanitized | Completed |



\---



\## Remaining Improvements



The project is now substantially aligned with the original scope.



Potential future improvements include:



\- adding a dedicated `developer-temporary-role`;

\- adding a dedicated `security-audit-role`;

\- adding real CloudWatch log events for runtime testing;

\- adding more Access Analyzer examples with controlled external access findings;

\- expanding cleanup and cost control documentation;

\- polishing the README before GitHub publication.



\---



\## Conclusion



The remediation successfully moves the simulated NovaCloud Analytics environment from broad, risky IAM examples to a controlled least privilege model.



The final design demonstrates:



\- scoped S3 access;

\- environment separation;

\- MFA-protected temporary access;

\- audit-only security visibility;

\- policy validation;

\- positive and negative access testing;

\- Terraform-managed infrastructure.



This creates a clear and portfolio-ready IAM least privilege case study.

