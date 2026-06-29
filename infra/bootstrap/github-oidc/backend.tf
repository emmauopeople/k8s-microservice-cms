terraform {
  backend "s3" {
    bucket         = "emmauopeople-k8s-microservice-cms-tfstate-prod-demo"
    key            = "bootstrap/github-oidc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
    dynamodb_table = "k8s-microservice-cms-terraform-locks"
  }
}
