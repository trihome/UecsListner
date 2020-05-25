defmodule Uecslistner.Xlsx do
  @moduledoc """
  Documentation for `Xlsx`.
  """

  use GenServer
  require Logger
  require Elixlsx
  alias Elixlsx.Sheet
  alias Elixlsx.Workbook

  @doc """
  start_link

  ## Parameter

  - hoge
  """
  def start_link(
        {hoge},
        opts
      ) do
    Logger.info("* #{__MODULE__}: start_link call")
    GenServer.start_link(__MODULE__, {hoge}, opts)
  end

  @doc """
  init

  ## Parameter
  """
  def init({hoge}) do
    Logger.info("* #{__MODULE__}: init > db: #{hoge}")

    {:ok, {hoge}}
  end

  @doc """
  export_xlsx

  xlsxに出力
  https://github.com/xou/elixlsx

  """
  def export_xlsx(_hoge) do
    {:ok, {_hoge}}
  end
end
