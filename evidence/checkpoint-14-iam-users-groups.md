\# Checkpoint 14 — IAM Users and Groups Evidence



\## Objective



This checkpoint adds the core IAM user and group structure required by the IAM Least Privilege Lab.



The goal is to represent the three NovaCloud Analytics teams as IAM users and IAM groups:



\- Developer team;

\- Data Analyst team;

\- Security Auditor team.



This checkpoint creates the identity structure only. It does not grant application permissions yet.



No console passwords or long-lived access keys are created by Terraform.



\---



\## Terraform Change Summary



A new reusable Terraform module was added:



```text

terraform/modules/iam\_users\_groups/

```



The module creates:



\- IAM users;

\- IAM groups;

\- IAM user-to-group memberships.



The module intentionally does not create:



\- IAM access keys;

\- IAM login profiles;

\- console passwords;

\- administrative permissions;

\- inline or managed IAM policies.



This keeps the checkpoint focused on identity structure and avoids introducing unnecessary credential risk.



\---



\## IAM Users Created



The following IAM users were created:



| User | Purpose |

|---|---|

| `novacloud-iam-lab-dev-developer-user` | Developer identity for least privilege testing |

| `novacloud-iam-lab-dev-data-analyst-user` | Data analyst identity for least privilege testing |

| `novacloud-iam-lab-dev-security-auditor-user` | Security auditor identity for IAM and Access Analyzer review |



Each user includes Terraform-managed tags such as:



\- `Project`;

\- `Environment`;

\- `ManagedBy`;

\- `Owner`;

\- `Team`;

\- `Purpose`;

\- `AccessModel`.



The `AccessModel` tag documents that no console password or long-lived access keys are managed by Terraform.



\---



\## IAM Groups Created



The following IAM groups were created:



| Group | Purpose |

|---|---|

| `novacloud-iam-lab-dev-developers-group` | Group for developer team permissions |

| `novacloud-iam-lab-dev-data-analysts-group` | Group for data analyst team permissions |

| `novacloud-iam-lab-dev-security-auditors-group` | Group for security auditor permissions |



\---



\## IAM Group Memberships



The following user-to-group memberships were created:



| User | Group |

|---|---|

| `novacloud-iam-lab-dev-developer-user` | `novacloud-iam-lab-dev-developers-group` |

| `novacloud-iam-lab-dev-data-analyst-user` | `novacloud-iam-lab-dev-data-analysts-group` |

| `novacloud-iam-lab-dev-security-auditor-user` | `novacloud-iam-lab-dev-security-auditors-group` |



\---



\## Terraform Plan Result



Before applying the change, Terraform showed the expected plan:



```text

Plan: 9 to add, 0 to change, 0 to destroy.

```



The expected resources were:



\- 3 IAM users;

\- 3 IAM groups;

\- 3 IAM user group memberships.



No existing resources were modified or destroyed.



No access keys, login profiles, or administrative policy attachments were included in the plan.



\---



\## User Verification



\### Developer User



Command:



```powershell

aws iam get-user `

&#x20; --user-name novacloud-iam-lab-dev-developer-user `

&#x20; --profile iam-lab

```



Result summary:



```text

UserName: novacloud-iam-lab-dev-developer-user

Arn: arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-developer-user

Team: Developer

AccessModel: No console password or long-lived access keys managed by Terraform

```



\### Data Analyst User



Command:



```powershell

aws iam get-user `

&#x20; --user-name novacloud-iam-lab-dev-data-analyst-user `

&#x20; --profile iam-lab

```



Result summary:



```text

UserName: novacloud-iam-lab-dev-data-analyst-user

Arn: arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-data-analyst-user

Team: Data Analyst

AccessModel: No console password or long-lived access keys managed by Terraform

```



\### Security Auditor User



Command:



```powershell

aws iam get-user `

&#x20; --user-name novacloud-iam-lab-dev-security-auditor-user `

&#x20; --profile iam-lab

```



Result summary:



```text

UserName: novacloud-iam-lab-dev-security-auditor-user

Arn: arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-security-auditor-user

Team: Security

AccessModel: No console password or long-lived access keys managed by Terraform

```



\---



\## Group Membership Verification



\### Developers Group



Command:



```powershell

aws iam get-group `

&#x20; --group-name novacloud-iam-lab-dev-developers-group `

&#x20; --profile iam-lab

```



Result summary:



```text

GroupName: novacloud-iam-lab-dev-developers-group

UserName: novacloud-iam-lab-dev-developer-user

```



\### Data Analysts Group



Command:



```powershell

aws iam get-group `

&#x20; --group-name novacloud-iam-lab-dev-data-analysts-group `

&#x20; --profile iam-lab

```



Result summary:



```text

GroupName: novacloud-iam-lab-dev-data-analysts-group

UserName: novacloud-iam-lab-dev-data-analyst-user

```



\### Security Auditors Group



Command:



```powershell

aws iam get-group `

&#x20; --group-name novacloud-iam-lab-dev-security-auditors-group `

&#x20; --profile iam-lab

```



Result summary:



```text

GroupName: novacloud-iam-lab-dev-security-auditors-group

UserName: novacloud-iam-lab-dev-security-auditor-user

```



\---



\## Access Key Verification



The following checks confirm that no long-lived access keys were created for the IAM users.



\### Developer User



Command:



```powershell

aws iam list-access-keys `

&#x20; --user-name novacloud-iam-lab-dev-developer-user `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "AccessKeyMetadata": \[]

}

```



\### Data Analyst User



Command:



```powershell

aws iam list-access-keys `

&#x20; --user-name novacloud-iam-lab-dev-data-analyst-user `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "AccessKeyMetadata": \[]

}

```



\### Security Auditor User



Command:



```powershell

aws iam list-access-keys `

&#x20; --user-name novacloud-iam-lab-dev-security-auditor-user `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "AccessKeyMetadata": \[]

}

```



\---



\## Security Notes



This checkpoint intentionally separates identity creation from permission assignment.



Creating users and groups first allows the project to show a clean IAM structure before attaching least privilege policies.



The users currently have no direct credentials managed by Terraform and no application permissions attached in this checkpoint.



This reduces credential exposure risk and avoids storing secrets in Terraform state.



Future checkpoints will attach least privilege policies to groups and roles instead of relying on direct user-level permissions.



\---



\## Checkpoint Result



Checkpoint 14 is complete.



The project now includes:



\- three IAM users;

\- three IAM groups;

\- one user assigned to each corresponding group;

\- no long-lived access keys;

\- no console passwords;

\- no administrative permissions granted by this checkpoint.



This prepares the project for the next IAM phases:



\- insecure baseline policy examples;

\- least privilege remediation;

\- developer permissions;

\- security auditor permissions;

\- positive and negative IAM access tests.

