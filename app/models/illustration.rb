class Illustration < ActiveRecord::Base

  has_many :content_tags, as: :taggable
  has_many :tag_submissions, as: :taggable
  has_many :tags, through: :content_tags
  belongs_to :oracle_card, class_name: 'OracleCard', foreign_key: 'oracle_id'

  before_create :generate_slug

  def uri
    $routes.show_illustration_path(slug)
  end

  def scryfall_uri
    "https://scryfall.com/search?q=%21%22#{ name.split(" ").join("+") }%22+a%3A%22#{ artist.split(" ").join("+") }%22"
  end

  def image_normal_uri
    "https://img.scryfall.com/#{ image_normal }"
  end

  def image_large_uri
    "https://img.scryfall.com/#{ image_large }"
  end

  def set_printing!(pid)
    card = MagicCard.find_by(printing_id: pid)
    unless card.oracle_id == oracle_id && card.artist == artist
      raise ArgumentError.new("printing must have the same oracle card and artist")
    end

    self.set_code = card.set_code
    self.layout = card.layout
    self.frame = card.frame

    image_data = face > 1 && card.image_2_data ? card.image_2_data : card.image_data
    self.image_normal = image_data.dig("normal", "id")
    self.image_large = image_data.dig("large", "id")

    self.save
    return self
  end

  def create_printing_variant!(pid)
    return Illustration.new({
      oracle_id: oracle_id,
      artist_id: artist_id,
      name: name,
      artist: artist,
      face: face,
    }).set_printing!(pid)
  end

protected

  def generate_slug
    slug_name = name.to_s.strip.gsub(/(?!-)[[:punct:]]/, "")
    slug_artist = artist.to_s.strip.gsub(/(?!-)[[:punct:]]/, "")
    slug_base = [slug_name.split(" ")[0..7], slug_artist.split(" ")].flatten.join("-").downcase

    self.slug = loop do
      random_slug = [slug_base, rand(0..9999).to_s.rjust(4, '0')].join("-")
      break random_slug unless self.class.exists?(slug: random_slug)
    end
  end

end