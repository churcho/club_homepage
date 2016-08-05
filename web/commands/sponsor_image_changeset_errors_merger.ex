defmodule ClubHomepage.SponsorImageChangesetErrorsMerger do

  alias Ecto.Changeset
  alias ClubHomepage.SponsorImage

  def merge(changeset1, changeset2) do
    errors = Keyword.merge(changeset2.errors, changeset1.errors)
    changeset = %Ecto.Changeset{changeset1 | errors: errors}

    case Enum.count(changeset.errors) do
      0 -> changeset
      _ -> %Changeset{changeset | valid?: false}
    end
  end

  defp add_error(changeset, field, value) do
    Changeset.add_error(changeset, field, value)
  end
end
