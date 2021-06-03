# What's Terraform
[Terraform](https://www.terraform.io/)は、[HashiCorp社](https://www.hashicorp.com/)によって、オープン化されたIaC(infrastructure as code)ツールである。  
[DevOps Roadmap](https://roadmap.sh/devops)でもInfrastructure Provisioningの推奨ツールとして掲載されており、ITインフラエンジニア、DevOpsエンジニア、SREなどの職種に従事される方にぴったりのツールである。  

# 説明
- [ドリコム](https://drecom.co.jp/)社内で利用する新米SREのためのレクチャー用コンテンツを元に、オープン可能の状態にした物
- ハンズオン経由でterraformの使い方、動きを肌感覚で取り入れるための練習用リポジトリー
- ドリコム式のterraform利用方法が含まれており、あくまでもドリコム色の書き方や利用方法であることを予めご了承ください


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
  - ここで0.14.7バージョンを利用してるが、適宜に変更していただくことが可能
- [docker](https://docs.docker.com/get-docker/)

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
- まずIAM, s3 bucketなどの各環境の共通リソースを作るためのworkspace commonにて、plan&applyを体験していただく
- 次に、lambda, apu-gateway, ecrなどの通信を司るリソースを作るために、workspace systemにて、plan&applyを体験していただく
- 最後、app-runnerなどのメインディッシュをproduction環境に作るためのworkspace productionにて、plan&applyを体験していただく
    - 初期のファイルで加え、自由に.tfファイルを追加してもらって、terraformの機能を体験していただく
    - issueベースに実現したい機能をディスカッションし、applyできるまでcommitを模索していただく
- 一通り触れて頂いたら、無駄なコストを発生させないため、リソースの掃除をお忘れなく


# ハンズオン
ここではローカル環境にtfstateファイルを保存されてるように見受けられるが、  
実際社内で使われてる時、plan & applyのステップは全部CI(Gitlab-CI)に任せて、tfstateファイルも管理されてるが、公開するといろいろまずいので、ここでは割愛させていただきます。  

## 1)共通系のリソース構築
```
$ git pull
# 各varsが基本的に下記ファイルに定義されており、まず一通り目を通して頂いて、適宜に編集してください
$ vi variables.tf
$ terraform init
$ terraform workspace select common
$ terraform plan
$ terraform apply
```

## 2)システム系のリソース構築
### 2-1)lambda functionをS3のバケットにアップロード
[Toolbox](https://git.drecom.jp/infrastructure/tool-aws-oss)のリポジトリをcloneし、READMEを参考に実行してください。  

### 2-2)リソース構築
```
$ terraform init
$ terraform workspace select system
$ terraform plan
$ terraform apply
```

### 2-2)lambda functionにhello
```
$ terraform output | grep deployment_invoke_url | awk '{print $3}' | xargs curl
```

## 3)Production環境構築
### 3-1) Push application image to AWS ECR
[sample-app](https://git.drecom.jp/infrastructure/tool-aws-oss/sample-app/go)のREADMEを参考に、イメージをpushしてください

### 3-2) リソース構築
```
$ terraform workspace select production
$ terraform plan
# 数分かかります...
$ terraform apply
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
