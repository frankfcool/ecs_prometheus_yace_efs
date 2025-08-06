variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

resource "aws_ecs_cluster" "this" {
  name = "prometheus-cluster"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "this" {
  name            = "prometheus-yace-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.prometheus_yace.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

output "prometheus_service_url" {
  value = "http://${aws_ecs_service.this.name}.ecs.${var.vpc_id}.amazonaws.com:9090"
}
