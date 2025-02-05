locals {
  azs = data.aws_availability_zones.available.names
}

# VPC

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "mtc-ecs"
  }
}

resource "aws_internet_gateway" "this" {

  tags = {
    Name = "mtc-ecs"
  }
}

resource "aws_internet_gateway_attachment" "this" {
  internet_gateway_id = aws_internet_gateway.this.id
  vpc_id              = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "mtc-ecs"
  }
}

resource "aws_route" "this" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "this" {
  for_each          = { for i in range(var.num_subnets) : "public${i}" => i }
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 8, each.value)
  availability_zone = local.azs[each.value % length(local.azs)]
  tags = {
    Name = "mtc-ecs-${each.key}"
  }
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.this
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this.id
}

resource "aws_lb" "this" {
  name               = "mtc-ecs-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [for subnet in aws_subnet.this : subnet.id]
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "I'm working, but the tasks aren't"
      status_code  = "503"
    }
  }
}

resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "mtc-ecs-alb"
  }
}