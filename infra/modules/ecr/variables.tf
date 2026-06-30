variable "repository_names" {
  description = "List of ECR repository names to create."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "Whether image tags are mutable or immutable."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push."
  type        = bool
  default     = true
}

variable "untagged_image_expiration_days" {
  description = "Number of days before untagged images expire."
  type        = number
  default     = 7
}

variable "max_tagged_images" {
  description = "Maximum number of tagged images to retain per repository."
  type        = number
  default     = 30
}
