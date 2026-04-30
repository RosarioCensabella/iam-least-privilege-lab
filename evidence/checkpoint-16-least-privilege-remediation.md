\# Checkpoint 16 — Least Privilege Remediation Evidence



\## Objective



This checkpoint implements the least privilege remediation phase for the IAM Least Privilege Lab.



The goal is to replace the insecure baseline concepts with controlled IAM permissions for the main NovaCloud Analytics teams:



\- Developer team;

\- Data Analyst team;

\- Security Auditor team.



This checkpoint also adds a CloudWatch Logs target for future developer read-only log access tests.



\---



\## Remediation Strategy



The remediation follows these security principles:



\- permissions are attached to IAM groups, not directly to users;

\- users do not receive long-lived access keys from Terraform;

\- users do not receive console login profiles from Terraform;

\- developer S3 access is restricted to the development bucket only;

\- data analysts assume an MFA-protected read-only role instead of receiving direct broad S3 permissions;

\- security auditors receive read-only IAM and Access Analyzer permissions;

\- no final policy grants `Action: "\*"` with `Resource: "\*"`;

\- no final policy grants `iam:\*`;

\- no final policy grants `s3:\*`.



\---



\## Terraform Change Summary



This checkpoint added two new Terraform modules:



```text

terraform/modules/cloudwatch\_app\_logs/

terraform/modules/iam\_least\_privilege\_policies/

```



It also updated the existing data analyst role module so that the role trust policy can support multiple trusted principals.



The data analyst role now trusts:



\- the lab administrator user used for controlled testing;

\- the dedicated data analyst IAM user created in the lab.



The MFA condition remains required.



\---



\## Terraform Plan Result



Terraform showed the expected plan:



```text

Plan: 8 to add, 1 to change, 0 to destroy.

```



The eight new resources were expected to be:



\- one CloudWatch log group;

\- one CloudWatch log stream;

\- three IAM managed policies;

\- three IAM group policy attachments.



The one changed resource was expected to be:



```text

module.iam\_data\_analyst\_role.aws\_iam\_role.this

```



This change updated only the trust policy of the existing data analyst role.



No resources were destroyed.



\---



\## Terraform Outputs



After applying the remediation, Terraform exposed the following relevant outputs:



```text

developer\_policy\_arn = "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-developers-least-privilege"



data\_analyst\_assume\_role\_policy\_arn = "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-data-analysts-assume-readonly-role"



security\_auditor\_policy\_arn = "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-security-auditors-readonly"



developer\_log\_group\_name = "/novacloud/iam-lab/dev/developer-app"



developer\_log\_stream\_name = "application"

```



\---



\## Developer Least Privilege Policy



The developer group received the policy:



```text

novacloud-iam-lab-dev-developers-least-privilege

```



Attached to:



```text

novacloud-iam-lab-dev-developers-group

```



Verification command:



```powershell

aws iam list-attached-group-policies `

&#x20; --group-name novacloud-iam-lab-dev-developers-group `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "AttachedPolicies": \[

&#x20;       {

&#x20;           "PolicyName": "novacloud-iam-lab-dev-developers-least-privilege",

&#x20;           "PolicyArn": "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-developers-least-privilege"

&#x20;       }

&#x20;   ]

}

```



\### Developer Permissions



The developer policy allows:



\- `s3:GetBucketLocation` on the development bucket;

\- `s3:ListBucket` on selected development prefixes;

\- `s3:GetObject` on selected development objects;

\- `s3:PutObject` on selected development objects;

\- read-only access to the dedicated CloudWatch application log group.



The policy does not grant:



\- access to the production bucket;

\- access to the data bucket;

\- bucket deletion;

\- IAM modification;

\- broad S3 administration;

\- access to all CloudWatch Logs resources.



\---



\## Data Analyst Remediation



The data analysts group received the policy:



```text

novacloud-iam-lab-dev-data-analysts-assume-readonly-role

```



Attached to:



```text

novacloud-iam-lab-dev-data-analysts-group

```



Verification command:



```powershell

aws iam list-attached-group-policies `

&#x20; --group-name novacloud-iam-lab-dev-data-analysts-group `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "AttachedPolicies": \[

&#x20;       {

&#x20;           "PolicyName": "novacloud-iam-lab-dev-data-analysts-assume-readonly-role",

&#x20;           "PolicyArn": "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-data-analysts-assume-readonly-role"

&#x20;       }

&#x20;   ]

}

```



\### Data Analyst Access Model



Data analysts do not receive direct broad S3 permissions through the group.



Instead, the group allows:



```text

sts:AssumeRole

```



only on:



```text

arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly

```



The role itself already contains the restricted read-only S3 permissions for the approved `reports/` prefix.



This keeps the data analyst access model based on temporary credentials and MFA-protected role assumption.



\---



\## Data Analyst Trust Policy Verification



Command:



```powershell

