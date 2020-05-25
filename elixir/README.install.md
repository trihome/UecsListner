# インストール手順

Elixirのインストールから、自動実行、ログのローテーションまでを説明します。

## 1.Elixirのインストール

2つのインストール方法があります。

それぞれ、elixir本体の他に、以下のパッケージも追加インストールしてください。

- erlang-dev
- erlang-parsetools
- erlang-inets
- erlang-xmerl 

### (1)Elixir公式のパッケージでインストール

`packages.erlang-solutions.com`のリポジトリを追加しますので、最新版がインストールできます。

- [公式ページ](https://elixir-lang.org/install.html)

```sh
$ sudo apt install elixir erlang-inets erlang-dev erlang-parsetools erlang-xmerl -y
$ elixir -v
Erlang/OTP 23 [erts-11.0] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]
Elixir 1.10.3 (compiled with Erlang/OTP 21)
```

バージョンがElixir 1.10.3、Erlang/OTP 21である事が確認できます。（2020年5月時点）

### (2)Raspbianのdebパッケージでインストール

```sh
$ sudo apt install elixir erlang-inets erlang-dev erlang-parsetools erlang-xmerl -y
$ elixir -v
Erlang/OTP 21 [erts-10.2.4] [source] [smp:4:4] [ds:4:4:10] [async-threads:1]
Elixir 1.7.4 (compiled with Erlang/OTP 21)
```

バージョンがElixir 1.7.4、Erlang/OTP 21である事が確認できます。（2020年5月時点）

## 2.インストールとテスト実行

アプリのインストール先ディレクトリは、下記の例では`/home/ubuntu/gitwork/uecslistner`としています。
各個のインストール先ディレクトリにあわせて読み替えてください。

```sh
$ pwd
/home/ubuntu
# インストール先ディレクトリを作成
$ mkdir -p ./gitwork/
$ cd ./gitwork
```

※`git`を使う時の作業ディレクトリです。

```sh
$ pwd
/home/ubuntu/gitwork
# GitHubからクローン
$ git clone hogehoge
$ cd uecslistner
```

```sh
$ pwd
/home/ubuntu/gitwork/uecslistner
# uecslistnerの実行に必要なライブラリをインストール
# `mix deps.get`というコマンドで、自動的にインストールされます。
$ mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
（･･･省略･･･）
All dependencies up to date
```

#### ※Elixirのバージョンが1.7系以下の場合

Raspbianのパッケージはこれに該当するので、ソースコードを一部修正してください。

```sh
$ nano config/config.exs
```

1行目の`Config`の前に、`Mix.`という文字を追記してください

|修正前|修正後|
|:--|:--|
|import Config|import Mix.Config|

この修正を加えてから、`mix deps.get`してください。

### 設定(config.exs)

実行環境にあわせて`config/Config.exs`ファイルに記述します。

#### `:logger`ログの出力レベル

|項目|意味|選択肢|
|:--|:--|:--|
|level_lower_than:|ログレベル|:info（デフォルト）, :debug|

#### `:uecslistner`アプリの設定

|項目|意味|
|:--|:--|
|database:|データベース名|
|username:|データベースへのログインユーザ名|
|password:|〃パスワード|
|hostname:|データベースを実行しているホスト名・IPアドレス|
|uecslogtable:|UECSデータをINSERTするテーブル名です|
|||
|writedbinterval:|指定した時間間隔ごとに、テーブルにINSERTします※|
|enable_uniqqueue:|※|

※補足

- true：UDPで流れてくるUECSのデータは、必ずしも一定間隔では届きません（保証していない）ので、`writedbinterval:`の間は、同一ノードで一位になるようデータを貯めておいて、指定時間毎にまとめてINSERTします。（データの保存量を若干節約できます。）

- false: UECSデータを受信する度に、テーブルにINSERTします。



### テスト実行

初回起動の時だけ、コンパイルが実行されます。

```sh
$ iex -S mix

Erlang/OTP 21 [erts-10.2.4] [source] [smp:4:4] [ds:4:4:10] [async-threads:1]
Compiling 8 files (.ex)
（･･･省略･･･）
Generated uecslistner app

22:11:05.727 [info]  * Elixir.Uecslistner.Udp: start_link call
22:11:05.734 [info]  * Elixir.Uecslistner.Dbuecs: start_link call
22:11:05.809 [info]  * Elixir.Uecslistner.DbUniqQueue: start_link call
22:11:05.809 [info]  * Elixir.Uecslistner.Auto: start_link call
Interactive Elixir (1.7.4) - press Ctrl+C to exit (type h() ENTER for help)

iex(1)>
```

iexのプロンプトが表示されたら、正常に実行されています。
終了するには以下の操作をします。

- コマンド`System.halt`を入力
- [Ctrl-\]を押す
- [Ctrl-C]を2回押す

※あるいは、iexシェルが必要なければ、下記のコマンドでも実行できます。

```sh
$ mix run --no-halt
```

#### トラブル例

- PostgreSQLに接続できていません。PostgreSQLを実行してください。

```sh
22:11:05.980 [error] Postgrex.Protocol (#PID<0.319.0>) failed to connect: ** (DBConnection.ConnectionError) tcp connect (localhost:5432): connection refused - :econnrefused
```

## 3.Linux立ち上げ時に自動起動

### (1)ログの保存ディレクトリを作る

systemd経由で起動すると、このディレクトリにログを出力します。

```sh
$ pwd
/home/ubuntu/gitwork/uecslistner
$ mkdir ./log
```

### (2)起動スクリプトを修正

```sh
$ pwd
/home/ubuntu/gitwork/uecslistner
$ nano uecsld.sh
```

ディレクトリ設定1カ所を、インストールした環境に合わせて修正

```sh
（･･･省略･･･）
#変数の設定
SCRIPTDIR=/home/ubuntu/gitwork/uecslistner
LOGDIR=$SCRIPTDIR/log
（･･･省略･･･）
```

### (3)自動起動に必要なserviceファイルをsystemdに設定

```sh
$ pwd
/home/ubuntu/gitwork/uecslistner
$ nano uecsld.service
```

serviceファイルの中のディレクトリ設定3カ所を、インストールした環境に合わせて修正

```service
[Unit]
Description=UECS Data Logger Daemon (elixir)
After=local-fs.target
ConditionPathExists=/home/ubuntu/gitwork/uecslistner/uecslistner

[Service]
WorkingDirectory=/home/ubuntu/gitwork/uecslistner/uecslistner
ExecStart=/home/ubuntu/gitwork/uecslistner/uecsld.sh
（･･･省略･･･）
```

```sh
#設定ファイルをリンク（コピーしてもOK）
$ sudo ln -s /home/ubuntu/gitwork/uecslistner/uecsld.service /etc/systemd/system
```

```sh
#systemdに設定の再読込を指示
$ sudo systemctl daemon-reload
```

```sh
#自動起動を有効化（次再起動したら、自動的に実行）
$ sudo systemctl enable uecsld.service
```

```sh
#ここでデーモンを直接起動
$ sudo systemctl start uecsld.service
```

```sh
#運転状態の確認
$ sudo systemctl status uecsld.service
● uecsld.service - UECS Data Logger Daemon (elixir)
   Loaded: loaded (/home/ubuntu/gitwork/uecslistner/uecsld.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2020-05-15 11:52:57 JST; 5 days ago
 Main PID: 30547 (beam.smp)
    Tasks: 27 (limit: 4662)
   CGroup: /system.slice/uecsld.service
           ├─30547 /usr/lib/erlang/erts-10.7.1/bin/beam.smp -- -root /usr/lib/erlang -progname erl -- -home /home/kenkyu -- -pa /usr/lib/elixir/bin/../lib/eex/eb
           ├─30588 erl_child_setup 1024
           ├─30618 inet_gethost 4
           └─30619 inet_gethost 4

 5月 15 11:52:57 smsv3 systemd[1]: Started UECS Data Logger Daemon (elixir).
```

※その他の命令です。（メンテナンス等で使います）

```sh
#デーモンを停止
$ sudo systemctl stop uecsld.service
```

```sh
#自動起動を無効化
$ sudo systemctl disable uecsld.service
```

## 4.logrotateの設定

```sh
$ pwd
/home/ubuntu/gitwork/uecslistner
$ nano uecsld.logrotate
```

logrotateファイルの中のディレクトリ設定1カ所を、インストールした環境に合わせて修正

```logrotate
/home/ubuntu/gitwork/uecslistner/log/run.log {
  daily
  missingok
  rotate 15
  compress
  delaycompress
  notifempty
  copytruncate
  su kenkyu kenkyu
}
```

```sh
#パーミッションを必ず644に変更(実行属性を取り除く)
$ chmod 644 uecsld.logrotate
#logrotateファイルを登録
$ sudo cp /home/ubuntu/gitwork/uecslistner/uecsld.logrotate /etc/logrotate.d/uecsld
#強制実行
$ sudo logrotate -f /etc/logrotate.d/uecsld
```

以上で設定完了です。
