locals {
  instances = {
    bastion = {
      ami                    = "ami-09f67f6dc966a7829"
      instance_type          = "t2.micro"
      vpc_security_group_ids = [aws_security_group.bastion_sg.id]
      user_data              = local.bastion_user_data
    }, 
    redis = {
      ami                    = "ami-09f67f6dc966a7829"
      instance_type          = "t2.small"
      vpc_security_group_ids = [aws_security_group.redis_sg.id]
      user_data              = local.redis_user_data
    },
    cicd = {
      ami                    = "ami-0f8e81a3da6e2510a"
      instance_type          = "t2.micro"
      vpc_security_group_ids = [aws_security_group.cicd_sg.id]
      user_data              = local.cicd_user_data
    }
  }
}

locals {
  groups = {
      frontend = {
          vpc_security_group_ids = [module.security_group["frontend"].sg_id],
          user_data = local.frontend_user_data
      },
      users = {
          vpc_security_group_ids = [module.security_group["users"].sg_id],
          user_data = local.users_user_data
      },
      todos = {
          vpc_security_group_ids = [module.security_group["todos"].sg_id],
          user_data = local.todos_user_data
      },
      auth = {
          vpc_security_group_ids = [module.security_group["auth"].sg_id],
          user_data = local.auth_user_data
      },
      lmp = {
          vpc_security_group_ids = [module.security_group["lmp"].sg_id],
          user_data = local.lmp_user_data
      },
      zipkin = {
          vpc_security_group_ids = [module.security_group["zipkin"].sg_id],
          user_data = local.zipkin_user_data
      }
  }
    
  redis_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 6379:6379 redis:alpine
    EOF

  bastion_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    touch test
    EOF

  frontend_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 80:80 -p 443:80 -e PORT=80 \
    -e AUTH_API_ADDRESS=http://${module.alb.lb_dns_name}:8000 -e TODOS_API_ADDRESS=http://${module.alb.lb_dns_name}:8082 \
    -e http://ZIPKIN_URL=${module.alb.lb_dns_name}:9411/api/v2/spans mvot/frontend-app:${var.docker_tag}
    EOF

  auth_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 8000:8000 -e JWT_SECRET=PRFT \
    -e AUTH_API_PORT=8000 -e USERS_API_ADDRESS=http://${module.alb.lb_dns_name}:8083 mvot/auth-app:${var.docker_tag}
    EOF

  lmp_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 9001:9001 -e REDIS_HOST=http://${module.alb.lb_dns_name} -e REDIS_PORT=6379 \
    -e REDIS_CHANNEL=log_channel mvot/lmp-app:${var.docker_tag}
    EOF

  todos_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sleep 60
    sudo docker run --rm -dp 8082:8082 -e JWT_SECRET=PRFT -e TODO_API_PORT=8082 \
    -e REDIS_HOST=${module.ec2_instance["redis"].private_ip} -e REDIS_PORT=6379 -e REDIS_CHANNEL=log_channel \
    -e ZIPKIN_URL=http://${module.alb.lb_dns_name}:9411/api/v2/spans mvot/todos-app:${var.docker_tag}
    EOF

  users_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 8083:8083 -e JWT_SECRET=PRFT -e SERVER_PORT=8083 mvot/users-app:${var.docker_tag}
    EOF

  zipkin_user_data = <<-EOF
    #!/bin/bash
    cd ~
    sudo yum update -y
    sudo yum install -y docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run --rm -dp 9411:9411 openzipkin/zipkin
    EOF

  cicd_user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install ca-certificates curl gnupg -y
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    EOF
}
