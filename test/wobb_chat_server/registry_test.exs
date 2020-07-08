defmodule ElixirChatbotInterface.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(ElixirChatbotInterface.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert ElixirChatbotInterface.Registry.lookup(registry, "shopping") == :error

    ElixirChatbotInterface.Registry.create(registry, "shopping")
    assert {:ok, bucket} = ElixirChatbotInterface.Registry.lookup(registry, "shopping")

    ElixirChatbotInterface.Bucket.put(bucket, "milk", 1)
    assert ElixirChatbotInterface.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    ElixirChatbotInterface.Registry.create(registry, "shopping")
    {:ok, bucket} = ElixirChatbotInterface.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert ElixirChatbotInterface.Registry.lookup(registry, "shopping") == :error
  end

  test "test reading json", %{} do
    file_path = "./test/test_data/sendbird_callback_sample_data.json"

    {:ok, result} = with {:ok, body} <- File.read(file_path),
          {:ok, json} <- Poison.decode(body), do: {:ok, json}

    assert result["bot"]["bot_nickname"] == "AIVI"
  end

  # test "removes bucket on crash", %{registry: registry} do
  #   ElixirChatbotInterface.Registry.create(registry, "shopping")
  #   {:ok, bucket} = ElixirChatbotInterface.Registry.lookup(registry, "shopping")

  #   # Stop the bucket with non-normal reason
  #   Agent.stop(bucket, :shutdown)
  #   assert ElixirChatbotInterface.Registry.lookup(registry, "shopping") == :error
  # end

end
