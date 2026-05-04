\# Cost Control and Cleanup



\## Overview



This document explains the cost control and cleanup strategy for the NovaCloud Analytics S.r.l. IAM Least Privilege Lab.



The project is designed as a low-cost AWS security lab, but some resources can still generate charges if they are left active or if usage increases.



The goal of this document is to make the lab safe to operate, easy to clean up, and suitable for portfolio publication.



\---



\## Cost Control Goals



The cost control goals are:



1\. Keep the lab environment minimal.

2\. Avoid unnecessary paid services.

3\. Avoid long-running or high-volume resources.

4\. Avoid storing large objects in S3.

5\. Avoid enabling CloudTrail data events unless needed.

6\. Destroy the dev environment when it is no longer required.

7\. Preserve the Terraform backend only when future work is planned.

8\. Never commit Terraform state or sensitive local files.



\---



\## Resources Created by the Lab



The dev environment currently includes the following AWS resources:



| Resource Type | Purpose | Cost Consideration |

|---|---|---|

| S3 buckets | Development, data, production, and Terraform state storage | Low cost for small objects, but versioning can increase storage usage |

| S3 objects | Placeholder prefixes and test files | Usually minimal cost |

| IAM users | Simulated team identities | No direct cost |

| IAM groups | Team-based permission management | No direct cost |

| IAM roles | Temporary access and least privilege flows | No direct cost |

| IAM managed policies | Least privilege permissions | No direct cost |

| IAM Access Analyzer | Policy and access analysis | Usually low/no cost for basic account-level use, but review AWS pricing before extended usage |

| CloudWatch log group | Developer application log read testing | Can generate cost if log ingestion or retention grows |

| CloudWatch log stream | Placeholder application log stream | Minimal cost if no log events are ingested |

| CloudTrail Event History | Management event review | Event History is available by default; avoid enabling unnecessary paid data events |



\---



\## S3 Cost Considerations



The lab uses multiple S3 buckets:



```text

novacloud-iam-lab-dev-development-606895006811

novacloud-iam-lab-dev-606895006811

novacloud-iam-lab-dev-production-606895006811

iam-lab-tfstate-rosario-20260429

```



The first three buckets belong to the lab environment.



The Terraform state bucket belongs to the backend/bootstrap layer.



\### Why S3 Can Still Generate Cost



S3 cost is usually low for this lab, but cost can grow if:



\- large files are uploaded;

\- many object versions accumulate;

\- logs or evidence files are stored repeatedly;

\- buckets are not cleaned before destruction;

\- CloudTrail data events are enabled for S3 object-level activity.



\### Versioning Warning



The lab enables S3 versioning on security-relevant buckets.



Versioning is useful because it protects against accidental overwrite or deletion, but it also means deleted or overwritten objects may still exist as previous versions.



Before destroying versioned buckets, object versions and delete markers may need to be removed.



\---



\## CloudWatch Logs Cost Considerations



The lab includes a CloudWatch log group:



```text

/novacloud/iam-lab/dev/developer-app

```



It is used to test developer read-only log access.



The retention period is configured as:



```text

7 days

```



This helps reduce long-term log storage cost.



\### Cost Risk



CloudWatch Logs cost can increase if:



\- large volumes of logs are ingested;

\- retention is set too high;

\- many log groups are created;

\- metric filters, subscriptions, or exports are added later.



\### Current Lab Position



The current lab log group is intentionally minimal.



It exists primarily as an IAM test target.



\---



\## IAM Cost Considerations



IAM users, groups, roles, and policies do not directly generate usage cost.



However, IAM misconfiguration can indirectly create cost risk.



For example, if an identity has broad permissions, it could create paid resources such as:



\- EC2 instances;

\- NAT gateways;

\- RDS databases;

\- CloudWatch log ingestion;

\- CloudTrail data events;

\- KMS keys;

\- large S3 storage usage.



The least privilege design reduces this risk by limiting what each identity can do.



\---



\## IAM Access Analyzer Cost Considerations



The lab creates an account-level IAM Access Analyzer:



