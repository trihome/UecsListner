# その他

実験的な機能など。

### 自動起動で実行中のデーモンにアタッチする

serviceファイルから起動する際に、デーモンには名前`uecsld`がついています。
ターミナルを別に開いて、下記を実行してアタッチします。`ホスト名`の箇所は、当該のサーバのホスト名を書きます。

```sh
#対話型シェルを`debug`という名前で立ち上げ
$ iex --sname debug

iex(debug@ホスト名)1> Node.connect(:uecsld@ホスト名)
true
iex(debug@ホスト名)2> Node.list
[:uecsld@ホスト名]
```

これでアタッチできました。

※デーモンが起動していない状態でアタッチしようとすると、下記のようになります。

```sh
iex(debug@ホスト名)1> Node.connect(:uecsld@smsv3)
false
iex(debug@ホスト名)2> Node.list
[] #←空っぽ
```

#### アタッチ中に使用できるコマンド

- showqueue
`:gen_server.call(:global.whereis_name(:DbUniqQueue), :showqueue)`

>テーブルへ書き込む内部キューに貯まっているデータを表示します。

例

```elixir
iex(debug@ホスト名)3> :gen_server.call(:global.whereis_name(:DbUniqQueue), :showqueue)

{%{
   "192.168.5.191,InAirCO2,1,101,0" => %{
     data: ['366'],
     datetime: "2020/5/20 16:41:23",
      （･･･省略･･･）
     ip: ['192.168.5.191'],
     order: ['0'],
     priority: ['29'],
     region: ['101'],
     room: ['1'],
     type: ['InAirTemp']
   }
 }, 4}
```

- 配列に入った状態のUECSデータを確認できます
- 最後の方に、（例）` }, 4}`と表示されている箇所の数字は、キューに貯まっているレコード数です

