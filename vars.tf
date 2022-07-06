# AWS ECR variables
variable "ecr_name" {
    type = string
}

variable "mutability" {
    type = string
}

variable "ecs_cluster_name" {
    type = string
}

variable "task_name" {
    type = string
}

variable "ecs_container_name" {
    type = string
}

variable "port" {
    type = number
}

variable "service_name" {
    type = string
}
/*
variable "target_group_arn" {
    type = string
}
*/
variable "service_sg_id" {
    default = ["sg-0065020001359c317"]
}

variable "subnet_id" {
    type = list(string)
}

variable "launch_type" {
    default     = "FARGATE"
}

variable "role_arn" { 
    default = "arn:aws:iam::270354559873:role/ecsTaskExecutionRole"
}

variable "network_mode" {
    default = "awsvpc"
}

variable "alb_name" {
    default = "tfFoodTruckALB"
}

variable "tg_name" {
    default = "tfFoodTrucktg"
}

variable "vpc_id" {
    default = "vpc-0c7a82a5ce671f6ef"
}
/*
variable "tf_alb_sg_id" {
    type = list(string)
}
*/