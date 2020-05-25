defmodule Uecslistner do
  @moduledoc """
  Documentation for `Uecslistner`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Uecslistner.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Configの値を確認

  ## Examples
    iex> Uecslistner.getenv
  """
  def getenv do
    Application.get_all_env(:uecslistner)
    |> IO.inspect()
  end
end
