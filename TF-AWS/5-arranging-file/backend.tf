terraform {
  backend "s3" {
    bucket       = "mirecloud-bucket"
    key          = "pdev.terraform.tfstate"
    region       = "us-east-1"
    encrypt      = false
    use_lockfile = true
  }
}
