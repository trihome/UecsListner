defmodule Uecslistner.Auto do
  @moduledoc """
  Documentation for `Auto`.
  定期実行
  """

  use GenServer
  require Logger
  alias Uecslistner.DbUniqQueue

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
    - state:一時保管するデータ
  """
  def init(state) do
    Logger.debug("* #{__MODULE__}: init")
    schedule_work()
    {:ok, state}
  end

  @doc """
  一定時間毎に実行
  実行間隔：Application.fetch_env!で与える
  """
  def schedule_work do
    Process.send_after(self(), :work, Application.fetch_env!(:uecslistner, :writedbinterval))
  end

  @doc """
  一定時間毎に実行する実装

  ## Parameter
  - state:一時保管するデータ
  """
  def handle_info(:work, state) do
    # データベースに書き込み
    DbUniqQueue.writetodb()

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end
end
