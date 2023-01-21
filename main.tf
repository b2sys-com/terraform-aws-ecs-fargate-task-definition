locals {
  containers_logs_group = jsondecode(var.containers_to_run)
}

# AWS ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.fargate_cluster_name}-ecs-task-execution-role-${substr(uuid(), 0, 3)}"
  assume_role_policy = file("${path.module}/policies/iam/ecs_task_execution_iam_role.json")
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# AWS ECS Task Execution Command
resource "aws_iam_role" "ecs_execute_command_role" {
  count              = var.enable_execute_command ? 1 : 0
  name               = "${var.fargate_cluster_name}-ecs-execute-command-role-${substr(uuid(), 0, 3)}"
  assume_role_policy = file("${path.module}/policies/ssm/ecs_execute_command.json")
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execute_command_role_policy_attach" {
  count      = var.enable_execute_command ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  depends_on = [aws_iam_role.ecs_execute_command_role]
}

# Task Definition
resource "aws_ecs_task_definition" "td" {
  family                = var.family
  container_definitions = var.containers_to_run
  task_role_arn         = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  network_mode          = "awsvpc"
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = placement_constraints.value.type
    }
  }
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  requires_compatibilities = ["FARGATE"]
  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration
    content {
      container_name = var.family
      properties     = lookup(proxy_configuration.value, "properties", null)
      type           = lookup(proxy_configuration.value, "type", null)
    }
  }

  dynamic "volume" {
    for_each = var.efs_id != null ? list([0]) : []
    content {
      name = "pts-volume"
      efs_volume_configuration {
        file_system_id = var.efs_id
        root_directory = "/"
      }
    }
  }

}

resource "aws_cloudwatch_log_group" "cw_container_log" {
  count             = var.containers_into_task
  name              = "/ecs/${lookup(element(local.containers_logs_group, count.index), "name", null)}"
  retention_in_days = var.retention_in_days
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
  depends_on = [aws_ecs_task_definition.td, local.containers_logs_group, var.containers_to_run]
}
