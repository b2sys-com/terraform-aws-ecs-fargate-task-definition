variable "fargate_cluster_name" {
  description = "ECS Fargate Cluster Name"
  type        = string
}

variable "family" {
  description = "(Required) A unique name for your task definition."
  type        = string
}

variable "region" {
  description = "AWS Region the infrastructure is hosted in"
  type        = string
  default     = "us-east-1"
}

variable "task_cpu" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The number of cpu units to reserve for the Task. This is optional for tasks using Fargate launch type and the total amount of container_cpu of all containers in a task will need to be lower than this task-level cpu value"
  type        = number
  default     = 2048 # 2 vCPU
}

variable "task_memory" {
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs
  description = "(Optional) The amount of memory (in MiB) to allow the container to use. This is a hard limit, if the container attempts to exceed the container_memory, the container is killed. This field is optional for Fargate launch type and the total amount of container_memory of all containers in a task will need to be lower than the task memory value"
  type        = number
  default     = 4096 # 4 GB
}

# AWS ECS Task Definition Variables
variable "placement_constraints" {
  description = "(Optional) A set of placement constraints rules that are taken into consideration during task placement. Maximum number of placement_constraints is 10. This is a list of maps, where each map should contain \"type\" and \"expression\""
  type        = list(any)
  default     = []
}

variable "proxy_configuration" {
  description = "(Optional) The proxy configuration details for the App Mesh proxy. This is a list of maps, where each map should contain \"container_name\", \"properties\" and \"type\""
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "Map of tags"
  type        = map(any)
  default     = {}
}

variable "containers_to_run" {
  description = "List of container to run"
  type        = string
}

variable "containers_into_task" {
  description = "Number of container into the Fargate Task"
  type        = number
  default     = 1
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
  type        = number
  default     = 7
}

variable "efs_id" {
  type        = string
  description = "The EFS id to mount in the task definition"
  default     = null
}

variable "enable_execute_command" {
  description = "(Optional) Specifies whether to enable Amazon ECS Exec for the tasks within the service. Default: false"
  default     = false
  type        = bool
}