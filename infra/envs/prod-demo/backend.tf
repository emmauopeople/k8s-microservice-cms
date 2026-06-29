terraform {
  backend "s3" {
    bucket  = "emmauopeople-k8s-microservice-cms-tfstate-prod-demo"
    key     = "prod-demo/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # Modern S3 native state locking.
    use_lockfile = true

    # DynamoDB locking is deprecated in newer Terraform versions,
    # but included here because this project intentionally demonstrates
    # the classic S3 + DynamoDB backend pattern.
    dynamodb_table = "k8s-microservice-cms-terraform-locks"
  }
}
