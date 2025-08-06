variable "efs_id" {}

resource "aws_ecs_task_definition" "prometheus_yace" {
  family                   = "prometheus-yace"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:latest"
      essential = true
      portMappings = [{
        containerPort = 9090
      }]
      mountPoints = [{
        sourceVolume  = "prometheus-config"
        containerPath = "/etc/prometheus"
      }]
    },
    {
      name      = "yace"
      image     = "ghcr.io/ivx/yet-another-cloudwatch-exporter:latest"
      essential = true
      portMappings = [{
        containerPort = 5000
      }]
      mountPoints = [{
        sourceVolume  = "yace-config"
        containerPath = "/config"
      }]
    }
  ])

  volume {
    name = "prometheus-config"
    efs_volume_configuration {
      file_system_id = var.efs_id
      root_directory = "/prometheus"
      transit_encryption = "ENABLED"
    }
  }

  volume {
    name = "yace-config"
    efs_volume_configuration {
      file_system_id = var.efs_id
      root_directory = "/yace"
      transit_encryption = "ENABLED"
    }
  }
}
