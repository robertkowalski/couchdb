defmodule Chttpd.Graphql do
  def run() do
    doc = """
{
  item(id: "foo") {
    name
  }
}
"""


    Absinthe.run(doc, Chttpd.Schema, variables: %{"id" => "foo"})
  end
end
