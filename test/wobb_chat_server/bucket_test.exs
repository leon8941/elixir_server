require IEx

defmodule ElixirChatbotInterface.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = ElixirChatbotInterface.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert ElixirChatbotInterface.Bucket.get(bucket, "milk") == nil

    ElixirChatbotInterface.Bucket.put(bucket, "milk", 3)
    assert ElixirChatbotInterface.Bucket.get(bucket, "milk") == 3
  end
end
