# Incident Response Runbook - IAM Least Privilege Lab

## Objective

This runbook describes how to investigate and respond to suspicious IAM and S3 activity in the IAM Least Privilege Lab.

The lab scenario focuses on a data analyst role with read-only access to the `reports/` prefix in an S3 bucket.

Sensitive resources:

- IAM role: `novacloud-iam-lab-dev-data-analyst-readonly`
- IAM policy: `novacloud-iam-lab-dev-data-analyst-s3-readonly`
- S3 bucket: `novacloud-iam-lab-dev-606895006811`
- Allowed S3 prefix: `reports/`
- Restricted S3 prefix: `evidence/`

---

## Incident Scenario 1 - Unexpected Role Assumption

### Scenario

The data analyst role is assumed unexpectedly.

Examples:

- role assumed outside expected working hours;
- role assumed by an unexpected principal;
- suspicious session name;
- repeated role assumption attempts;
- role assumption from unusual source IP;
- role assumption without expected MFA context.

---

## Initial Triage

### Step 1 - Identify Recent AssumeRole Events

Run:

    aws cloudtrail lookup-events `
      --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole `
      --max-results 50 `
      --profile iam-lab `
      --query "Events[?contains(CloudTrailEvent, 'novacloud-iam-lab-dev-data-analyst-readonly')].{Time:EventTime,EventId:EventId,Source:EventSource,Username:Username}" `
      --output table

Expected fields:

- event time;
- event ID;
- event source;
- username.

Security interpretation:

The presence of an `AssumeRole` event confirms that temporary credentials were requested for the role.

---

### Step 2 - Retrieve Full Event Details

Use the suspicious `EventId` from the previous query.

Example:

    aws cloudtrail lookup-events `
      --lookup-attributes AttributeKey=EventId,AttributeValue=<EVENT_ID> `
      --profile iam-lab

Review:

- `userIdentity`;
- `sourceIPAddress`;
- `userAgent`;
- `requestParameters.roleArn`;
- `requestParameters.roleSessionName`;
- `errorCode`;
- `errorMessage`;
- MFA-related context if available.

---

### Step 3 - Confirm the Role Trust Policy

Check whether the role still requires MFA:

    aws iam get-role `
      --role-name novacloud-iam-lab-dev-data-analyst-readonly `
      --profile iam-lab `
      --query "Role.AssumeRolePolicyDocument"

Expected condition:

    aws:MultiFactorAuthPresent = true

Security interpretation:

If the MFA condition is missing, the trust policy may have been weakened.

---

## Containment

### Step 4 - Temporarily Remove the Policy Attachment

