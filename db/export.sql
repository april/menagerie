COPY (SELECT DISTINCT ON (name, artist) name, artist, collector_number, set_code FROM magic_cards) TO '/Users/gregmacwilliam/Desktop/cards.csv' (format CSV);
COPY (SELECT DISTINCT name, artist FROM magic_cards) TO '/Users/gregmacwilliam/Desktop/cards.csv' (format CSV);

COPY (SELECT DISTINCT ON (name, artist)
  name,
  artist,
  jsonb(image_data->>'normal')->>'id',
  jsonb(image_data->>'large')->>'id',
  jsonb(image_data->>'art_crop')->>'id'
  FROM magic_cards) TO '/Users/gregmacwilliam/Desktop/cards.csv' (format CSV);