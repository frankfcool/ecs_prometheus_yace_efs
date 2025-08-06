output "efs_id" {
  value = module.efs.efs_id
}

output "prometheus_service_url" {
  value = module.ecs.prometheus_service_url
}
