#------------------------------------------------------------------------------
# ECS Task Definition
#------------------------------------------------------------------------------
output "aws_ecs_task_definition_td_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = aws_ecs_task_definition.td.arn
}

output "aws_ecs_task_definition_td_family" {
  description = "The family of the Task Definition."
  value       = aws_ecs_task_definition.td.family
}

output "aws_ecs_task_definition_td_revision" {
  description = "The revision of the task in a particular family."
  value       = aws_ecs_task_definition.td.revision
}
output "container_name" {
  description = "Name of the container"
  value       = var.container_name
}

output "name_prefix" {
  description = "Name of the container"
  value       = var.name_prefix
}
