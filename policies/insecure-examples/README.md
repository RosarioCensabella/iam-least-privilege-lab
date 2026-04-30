\# Insecure IAM Policy Examples



This folder contains intentionally insecure IAM policy examples used for the IAM Least Privilege Lab.



These files represent the insecure baseline configuration that NovaCloud Analytics S.r.l. could have had before the remediation phase.



\## Important Safety Notice



These policies are provided for documentation, analysis, and portfolio demonstration purposes only.



They must not be attached to IAM users, IAM groups, or IAM roles in a real AWS account.



They are intentionally over-permissive and are used to explain:



\- excessive S3 permissions;

\- unnecessary write/delete access;

\- overly broad IAM permissions;

\- unsafe role trust relationships;

\- missing MFA conditions;

\- missing resource scoping.



\## Files



| File | Risk Demonstrated |

|---|---|

| `developer-overpermissive-s3-policy.json` | Developers can perform any S3 action on any bucket. |

| `data-analyst-unnecessary-write-policy.json` | Data analysts receive write and delete access they do not need. |

| `security-auditor-overpermissive-iam-policy.json` | Security auditors can modify IAM instead of only reviewing it. |

| `open-assume-role-trust-policy.json` | A role can be assumed by any AWS principal without MFA. |



\## Remediation Direction



The final least privilege design should replace these insecure examples with scoped policies that:



\- limit actions to the minimum required;

\- limit resources to specific bucket ARNs, prefixes, roles, and analyzers;

\- avoid `Action: "\*"` and `Resource: "\*"` combinations;

\- require MFA for sensitive role assumption flows;

\- separate read-only audit permissions from administrative permissions;

\- use groups and roles instead of direct user-level permissions where possible.