```text

novacloud-iam-lab-dev-access-analyzer

```



IAM Access Analyzer is useful for identifying external access and validating policies.



Before using Access Analyzer heavily or enabling additional analysis features, review current AWS pricing.



For this lab, usage is intentionally limited to:



\- account-level analyzer creation;

\- listing findings;

\- validating IAM policies.



\---



\## CloudTrail Cost Considerations



The project uses CloudTrail Event History to review management events such as:



```text

sts:AssumeRole

```



CloudTrail Event History is useful for lightweight evidence gathering.



\### Important Warning About Data Events



CloudTrail data events can generate additional cost.



S3 object-level data events can become expensive if enabled broadly across busy buckets.



For this lab:



\- CloudTrail management event history is sufficient;

\- S3 data events are not required for the core portfolio scope;

\- data events should not be enabled unless there is a specific documented reason.



\---



\## Files That Must Never Be Committed



The following files must not be committed to Git:



```text

.terraform/

terraform.tfstate

terraform.tfstate.backup

terraform.tfvars

backend.hcl

bootstrap.tfplan

\*.tfplan

```



The following values must never be committed:



```text

AWS access keys

AWS secret keys

AWS session tokens

MFA codes

Full raw CloudTrail event payloads with sensitive metadata

Terraform state containing secrets

```



The project `.gitignore` should continue to exclude local Terraform and credential-related files.



\---



\## Cleanup Strategy



Cleanup should be performed in layers.



The recommended order is:



1\. Destroy the dev environment.

2\. Confirm application buckets and IAM resources are removed.

3\. Decide whether to preserve or destroy the Terraform backend.

4\. Destroy the bootstrap backend only if the project no longer needs remote state.

5\. Confirm no unexpected AWS resources remain.



\---



\## Destroying the Dev Environment



To destroy the dev environment, use the dev Terraform configuration.



From the dev environment directory:



```powershell

cd C:\\Users\\RosarioCensabella\\projects\\iam-least-privilege-lab\\terraform\\envs\\dev

terraform init -reconfigure "-backend-config=backend.hcl"

terraform plan -destroy

```



Review the plan carefully.



Only proceed if the plan shows the expected lab resources.



Then run:



```powershell

terraform destroy

```



Confirm with:



```text

yes

```



\---



\## Important Warning About Versioned S3 Buckets



Terraform may fail to destroy versioned S3 buckets if they contain object versions or delete markers.



If destruction fails because a bucket is not empty, list object versions.



Example:



```powershell

aws s3api list-object-versions `

&#x20; --bucket novacloud-iam-lab-dev-development-606895006811 `

&#x20; --profile iam-lab

```



A manual cleanup may be required for:



\- object versions;

\- delete markers;

\- test files;

\- evidence files uploaded during testing.



Be careful before deleting objects from the Terraform backend bucket.



\---



\## Application Bucket Cleanup



The lab application buckets are:



```text

novacloud-iam-lab-dev-development-606895006811

novacloud-iam-lab-dev-606895006811

novacloud-iam-lab-dev-production-606895006811

```



These may be destroyed with the dev Terraform environment.



Before destroy, make sure no important evidence exists only in S3.



Evidence intended for the portfolio should live in the local repository under:



```text

evidence/

docs/

```



and should be reviewed for sensitive information before publication.



\---



\## Terraform Backend Cleanup



The Terraform backend bucket is separate from the dev lab resources.



Current backend bucket:



```text

iam-lab-tfstate-rosario-20260429

```



This bucket stores Terraform remote state.



Do not delete it casually.



\### Preserve the Backend If



Preserve the bootstrap backend if:



\- future Terraform work is planned;

\- the dev environment may be recreated;

\- the project is still being maintained;

\- state history is needed.



\### Destroy the Backend If



Destroy the bootstrap backend only if:



\- the lab is complete;

\- all environments have been destroyed;

\- no future Terraform operations are planned;

\- the state bucket contents have been reviewed;

\- the user intentionally wants to remove all AWS resources related to the project.



To destroy the bootstrap layer, use:



```powershell

