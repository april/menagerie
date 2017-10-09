SCRYFALL_DB = YAML.load(
  ERB.new(
    IO.read(Rails.root.join("config", "database_scryfall.yml"))
  ).result
)[Rails.env.to_s]