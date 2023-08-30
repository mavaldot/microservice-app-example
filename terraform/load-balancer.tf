module "alb" {
    source = "terraform-aws-modules/alb/aws"
    version = "~> 8.0"

    name = "my-alb"

    load_balancer_type = "application"

    vpc_id = var.my_vpc
    subnets = [var.public_subnet_1, var.public_subnet_2]
    security_groups = [aws_security_group.alb_sg.id]

    tags = {
        project = var.project
        responsible = var.responsible
    }
}

resource "aws_lb_listener" "listener" {
    for_each = var.service_map

    load_balancer_arn = module.alb.lb_arn
    port = each.value.port
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_group[each.key].arn
    }
}

resource "aws_lb_target_group" "target_group" {
    for_each = var.service_map
    name = "alb-${each.key}-group"
    port = each.value.port
    protocol = "HTTP"
    vpc_id = var.my_vpc
}

resource "aws_autoscaling_attachment" "attachment" {
    for_each = var.service_map
    autoscaling_group_name = module.auto_scaling_groups[each.key].asg_id
    lb_target_group_arn = aws_lb_target_group.target_group[each.key].arn
}

resource "aws_lb_listener_rule" "path_routing_login" {
    listener_arn = aws_lb_listener.listener["frontend"].arn
    priority = 1

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_group["auth"].arn
    }

    condition {
        path_pattern {
            values = ["*/login"]
        }
    }
}

resource "aws_lb_listener_rule" "path_routing_todos" {
    listener_arn = aws_lb_listener.listener["frontend"].arn
    priority = 2

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_group["todos"].arn
    }

    condition {
        path_pattern {
            values = ["*/todos*"]
        }
    }
}