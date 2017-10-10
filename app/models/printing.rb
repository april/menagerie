class Printing < ScryfallModel

  def image_uri(size)
    return %{https://img.scryfall.com/#{image_data.dig(size.to_s, "id")}}
  end

end