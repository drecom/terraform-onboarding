# i18n
[日本語版はこちらになります](./README_JP.md)
# What's Terraform
[Terraform](https://www.terraform.io/) is an IaC(infrastructure as code) software tool, which created by [HashiCorp](https://www.hashicorp.com/).  
Listed as a recommended tool for Infrastructure Provisioning at [DevOps Roadmap](https://roadmap.sh/devops),   
[Terraform](https://www.terraform.io/) is a perfect tool for those engaged in occupations such as IT infrastructure engineers, DevOps engineers, and SREs.  

# Getting Started
- Based on the content for help junior SREs onboarding used in-house. -> [Drecom](https://drecom.co.jp/)
- A practice repository for using terraform via hands-on to show you how terraform working and what's Drecom-style.
- Please note that the Drecom-style terraform usage method is included, these may not be a best practice but we use them for our daily job.
- AWS Resources used
  - IAM
  - S3
  - Api-gateway
  - Lambda function
  - ECR
  - App Runner


# Who might be interested
- Terraform beginners
- Junior DevOps engineers
- Junior SREs
- etc.

# Prerequisite
- Terminal application(e.g. iTerm2, wsl2)
- [curl](https://formulae.brew.sh/formula/curl)
- AWS account(with access key & secret access key)
- A modern browser
- [Terraform(0.12+)](https://www.terraform.io/downloads.html)
  - we use Ver. 0.14.7 here
- [docker](https://docs.docker.com/get-docker/)

# Usage
- Set your AWS Credentials into a example file
  - service_account_id = ""
  - aws_access_key = ""
  - aws_secret_key = ""
  - region = "ap-northeast-1"
```
$ mv terraform.tfvars.example terraform.tfvars
$ vi terraform.tfvars
```

- To prevent the resources of each environment (staging, production, etc.) from being influenced by each other, [Drecom](https://drecom.co.jp/) use [terraform workspace](https://www.terraform.io/docs/language/state/workspaces.html) to get it done.
- Firstly, make a workspace called 'common' to build IAM, S3 bucket resources to your AWS env, via terraform plan & apply
- Secondly, make a workspace called 'system' to build lambda-function, api-gateway, ecr resources to your AWS env, via terraform plan & apply
- Finally, make a workspace called 'production' to build app-runner resources to your AWS env, via terraform plan & apply
    - Be free to add other .tf files to see how to build others resources.
    - Discussion with your partner based on issues, and see what you can do togerther.
- __Don't forget to clear up after workshop, or AWS will send you a surprise bill__ :)


# Hands-on
You may found the tfstate files are stored here in the local environment,  
but the truth is we do all that stuff via CI tool(gitlab-ci, in our case),   
since it has some sensitive information that not suitable to be published, so let's do it locally here. 

## 1)Build common resources
```
$ git clone
# Several variables are defined by variables.tf   
# Before running other command, you may take a look at it.  
$ vi variables.tf
$ terraform init
$ terraform workspace select common
$ terraform plan
$ terraform apply
```

## 2)Build system resources
### 2-1)Upload lambda function to S3 bucket
See [Toolbox](https://git.drecom.jp/infrastructure/tool-aws-oss)'s README for more details.

### 2-2)Build resources
```
$ terraform workspace select system
$ terraform plan
$ terraform apply
```

### 2-3)Say hello to lambda function
```
$ terraform output | grep deployment_invoke_url | awk '{print $3}' | xargs curl
{"drecom": "with entertainment <TIME_NOW+0900>"}
```

## 3)Build production resources
### 3-1) Push application image to AWS ECR
See [sample-app](https://git.drecom.jp/infrastructure/tool-aws-oss/sample-app/go)'s README for more details.

### 3-2) Build resources
```
$ terraform workspace select production
$ terraform plan
# It usually takes several minutes
$ terraform apply
```

### 3-3) Access the output's URL to see application
- app_runner_url
## Don't forget to clear up after workshop
```
$ terraform workspace select production
$ terraform destroy
$ terraform workspace select system
# Before you do next step, make sure you delete s3 bucket's all objects(which means all versions)
$ terraform destroy
$ terraform workspace select common
$ terraform destroy
```

# Tips
- We use some runtime manager to help us handling different versions of terraform. (e.g.
  - [asdf](https://asdf-vm.com/)
  - [anyenv](https://anyenv.github.io/)
  - etc.
