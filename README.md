# ECS Prometheus + YACE + EFS

This Terraform project sets up:
- Prometheus on ECS Fargate
- YACE (Yet-Another-Cloudwatch-Exporter) on the same ECS Task
- Shared EFS for Prometheus and YACE configuration

## Assumptions

- You already have a VPC, public/private subnets, and internet access
- You will manually upload `prometheus.yml` and `config.yml` to EFS
