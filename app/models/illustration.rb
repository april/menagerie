class Illustration < ActiveRecord::Base

  has_many :illustration_tags
  has_many :tags, through: :illustration_tags
  has_many :tag_submissions

  def uri
    $routes.show_illustration_path(slug)
  end

  def scryfall_uri
    "https://scryfall.com/search?q=%21%22#{ name.split(" ").join("+") }%22+a%3A%22#{ artist.split(" ").join("+") }%22"
  end

end