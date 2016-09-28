defmodule Chttpd.Schema do
  use Absinthe.Schema

  @fake_db %{
    "foo" => %{id: "foo", name: "Foo", value: 4},
    "bar" => %{id: "bar", name: "Bar", value: 5}
  }

  query do
    @desc "Get an item by ID"
    field :item, type: :item do

      @desc "The ID of the item"
      arg :id, :id

      resolve fn %{id: id}, _ ->
        {:ok, Map.get(@fake_db, id)}
      end
    end
  end

  @desc "A valuable item"
  object :item do
    field :id, :id
    field :name, :string, description: "The item's name"
    field :value, :integer, description: "Recently appraised value"
  end
end
