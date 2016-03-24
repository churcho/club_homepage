defmodule ClubHomepage.TextPage do
  use ClubHomepage.Web, :model

  alias ClubHomepage.ModelValidator

  schema "text_pages" do
    field :key, :string
    field :text, :string

    timestamps
  end

  @required_fields ~w(key text)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> ModelValidator.validate_uniqueness(:key)
  end
end
