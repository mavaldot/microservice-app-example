module "auto_scaling_groups" {
    source = "./asg-module"
    for_each = local.groups

    name = each.key
    key_name = aws_key_pair.rsa_key.key_name
    vpc_security_group_ids = each.value.vpc_security_group_ids

    vpc_zone_identifier = [var.private_subnet_1, var.private_subnet_2]

    user_data = each.value.user_data
}