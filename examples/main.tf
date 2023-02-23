terraform {
  backend "s3" {
    profile = "agrilution_dev"
    bucket  = "tf-state-for-dev-agr-mvf"
    key     = "appsync/staging/terraform.tfstate"
    region  = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "agrilution_dev"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}



module "appsync" {
  # source = "git@gitlab.com:backend267/infrastructure/terraform-modules/appsync-module.git"
  source = "../"

  api_name = "sample-appsync-api"

  schema_directory = "./objects"
  resolver_path = "./resolvers"
  domain_name_association_enabled = true
  caching_enabled                 = true

  domain_name             = "api.agrilution_dev.com"
  domain_name_description = "My awesome AppSync Domain"
  # certificate_arn         = "acm_certificate_arn"

  caching_behavior                 = "PER_RESOLVER_CACHING"
  cache_type                       = "SMALL"
  cache_ttl                        = 60
  cache_at_rest_encryption_enabled = true
  cache_transit_encryption_enabled = true

  api_keys = {
    future  = "2021-08-20T15:00:00Z"
    default = null
  }

  authentication_type = "AMAZON_COGNITO_USER_POOLS"
  user_pool_config = {
    aws_region     = "eu-central-1"
    default_action = "DENY"
    user_pool_id   = "eu-central-1_GAtMVeLwu"
  }

  # lambda_authorizer_config = {
  #   authorizer_uri = "arn:aws:lambda:eu-west-1:835367859851:function:appsync_auth_1"
  # }

  # openid_connect_config = {
  #   issuer    = "https://www.issuer1.com/"
  #   client_id = "client_id1"
  #   auth_ttl  = 100
  #   iat_ttl   = 200
  # }

  # additional_authentication_provider = {
  #   iam = {
  #     authentication_type = "AWS_IAM"
  #   }
  #   openid_connect_2 = {
  #     authentication_type = "OPENID_CONNECT"

  #     openid_connect_config = {
  #       issuer    = "https://www.issuer2.com/"
  #       client_id = "client_id2"
  #     }
  #   }

  #   my_user_pool = {
  #     authentication_type = "AMAZON_COGNITO_USER_POOLS"

  #     user_pool_config = {
  #       user_pool_id        = "eu-central-1_GAtMVeLwu"
  #       # app_id_client_regex = aws_cognito_user_pool_client.this.id
  #     }
  #   }
  # }

  datasources = {
    # registry_terraform_io = {
    #   type        = "HTTP"
    #   endpoint    = "https://registry.terraform.io"
    #   description = ""
    # }
    # None = {
    #   type = "NONE"
    # }

    # lambda1 = {
    #   type         = "AWS_LAMBDA"
    #   function_arn = "arn:aws:lambda:eu-west-1:*******:function:index_1"
    #   description  = ""
    # }

    # lambda2 = {
    #   type         = "AWS_LAMBDA"
    #   function_arn = "arn:aws:lambda:eu-west-1:*******:function:index_2"
    #   description  = ""
    #   service_role_arn = "arn:aws:iam::*******:role/lambda1-service"
    # }
    change_management_table = {
      type        = "AMAZON_DYNAMODB"
      table_name  = "change_management_internal"
      region      = "eu-central-1"
      description = ""
    }

    # Elasticsearch support has not been finished & tested
    # elasticsearch1 = {
    #   type        = "AMAZON_ELASTICSEARCH"
    #   endpoint    = "https://search-my-domain.eu-central-1.es.amazonaws.com"
    #   region      = "eu-central-1"
    #   description = ""
    # }
  }
}