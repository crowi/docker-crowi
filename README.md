[![Crowi](https://camo.githubusercontent.com/25aba13a62a44530175dc8eebb1567d829a3cbb0/687474703a2f2f7265732e636c6f7564696e6172792e636f6d2f6872736379777634702f696d6167652f75706c6f61642f635f6c696d69742c665f6175746f2c685f3930302c715f38302c775f313230302f76312f3139393637332f68747470735f7777775f66696c657069636b65725f696f5f6170695f66696c655f567059455033325a5179435a383575365843586f5f7a736b7072612e706e67)](http://site.crowi.wiki)

# [Crowi](http://site.crowi.wiki) on Docker

※ 現在Docker Cloudへ移行中です。

## 利用方法

### 既にMongoDBとRedisとElasticsearchのサーバーがある場合

```
$ git clone https://github.com/crowi/docker-crowi.git
$ cd docker-crowi
$ docker build -t crowi:1.6.3 .
$ docker run --name some-crowi -p 8080:3000 -d \
  -e MONGO_URI=mongodb://MONGODB_HOST:MONGODB_PORT/some-crowi \
  -e REDIS_URL=redis://REDIS_HOST:REDIS_PORT/some-crowi \
  -e ELASTICSEARCH_URI=http://ELASTICSEARCH_HOST:ELASTICSEARCH_PORT/some-crowi \
  crowi:1.6.3
```

と実行し、`http://localhost:8080`にアクセスすると使えるようになります。たぶん。


### [Docker Compose](https://docs.docker.com/compose/)を使う

MongoDBのコンテナを`db`として、Redisのコンテナを`redis`として、Elasticsearchのコンテナを`es`としてリンクできるようにしてあるので、このリポジトリをcloneして以下のように`docker-compose.yml`を書き、`docker-compose up`を実行すれば`http://localhost:8080`にアクセスして使えるようになります。

```yaml
# とりあえず全機能オンにして試しにローカルで使ってみる用の設定
version: '3'

services:
  crowi:
    build: .
    image: crowi:1.6.3
    environment:
      - MATHJAX=1
      - PLANTUML_URI=http://localhost:18080
    ports:
      - 8080:3000

  db:
    image: mongo:latest

  redis:
    image: redis:alpine

  es:
    # テスト用の設定
    # 正しい設定はElasticsearchのドキュメントを参照
    image: docker.elastic.co/elasticsearch/elasticsearch:5.6.4
    environment:
      # パスワードの入力を省略するためX-Packを切る
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    # プラグインのKuromojiが必要
    entrypoint:
      - bash
      - -c
      - >-
        elasticsearch-plugin list | grep -q analysis-kuromoji
        || elasticsearch-plugin install analysis-kuromoji
        && exec $$0 $$@
    command:
      - /bin/bash
      - bin/es-docker

  plantuml:
    image: plantuml/plantuml-server:latest
    ports:
      - 18080:8080
```

コンテナのアップデートは`docker-compose pull && docker-compose up`で。


## 環境変数

- `PORT`: コンテナ側のポート。デフォルトは3000。普通弄る必要はありません。
- `MONGO_URI`: MongoDBに接続するためのURI。`db`コンテナをリンクする場合は必要ありません。
- `REDIS_URL`: Redisのセッションストアに接続するためのURI。`redis`コンテナをリンクする場合は必要ありません。無くても一応起動できますが非推奨です。
- `ELASTICSEARCH_URI`: Elasticsearchでページ検索できるようにするためのURI。`es`コンテナをリンクする場合は必要ありません。無い場合は検索機能が無効になります。プラグインのKuromojiが必要なことに注意してください。
- `PLANTUML_URI`: PlantUMLを利用してUMLを書けるようにするためのURI。Crowiサーバーとは通信せず、ユーザーがPlantUMLサーバーにリクエストを送る形になるので、ユーザーからアクセスできるURIを指定してください。
- `MATHJAX`: 1にしておくとMathJaxを利用してTeX記法で数式を書けるようになります（beta）。
- `PASSWORD_SEED`: ユーザーのパスワードからハッシュを生成するときにつかう種です。指定しなくても自動生成します。これが変更されると既に登録しているユーザーがログインできなくなるので注意してください。
- `SECRET_TOKEN`: 署名されたcookieを確認するための秘密鍵。
- `FILE_UPLOAD`: デフォルトで`local`になっています。`aws`や`none`を指定できます。


## ボリューム

コンテナの`/data`をボリュームとして登録してあります。中には`PASSWORD_SEED`を保存する`config`ファイルと`FILE_UPLOAD`が`local`の時にアップロードされたファイルを保存する`uploads`ディレクトリがあります。

このボリュームが失われると`PASSWORD_SEED`が失われることにより管理者を含めた既存ユーザーがCrowiにログインできなくなるので注意してください。
`PASSWORD_SEED`環境変数を指定するか、`docker run`時に`-v crowidata:/data`などとしておくと次のときも同様に起動できるので良いと思います。
