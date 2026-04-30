\# Checkpoint 17 — Developer Least Privilege Tests



\## Objective



This checkpoint validates the least privilege permissions assigned to the Developer team.



The developer identity tested was:



```text

arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-developer-user

```



The tests were executed with IAM Policy Simulator instead of long-lived developer credentials.



This approach avoids creating permanent access keys while still validating the effective IAM authorization model.



\---



\## Test Method



The following AWS CLI command pattern was used:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn <developer-user-arn> `

&#x20; --action-names <action> `

&#x20; --resource-arns <resource-arn> `

&#x20; --profile iam-lab

```



The developer user has no access keys and no console password managed by Terraform.



\---



\## Test Variables



The following resources were used during the tests:



```text

Developer user ARN:

arn:aws:iam::606895006811:user/novacloud-iam-lab-dev-developer-user



Development bucket:

arn:aws:s3:::novacloud-iam-lab-dev-development-606895006811



Production bucket:

arn:aws:s3:::novacloud-iam-lab-dev-production-606895006811



Developer CloudWatch log group:

arn:aws:logs:eu-west-1:606895006811:log-group:/novacloud/iam-lab/dev/developer-app



Developer CloudWatch log stream:

arn:aws:logs:eu-west-1:606895006811:log-group:/novacloud/iam-lab/dev/developer-app:log-stream:application

```



\---



\## Summary of Results



| Test | Expected Result | Actual Result | Status |

|---|---:|---:|---:|

| List authorized development bucket prefix | allowed | allowed | Passed |

| Read object from development bucket `uploads/` prefix | allowed | allowed | Passed |

| Write object to development bucket `uploads/` prefix | allowed | allowed | Passed |

| Read object from development bucket `logs/` prefix | allowed | allowed | Passed |

| Read object from production bucket | implicitDeny | implicitDeny | Passed |

| Delete development bucket | implicitDeny | implicitDeny | Passed |

| Create IAM user | implicitDeny | implicitDeny | Passed |

| Describe CloudWatch log groups | allowed | allowed | Passed |

| Filter CloudWatch log events from authorized log group | allowed | allowed | Passed |

| Delete CloudWatch log group | implicitDeny | implicitDeny | Passed |



\---



\## Positive Test — List Development Bucket Prefix



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names s3:ListBucket `

&#x20; --resource-arns $DevBucketArn `

&#x20; --context-entries ContextKeyName=s3:prefix,ContextKeyValues=uploads/,ContextKeyType=string `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   s3:ListBucket

Decision: allowed

Resource: arn:aws:s3:::novacloud-iam-lab-dev-development-606895006811

```



Interpretation:



The developer can list the authorized `uploads/` prefix in the development bucket.



\---



\## Positive Test — Read and Write Development Object



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names s3:GetObject s3:PutObject `

&#x20; --resource-arns $DevUploadObjectArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   s3:GetObject

Decision: allowed

Resource: arn:aws:s3:::novacloud-iam-lab-dev-development-606895006811/uploads/developer-test.txt



Action:   s3:PutObject

Decision: allowed

Resource: arn:aws:s3:::novacloud-iam-lab-dev-development-606895006811/uploads/developer-test.txt

```



Interpretation:



The developer can read and write objects only within the authorized development bucket prefixes.



\---



\## Positive Test — Read Development Logs Prefix Object



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names s3:GetObject `

&#x20; --resource-arns $DevLogsObjectArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   s3:GetObject

Decision: allowed

Resource: arn:aws:s3:::novacloud-iam-lab-dev-development-606895006811/logs/developer-log.txt

```



Interpretation:



The developer can read objects under the authorized `logs/` prefix in the development bucket.



\---



\## Negative Test — Production Bucket Access



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names s3:GetObject `

&#x20; --resource-arns $ProdProtectedObjectArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   s3:GetObject

Decision: implicitDeny

Resource: arn:aws:s3:::novacloud-iam-lab-dev-production-606895006811/protected/production-secret.txt

```



Interpretation:



The developer cannot read protected production data.



\---



\## Negative Test — Bucket Deletion



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names s3:DeleteBucket `

&#x20; --resource-arns $DevBucketArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   s3:DeleteBucket

Decision: implicitDeny

Resource: arn:aws:s3:::novacloud-iam-lab-dev-development-606895006811

```



Interpretation:



The developer can work with authorized objects but cannot delete the development bucket.



\---



\## Negative Test — IAM User Creation



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

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



The developer cannot create IAM users or perform IAM administration.



\---



\## Positive Test — Describe CloudWatch Log Groups



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names logs:DescribeLogGroups `

&#x20; --resource-arns "\*" `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   logs:DescribeLogGroups

Decision: allowed

Resource: \*

```



Interpretation:



The developer can discover CloudWatch log groups, which is required before reading application logs.



\---



\## Positive Test — Filter CloudWatch Log Events



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names logs:FilterLogEvents `

&#x20; --resource-arns $DeveloperLogGroupArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   logs:FilterLogEvents

Decision: allowed

Resource: arn:aws:logs:eu-west-1:606895006811:log-group:/novacloud/iam-lab/dev/developer-app

```



Interpretation:



The developer can read/filter events from the authorized application log group.



\---



\## Negative Test — Delete CloudWatch Log Group



Command:



```powershell

aws iam simulate-principal-policy `

&#x20; --policy-source-arn $DeveloperUserArn `

&#x20; --action-names logs:DeleteLogGroup `

&#x20; --resource-arns $DeveloperLogGroupArn `

&#x20; --profile iam-lab `

&#x20; --query "EvaluationResults\[].{Action:EvalActionName,Decision:EvalDecision,Resource:EvalResourceName}" `

&#x20; --output table

```



Result:



```text

Action:   logs:DeleteLogGroup

Decision: implicitDeny

Resource: arn:aws:logs:eu-west-1:606895006811:log-group:/novacloud/iam-lab/dev/developer-app

```



Interpretation:



The developer can read authorized logs but cannot delete the CloudWatch log group.



\---



\## CloudWatch Logs Policy Refinement During Testing



During testing, `logs:GetLogEvents` returned `implicitDeny` in IAM Policy Simulator even after the active AWS policy contained the following statement:



```json

{

&#x20; "Action": "logs:GetLogEvents",

&#x20; "Effect": "Allow",

&#x20; "Resource": "arn:aws:logs:eu-west-1:606895006811:log-group:/novacloud/iam-lab/dev/developer-app:log-stream:\*",

&#x20; "Sid": "AllowGetDeveloperApplicationLogEvents"

}

```



The policy was refined to separate log group level actions from log stream level actions:



\- `logs:DescribeLogStreams` and `logs:FilterLogEvents` are scoped to the log group ARN;

\- `logs:GetLogEvents` is scoped to the log stream ARN pattern.



The checkpoint uses `logs:FilterLogEvents` as the positive CloudWatch Logs read test because it passed with the scoped log group ARN and demonstrates authorized log read capability without broadening permissions to `Resource: "\*"`.



\---



\## Security Conclusion



The developer least privilege policy behaves as intended for the tested access boundaries.



The developer can:



\- list authorized development prefixes;

\- read and write authorized development objects;

\- read authorized CloudWatch log data;

\- describe log groups.



The developer cannot:



\- access production S3 data;

\- delete S3 buckets;

\- create IAM users;

\- delete CloudWatch log groups.



This validates the least privilege remediation for the Developer team.

