# データベースの準備

## PostgreSQLのインストール

```shell-session
$ sudo apt install postgresql
```

## データベースの設定

```shell-session
#ユーザpostgresになる
~$ sudo su - postgres

#postgresの中にuecsユーザを作成
postgres@ubuntu:~$ createuser uecs

#postgresの中にuecsユーザオーナーとするuecssmsvデータベースを作成
postgres@ubuntu:~$ createdb uecssmsv -O uecs

#データベースの一覧を表示
postgres@ubuntu:~$ psql -l
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 postgres  | postgres | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8 | 
 template0 | postgres | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 template1 | postgres | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8 | =c/postgres          +
           |          |          |             |             | postgres=CTc/postgres
 uecssmsv  | uecs     | UTF8     | ja_JP.UTF-8 | ja_JP.UTF-8 | 
(4 rows)

#psqlに入る
postgres@ubuntu:~$ psql uecssmsv
```

## テーブル作成

```sql
---作成
uecssmsv=# create table Uecs_LRaw (
  EqLogID int GENERATED ALWAYS AS IDENTITY  not null
  , ClientIp varchar(45) default '0.0.0.0' not null
  , DataVal decimal(9, 3)
  , DataType varchar(20)
  , DataRoom smallint default 0 not null
  , DataRegion smallint default 0 not null
  , DataOrder int default 0 not null
  , DataPriority smallint default 30 not null
  , DataAVal varchar(255)
  , TriggerDate TIMESTAMP not null
  , ProcTime int default 0 not null
  , primary key (EqLogID)
);
CREATE TABLE

--テーブルが出来たか確認
uecssmsv=# \dt;
           List of relations
 Schema |   Name    | Type  |  Owner   
--------+-----------+-------+----------
 public | uecs_lraw | table | postgres
(1 rows)

--- テーブルの中身を確認
uecssmsv=# \d uecs_lraw;
                                     Table "public.uecs_lraw"
    Column    |            Type             | Collation | Nullable |           Default            
--------------+-----------------------------+-----------+----------+------------------------------
 eqlogid      | integer                     |           | not null | generated always as identity
 clientip     | character varying(45)       |           | not null | '0.0.0.0'::character varying
 dataval      | numeric(9,3)                |           |          | 
 datatype     | character varying(20)       |           |          | 
 dataroom     | smallint                    |           | not null | 0
 dataregion   | smallint                    |           | not null | 0
 dataorder    | integer                     |           | not null | 0
 datapriority | smallint                    |           | not null | 30
 dataaval     | character varying(255)      |           |          | 
 triggerdate  | timestamp without time zone |           | not null | 
 proctime     | integer                     |           | not null | 0
Indexes:
    "uecs_lraw_pkey" PRIMARY KEY, btree (eqlogid)
```

## テーブルへのアクセス権限付与

```sql
--アクセス権限付与前
uecssmsv=# \dp
                                          Access privileges
 Schema |         Name          |   Type   |     Access privileges     | Column privileges | Policies 
--------+-----------------------+----------+---------------------------+-------------------+----------
 public | uecs_lraw             | table    | postgres=arwdDxt/postgres+|                   | 
        |                       |          | uecs=arwd/postgres       +|                   | 
        |                       |          | kenkyu=arwd/postgres      |                   | 
 public | uecs_lraw_eqlogid_seq | sequence |                           |                   | 

--アクセス権限付与
uecssmsv=# GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO uecs;

--アクセス権限付与後
uecssmsv=# \dp
                                          Access privileges
 Schema |         Name          |   Type   |     Access privileges     | Column privileges | Policies 
--------+-----------------------+----------+---------------------------+-------------------+----------
 public | uecs_lraw             | table    | postgres=arwdDxt/postgres+|                   | 
        |                       |          | uecs=arwd/postgres       +|                   | 
        |                       |          | kenkyu=arwd/postgres      |                   | 
 public | uecs_lraw_eqlogid_seq | sequence |                           |                   | 
```

## ユーザにパスワードを設定

```sql
---パスワードの設定
uecsraspi=# CREATE ROLE uecs LOGIN PASSWORD 'hogefuga';
---（パスワードの変更）
uecsraspi=# ALTER ROLE uecs LOGIN PASSWORD 'fugahoge';
```

## PostgreSQLに対するネットワーク経由のアクセス権限

### confファイルのバックアップを作成

```shell-session
$ cd /etc/postgresql/10/main
$ sudo cp -p postgresql.conf postgresql.conf.org
$ sudo cp -p pg_hba.conf pg_hba.conf.org
```

### postgresql.confの修正

```shell-session
$ sudo nano postgresql.conf
```

検索して下記の箇所を修正

```conf
･･･（省略）･･･
listen_addresses = '0.0.0.0'          # what IP address(es) to listen on;
･･･（省略）･･･
```

### pg_hba.confの修正

```shell-session
$ sudo nano pg_hba.conf
```

uecsユーザと、接続元ネットワークを記述

```conf
...（最後の行）
host    all             uecs          192.168.0.0/24          md5
```

### 設定反映

```shell-session
$ sudo systemctl reload postgresql

# あるいは
$ sudo systemctl stop postgresql
$ sudo systemctl start postgresql
```

ここまでで、リモートからPostgreSQLの読み書きができるようになります。

## Appendix

