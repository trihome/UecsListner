# UecsListner

UECS通信実用規約に基づいたロギング用ソフトウェアです。
UECS通信網を流れるデータを拾って、そのままPostgreSQLのテーブルに追加します。


農研機構「UECS通信実用規約に基づいたロギング用ソフトウェア」のElixir実装版です。

- [ユビキタス環境制御システム(UECS)技術](https://www.naro.affrc.go.jp/laboratory/nivfs/contents/kenkyu_joho/uecs/index.html)

## 1.Installation

実行環境は下記を想定しています。

- Desktop PC
  - Ubuntu Linux 18.04LTS
- Raspberry Pi 3B+
  - Raspbian Buster

※基本的にElixir言語が実行できれば動作します。

詳細な手順は下記リンク先をご覧ください。

1. [データベースの準備](./README.db.md)
1. [Elixirのインストール、UecsListnerのインストール・設定、自動起動、ログのローテーション](./README.install.md)

## 2.Usage

終了するには、[Ctrl-\]を押すか、[Ctrl-C]を2回押します。

```sh
$ mix run --no-halt
```

対話型で実行する場合

```sh
$ iex -S mix
```

1. [その他の機能](./README.etc.md)

## 3.Note

- このソフトウェアの利用に関して、作者は一切の責任を負いません。

### 参考資料

- [Elixir School](https://elixirschool.com/ja/)
- [Qiita](https://qiita.com/tags/elixir)
- [ユビキタス環境制御システム「UECS」](https://uecs.jp/)

## 4.Author
 
* myasu
  * twitter: @etcinitd
  * GitHub:  https://github.com/trihome
  * Qiita:   https://qiita.com/myasu
 
## License

This is under [MIT license](https://en.wikipedia.org/wiki/MIT_License).
