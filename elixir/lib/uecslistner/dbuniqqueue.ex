defmodule Uecslistner.DbUniqQueue do
  @moduledoc """
  Documentation for `DbUniqQueue`.
  キューに貯めている間、指定の条件でデータの内容を書き換え・保持
  """

  use GenServer
  require Logger

  @doc """
  start_link
  application.exのworkerから起動

  ## Parameter
  - state:一時保管するデータ
  - opts:起動オプション
  """
  def start_link(state, opts) do
    Logger.info("* #{__MODULE__}: start_link call")
    {ret, pid} = GenServer.start_link(__MODULE__, state, opts)
  end

  @doc """
  init
  GenServer起動時の初期化

  ## Parameter
    - queue:一時保管するUECSデータ
  """
  def init(queue) do
    Logger.debug("* #{__MODULE__}: init")
    :global.register_name(:DbUniqQueue, self())
    {:ok, queue}
  end

  @doc """
  GenServer API
  キューにデータを追加する。
  定時間毎の書き込み時に同一ノードのダブりを無くすため
  下記のパラメータが同じものは（上書きして）保持。
  ClientIp, DataType, DataRoom, DataRegion, DataOrder

  ## Parameter
    - value:レコードのデータ
          フォーマット
          %{
            ip: ['192.168.5.191'],
            type: ['InAirTemp'],
            data: ['22.12'],
            order: ['0'],
            room: ['1'],
            region: ['101'],
            priority: ['29']
          }
    - datetime:年月日時刻
          フォーマット YYYY/MM/DD HH:MM:SS
    - queue:一時保管するUECSデータ
  """
  def handle_cast({:add, value, datetime}, queue) do
    # 一意検査のためのハッシュ文字を生成
    # ここでは、ClientIp, DataType, DataRoom, DataRegion, DataOrder
    # の組み合わせの重複をチェック
    key =
      (value[:ip] ++ value[:type] ++ value[:room] ++ value[:region] ++ value[:order])
      |> Enum.join(",")

    # valueマップに時刻情報を追加
    value = Map.put(value, :datetime, datetime)

    # queueマップに追加
    # 同じkeyは上書きのモードを使う
    # https://alpacat.hatenablog.com/entry/elixir-map-update
    queue = Map.put(queue, key, value)
    # 返り値
    {:noreply, queue}
  end

  @doc """
  クライアント側API / ヘルパー関数
  キューにデータを追加する。

  ## Parameter
    - value:レコードのデータ
    - datetime:年月日時刻
    - queue:一時保管するUECSデータ

  ## Return
    - arg:追加するデータのマップ
  """
  def add(arg, datetime) do
    GenServer.cast(:dbuniqqueue, {:add, arg, datetime})
    # 返り値
    arg
  end

  @doc """
  クライアント側API / ヘルパー関数
  キューにダミーデータを追加する。

  ## Return
    - dummydata:追加するデータのマップ
  """
  def add(_datetime) do
    # デバッグ用のダミーデータ
    dummydata = %{
      # データ形式（気温）
      type: ['InAirTemp'],
      # 気温
      data: ['22.12'],
      # ノードのIPアドレス
      ip: ['192.168.5.191'],
      # 部屋番号
      room: ['1'],
      # 系統番号
      region: ['101'],
      # （ノード機器の）通し番号
      order: ['0'],
      # 優先順位
      priority: ['29']
    }

    # 呼び出し
    GenServer.cast(:dbuniqqueue, {:add, dummydata})
    # 返り値
    dummydata
  end

  @doc """
  GenServer API
  保持しているデータをデータベースに書き込み

  ## Parameter
    - queue:一時保管するUECSデータ
  """
  def handle_cast(:writetodb, queue) do
    queue
    # key/valueのうちvalueだけ取り出す
    # https://qiita.com/niku/items/729ece76d78057b58271#%E3%83%9E%E3%83%83%E3%83%97%E3%81%AE%E6%93%8D%E4%BD%9C
    |> Map.values()
    # テーブルに追加
    |> Enum.each(fn x -> Uecslistner.Dbuecs.table_insert(x) end)

    # 受信情報の表示
    Logger.debug("* #{__MODULE__}: handle_cast > :writetodb Counts: #{Enum.count(queue)}")

    # （テーブルに追加し終えたら）マップの内容をクリア
    queue = Map.new()
    # 返り値
    {:noreply, queue}
  end

  @doc """
  クライアント側API / ヘルパー関数
  保持しているデータをデータベースに書き込み
  Workerから任意の時間間隔で定期実行する
  """
  def writetodb() do
    GenServer.cast(:dbuniqqueue, :writetodb)
  end

  @doc """
  GenServer API
  保持しているデータの内容確認

  ## Parameter
    - queue:一時保管するUECSデータ
  """
  def handle_call(:showqueue, _from, queue) do
    # キューの件数
    result = Enum.count(queue)
    # ここから表示開始
    IO.puts("--- queue ---")

    queue
    |> IO.inspect()

    IO.puts("--- queue (#{result} counts) end ---")
    # 返り値
    {:reply, {queue, result}, queue}
  end

  @doc """
  クライアント側API / ヘルパー関数
  保持しているキューを表示

  ## Example
    iex(6)> Uecslistner.DbUniqQueue.showqueue
    --- queue ---
    %{
      "192.168.5.191,InAirCO2,1,101,0" => %{
        data: ['388'],
        datetime: "2020/5/15 10:08:18",
        ip: ['192.168.5.191'],
        order: ['0'],
        priority: ['29'],
        region: ['101'],
        room: ['1'],
        type: ['InAirCO2']
      },
      ･･･（省略）･･･
    }
    --- queue (4 counts) end ---
    4
    iex(7)>
  """
  def showqueue() do
    GenServer.call(:dbuniqqueue, :showqueue)
  end
end
