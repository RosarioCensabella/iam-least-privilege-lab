\# Checkpoint 13 — Multi-Bucket S3 Environment Evidence



\## Objective



This checkpoint extends the IAM Least Privilege Lab S3 environment by adding dedicated development and production buckets while preserving the existing data bucket already used by the data analyst least privilege scenario.



The goal is to create a clearer separation between:



\- development workloads;

\- business data reports;

\- protected production data.



This separation supports future IAM least privilege testing for the developer, data analyst, and security auditor scenarios.



\---



\## Terraform Change Summary



A new reusable Terraform module was added:



```text

terraform/modules/s3\_secure\_bucket/

```



The module creates secure S3 buckets with the following controls:



\- S3 Block Public Access enabled;

\- server-side encryption using AES256;

\- versioning enabled;

\- Terraform-managed tags;

\- optional placeholder prefix objects.



The existing data bucket module was not refactored during this checkpoint in order to avoid disrupting the already tested data analyst scenario.



\---



\## Buckets in Scope



After this checkpoint, the lab contains the following S3 buckets:



| Bucket | Purpose |

|---|---|

| `novacloud-iam-lab-dev-606895006811` | Existing data bucket used by the data analyst read-only scenario |

| `novacloud-iam-lab-dev-development-606895006811` | Development bucket for future developer read/write tests |

| `novacloud-iam-lab-dev-production-606895006811` | Protected production bucket for future negative access tests |



\---



\## Terraform Plan Result



Before applying the change, Terraform showed the expected plan:



```text

Plan: 11 to add, 0 to change, 0 to destroy.

```



This confirmed that Terraform would only create new resources and would not modify or destroy the existing data analyst bucket, IAM role, IAM policy, or Access Analyzer resources.



\---



\## Terraform Output



After applying the Terraform configuration, the following relevant outputs were available:



```text

s3\_data\_bucket\_name = "novacloud-iam-lab-dev-606895006811"

s3\_development\_bucket\_name = "novacloud-iam-lab-dev-development-606895006811"

s3\_production\_bucket\_name = "novacloud-iam-lab-dev-production-606895006811"

```



The existing data analyst IAM resources remained available:



```text

data\_analyst\_role\_name = "novacloud-iam-lab-dev-data-analyst-readonly"

data\_analyst\_policy\_arn = "arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-data-analyst-s3-readonly"

access\_analyzer\_name = "novacloud-iam-lab-dev-access-analyzer"

```



\---



\## Bucket Listing Evidence



The AWS CLI confirmed that the three lab buckets exist:



```text

2026-04-29 16:53:31 iam-lab-tfstate-rosario-20260429

2026-04-30 10:36:04 novacloud-iam-lab-dev-606895006811

2026-04-30 16:18:53 novacloud-iam-lab-dev-development-606895006811

2026-04-30 16:18:53 novacloud-iam-lab-dev-production-606895006811

```



The Terraform state backend bucket is also visible in the account:



```text

iam-lab-tfstate-rosario-20260429

```



This backend bucket is not part of the application lab environment. It is used only to store Terraform remote state.



\---



\## Development Bucket Prefixes



Command:



```powershell

aws s3 ls s3://novacloud-iam-lab-dev-development-606895006811 --profile iam-lab

```



Result:



```text

&#x20;                          PRE logs/

&#x20;                          PRE uploads/

```



The development bucket contains two placeholder prefixes:



| Prefix | Purpose |

|---|---|

| `logs/` | Placeholder for future developer log-related objects |

| `uploads/` | Placeholder for future developer upload tests |



\---



\## Production Bucket Prefixes



Command:



```powershell

aws s3 ls s3://novacloud-iam-lab-dev-production-606895006811 --profile iam-lab

```



Result:



```text

&#x20;                          PRE protected/

```



The production bucket contains one placeholder prefix:



| Prefix | Purpose |

|---|---|

| `protected/` | Protected prefix used for future negative access tests |



\---



\## Public Access Block Verification



\### Development Bucket



Command:



```powershell

aws s3api get-public-access-block `

&#x20; --bucket novacloud-iam-lab-dev-development-606895006811 `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "PublicAccessBlockConfiguration": {

&#x20;       "BlockPublicAcls": true,

&#x20;       "IgnorePublicAcls": true,

&#x20;       "BlockPublicPolicy": true,

&#x20;       "RestrictPublicBuckets": true

&#x20;   }

}

```



\### Production Bucket



Command:



```powershell

aws s3api get-public-access-block `

&#x20; --bucket novacloud-iam-lab-dev-production-606895006811 `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "PublicAccessBlockConfiguration": {

&#x20;       "BlockPublicAcls": true,

&#x20;       "IgnorePublicAcls": true,

&#x20;       "BlockPublicPolicy": true,

&#x20;       "RestrictPublicBuckets": true

&#x20;   }

}

```



Both buckets block public ACLs and public bucket policies.



\---



\## Versioning Verification



\### Development Bucket



Command:



```powershell

aws s3api get-bucket-versioning `

&#x20; --bucket novacloud-iam-lab-dev-development-606895006811 `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "Status": "Enabled"

}

```



\### Production Bucket



Command:



```powershell

aws s3api get-bucket-versioning `

&#x20; --bucket novacloud-iam-lab-dev-production-606895006811 `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "Status": "Enabled"

}

```



Versioning is enabled on both buckets.



\---



\## Encryption Verification



\### Development Bucket



Command:



```powershell

aws s3api get-bucket-encryption `

&#x20; --bucket novacloud-iam-lab-dev-development-606895006811 `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "ServerSideEncryptionConfiguration": {

&#x20;       "Rules": \[

&#x20;           {

&#x20;               "ApplyServerSideEncryptionByDefault": {

&#x20;                   "SSEAlgorithm": "AES256"

&#x20;               },

&#x20;               "BucketKeyEnabled": false,

&#x20;               "BlockedEncryptionTypes": {

&#x20;                   "EncryptionType": \[

&#x20;                       "SSE-C"

&#x20;                   ]

&#x20;               }

&#x20;           }

&#x20;       ]

&#x20;   }

}

```



\### Production Bucket



Command:



```powershell

aws s3api get-bucket-encryption `

&#x20; --bucket novacloud-iam-lab-dev-production-606895006811 `

&#x20; --profile iam-lab

```



Result:



```json

{

&#x20;   "ServerSideEncryptionConfiguration": {

&#x20;       "Rules": \[

&#x20;           {

&#x20;               "ApplyServerSideEncryptionByDefault": {

&#x20;                   "SSEAlgorithm": "AES256"

&#x20;               },

&#x20;               "BucketKeyEnabled": false,

&#x20;               "BlockedEncryptionTypes": {

&#x20;                   "EncryptionType": \[

&#x20;                       "SSE-C"

&#x20;                   ]

&#x20;               }

&#x20;           }

&#x20;       ]

&#x20;   }

}

```



Both buckets use default server-side encryption with AES256.



\---



\## Security Notes



This checkpoint improves the lab architecture by introducing explicit environment separation.



The development bucket will be used later to grant developers limited read/write permissions.



The production bucket will be used later to prove that developers and data analysts cannot access protected production data.



The existing data bucket remains unchanged and continues to support the already tested data analyst read-only scenario.



\---



\## Checkpoint Result



Checkpoint 13 is complete.



The project now has a multi-bucket S3 environment:



\- one existing data bucket;

\- one new development bucket;

\- one new production bucket.



All newly added buckets include:



\- public access blocked;

\- versioning enabled;

\- server-side encryption enabled;

\- Terraform-managed configuration.



No existing resources were changed or destroyed.

