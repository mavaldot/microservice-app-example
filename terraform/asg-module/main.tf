resource "aws_launch_template" "this" {
    name = var.name
    image_id = var.image_id
    instance_type = var.instance_type
    key_name = var.key_name

    user_data = base64encode(var.user_data)
    
    vpc_security_group_ids = var.vpc_security_group_ids

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name = var.name
    }

    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = var.name
            project = var.project
            responsible = var.responsible
        }
    }

    tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.name
      project = var.project
      responsible = var.responsible
    }
  }


}

resource "aws_autoscaling_group" "this" {
    min_size = 1
    max_size = 2
    desired_capacity = 1

    launch_template {
        id = aws_launch_template.this.id
        version = "$Latest"
    }

    vpc_zone_identifier = var.vpc_zone_identifier

    tag {
        key = "project"
        value = var.project
        propagate_at_launch = true
    }

    tag {
        key = "responsible"
        value = var.project
        propagate_at_launch = true
    }
}