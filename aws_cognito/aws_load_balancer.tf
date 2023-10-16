resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all inbound trafic"
  vpc_id = var.vpc_id

  ingress {
    description = "https"
    from_port = 443
    to_port = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

resource "aws_lb" "kinetix" {
  name = "kinetix-lb-tf"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_all.id]
  subnets            = var.kinetix_subnets["dmz_vpc_subnets_new"]
  }
  
  resource "aws_lb_target_group" "kinetix" {
    deregistration_delay = "300"
    health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    matcher             = "200"
    path                = "/ping/kinetix_frontend"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    unhealthy_threshold = "3"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "kinetix-target-group-st"
  port                          = "80"
  protocol                      = "HTTP"
  protocol_version              = "HTTP1.1"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400"
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = "vpc-c02371a4"
}

resource "aws_lb_target_group_attachment" "target_group_attachment_staging" {
  target_group_arn = aws_lb_target_group.kinetix.arn
  target_id        = ""
}

resource "aws_lb_listener" "kinetix-listener" {
  load_balancer_arn = aws_lb.kinetix.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.certificate.arn

  lifecycle {
    create_before_destroy = true
  }

  default_action {
    type = "authenticate-cognito"

    authenticate_cognito {
      user_pool_arn       = aws_cognito_user_pool.kinetix-okta-user-pool.arn
      user_pool_client_id = aws_cognito_user_pool_client.client.id
      user_pool_domain    = aws_cognito_user_pool_domain.domain.domain
    }
  }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kinetix.arn
  }
}
  
 
