locals {
  developer_policy_name        = "${var.project_name}-${var.environment}-developers-least-privilege"
  data_analyst_policy_name     = "${var.project_name}-${var.environment}-data-analysts-assume-readonly-role"
  security_auditor_policy_name = "${var.project_name}-${var.environment}-security-auditors-readonly"
}

data "aws_iam_policy_document" "developer" {
  statement {
    sid    = "AllowDevelopmentBucketLocation"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      var.development_bucket_arn
    ]
  }

  statement {
    sid    = "AllowListDevelopmentBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.development_bucket_arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "uploads",
        "uploads/",
        "uploads/*",
        "logs",
        "logs/",
        "logs/*"
      ]
    }
  }

  statement {
    sid    = "AllowReadWriteDevelopmentObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${var.development_bucket_arn}/uploads/*",
      "${var.development_bucket_arn}/logs/*"
    ]
  }

  statement {
    sid    = "AllowDescribeCloudWatchLogGroups"
    effect = "Allow"

    actions = [
      "logs:DescribeLogGroups"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowReadDeveloperApplicationLogs"
    effect = "Allow"

    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]

    resources = [
      var.cloudwatch_log_group_arn,
      var.cloudwatch_log_streams_arn
    ]
  }
}

resource "aws_iam_policy" "developer" {
  name        = local.developer_policy_name
  description = "Least privilege permissions for developers to use the development S3 bucket and read application logs."
  policy      = data.aws_iam_policy_document.developer.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Developer least privilege policy"
  }
}

resource "aws_iam_group_policy_attachment" "developer" {
  group      = var.developer_group_name
  policy_arn = aws_iam_policy.developer.arn
}

data "aws_iam_policy_document" "data_analyst_assume_role" {
  statement {
    sid    = "AllowAssumeDataAnalystReadonlyRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      var.data_analyst_role_arn
    ]
  }
}

resource "aws_iam_policy" "data_analyst_assume_role" {
  name        = local.data_analyst_policy_name
  description = "Allows data analysts to assume the MFA-protected read-only data analyst role."
  policy      = data.aws_iam_policy_document.data_analyst_assume_role.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Data analyst assume role policy"
  }
}

resource "aws_iam_group_policy_attachment" "data_analyst_assume_role" {
  group      = var.data_analysts_group_name
  policy_arn = aws_iam_policy.data_analyst_assume_role.arn
}

data "aws_iam_policy_document" "security_auditor" {
  statement {
    sid    = "AllowIamReadOnlyReview"
    effect = "Allow"

    actions = [
      "iam:Get*",
      "iam:List*",
      "iam:GetAccountSummary",
      "iam:GenerateCredentialReport",
      "iam:GetCredentialReport"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowAccessAnalyzerReadAndValidate"
    effect = "Allow"

    actions = [
      "access-analyzer:Get*",
      "access-analyzer:List*",
      "access-analyzer:ValidatePolicy"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "security_auditor" {
  name        = local.security_auditor_policy_name
  description = "Read-only IAM and Access Analyzer permissions for security auditors."
  policy      = data.aws_iam_policy_document.security_auditor.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Security auditor read-only policy"
  }
}

resource "aws_iam_group_policy_attachment" "security_auditor" {
  group      = var.security_auditors_group_name
  policy_arn = aws_iam_policy.security_auditor.arn
}