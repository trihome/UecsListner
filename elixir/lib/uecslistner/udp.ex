defmodule Uecslistner.Udp do
  @moduledoc """
  Documentation for `Udp`.
  """

  use GenServer
  use Timex
  require Logger
  import SweetXml
  alias Uecslistner.DbUniqQueue
  alias Uecslistner.Dbuecs

  @doc """
  start_link
  application.exのworkerから起動

  ## Parameter
  - state:一時保管するデータ
  - opts:起動オプション
  """
  def start_link(state, opts) do
    Logger.info("* #{__MODULE__}: start_link call")
    GenServer.start_link(__MODULE__, state, opts)
  end

  @doc """
  init
  GenServer起動時の初期化

  ## Parameter
    - port:待機するポート番号
  """
  def init(port) do
    Logger.debug("* #{__MODULE__}: UDP server binding #{port}")
    :gen_udp.open(port, [:binary])
    {:ok, port}
  end

  @doc """
  GenServer API
  UDPを受信したときに実行
  """
  def handle_info({:udp, _socket, ip, port, data}, server_socket) do
    # 受信情報の表示
    Logger.debug("* #{__MODULE__}: handle_info > #{getdatetimestr()}, #{inspect(ip)}, #{port}")

    data
    # 受信したUECS-XMLの内容をパース
    |> perse_uecs()
    # 設定に従いこの後の処理を分岐
    |> dodb(Application.fetch_env!(:uecslistner, :enable_uniqqueue))

    {:noreply, server_socket}
  end

  @doc """
  UECS-XMLの内容をキューに追加

  ## Parameter
    - arg:UECS-XMLのマップ
  """
  def dodb(arg, true) do
    arg
    # |> IO.inspect()
    # データをテーブル登録キューに追加
    |> DbUniqQueue.add(getdatetimestr())
  end

  @doc """
  UECS-XMLの内容をテーブルに追加

  ## Parameter
    - arg:UECS-XMLのマップ
  """
  def dodb(arg, false) do
    arg
    # レコードに時刻を追加
    |> Map.put(:datetime, getdatetimestr())
    # |> IO.inspect()
    # データをテーブルに直接追加
    |> Dbuecs.table_insert()
  end

  @doc """
  現在時刻を文字列で取得

  ## Example
    iex(1)> Uecslistner.Udp.getdatetimestr
      2020/5/15 10:44:36
  """
  def getdatetimestr() do
    Timex.local()
    |> Timex.format!("{YYYY}/{M}/{D} {h24}:{m}:{s}")
  end

  @doc """
  UECS-XMLの内容をパースしてマップ化

  ## Parameter
    - arg:UECS-XMLの文字列
  ## Return:UECS-XMLのマップ
  """
  def perse_uecs(arg) do
    # XMLデータを読み込んでパースし、
    # マップに変換して返り値にする
    %{
      :ip => arg |> xpath(~x"/UECS/IP/text()"l),
      :data => arg |> xpath(~x"/UECS/DATA/text()"l),
      :type => arg |> xpath(~x"/UECS/DATA/@type"l),
      :room => arg |> xpath(~x"/UECS/DATA/@room"l),
      :region => arg |> xpath(~x"/UECS/DATA/@region"l),
      :order => arg |> xpath(~x"/UECS/DATA/@order"l),
      :priority => arg |> xpath(~x"/UECS/DATA/@priority"l)
    }
  end
end
