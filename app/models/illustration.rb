class Illustration < ActiveRecord::Base

  has_many :illustration_tags
  has_many :tags, through: :illustration_tags

  def new_tags(tags)
    current_tags = self.tags.pluck(:name).map(&:downcase)
    tags
      .select(&:present?)
      .map { |t| t.strip.squish }
      .select { |t| !current_tags.include?(t.downcase) }
      .uniq
      .map { |t| Tag.new(name: t) }
  end

  def create_tags!(tags)
    new_tags(tags).each do |t|
      self.tags << Tag.find_or_create_by(name: t.name)
    end

    update_attributes(tagged: self.tags.any?)
  end

  def scryfall_uri
    "https://scryfall.com/search?q=%21%22#{ name.split(" ").join("+") }%22+a%3A%22#{ artist.split(" ").join("+") }%22"
  end

end