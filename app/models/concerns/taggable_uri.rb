module TaggableUri

  def taggable_uri
    case taggable_type
    when Illustration.class.name
      return $routes.show_illustration_path(taggable.slug)
    when OracleCard.class.name
      return $routes.show_oracle_card_path(taggable.id)
    end
  end

end