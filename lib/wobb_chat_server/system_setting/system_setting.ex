defmodule ElixirChatbotInterface.SystemSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "system_settings" do
    field :boolean_val, :boolean, default: false
    field :created_at, :naive_datetime
    field :description, :string
    field :integer_val, :integer
    field :name, :string
    field :string_val, :string
    field :updated_at, :naive_datetime
  end

  @doc false
  def changeset(system_setting, attrs) do
    system_setting
    |> cast(attrs, [:name, :description, :string_val, :boolean_val, :integer_val, :created_at, :updated_at])
    |> validate_required([:name, :description, :string_val, :boolean_val, :integer_val, :created_at, :updated_at])
  end
end
