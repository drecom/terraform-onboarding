#
# Account
#
locals {
  # 実行するアカウント(キーの取り違えによる事故防止のため自動取得はしない)
  # 必ずダブルコーテーションで囲むこと
  service_account_id = "380705665641"

  # 展開するサービス名
  service_name = "base"

  # サービスのリージョン
  region = "ap-northeast-1"

  # グローバルリージョン
  region_global = "us-east-1"

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

locals {
  hostname_suffix = local.env == "production" ? "" : format("-%s", local.env)
}

#
# VPC
#
locals {
  # サービスの仮想CIDR範囲。実体はなく、vpc, subnet の計算に利用
  service_cidr = "10.1.1.0/18"

  # 各環境毎のVPCのCIDR
  # service_cidr の /XY に newbits を足した分割で、netnum 番目を範囲とします
  # common は配列処理上の問題で形式上だけの記述です
  vpc_cidr_split = {
    common = {
      "newbits" = 0
      "netnum"  = 0
    }
    production = {
      "newbits" = 1
      "netnum"  = 0
    }
    staging = {
      "newbits" = 4
      "netnum"  = 8
    }
    system = {
      "newbits" = 4
      "netnum"  = 15
    }
  }

  # 各環境毎のSubnetのCIDR
  # service_cidr の /XY に netbits を足した分割で、
  # start_netnum 番目を起点とし、aznum 個のAZに public + private の 2つずつ作成します
  # common は配列処理上の問題で形式上だけの記述です
  subnet_cidr_split = {
    common = {
      "newbits"      = 0
      "start_netnum" = 0
      "aznum"        = 0
    }
    production = {
      "newbits"      = 4
      "start_netnum" = 0
      "aznum"        = 3
    }
    staging = {
      "newbits"      = 7
      "start_netnum" = 64
      "aznum"        = 3
    }
    system = {
      "newbits"      = 6
      "start_netnum" = 60
      "aznum"        = 2
    }
  }
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

#
# Key
#
locals {
  key_pairs_name   = "drecom_key"
}

#
# Code
#
locals {
  s3_bucket_code_artifact = "${local.service_name}-code-artifact"
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "key_pairs_public_key" {
}