cd C:\\Users\\RosarioCensabella\\projects\\iam-least-privilege-lab\\terraform\\bootstrap

terraform plan -destroy

terraform destroy

```



Only do this after the dev environment is already destroyed.



\---



\## Cleanup Verification Commands



After destroying the dev environment, verify S3 buckets:



```powershell

aws s3 ls --profile iam-lab

```



Verify IAM users:



```powershell

aws iam list-users --profile iam-lab

```



Verify IAM groups:



```powershell

aws iam list-groups --profile iam-lab

```



Verify IAM roles:



```powershell

aws iam list-roles --profile iam-lab

```



Verify IAM policies by project prefix:



```powershell

aws iam list-policies `

&#x20; --scope Local `

&#x20; --profile iam-lab `

&#x20; --query "Policies\[?contains(PolicyName, 'novacloud-iam-lab')]"

```



Verify Access Analyzer:



```powershell

aws accessanalyzer list-analyzers --profile iam-lab

```



Verify CloudWatch log groups:



```powershell

aws logs describe-log-groups `

&#x20; --log-group-name-prefix "/novacloud/iam-lab" `

&#x20; --profile iam-lab

```



\---



\## Safe Git Cleanup Before Publication



Before pushing to GitHub, run:



```powershell

git status

```



Confirm:



```text

nothing to commit, working tree clean

```



Review ignored files:



```powershell

git status --ignored

```



Search for common secret patterns before publication.



Examples:



```powershell

Select-String -Path .\\\* -Pattern "AKIA" -Recurse

Select-String -Path .\\\* -Pattern "aws\_secret\_access\_key" -Recurse

Select-String -Path .\\\* -Pattern "sessionToken" -Recurse

Select-String -Path .\\\* -Pattern "SecretAccessKey" -Recurse

```



Review evidence files manually, especially:



```text

evidence/

docs/

```



Do not publish:



\- raw CloudTrail payloads;

\- access keys;

\- session tokens;

\- MFA codes;

\- local backend configuration;

\- Terraform state files.



\---



\## Cost Control Checklist



Before leaving the lab running:



\- \[ ] Confirm no EC2, RDS, NAT Gateway, or other unrelated paid resources were created.

\- \[ ] Confirm S3 buckets contain only small test objects.

\- \[ ] Confirm CloudWatch Logs retention is limited.

\- \[ ] Confirm CloudTrail data events are not enabled unnecessarily.

\- \[ ] Confirm IAM users have no access keys unless intentionally created outside this lab.

\- \[ ] Confirm no broad policies are attached to lab users or groups.

\- \[ ] Confirm Terraform state files are not committed.

\- \[ ] Confirm evidence files are sanitized.



Before destroying the lab:



\- \[ ] Run `terraform plan -destroy` from `terraform/envs/dev`.

\- \[ ] Review all resources marked for deletion.

\- \[ ] Confirm no required evidence exists only in S3.

\- \[ ] Empty versioned S3 buckets if Terraform cannot destroy them.

\- \[ ] Run `terraform destroy` for the dev environment.

\- \[ ] Verify remaining AWS resources with AWS CLI.

\- \[ ] Decide whether to preserve or destroy the bootstrap backend.



Before publishing to GitHub:



\- \[ ] Run `git status`.

\- \[ ] Run `git status --ignored`.

\- \[ ] Review `.gitignore`.

\- \[ ] Review evidence files.

\- \[ ] Search for access keys and session tokens.

\- \[ ] Review README accuracy.

\- \[ ] Confirm the project does not claim unsupported results.



\---



\## Recommended Lab Shutdown Approach



For a portfolio project, the recommended approach is:



1\. Keep the repository and documentation.

2\. Destroy the dev environment when screenshots/evidence are complete.

3\. Preserve or export sanitized evidence.

4\. Keep the Terraform backend only while active development continues.

5\. Destroy the backend when the project is fully complete and no longer needs remote state.



\---



\## Final Note



This lab is intentionally small, but cost control is still part of secure cloud operations.



A good cloud security project should not only implement least privilege, but also show responsible cleanup, evidence handling, and operational discipline.

