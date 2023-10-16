resource "aws_secretsmanager_secret" "secret" {
  name = "alb-auth-okta-secret"
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = ""

  lifecycle {
    ignore_changes = [secret_string]
  }
}

data "aws_secretsmanager_secret" "secrets" {
  arn = aws_secretsmanager_secret.secret.arn
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id

}
