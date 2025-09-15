terraform {
  backend "s3" {
    bucket         = "goit-devops-lesson-5"
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
