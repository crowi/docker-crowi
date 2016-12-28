# [![Crowi](https://camo.githubusercontent.com/25aba13a62a44530175dc8eebb1567d829a3cbb0/687474703a2f2f7265732e636c6f7564696e6172792e636f6d2f6872736379777634702f696d6167652f75706c6f61642f635f6c696d69742c665f6175746f2c685f3930302c715f38302c775f313230302f76312f3139393637332f68747470735f7777775f66696c657069636b65725f696f5f6170695f66696c655f567059455033325a5179435a383575365843586f5f7a736b7072612e706e67)](http://site.crowi.wiki)

[![](https://images.microbadger.com/badges/image/bakudankun/crowi.svg)](http://microbadger.com/images/bakudankun/crowi)

このDockerイメージはオープンソースのWikiサーバーアプリ[Crowi](http://site.crowi.wiki)をDocker上で使えるようにしたものです。


## サポートされるタグとその`Dockerfile`

- [`1.5.2`, `1.5`, `1`, `latest` (Dockerfile)](https://github.com/Bakudankun/docker-crowi/blob/master/Dockerfile)


## 利用方法

### 既にMongoDBとRedisとElasticsearchのサーバーがある場合

```
docker run --name some-crowi -p 8080:3000 -d \
	-e MONGO_URI=mongodb://MONGODB_HOST:MONGODB_PORT/some-crowi \
	-e REDIS_URL=redis://REDIS_HOST:REDIS_PORT/some-crowi \
	-e ELASTICSEARCH_URI=http://ELASTICSEARCH_HOST:ELASTICSEARCH_PORT/some-crowi \
	bakudankun/crowi
```

と実行し、`http://localhost:8080`にアクセスすると使えるようになります。たぶん。


### [Docker Compose](https://docs.docker.com/compose/)を使う

MongoDBのコンテナを`db`として、Redisのコンテナを`redis`として、Elasticsearchのコンテナを`es`としてリンクできるようにしてあるので、例えば以下のように`docker-compose.yml`を書き、`docker-compose up`を実行すれば`http://localhost:8080`にアクセスして使えるようになります。

```yaml
version: '2'

services:
  crowi:
    image: bakudankun/crowi:latest
    links:
      - mongo:db
      - redis:redis
      - elasticsearch:es
    ports:
      - 8080:3000

  mongo:
    image: mongo

  redis:
    image: redis:alpine

  elasticsearch:
    image: elasticsearch:2
    # プラグインのKuromojiが必要
    entrypoint:
      - bash
      - -c
      - >-
        bin/plugin list | grep -q analysis-kuromoji
        || bin/plugin install analysis-kuromoji
        && exec /docker-entrypoint.sh $$0 $$@
    command: elasticsearch
```

コンテナのアップデートは`docker-compose pull && docker-compose up`で。


## 環境変数

- `PORT`: コンテナ側のポート。デフォルトは3000。普通弄る必要はありません。
- `MONGO_URI`: MongoDBに接続するためのURI。`db`コンテナをリンクする場合は必要ありません。
- `REDIS_URL`: Redisのセッションストアに接続するためのURI。`redis`コンテナをリンクする場合は必要ありません。無くても一応起動できますが非推奨です。
- `ELASTICSEARCH_URI`: Elasticsearchでページ検索できるようにするためのURI。`es`コンテナをリンクする場合は必要ありません。無い場合は検索機能が無効になります。プラグインのKuromojiが必要なことに注意してください。
- `PASSWORD_SEED`: ユーザーのパスワードからハッシュを生成するときにつかう種です。指定しなくても自動生成します。これが変更されると既に登録しているユーザーがログインできなくなるので注意してください。
- `SECRET_TOKEN`: 署名されたcookieを確認するための秘密鍵。
- `FILE_UPLOAD`: デフォルトで`local`になっています。`aws`や`none`を指定できます。


## ボリューム

コンテナの`/data`をボリュームとして登録してあります。中には`PASSWORD_SEED`を保存する`config`ファイルと`FILE_UPLOAD`が`local`の時にアップロードされたファイルを保存する`uploads`ディレクトリがあります。

このボリュームが失われると`PASSWORD_SEED`が失われることにより管理者を含めた既存ユーザーがCrowiにログインできなくなるので注意してください。
`PASSWORD_SEED`環境変数を指定するか、`docker run`時に`-v crowidata:/data`などとしておくと次のときも同様に起動できるので良いと思います。
