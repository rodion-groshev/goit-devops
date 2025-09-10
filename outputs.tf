output "state_backend" {
  value = {
    bucket_name         = module.s3_backend.bucket_name
    bucket_arn          = module.s3_backend.bucket_arn
    dynamodb_table_name = module.s3_backend.dynamodb_table_name
    dynamodb_table_arn  = module.s3_backend.dynamodb_table_arn
  }
}

output "network" {
  value = {
    vpc_id              = module.vpc.vpc_id
    public_subnet_ids   = module.vpc.public_subnet_ids
    private_subnet_ids  = module.vpc.private_subnet_ids
    internet_gateway_id = module.vpc.igw_id
    nat_gateway_ids     = module.vpc.nat_gateway_ids
  }
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
