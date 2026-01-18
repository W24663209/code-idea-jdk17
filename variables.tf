variable "cpu_cores" {
  type        = number
  default     = 8
  description = "CPU cores for the workspace container."
}

variable "memory_gb" {
  type        = number
  default     = 16
  description = "Memory in GB for the workspace container."
}
