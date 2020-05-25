import Config

# ログレベル
config :logger,
  compile_time_purge_matching: [
    [level_lower_than: :info]
    # [level_lower_than: :debug]
  ]

# アプリの各種設定
config :uecslistner,
  # データベースの接続情報
  database: "uecsraspi",
  username: "uecs",
  password: "hogefuga",
  hostname: "localhost",
  # 書き込み先テーブル
  uecslogtable: "uecs_lraw",
  # データベースへの書き込み時間間隔(ms)
  writedbinterval: 60 * 1000,
  # 一定時間キューに貯めて、同一ノードのデータのダブりを除去する機能
  enable_uniqqueue: true

# TzData
# 自動アップデートの無効化
# https://elixirforum.com/t/timex-tzdata-error/28146
config :tzdata, :autoupdate, :disabled

