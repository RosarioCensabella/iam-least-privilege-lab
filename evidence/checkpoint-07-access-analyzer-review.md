\# Checkpoint 07 - IAM Access Analyzer Review



\## Objective



Validate the IAM least privilege implementation using AWS IAM Access Analyzer.



This checkpoint covers:



\- account-level Access Analyzer creation;

\- external access findings review;

\- custom IAM policy validation.



\---



\## Access Analyzer Resource



Terraform created an account-level IAM Access Analyzer.



Analyzer name:



&#x20;   novacloud-iam-lab-dev-access-analyzer



Analyzer type:



&#x20;   ACCOUNT



Security purpose:



The analyzer checks supported resources in the AWS account and reports findings when a resource policy allows access from outside the zone of trust.



\---



\## External Access Findings



Command:



&#x20;   aws accessanalyzer list-findings `

&#x20;     --analyzer-arn <access-analyzer-arn> `

&#x20;     --profile iam-lab



Result:



&#x20;   {

&#x20;       "findings": \[]

&#x20;   }



Security meaning:



No external access findings were detected by the account-level analyzer at the time of the review.



\---



\## IAM Policy Validation



Validated policy:



&#x20;   novacloud-iam-lab-dev-data-analyst-s3-readonly



Policy ARN:



&#x20;   arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-data-analyst-s3-readonly



Command:



&#x20;   aws accessanalyzer validate-policy `

&#x20;     --policy-document file://data-analyst-policy.json `

&#x20;     --policy-type IDENTITY\_POLICY `

&#x20;     --profile iam-lab



Result:



&#x20;   {

&#x20;       "findings": \[]

&#x20;   }



Security meaning:



IAM Access Analyzer did not report syntax errors, security warnings, general warnings, or suggestions for the custom read-only identity policy.



\---



\## Validated Policy Scope



The policy allows only:



\- `s3:GetBucketLocation` on the lab S3 bucket;

\- `s3:ListBucket` on the lab S3 bucket, restricted to the `reports/` prefix;

\- `s3:GetObject` only on `reports/\*`.



The policy does not allow:



\- unrestricted S3 access;

\- write access;

\- delete access;

\- bucket administration;

\- access to the `evidence/` prefix.



\---



\## Note About JSON Export



During the validation process, the first exported JSON file produced a `JSON\_SYNTAX\_ERROR`.



Root cause:



PowerShell output redirection created a file encoding that Access Analyzer could not parse correctly.



Resolution:



The policy document was regenerated in UTF-8 using:



&#x20;   \[System.IO.File]::WriteAllText(

&#x20;     "$PWD\\data-analyst-policy.json",

&#x20;     $policyJson,

&#x20;     \[System.Text.UTF8Encoding]::new($false)

&#x20;   )



After regenerating the file, policy validation completed successfully.



\---



\## Conclusion



IAM Access Analyzer confirmed that:



\- the account-level analyzer is active;

\- no external access findings were detected;

\- the custom data analyst policy produced no validation findings.



This provides an additional automated review layer on top of the manual positive and negative access tests.

