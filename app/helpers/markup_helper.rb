# frozen_string_literal: true

module MarkupHelper

  # Inserts the content of an SVG file in assets/images onto the page
  # The SVG must already be optimized
  def inline_svg(image_path, opts={})
    svg = File.read(Rails.root.join("app/assets/images/#{image_path}.svg"))
    svg.sub!(/^\s*<svg\b/, %Q(<svg aria-hidden="true" focusable="false" class="#{opts[:class]}"))
    return raw(svg)
  end


end
