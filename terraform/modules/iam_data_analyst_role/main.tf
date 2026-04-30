locals {
  role_name   = "${var.project_name}-${var.environment}-data-analyst-readonly"
  policy_name = "${var.project_name}-${var.environment}-data-analyst-s3-readonly"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AllowTrustedPrincipalToAssumeRoleWithMFA"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        var.trusted_principal_arn
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Read-only access to analytics reports"
  }
}

data "aws_iam_policy_document" "s3_readonly_reports" {
  statement {
    sid    = "AllowGetBucketLocation"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      var.bucket_arn
    ]
  }

  statement {
    sid    = "AllowListReportsPrefixOnly"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.bucket_arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "reports",
        "reports/",
        "reports/*"
      ]
    }
  }

  statement {
    sid    = "AllowReadReportsObjectsOnly"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${var.bucket_arn}/reports/*"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name        = local.policy_name
  description = "Allows read-only access to the reports prefix in the lab S3 bucket."
  policy      = data.aws_iam_policy_document.s3_readonly_reports.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Least privilege S3 read-only policy"
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}