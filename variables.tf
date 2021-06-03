#
# Account
#
locals {
  # 実行するアカウント(キーの取り違えによる事故防止のため自動取得はしない)
  # 必ずダブルコーテーションで囲むこと
  service_account_id = "380705665641"

  # 展開するサービス名
  service_name = "workshop"

  # サービスのリージョン
  region = "ap-northeast-1"

  # 会社名
  company_name = "drecom"
}

#
# 環境ごとにリソースの必要性を判断するための変数
#    - common  : IAM や key_pair など共通で使うもの
#    - system  : サービス外でIAMを利用したり、サービス外VPCを利用するもの
#    - network : VPCを利用する環境
#    - service : サービス稼働に直接関係するもの
locals {
  env        = terraform.workspace
  on_common  = local.env == "common" ? true : false
  on_system  = local.env == "system" ? true : false
  on_network = local.env != "common" ? true : false
  on_service = local.env != "common" && local.env != "system" ? true : false
}

#
# Lambda
#
locals {
  lambda_bucket   = "drecom-lambda"
  lambda_key      = "lambda.zip"
  lambda_main_key = "lambda_main.zip"
  lambda_lib_key  = "lambda_lib.zip"
  lambda_runtime  = "python3.6"
}

locals {
  lambda_log_group_prefix = "/aws/lambda/"
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}
