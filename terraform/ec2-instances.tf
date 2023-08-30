module "ec2_instance" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  for_each      = local.instances
  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = var.public_subnet_1
  user_data     = each.value.user_data
  key_name      = aws_key_pair.rsa_key.key_name

  vpc_security_group_ids = each.value.vpc_security_group_ids

  tags = {
    Name        = each.key
    project     = var.project
    responsible = var.responsible
  }

  volume_tags = {
    project     = var.project
    responsible = var.responsible
  }
}