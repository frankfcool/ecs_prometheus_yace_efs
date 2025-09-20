variable "efs_id" {}

resource "aws_ecs_task_definition" "prometheus_yace" {
  family                   = "prometheus-yace"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "prometheus"
      image     = "prom/prometheus:latest"
      essential = true
      portMappings = [{
        containerPort = 9090
      }]
      mountPoints = [
        {
          sourceVolume  = "prometheus-config"
          containerPath = "/etc/prometheus"
        },
        {
          sourceVolume  = "prometheus-data"
          containerPath = "/prometheus"
        }
      ]
      command = [
        "--config.file=/etc/prometheus/prometheus.yml",
        "--storage.tsdb.path=/prometheus",
        "--web.console.libraries=/etc/prometheus/console_libraries",
        "--web.console.templates=/etc/prometheus/consoles",
        "--storage.tsdb.retention.time=2h",
        "--storage.tsdb.retention.size=1GB",
        "--storage.tsdb.wal-compression",
        "--web.enable-lifecycle",
        "--web.enable-admin-api",
        "--web.external-url=http://localhost:9090/",
        "--web.route-prefix=/"
      ]
    },
    {
      name      = "thanos-sidecar"
      image     = "quay.io/thanos/thanos:latest"
      essential = true
      portMappings = [
        {
          containerPort = 10901
        },
        {
          containerPort = 10902
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "prometheus-data"
          containerPath = "/prometheus"
        }
      ]
      command = [
        "sidecar",
        "--tsdb.path=/prometheus",
        "--prometheus.url=http://localhost:9090",
        "--http-address=0.0.0.0:10902",
        "--grpc-address=0.0.0.0:10901",
        "--s3.config-file=/etc/thanos/s3-config.yaml"
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        }
      ]
    },
    {
      name      = "thanos-query"
      image     = "quay.io/thanos/thanos:latest"
      essential = true
      portMappings = [
        {
          containerPort = 10903
        },
        {
          containerPort = 10904
        }
      ]
      command = [
        "query",
        "--http-address=0.0.0.0:10903",
        "--grpc-address=0.0.0.0:10904",
        "--query.replica-label=replica",
        "--store=thanos-sidecar:10901",
        "--query.auto-downsampling",
        "--query.partial-response",
        "--query.max-concurrent=20",
        "--query.timeout=30s"
      ]
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
      environment = [
        {
          name  = "AWS_REGION"
          value = "us-east-1"
        }
      ]
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
    name = "prometheus-data"
    efs_volume_configuration {
      file_system_id = var.efs_id
      root_directory = "/prometheus-data"
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