# ═══════════════════════════════════════════════════════════
#  ECR_ECS.TF — ECR Repositories + ECS Cluster & Services
#
#  Separated from main.tf intentionally.
#  Deploy order: terraform apply (main.tf first via depends),
#  then image_tag passed by CI/CD pipeline.
# ═══════════════════════════════════════════════════════════

provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
}

# ── ECR Repositories ─────────────────────────────────────────
module "ecr" {
  source = "./modules/ecr"

  aws_account_id = var.aws_account_id

  providers = {
    aws        = aws
    aws.oregon = aws.oregon
  }
}

# ── ECS Cluster & Services ───────────────────────────────────
module "ecs" {
  source = "./modules/ecs"

  aws_account_id        = var.aws_account_id
  aws_region            = var.aws_region
  image_tag             = var.image_tag
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security.sg_ecs_id
  tg_fe_arn             = module.alb.tg_fe_arn
  tg_api_arn            = module.alb.tg_api_arn
  alb_dns_name          = module.alb.alb_dns_name
  db_host               = module.database.rds_endpoint
  db_password           = var.db_password
  sqs_queue_url         = module.database.sqs_queue_url
  dynamodb_table        = module.database.dynamodb_table_name
}
