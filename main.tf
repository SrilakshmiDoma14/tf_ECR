provider "aws" {
  region = "us-west-2"
}

###### AWS ECR #######
resource "aws_ecr_repository" "estl_ecr_repo" {
  name                 = var.ecr_name
  image_tag_mutability = var.mutability
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.estl_ecr_repo.name
 
  policy = jsonencode({
   rules = [{
     rulePriority = 1
     action       = {
       type = "expire"
     }
     selection     = {
       tagStatus   = "any"
       countType   = "imageCountMoreThan"
       countNumber = 10
     }
   }]
  })
}

###### AWS ECS Fargate #######
resource "aws_ecs_cluster" "estl_ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "estl_ecs_cluster_provider" {
  cluster_name = aws_ecs_cluster.estl_ecs_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
  depends_on = [aws_ecs_cluster.estl_ecs_cluster]
}

#### AWS ECS task definition ########
resource "aws_ecs_task_definition" "estl_ecs_task" {
  family = var.task_name
  requires_compatibilities = ["FARGATE"]
  network_mode = var.network_mode
  cpu = 1024
  memory = 2048
  execution_role_arn = var.role_arn
  container_definitions = "${file("/Users/sri/Desktop/EST/Terraform/ft.json")}"
  depends_on = [aws_ecs_cluster.estl_ecs_cluster]
}

###### AWS ECS Service #########
resource "aws_ecs_service" "estl_ecs_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.estl_ecs_cluster.name
  task_definition = aws_ecs_task_definition.estl_ecs_task.arn
  desired_count   = 2
  launch_type     = var.launch_type

  load_balancer {
    target_group_arn = aws_lb_target_group.tf_ft_tg.arn 
    container_name   = var.ecs_container_name
    container_port   = var.port
  }

  network_configuration {
    security_groups  = var.service_sg_id
    subnets          = var.subnet_id
    assign_public_ip = true
  }
  depends_on = [aws_ecs_task_definition.estl_ecs_task,aws_lb_target_group.tf_ft_tg]
}

######## AWS ALB #########
resource "aws_lb" "tf_ft_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_alb_sg.id]
  subnets            = var.subnet_id

  enable_deletion_protection = false
  depends_on = [aws_security_group.tf_alb_sg]
}

####### AWS Target Group #######
resource "aws_lb_target_group" "tf_ft_tg" {
  name        = var.tg_name
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

###### AWS Listeners ##########
resource "aws_lb_listener" "tf_alb_listeners" {
  load_balancer_arn = aws_lb.tf_ft_alb.arn
  port              = var.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_ft_tg.arn
  }
  depends_on = [aws_lb.tf_ft_alb,aws_lb_target_group.tf_ft_tg]
}


######## AWS Security Group ########
resource "aws_security_group" "tf_alb_sg" {
  name = "tfFoodTruckALBsg"
  ingress {
    from_port        = var.port
    to_port          = var.port
    protocol         = "tcp"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
  }
  tags = {
    Name = "tfFoodTruckALBsg"
  }
}