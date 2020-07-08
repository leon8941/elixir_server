defmodule Client do
  # RETRIEVE DATA FROM SERVER : GET
  def get(url, headers) do
    url
    |> HTTPoison.get(headers)
    |> case do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {status_code, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
    |> (fn {ok, body} ->
          body
          |> Poison.decode(keys: :atoms)
          |> case do
            {:ok, parsed} -> {ok, parsed}
            _ -> {:error, body}
          end
        end).()
  end

  # MUTATE DATA ON SERVER : POST, PUT, DELETE, etc
  def modify(url, method, headers, body \\ "", query_params \\ %{}) do
    HTTPoison.request(
      method,
      url,
      body |> encode(),
      headers
    )
    |> case do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {status_code, body}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
    |> (fn {ok, body} ->
          body
          |> Poison.decode(keys: :atoms)
          |> case do
            {:ok, parsed} -> {ok, parsed}
            _ -> {:error, body}
          end
        end).()
  end

  defp encode(raw) do
    body = Poison.encode(raw)
    IO.inspect(body)
    elem(body, 1)
  end
end
