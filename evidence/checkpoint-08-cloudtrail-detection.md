\---



\## Observed AssumeRole Events



CloudTrail returned multiple `AssumeRole` events related to the data analyst role.



Sanitized output:



| EventId | Source | Time | Username |

|---|---|---|---|

| 429f72bf-2bab-4750-9d25-130e57866bb0 | sts.amazonaws.com | 2026-04-30T12:36:57+02:00 | terraform-lab-admin |

| d48003c8-dc05-4fc6-896a-63395b253278 | sts.amazonaws.com | 2026-04-30T12:23:41+02:00 | terraform-lab-admin |

| 0c93b960-2704-40da-8e45-56ba2ccbf387 | sts.amazonaws.com | 2026-04-30T11:33:29+02:00 | terraform-lab-admin |

| d429d79f-5993-437e-8022-7181f8707cb4 | sts.amazonaws.com | 2026-04-30T11:07:16+02:00 | terraform-lab-admin |

| 03491c22-2fe0-43ea-8f48-c2f1f85b394f | sts.amazonaws.com | 2026-04-30T11:04:13+02:00 | terraform-lab-admin |



Security interpretation:



These events show that role assumption activity is visible through CloudTrail and can be used as a detection source for monitoring access to sensitive IAM roles.

