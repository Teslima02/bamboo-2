defmodule Bamboo2.Event.Stock do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(trace_list) do
    Process.flag(:trap_exit, true)

    schedule_stock_provider()
    {:ok, %{trace_list: trace_list}}
  end

  def insert(event) do
    GenServer.cast(__MODULE__, {:insert, event})

    {:ok, event}
  end

  @impl true
  def handle_cast({:insert, event}, %{trace_list: trace_list} = state) do
    {:ok, response} = Poison.decode(event)
    trace_id = response["headers"]["X-Amzn-Trace-Id"]

    # check if is up to 10, the count start from index 0
    if length(trace_list) == 1, do: send(self(), {:completed, :normal})

    # check if trace_id already exist
    if Enum.member?(trace_list, trace_id) == true do
      send(self(), :check_provider)
    else
      new_list = [trace_id | trace_list]

      {:noreply, %{state | trace_list: new_list}}
    end
  end

  @impl true
  def handle_info({:completed, reason}, state) do
    IO.inspect(state.trace_list)
    IO.inspect("Task complete shutdown process")
    {:stop, reason, state}
  end

  def handle_info(:check_provider, state) do
    # make api call
    network_call()

    # Schedule another call again to check at every time specified
    schedule_stock_provider()

    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    IO.inspect("terminate state")
    System.stop
  end

  defp network_call do
    url = "https://httpbin.org/get"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        insert(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  defp schedule_stock_provider do
    # Process.send_after(self(), :check_provider, :timer.hours(1))
    # Process.send_after(self(), :check_provider, :timer.minutes(1))
    Process.send_after(self(), :check_provider, :timer.seconds(1))
  end
end
