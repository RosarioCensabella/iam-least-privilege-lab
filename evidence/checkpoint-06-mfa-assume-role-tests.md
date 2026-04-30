\# Checkpoint 06 - MFA Requirement for Role Assumption



\## Objective



Validate that the `novacloud-iam-lab-dev-data-analyst-readonly` IAM role can be assumed only when MFA is present.



This improves the access model by requiring a second authentication factor before temporary credentials can be issued through AWS STS.



\---



\## Security Change



The role trust policy was updated with the following condition:



&#x20;   aws:MultiFactorAuthPresent = true



This means that the trusted principal can assume the role only when the request includes a valid MFA context.



\---



\## Negative Test - Assume Role Without MFA



Command:



&#x20;   aws sts assume-role `

&#x20;     --role-arn arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly `

&#x20;     --role-session-name data-analyst-no-mfa-test `

&#x20;     --profile iam-lab



Result:



&#x20;   AccessDenied



Security meaning:



The IAM user `terraform-lab-admin` cannot assume the role using only long-term access keys.



\---



\## Positive Test - Assume Role With MFA



The MFA device associated with the lab IAM user was used:



&#x20;   arn:aws:iam::606895006811:mfa/iPhone\_RosarioCensabella



Command pattern:



&#x20;   aws sts assume-role `

&#x20;     --role-arn arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly `

&#x20;     --role-session-name data-analyst-mfa-test `

&#x20;     --serial-number <mfa-device-arn> `

&#x20;     --token-code <mfa-code> `

&#x20;     --profile iam-lab



Result:



&#x20;   Allowed



Caller identity after assuming the role:



&#x20;   arn:aws:sts::606895006811:assumed-role/novacloud-iam-lab-dev-data-analyst-readonly/data-analyst-mfa-test



Security meaning:



The role can be assumed only after successful MFA verification.



\---



\## Permission Revalidation After MFA



After assuming the role with MFA, the original least privilege behavior was still valid.



Allowed:



\- list `reports/`;

\- read objects from `reports/\*`.



Denied:



\- delete objects;

\- upload objects;

\- read `evidence/\*`;

\- list the bucket root.



\---



\## Conclusion



The MFA requirement strengthens the role assumption process without expanding the permissions granted by the role.



The final access model is:



&#x20;   trusted IAM user + valid MFA

&#x20;       -> STS AssumeRole

&#x20;       -> temporary credentials

&#x20;       -> read-only access to reports/



This reduces the risk of unauthorized role assumption if long-term IAM user credentials are compromised.

