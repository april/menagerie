# frozen_string_literal: true

class Illustration < ActiveRecord::Base

  has_many :content_tags
  has_many :tag_submissions
  has_many :tags, through: :content_tags
  has_many :printing_illustrations
  belongs_to :oracle_card, class_name: "OracleCard", foreign_key: "oracle_id"
  has_and_belongs_to_many :printings, class_name: "Printing", join_table: :printing_illustrations

  before_create :generate_slug

  def all_content_tags
    @all_content_tags ||= ContentTag.where(["illustration_id = ? OR oracle_id = ?", id, oracle_id])
  end

  def illustration_tags
    all_content_tags.select { |t| t.oracle_id.nil? }
  end

  def oracle_tags
    all_content_tags.select { |t| t.oracle_id.present? }
  end

  def search_type
    "illustration"
  end

  def uri
    $routes.show_illustration_path(slug)
  end

  def oracle_uri
    $routes.show_oracle_card_path(slug)
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
    p = Printing.find_with_set_code(pid)
    unless p.oracle_id == oracle_id && p.artist_id == artist_id
      raise ArgumentError.new("printing must have the same oracle card and artist")
    end

    self.printing_id = p.id
    self.set_code = p.set_code
    self.frame = p.frame

    image_data = face > 1 && p.image_2_data.present? ? p.image_2_data : p.image_data
    self.image_normal = image_data.dig("normal", "id")
    self.image_large = image_data.dig("large", "id")

    self.save
    return self
  end

  def create_printing_variant!(pid)
    return Illustration.new({
      oracle_id: oracle_id,
      artist_id: artist_id,
      face: face,
      name: name,
      artist: artist,
      layout: layout,
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