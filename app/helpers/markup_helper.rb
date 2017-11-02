# frozen_string_literal: true

module MarkupHelper

  # Inserts the content of an SVG file in assets/images onto the page
  # The SVG must already be optimized
  def inline_svg(image_path, opts={})
    svg = File.read(Rails.root.join("app/assets/images/#{image_path}.svg"))
    svg.sub!(/^\s*<svg\b/, %Q(<svg aria-hidden="true" focusable="false" class="#{opts[:class]}"))
    return raw(svg)
  end

  def inline_svg_symbol(image_path, id:nil)
    svg = File.read(Rails.root.join("app/assets/images/#{image_path}.svg"))
    svg.sub!(/^\s*<svg\b/, %Q(<symbol id="#{id}" )).sub!(/<\/svg>/, "</symbol>")
    return raw(svg)
  end

  # Provides a collection of search types for the search form
  def search_type_collection
    return [
      ["card", "Card Name"],
      ["artist", "Artist Name"],
      ["tag", "Tag"],
    ]
  end

  def tag_type_collection
    return [
      [ContentTag::Type::ILLUSTRATION, "artwork"],
      [ContentTag::Type::ORACLE_CARD, "card"]
    ]
  end

  def link_type_collection
    return [
      "similar",
      "better",
      "worse",
      "related",
    ]
  end

  def is_admin_screen?
    return params[:controller].start_with?("admin/")
  end

end