If the activity is suspicious and immediate containment is required, detach the policy from the role:

    aws iam detach-role-policy `
      --role-name novacloud-iam-lab-dev-data-analyst-readonly `
      --policy-arn arn:aws:iam::606895006811:policy/novacloud-iam-lab-dev-data-analyst-s3-readonly `
      --profile iam-lab

Security effect:

The role remains present, but it no longer has the custom read-only S3 permissions.

Important:

This is an emergency containment action. Since Terraform manages the attachment, the next `terraform plan` will detect drift and propose re-attaching the policy.

---

### Step 5 - Alternative Containment: Restrict the Trust Policy

If the issue is related to role assumption, another containment option is to restrict the trust policy.

Possible containment actions:

- restrict the trusted principal;
- keep MFA required;
- add additional conditions where appropriate;
- temporarily remove the trusted principal if needed.

In this lab, Terraform is the source of truth, so changes should normally be made in Terraform and applied through `terraform apply`.

---

## Investigation

### Step 6 - Check Current Terraform State

From the dev environment:

    cd terraform\envs\dev
    terraform plan

Expected result in a healthy state:

    No changes. Your infrastructure matches the configuration.

If Terraform detects changes, investigate drift.

Examples of suspicious drift:

- IAM policy changed outside Terraform;
- role trust policy changed outside Terraform;
- policy attachment removed or replaced;
- S3 bucket policy added manually.

---

### Step 7 - Validate IAM Policy

Export and validate the policy with IAM Access Analyzer:

    $policyArn = terraform output -raw data_analyst_policy_arn

    $policyVersion = aws iam get-policy `
      --policy-arn $policyArn `
      --profile iam-lab `
      --query "Policy.DefaultVersionId" `
      --output text

    $policyJson = aws iam get-policy-version `
      --policy-arn $policyArn `
      --version-id $policyVersion `
      --profile iam-lab `
      --query "PolicyVersion.Document" `
      --output json

    [System.IO.File]::WriteAllText(
      "$PWD\data-analyst-policy.json",
      $policyJson,
      [System.Text.UTF8Encoding]::new($false)
    )

    aws accessanalyzer validate-policy `
      --policy-document file://data-analyst-policy.json `
      --policy-type IDENTITY_POLICY `
      --profile iam-lab

Expected result:

    {
        "findings": []
    }

Security interpretation:

A clean result means IAM Access Analyzer did not detect syntax errors, security warnings, general warnings, or suggestions for the policy.

---

### Step 8 - Check Access Analyzer Findings

Run:

    $analyzerArn = terraform output -raw access_analyzer_arn

    aws accessanalyzer list-findings `
      --analyzer-arn $analyzerArn `
      --profile iam-lab

Expected result:

    {
        "findings": []
    }

Security interpretation:

Findings may indicate external or unintended access through resource policies or trust policies.

---

## Incident Scenario 2 - Read-Only Role Attempts Write or Delete

### Scenario

The data analyst role attempts an action outside its expected read-only behavior.

Examples:

- `s3:PutObject`;
- `s3:DeleteObject`;
- access to `evidence/*`;
- unrestricted bucket listing.

---

## Current Lab Limitation

The current lab has validated denied actions manually, but S3 object-level CloudTrail data events are not yet enabled.

That means object-level events such as:

- `s3:GetObject`;
- `s3:PutObject`;
- `s3:DeleteObject`.

are not yet available in CloudTrail Event History by default.

Future improvement:

Enable CloudTrail data events for the lab bucket to capture object-level access attempts.

---

## Expected Manual Evidence

Manual test evidence is stored in:

    evidence/checkpoint-04-iam-readonly-tests.md

The role was tested and denied for:

- listing the bucket root;
- reading `evidence/internal-evidence.txt`;
- uploading `reports/unauthorized-upload.txt`;
- deleting `reports/sample-report.txt`.

---

## Remediation

### Step 9 - Restore Expected Terraform Configuration

If manual emergency changes were made, restore the environment using Terraform:

    cd terraform\envs\dev
    terraform plan
    terraform apply

Expected result after remediation:

    No changes. Your infrastructure matches the configuration.

or a controlled plan that restores the expected IAM attachment, trust policy, or policy document.

---

### Step 10 - Rotate Credentials if Needed

If long-term IAM user credentials may be compromised:

1. deactivate the affected access key;
2. create a new access key only if required;
3. update the local AWS CLI profile;
4. delete the old access key after validation.

Investigation command:

    aws iam list-access-keys `
      --user-name terraform-lab-admin `
      --profile iam-lab

Containment command example:

    aws iam update-access-key `
      --user-name terraform-lab-admin `
      --access-key-id <ACCESS_KEY_ID> `
      --status Inactive `
      --profile iam-lab

Important:

Do not delete access keys before confirming that access has been restored through a safe path.

---

## Recovery Validation

After containment and remediation, validate the expected behavior again.

### 1. Role assumption without MFA is denied

    aws sts assume-role `
      --role-arn arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly `
      --role-session-name data-analyst-no-mfa-test `
      --profile iam-lab

Expected:

    AccessDenied

---

### 2. Role assumption with MFA is allowed

    aws sts assume-role `
      --role-arn arn:aws:iam::606895006811:role/novacloud-iam-lab-dev-data-analyst-readonly `
      --role-session-name data-analyst-mfa-test `
      --serial-number <MFA_DEVICE_ARN> `
      --token-code <MFA_CODE> `
      --profile iam-lab

Expected:

    Allowed

---

### 3. Authorized read is allowed

    aws s3 ls s3://novacloud-iam-lab-dev-606895006811/reports/

Expected:

    Allowed

---

### 4. Delete attempt is denied

    aws s3 rm s3://novacloud-iam-lab-dev-606895006811/reports/sample-report.txt

Expected:

    AccessDenied

---

## Evidence to Preserve

For every incident investigation, preserve:

- CloudTrail event IDs;
- timestamps;
- source IP addresses;
- user identity;
- role ARN;
- role session name;
- error codes;
- Terraform plan output;
- Access Analyzer findings;
- policy validation result;
- screenshots or terminal output.

Suggested evidence location:

    evidence/

---

## Communication Notes

For a real customer report, summarize:

- what happened;
- when it happened;
- which identity was involved;
- which role was targeted;
- whether MFA was present;
- what access was allowed or denied;
- containment action taken;
- remediation status;
- recommended improvements.

---

## Lessons Learned

Key lessons from this lab:

- role assumption is a critical security boundary;
- MFA reduces the risk of access key compromise;
- least privilege must be tested with both allowed and denied actions;
- Terraform helps detect configuration drift;
- Access Analyzer adds automated policy review;
- CloudTrail provides investigation evidence for management events;
- S3 object-level detection requires data events.

---

## Future Runbook Improvements

Recommended next steps:

- add CloudTrail data events for S3 object-level monitoring;
- create EventBridge rules for sensitive IAM changes;
- create CloudWatch alarms for repeated `AccessDenied` events;
- add Athena queries for CloudTrail log analysis;
- add a formal severity matrix;
- add escalation contacts;
- add rollback procedures for policy changes.

---

## Conclusion

This runbook provides a practical response process for suspicious IAM role assumption and least privilege boundary violations.

It connects prevention, detection, investigation, containment, remediation, and recovery validation in a single operational workflow.
