# What's Terraform
[Terraform](https://www.terraform.io/)は、[HashiCorp社](https://www.hashicorp.com/)によって、オープン化されたIaC(infrastructure as code)ツールです。  
[DevOps Roadmap](https://roadmap.sh/devops)でもInfrastructure Provisioningの推奨ツールとして掲載されており、ITインフラエンジニア、DevOpsエンジニア、SREなどの職種に従事される方にぴったりのツールです。

# 説明
- [ドリコム](https://drecom.co.jp/)社内で利用する新米SREのためのレクチャー用コンテンツを元に、オープン可能の状態にした物
- ハンズオン経由でterraformの使い方、動きを肌感覚で取り入れるための練習用リポジトリ
- ドリコム式のterraform利用方法が含まれており、あくまでもドリコム色の書き方や利用方法であることを予めご了承ください
- 利用されるAWSリソース:
  - IAM
  - S3
  - Api-gateway
  - Lambda function
  - ECR
  - App Runner


# 対象者
- Terraform初心者
- 新米DevOps engineer
- 新米SRE

# 必要アイテム
- Terminalアプリ(iTerm2やwsl2など)
- [curl](https://formulae.brew.sh/formula/curl)
- AWSアカウント
- ブラウザ(AWSコンソールログイン用)
- [Terraform(0.12+)](https://www.terraform.io/downloads.html)
  - ここで1.0.0バージョンを利用してるが、適宜に変更していただくことが可能
- [docker](https://docs.docker.com/get-docker/)

# 使い方
- AWSクレデンシャルの設置
  - service_account_id = ""
  - aws_access_key = ""
  - aws_secret_key = ""
  - region = "ap-northeast-1"
```
$ mv terraform.tfvars.example terraform.tfvars

# 実際のAWS認証情報を入れる
$ vi terraform.tfvars
```

- [ドリコム](https://drecom.co.jp/)では、各環境(staging, productionなど)のリソースを相互に影響されないようにするため、[terraform workspace](https://www.terraform.io/docs/language/state/workspaces.html)機能を利用し、各環境のリソース隔離を実施
- まずIAM, s3 bucketなどの各環境の共通リソースを作るためのworkspace commonにて、plan&applyを体験していただく
- 次に、lambda-function, api-gateway, ecrなどの通信を司るリソースを作るために、workspace systemにて、plan&applyを体験していただく
- 最後、apprunnerなどのメインディッシュをproduction環境に作るためのworkspace productionにて、plan&applyを体験していただく
    - 初期のファイルで加え、自由に.tfファイルを追加してもらって、terraformの機能を体験していただく
    - issueベースに実現したい機能をディスカッションし、applyできるまでcommitを模索していただく
- __一通り触れて頂いたら、無駄なコストを発生させないため、リソースの掃除をお忘れなく__ :)


# Workshop
ここではローカル環境にtfstateファイルを保存されてるように見受けられるが、  
実際社内で使われてる時、plan & applyのステップは全部CI(ドリコムの場合はGitlab-CI)に任せて、tfstateファイルも管理されてるが、公開するといろいろまずいのでここでは割愛させていただきます

## 1)共通系のリソース構築
```
$ git clone git@github.com:drecom/terraform-onboarding.git
$ cd terraform-onboarding
$ mv terraform.tfvars.example terraform.tfvars
# 実際のAWS認証情報を入れる
$ vi terraform.tfvars
# 各varsが基本的に下記ファイルに定義されており、まず一通り目を通して頂いて、適宜に編集してください
$ vi variables.tf
$ terraform init
# show all existing workspaces
$ terraform workspace list
$ terraform workspace select common
$ terraform plan
$ terraform apply
```

## 2)システム系のリソース構築
### 2-1)lambda functionをS3のバケットにアップロード
[drecom/demo-box](https://github.com/drecom/demo-box)のリポジトリをcloneし、READMEを参考に実行してください

### 2-2)リソース構築
```
$ terraform init
$ terraform workspace select system
$ terraform plan
$ terraform apply
```

### 2-2)lambda functionにhello
```
# on workspace system
$ terraform output | grep deployment-invoke-url | awk '{print $3}' | xargs curl
{"drecom": "with entertainment <TIME_NOW+0900>"}
```

## 3)Production環境構築
### 3-1) Push application image to AWS ECR
[sample-app](https://github.com/drecom/demo-box/tree/main/sample-app)のREADMEを参考に、イメージをpushしてください

### 3-2) リソース構築
```
$ terraform workspace select production
$ terraform plan
# 数分かかります...
$ terraform apply
```

### 3-3) ブラウザでoutputから出力されたURLにアクセス
- apprunner-url

### 3-option) Create a EC2 instance and install nginx
```
$ terraform workspace select production
# switch “production = false” to “production = true”
$ vi ec2_variables.tf
$ terraform plan
# 数分かかります...
$ terraform apply
# インスタンスの状態がhealthyになるまでしばらくお待ちを(3分程度)
# AWS consoleから確認できます
$ terraform output | grep practice-ec2-public-dns | awk '{print $3}' | xargs curl
```

## 利用後はちゃんとお掃除
```
$ terraform workspace select production
$ terraform destroy
$ terraform workspace select system
# 次のステップの前に、lambda functionの格納s3を手動でクリアする必要がある（バージョンの表示を有効にし、完全にすべてのバージョンを削除するように）
$ terraform destroy
$ terraform workspace select common
$ terraform destroy
```

# Tips
- 社内で使われてるterraformバージョンは統一されてないため、各バージョンの切り替えが結構あります。そのため、仮想バージョン管理ツールを利用することをおすすめします。  
例) 
  - [asdf](https://asdf-vm.com/)
  - [anyenv](https://anyenv.github.io/)
  - etc.
