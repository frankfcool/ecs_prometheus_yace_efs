data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "private_subnet_ids" {
  value = data.aws_subnets.private.ids
}
