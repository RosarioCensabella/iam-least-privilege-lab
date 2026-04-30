\# Checkpoint 15 — Insecure Baseline Policies Evidence



\## Objective



This checkpoint documents intentionally insecure IAM policy examples used as the baseline configuration for the IAM Least Privilege Lab.



The goal is to show the type of risky IAM configuration that could exist before a least privilege remediation project.



These policies are not deployed to AWS and are not attached to any IAM user, group, or role.



\---



\## Safety Decision



The insecure baseline is stored as static policy examples under:



```text

policies/insecure-examples/

```



The insecure policies are intentionally not applied through Terraform.



This avoids leaving dangerous permissions active in the AWS account while still allowing the project to demonstrate risk analysis and remediation planning.



No `terraform plan` or `terraform apply` was required for this checkpoint.



\---



\## Files Created



| File | Purpose |

|---|---|

| `policies/insecure-examples/README.md` | Explains the purpose and safety boundaries of the insecure examples. |

| `policies/insecure-examples/developer-overpermissive-s3-policy.json` | Demonstrates excessive developer access to all S3 actions and resources. |

| `policies/insecure-examples/data-analyst-unnecessary-write-policy.json` | Demonstrates unnecessary write and delete access for data analysts. |

| `policies/insecure-examples/security-auditor-overpermissive-iam-policy.json` | Demonstrates excessive IAM and Access Analyzer permissions for auditors. |

| `policies/insecure-examples/open-assume-role-trust-policy.json` | Demonstrates an unsafe trust policy that allows any AWS principal to assume a role. |



\---



\## Insecure Developer Policy



The insecure developer policy grants:



```json

{

&#x20; "Action": "s3:\*",

&#x20; "Resource": "\*"

}

```



\### Risk



This would allow developers to perform any S3 action against any bucket in the account.



Potential impact:



\- access to production data;

\- deletion of development or production buckets;

\- modification of bucket policies;

\- modification of encryption, lifecycle, or access configurations;

\- data exfiltration risk.



\### Expected Remediation



The developer policy should be restricted to:



\- read/write access only on the development bucket;

\- no access to the production bucket;

\- no S3 bucket deletion permissions;

\- no IAM permissions.



\---



\## Insecure Data Analyst Policy



The insecure data analyst policy grants unnecessary write and delete permissions:



```json

\[

&#x20; "s3:PutObject",

&#x20; "s3:DeleteObject"

]

```



It also uses:



```json

"Resource": "\*"

```



\### Risk



This would allow data analysts to modify or delete data across S3 resources instead of only reading approved business reports.



Potential impact:



\- accidental or malicious deletion of datasets;

\- unauthorized modification of business reports;

\- access to production or internal evidence data;

\- violation of separation of duties.



\### Expected Remediation



The final data analyst policy should remain read-only and scoped to the approved report prefix only.



This remediation has already been implemented for the data analyst role.



\---



\## Insecure Security Auditor Policy



The insecure security auditor policy grants:



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



\### Risk



This violates separation of duties because an auditor should not be able to modify the IAM environment they are reviewing.



Potential impact:



\- create privileged users;

\- create or modify roles;

\- attach administrative policies;

\- delete IAM resources;

\- alter Access Analyzer configuration;

\- hide or weaken security visibility;

\- pass roles to AWS services through `iam:PassRole`.



\### Expected Remediation



The security auditor should receive read-only IAM visibility and controlled Access Analyzer permissions.



The auditor should not be able to create, update, delete, or attach IAM policies.



\---



\## Insecure Trust Policy



The insecure trust policy allows:



```json

"Principal": {

&#x20; "AWS": "\*"

}

```



with:



```json

"Action": "sts:AssumeRole"

```



\### Risk



This creates an overly broad trust relationship and allows any AWS principal to attempt role assumption.



Potential impact:



\- unauthorized role assumption attempts;

\- confused deputy risk;

\- cross-account exposure;

\- privilege escalation if identity permissions are also misconfigured.



\### Expected Remediation



A secure trust policy should:



\- restrict the trusted principal;

\- require MFA for sensitive role assumption;

\- use conditions where appropriate;

\- avoid wildcard principals.



The data analyst role already demonstrates a safer pattern by requiring MFA through the `aws:MultiFactorAuthPresent` condition.



