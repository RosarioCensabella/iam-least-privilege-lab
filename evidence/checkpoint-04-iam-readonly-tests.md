\# IAM Read-Only Role Tests



\## Objective



Validate that the `novacloud-iam-lab-dev-data-analyst-readonly` IAM role follows least privilege principles.



The role must be able to:



\- list the authorized `reports/` prefix;

\- download files from `reports/`.



The role must not be able to:



\- list the bucket root;

\- read objects from `evidence/`;

\- upload objects;

\- delete objects.



\---



\## Role Assumption



The role was assumed using AWS STS.



Command:



```powershell

aws sts assume-role `

&#x20; --role-arn arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly `

&#x20; --role-session-name data-analyst-readonly-test `

&#x20; --profile iam-lab







Caller identity after assuming the role:



{

&#x20;   "UserId": "AROAY2TOC4RNUNWMBJB2O:data-analyst-readonly-test",

&#x20;   "Account": "606895006811",

&#x20;   "Arn": "arn:aws:sts::606895006811:assumed-role/novacloud-iam-lab-dev-data-analyst-readonly/data-analyst-readonly-test"

}









POSTIVE TESTS



Positive Test 1 - List Authorized Reports Prefix

Command: aws s3 ls "s3://novacloud-iam-lab-dev-606895006811/reports/"



Result:

2026-04-30 10:36:04          0

2026-04-30 10:45:59         65 sample-report.txt



Result: Allowed





Positive Test 2 - Download Authorized Report

Command: aws s3 cp "s3://novacloud-iam-lab-dev-606895006811/reports/sample-report.txt" .\\downloaded-sample-report.txt



Result: download: s3://novacloud-iam-lab-dev-606895006811/reports/sample-report.txt to .\\downloaded-sample-report.txt



Downloaded file content: NovaCloud Analytics - sample report for IAM least privilege lab



Result: Allowed



The role can read authorized report objects.











NEGATIVE TESTS



Negative Test 1 - List Bucket Root

Command: aws s3 ls "s3://novacloud-iam-lab-dev-606895006811"



Result: AccessDenied



Detailed error: User: arn:aws:sts::606895006811:assumed-role/novacloud-iam-lab-dev-data-analyst-readonly/data-analyst-readonly-test is not authorized to perform: s3:ListBucket on resource: "arn:aws:s3:::novacloud-iam-lab-dev-606895006811"



Result: Denied





Negative Test 2 - Read Evidence Prefix

Command: aws s3 cp "s3://novacloud-iam-lab-dev-606895006811/evidence/internal-evidence.txt" .\\should-not-download.txt



Result: fatal error: An error occurred (403) when calling the HeadObject operation: Forbidden



Result: Denied



The role cannot read objects outside the authorized reports/ prefix.





Negative Test 3 - Upload Object

Command: aws s3 cp .\\unauthorized-upload.txt "s3://novacloud-iam-lab-dev-606895006811/reports/unauthorized-upload.txt"



Result: AccessDenied



Detailed error: is not authorized to perform: s3:PutObject



Result: Denied





Negative Test 4 - Delete Object

Command: aws s3 rm "s3://novacloud-iam-lab-dev-606895006811/reports/sample-report.txt"



Result: AccessDenied



Detailed error: is not authorized to perform: s3:DeleteObject



Result: Denied



The role cannot delete report data.













Conclusion



The IAM role follows least privilege principles.



Allowed actions:



s3:GetBucketLocation

s3:ListBucket only for the reports/ prefix

s3:GetObject only for reports/\*



Denied actions:



unrestricted bucket listing;

reading evidence/\*;

uploading objects;

deleting objects;

modifying bucket configuration.



This validates that the role grants only the minimum permissions required for a data analyst read-only use case.

