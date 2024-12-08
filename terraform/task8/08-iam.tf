resource "aws_iam_role" "ec2_secrets_manager_role" {
  name               = "ec2-secrets-manager-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policy for Secrets Manager access
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerAccess"
  description = "Allows EC2 to access Secrets Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.ec2_secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

resource "aws_iam_instance_profile" "k3s_vm" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_secrets_manager_role.name
}