aws iam get-role `

&#x20; --role-name novacloud-iam-lab-dev-data-analyst-readonly `

&#x20; --profile iam-lab

```



Relevant result:



```json

{

&#x20;   "Sid": "AllowTrustedPrincipalToAssumeRoleWithMFA",

&#x20;   "Effect": "Allow",

&#x20;   "Principal": {

&#x20;       "AWS": \[

&#x20;           "arn:aws:iam::606895006811:user/terraform-lab-admin",

&#x20;           "arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-data-analyst-user"

&#x20;       ]

&#x20;   },

&#x20;   "Action": "sts:AssumeRole",

&#x20;   "Condition": {

&#x20;       "Bool": {

&#x20;           "aws:MultiFactorAuthPresent": "true"

&#x20;       }

&#x20;   }

}

```



\### Interpretation



The role trust policy now supports both:



\- the lab administrator identity used for controlled testing;

\- the dedicated data analyst IAM user.



MFA remains mandatory through:



```text

aws:MultiFactorAuthPresent = true

```



This preserves the security behavior tested in previous checkpoints.



\---



\## Security Auditor Least Privilege Policy



The security auditors group received the policy:



```text

novacloud-iam-lab-dev-security-auditors-readonly

```



Attached to:



```text

novacloud-iam-lab-dev-security-auditors-group

```



Verification command:



```powershell

aws iam list-attached-group-policies `

&#x20; --group-name novacloud-iam-lab-dev-security-auditors-group `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "AttachedPolicies": \[

&#x20;       {

&#x20;           "PolicyName": "novacloud-iam-lab-dev-security-auditors-readonly",

&#x20;           "PolicyArn": "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-security-auditors-readonly"

&#x20;       }

&#x20;   ]

}

```



\### Security Auditor Permissions



The security auditor policy allows read-oriented actions such as:



\- `iam:Get\*`;

\- `iam:List\*`;

\- `iam:GetAccountSummary`;

\- `iam:GenerateCredentialReport`;

\- `iam:GetCredentialReport`;

\- `access-analyzer:Get\*`;

\- `access-analyzer:List\*`;

\- `access-analyzer:ValidatePolicy`.



The policy does not grant:



\- `iam:\*`;

\- `iam:CreateUser`;

\- `iam:CreateRole`;

\- `iam:AttachUserPolicy`;

\- `iam:AttachRolePolicy`;

\- `iam:PutRolePolicy`;

\- `iam:DeleteRole`;

\- `iam:PassRole`;

\- administrative Access Analyzer permissions.



\---



\## CloudWatch Logs Verification



This checkpoint added a dedicated CloudWatch Logs target for developer read-only log access tests.



Log group:



```text

/novacloud/iam-lab/dev/developer-app

```



Log stream:



```text

application

```



\### Log Group Verification



Command:



```powershell

aws logs describe-log-groups `

&#x20; --log-group-name-prefix "/novacloud/iam-lab/dev/developer-app" `

&#x20; --profile iam-lab

```



Result summary:



```text

logGroupName: /novacloud/iam-lab/dev/developer-app

retentionInDays: 7

logGroupClass: STANDARD

storedBytes: 0

```



\### Log Stream Verification



Command:



```powershell

aws logs describe-log-streams `

&#x20; --log-group-name "/novacloud/iam-lab/dev/developer-app" `

&#x20; --profile iam-lab

```



Result summary:



```text

logStreamName: application

storedBytes: 0

```



\---



\## Before and After Summary



| Area | Insecure Baseline | Least Privilege Remediation |

|---|---|---|

| Developer S3 access | `s3:\*` on `\*` | Read/write only on selected prefixes in the development bucket |

| Data Analyst access | Direct S3 read/write/delete access | MFA-protected temporary role with read-only access to `reports/` |

| Security Auditor access | `iam:\*` and `access-analyzer:\*` on `\*` | IAM and Access Analyzer read-only permissions |

| Role trust policy | Wildcard principal without MFA | Restricted principals with MFA required |

| CloudWatch Logs | Not scoped | Developer access scoped to a dedicated application log group |



\---



\## Security Notes



This checkpoint implements the remediation direction established by the insecure baseline examples.



The final policies are intentionally scoped to job functions:



\- developers can work only in the development S3 bucket and read the dedicated application logs;

\- data analysts can assume a controlled, MFA-protected read-only role;

\- security auditors can review IAM and Access Analyzer information but cannot modify IAM resources.



This design supports separation of duties and reduces the blast radius of each identity.



\---



\## Checkpoint Result



Checkpoint 16 is complete.



The project now includes final least privilege IAM policies for:



\- Developer team;

\- Data Analyst team;

\- Security Auditor team.



The project also includes a CloudWatch Logs target for future developer tests.



No resources were destroyed during this checkpoint.

