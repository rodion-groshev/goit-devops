terraform {
  backend "s3" {
    bucket         = "goit-devops-lesson-5"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