\---



\## JSON Encoding Issue and Resolution



During IAM Access Analyzer validation, the policy files initially returned:



```text

JSON\_SYNTAX\_ERROR

```



The error appeared at:



```text

line 1, column 0

```



This indicated an encoding or invisible character issue rather than a visible JSON structure issue.



The files were rewritten as UTF-8 without BOM using PowerShell:



```powershell

$utf8NoBom = \[System.Text.UTF8Encoding]::new($false)



\[System.IO.File]::WriteAllText(

&#x20; "$PWD\\policies\\insecure-examples\\developer-overpermissive-s3-policy.json",

&#x20; $developerPolicy,

&#x20; $utf8NoBom

)

```



After rewriting the policy files, IAM Access Analyzer was able to parse them correctly.



\---



\## IAM Access Analyzer Validation



IAM Access Analyzer validation was run against the identity policy examples.



The purpose of this validation was not to approve the policies for deployment.



The purpose was to confirm that the policy documents are syntactically valid and suitable for security review.



\---



\### Developer Over-Permissive S3 Policy



Command:



```powershell

aws accessanalyzer validate-policy `

&#x20; --policy-document file://policies/insecure-examples/developer-overpermissive-s3-policy.json `

&#x20; --policy-type IDENTITY\_POLICY `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "findings": \[]

}

```



\### Interpretation



IAM Access Analyzer did not return a finding for this policy.



However, the policy remains insecure in the context of the NovaCloud Analytics scenario because it grants:



```json

"Action": "s3:\*",

"Resource": "\*"

```



This violates the project requirement that developers should only access the development bucket and should not access production data or perform destructive bucket-level actions.



\---



\### Data Analyst Unnecessary Write Policy



Command:



```powershell

aws accessanalyzer validate-policy `

&#x20; --policy-document file://policies/insecure-examples/data-analyst-unnecessary-write-policy.json `

&#x20; --policy-type IDENTITY\_POLICY `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "findings": \[]

}

```



\### Interpretation



IAM Access Analyzer did not return a finding for this policy.



However, the policy remains insecure in the context of the NovaCloud Analytics scenario because data analysts only require read access to approved report data.



The policy grants unnecessary actions such as:



```json

\[

&#x20; "s3:PutObject",

&#x20; "s3:DeleteObject"

]

```



It also applies these permissions to:



```json

"Resource": "\*"

```



This violates least privilege and separation of duties.



\---



\### Security Auditor Over-Permissive IAM Policy



Command:



```powershell

aws accessanalyzer validate-policy `

&#x20; --policy-document file://policies/insecure-examples/security-auditor-overpermissive-iam-policy.json `

&#x20; --policy-type IDENTITY\_POLICY `

&#x20; --profile iam-lab

```



Result summary:



```text

findingType: WARNING

issueCode: CREATE\_SLR\_WITH\_STAR\_IN\_ACTION\_AND\_RESOURCE

```



Access Analyzer reported that using wildcards in both the action and resource can allow unintended service-linked role creation through `iam:CreateServiceLinkedRole`.



Result summary:



```text

findingType: SECURITY\_WARNING

issueCode: PASS\_ROLE\_WITH\_STAR\_IN\_ACTION\_AND\_RESOURCE

```



Access Analyzer also reported that using wildcards in both the action and resource can allow overly permissive `iam:PassRole` permissions.



\### Interpretation



This result confirms that the security auditor example is dangerously over-permissive.



The policy grants:



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



This is not appropriate for an auditor role, which should be read-only and unable to modify IAM resources.



\---



\## Important Lesson



IAM Access Analyzer is useful, but it does not replace business-context security analysis.



A policy can be syntactically valid and still violate least privilege.



For this project, the final judgment is based on both:



\- AWS policy validation;

\- the NovaCloud Analytics business requirements.



\---



\## Checkpoint Result



Checkpoint 15 is complete.



The project now includes a documented insecure baseline for:



\- developer S3 over-permissioning;

\- data analyst unnecessary write access;

\- security auditor excessive IAM permissions;

\- unsafe role trust configuration.



These examples will be used in later documentation to explain the before-and-after remediation path toward least privilege.



The insecure examples are documentation artifacts only and are not attached to IAM users, groups, or roles.

