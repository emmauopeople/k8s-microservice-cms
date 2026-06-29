module "ecr" {
  source = "../../modules/ecr"

  repository_names = [
    "church-auth-service",
    "church-core-service",
    "church-document-core-service",
    "church-frontend"
  ]

  image_tag_mutability           = "IMMUTABLE"
  scan_on_push                   = true
  untagged_image_expiration_days = 7
  max_tagged_images              = 30
}
