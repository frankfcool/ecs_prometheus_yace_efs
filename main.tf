module "network" {
  source = "./modules/network"
}

module "efs" {
  source = "./modules/efs"
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
}

module "ecs" {
  source = "./modules/ecs"
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  efs_id = module.efs.efs_id
}
