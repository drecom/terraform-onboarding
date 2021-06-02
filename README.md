# What's Terraform
[Terraform](https://www.terraform.io/)は、[HashiCorp社](https://www.hashicorp.com/)によって、オープン化されたIaC(infrastructure as code)ツールである。  
[DevOps Roadmap](https://roadmap.sh/devops)でもInfrastructure Provisioningの推奨ツールとして掲載されており、ITインフラエンジニア、DevOpsエンジニア、SREなどの職種に従事される方にぴったりのツールである。  

# 説明
- [ドリコム](https://drecom.co.jp/)社内で利用する新米SREのためのレクチャー用コンテンツを元に、オープン可能の状態にした物
- ハンズオン経由でterraformの使い方、動きを肌感覚で取り入れるための練習用リポジトリー
- ドリコム式のterraform利用方法が含まれており、あくまでもドリコム色の書き方や利用方法であることを予めご了承ください


# 対象者
Terraform初心者

# 必要アイテム
- Terminalアプリ(iTerm2やwsl2など)
- AWSアカウント
- ブラウザ(AWSコンソールログイン用)
- [Terraform(0.12+)](https://www.terraform.io/downloads.html)
  - ここで0.14.7バージョンを利用してるが、適宜に変更していただくことが可能

# 使い方
- AWSクレデンシャルの設置
  - aws_access_key = ""
  - aws_secret_key = ""
```
$ mv terraform.tfvars.example terraform.tfvars

# 実際のAWS認証情報を入れる
$ vi terraform.tfvars
```

- [ドリコム](https://drecom.co.jp/)では、各環境(staging, productionなど)のリソースを相互に影響されないようにするため、[terraform workspace](https://www.terraform.io/docs/language/state/workspaces.html)機能を利用し、各環境のリソース隔離を実施
- まずIAMなどの各環境の共通リソースを作るためのworkspace commonにて、plan&applyを体験していただく
- 次に、vpc,subnet,route-tableなどの通信を司るリソースを作るために、workspace systemにて、plan&applyを体験していただく
- 最後、EC2やElasticache, RDSなどのメインディッシュをstaging環境に作るためのworkspace stagingにて、plan&applyを体験していただく
    - 初期のファイルで加え、自由に.tfファイルを追加してもらって、terraformの機能を体験していただく
    - issueベースに実現したい機能をディスカッションし、applyできるまでcommitを模索していただく
- production環境を作る予定がないため、workspace productionは割愛させていただきます
- 一通り触れて頂いたら、無駄なコストを発生させないため、リソースの掃除をお忘れなく


# ハンズオン
ここではローカル環境にtfstateファイルを保存されてるように見受けられるが、  
実際社内で使われてる時、plan & applyのステップは全部CI(Gitlab-CI)に任せて、tfstateファイルも管理されてるが、公開するといろいろまずいので、ここでは割愛させていただきます。  

## 1)共通系のリソース構築
```
$ git pull
# 各varsが基本的に下記ファイルに定義されており、まず一通り目を通して頂いて、適宜に編集してください
$ vi variables.tf

$ export AWS_ACCESS_KEY_ID="<ご自分のアカウント情報>"
$ export AWS_SECRET_ACCESS_KEY="<ご自分のアカウント情報>"
$ terraform init
$ terraform workspace select common
$ terraform plan
$ terraform apply
```

## 2)システム系のリソース構築
```
$ terraform init
$ terraform workspace select system
$ chmod +x update_lambda_bucket.sh
$ ./update_lambda_bucket.sh
$ terraform plan
$ terraform apply
```

## 3)Staging環境構築
```
$ terraform init
$ terraform workspace select staging
$ terraform plan
$ terraform apply
```

## 利用後はちゃんとお掃除
```
$ terraform workspace select staging
$ terraform destroy
$ terraform workspace select system
$ terraform destroy
$ terraform workspace select common
$ terraform destroy
```

# Tips
- 社内で使われてるterraformバージョンは同一されてないため、各バージョンの切り替えが結構あります。そのため、仮想バージョン管理ツールを利用することをおすすめします。  
例) 
- [asdf](https://asdf-vm.com/)
- [anyenv](https://anyenv.github.io/)
- etc.
