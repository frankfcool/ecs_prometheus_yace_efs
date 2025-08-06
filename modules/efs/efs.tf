variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}

resource "aws_efs_file_system" "this" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  throughput_mode = "bursting"
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  vpc_id      = var.vpc_id
  description = "Allow NFS access"

  ingress {
    from_port   = 2049
    to_port     = 2049
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

resource "aws_efs_mount_target" "this" {
  count          = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.efs_sg.id]
}

output "efs_id" {
  value = aws_efs_file_system.this.id
}
