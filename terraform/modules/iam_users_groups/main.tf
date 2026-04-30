locals {
  name_prefix = "${var.project_name}-${var.environment}"

  users = {
    developer = {
      name    = "developer-user"
      team    = "Developer"
      purpose = "Developer identity for least privilege testing"
    }

    data_analyst = {
      name    = "data-analyst-user"
      team    = "Data Analyst"
      purpose = "Data analyst identity for least privilege testing"
    }

    security_auditor = {
      name    = "security-auditor-user"
      team    = "Security"
      purpose = "Security auditor identity for IAM and Access Analyzer review"
    }
  }

  groups = {
    developers = {
      name    = "developers-group"
      purpose = "Group for developer team permissions"
    }

    data_analysts = {
      name    = "data-analysts-group"
      purpose = "Group for data analyst team permissions"
    }

    security_auditors = {
      name    = "security-auditors-group"
      purpose = "Group for security auditor permissions"
    }
  }

  memberships = {
    developer = {
      user_key  = "developer"
      group_key = "developers"
    }

    data_analyst = {
      user_key  = "data_analyst"
      group_key = "data_analysts"
    }

    security_auditor = {
      user_key  = "security_auditor"
      group_key = "security_auditors"
    }
  }
}

resource "aws_iam_user" "this" {
  for_each = local.users

  name          = "${local.name_prefix}-${each.value.name}"
  path          = var.iam_path
  force_destroy = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Team        = each.value.team
    Purpose     = each.value.purpose
    AccessModel = "No console password or long-lived access keys managed by Terraform"
  }
}

resource "aws_iam_group" "this" {
  for_each = local.groups

  name = "${local.name_prefix}-${each.value.name}"
  path = var.iam_path
}

resource "aws_iam_user_group_membership" "this" {
  for_each = local.memberships

  user = aws_iam_user.this[each.value.user_key].name

  groups = [
    aws_iam_group.this[each.value.group_key].name
  ]
}