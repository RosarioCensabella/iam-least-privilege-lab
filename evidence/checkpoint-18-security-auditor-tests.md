\# Checkpoint 18 — Security Auditor Least Privilege Tests



\## Objective



This checkpoint validates the least privilege permissions assigned to the Security Auditor team.



The security auditor identity tested was:



```text

arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-security-auditor-user

```



The tests were executed with IAM Policy Simulator instead of long-lived user credentials.



This approach avoids creating permanent access keys while still validating the effective IAM authorization model.



\---



\## Security Model



The Security Auditor team should be able to review IAM and Access Analyzer configuration, but should not be able to modify IAM resources or weaken the security posture of the AWS account.



The expected access model is:



| Capability | Expected |

|---|---:|

| List IAM users, groups, and roles | allowed |

| Read IAM user and policy metadata | allowed |

| Use IAM Access Analyzer in read/validation mode | allowed |

| Create IAM users | denied |

| Create IAM policies | denied |

| Attach policies to users | denied |

| Pass IAM roles | denied |

| Delete Access Analyzer resources | denied |



This validates separation of duties between security review and security administration.



\---



\## Test Method



The following AWS CLI command pattern was used:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn <security-auditor-user-arn> `

&#x20; --action-names <action> `

&#x20; --resource-arns <resource-arn> `

&#x20; --profile iam-lab

```



The security auditor user has no access keys and no console password managed by Terraform.



\---



\## Test Variables



The following resources were used during the tests:



```text

Security auditor user ARN:

arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-security-auditor-user



Developer user ARN:

arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-developer-user



Developer least privilege policy ARN:

arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-developers-least-privilege



Data analyst role ARN:

arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly



IAM Access Analyzer ARN:

arn:aws:access-analyzer:eu-west-1:606895006811:analyzer/novacloud-iam-lab-dev-access-analyzer

```



\---



\## Summary of Results



| Test | Expected Result | Actual Result | Status |

|---|---:|---:|---:|

| List IAM users | allowed | allowed | Passed |

| List IAM groups | allowed | allowed | Passed |

| List IAM roles | allowed | allowed | Passed |

| Read IAM user details | allowed | allowed | Passed |

| Read IAM policy metadata | allowed | allowed | Passed |

| List IAM Access Analyzer analyzers | allowed | allowed | Passed |

| Validate IAM policy with Access Analyzer | allowed | allowed | Passed |

| Create IAM user | implicitDeny | implicitDeny | Passed |

| Create IAM policy | implicitDeny | implicitDeny | Passed |

| Attach policy to IAM user | implicitDeny | implicitDeny | Passed |

| Pass IAM role | implicitDeny | implicitDeny | Passed |

| Delete IAM Access Analyzer analyzer | implicitDeny | implicitDeny | Passed |



\---



\## Positive Test — List IAM Users



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:ListUsers `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:ListUsers

Decision: allowed

Resource: \*

```



Interpretation:



The security auditor can list IAM users for review purposes.



\---



\## Positive Test — List IAM Groups



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:ListGroups `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:ListGroups

Decision: allowed

Resource: \*

```



Interpretation:



The security auditor can list IAM groups to review group-based permission assignments.



\---



\## Positive Test — List IAM Roles



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:ListRoles `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:ListRoles

Decision: allowed

Resource: \*

```



Interpretation:



The security auditor can list IAM roles to review role-based access and trust relationships.



\---



\## Positive Test — Read IAM User Details



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:GetUser `

&#x20; --resource-arns $DeveloperUserArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:GetUser

Decision: allowed

Resource: arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-developer-user

```



Interpretation:



The security auditor can inspect IAM user metadata but cannot modify the user.



\---



\## Positive Test — Read IAM Policy Metadata



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:GetPolicy `

&#x20; --resource-arns $DeveloperPolicyArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:GetPolicy

Decision: allowed

Resource: arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-developers-least-privilege

```



Interpretation:



The security auditor can inspect IAM policy metadata for review purposes.



\---



\## Positive Test — List IAM Access Analyzer Analyzers



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names access-analyzer:ListAnalyzers `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   access-analyzer:ListAnalyzers

Decision: allowed

Resource: \*

```



Interpretation:



The security auditor can list Access Analyzer analyzers to support security review activities.



\---



\## Positive Test — Validate IAM Policy



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names access-analyzer:ValidatePolicy `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   access-analyzer:ValidatePolicy

Decision: allowed

Resource: \*

```



Interpretation:



The security auditor can validate IAM policies with IAM Access Analyzer.



This supports security review without granting permissions to modify IAM resources.



\---



\## Negative Test — Create IAM User



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:CreateUser `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:CreateUser

Decision: implicitDeny

Resource: \*

```



Interpretation:



The security auditor cannot create IAM users.



\---



\## Negative Test — Create IAM Policy



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:CreatePolicy `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:CreatePolicy

Decision: implicitDeny

Resource: \*

```



Interpretation:



The security auditor cannot create IAM policies.



\---



\## Negative Test — Attach Policy to IAM User



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:AttachUserPolicy `

&#x20; --resource-arns $DeveloperUserArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:AttachUserPolicy

Decision: implicitDeny

Resource: arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-developer-user

```



Interpretation:



The security auditor cannot attach policies to users and cannot grant additional privileges.



\---



\## Negative Test — Pass IAM Role



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names iam:PassRole `

&#x20; --resource-arns $DataAnalystRoleArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   iam:PassRole

Decision: implicitDeny

Resource: arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly

```



Interpretation:



The security auditor cannot pass IAM roles to AWS services.



This is important because `iam:PassRole` can be involved in privilege escalation paths when combined with other service permissions.



\---



\## Negative Test — Delete IAM Access Analyzer Analyzer



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $SecurityAuditorUserArn `

&#x20; --action-names access-analyzer:DeleteAnalyzer `

&#x20; --resource-arns $AccessAnalyzerArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   access-analyzer:DeleteAnalyzer

Decision: implicitDeny

Resource: arn:aws:access-analyzer:eu-west-1:606895006811:analyzer/novacloud-iam-lab-dev-access-analyzer

```



Interpretation:



The security auditor can use Access Analyzer for review, but cannot delete the analyzer or weaken detection capability.



\---



\## Security Conclusion



The security auditor least privilege policy behaves as intended.



The security auditor can:



\- inspect IAM users;

\- inspect IAM groups;

\- inspect IAM roles;

\- inspect IAM policies;

\- use IAM Access Analyzer for read and validation activities.



The security auditor cannot:



\- create IAM users;

\- create IAM policies;

\- attach policies to users;

\- pass IAM roles;

\- delete Access Analyzer resources.



This validates the least privilege remediation for the Security Auditor team and demonstrates separation of duties between audit visibility and administrative control.

