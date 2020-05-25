defmodule Uecslistner.Dbuecs do
  @moduledoc """
  Documentation for `Dbuecs`.
  """

  use GenServer
  require Logger

  @doc """
  start_link
  application.exのworkerから起動

  ## Parameter
  - pidpg:一時保管するデータ
  """
  def start_link(_pidpg) do
    Logger.info("* #{__MODULE__}: start_link call")

    # Postgrexを起動しPIDを取得
    {:ok, pidpg} =
      Postgrex.start_link(
        database: Application.fetch_env!(:uecslistner, :database),
        username: Application.fetch_env!(:uecslistner, :username),
        password: Application.fetch_env!(:uecslistner, :password),
        hostname: Application.fetch_env!(:uecslistner, :hostname)
      )

    GenServer.start_link(__MODULE__, pidpg, name: __MODULE__)
  end

  @doc """
  init
  GenServer起動時の初期化

  ## Parameter
    - pidpg:一時保管するPostgrexのPID
  """
  def init(pidpg) do
    Logger.debug("* #{__MODULE__}: init")
    {:ok, pidpg}
  end

  @doc """
  GenServer API
  問い合わせ

  ## Parameter
    - pidpg:一時保管するPostgrexのPID
  """

  def handle_call(:table_select, _from, pidpg) do
    # SELECTするSQL分
    # 本日の取得データを表示
    result = Postgrex.query!(pidpg, "
      select
        *
      from
        #{Application.fetch_env!(:uecslistner, :uecslogtable)}
      where
        triggerdate >= to_timestamp(to_char(current_date, 'YYYY-MM-DD'), 'YYYY-MM-DD 0:0:0')
      order by
        triggerdate desc
      limit
        20
      ;
    ", [])
    {:reply, result, pidpg}
  end

  @doc """
  クライアント側API / ヘルパー関数
  問い合わせ

  ## Example
   iex(1)> Uecslistner.Dbuecs.table_select
     %Postgrex.Result{
       columns: ["eqlogid", "clientip", "dataval", "datatype", "dataroom",
       "dataregion", "dataorder", "datapriority", "dataaval", "triggerdate",
       "proctime"],
       command: :select,
       connection_id: 29415,
       messages: [],
       num_rows: 20,
       rows: [
         [1897165, "192.168.5.191", #Decimal<399.000>, "InAirCO2", 1, 101, 0, 29,
         nil, ~N[2020-05-15 11:10:45.000000], 0],
         [1897168, "192.168.5.191", #Decimal<23.090>, "InAirTemp", 1, 101, 0, 29,
         nil, ~N[2020-05-15 11:10:45.000000], 0],
     ･･･（省略）･･･
  """
  def table_select() do
    GenServer.call(__MODULE__, :table_select)
  end

  @doc """
  GenServer API
  テーブルにINSERT

  ## Parameter
    - ip:発信ノードのIPアドレス
    - data:データ
    - type:CCM識別子
    - room:部屋番号
    - region:系統番号
    - order:通し番号
    - priority:優先順位
    - triggerdate:年月日時刻（フォーマット YYYY/MM/DD HH:MM:SS）
  """
  def handle_call(
        {:table_insert, ip, data, type, room, region, order, priority, triggerdate},
        _from,
        pidpg
      ) do
    result = Postgrex.query!(pidpg, "
      INSERT INTO #{Application.fetch_env!(:uecslistner, :uecslogtable)}
        (ClientIp, DataVal, DataType, DataRoom, DataRegion, DataOrder, DataPriority, TriggerDate )
      VALUES
        ('#{ip}', #{data}, '#{type}', #{room}, #{region}, #{order}, #{priority}, '#{triggerdate}')
    ", [])
    Logger.debug("* #{__MODULE__}: handle_call > #{inspect(result)}")
    {:reply, result, pidpg}
  end

  @doc """
  クライアント側API / ヘルパー関数
  テーブルにINSERT

  ## Return
    - arg:追加するデータのマップ
  """
  def table_insert(arg) do
    GenServer.call(
      __MODULE__,
      {:table_insert, arg[:ip], arg[:data], arg[:type], arg[:room], arg[:region], arg[:order],
       arg[:priority], arg[:datetime]}
    )

    arg
  end
end
