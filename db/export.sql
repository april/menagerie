COPY (SELECT DISTINCT ON (name, artist) name, artist, collector_number, set_code FROM magic_cards) TO '/Users/gregmacwilliam/Desktop/cards.csv' (format CSV);
COPY (SELECT DISTINCT name, artist FROM magic_cards) TO '/Users/gregmacwilliam/Desktop/cards.csv' (format CSV);

COPY (SELECT DISTINCT ON (name, artist)
  name,
  artist,
  jsonb(image_data->>'normal')->>'id',
  jsonb(image_data->>'large')->>'id',
  jsonb(image_data->>'art_crop')->>'id'
  FROM magic_cards) TO '/Users/gregmacwilliam/Desktop/cards.csv' (format CSV);

COPY (SELECT * FROM (
      SELECT name, id, oracle_id, illustration_id, jsonb(image_data->>'small')->>'id', ROW_NUMBER() OVER(
        PARTITION BY illustration_id ORDER BY oracle_id asc
      )
      AS Row FROM (SELECT printings.id, printings.illustration_id, printings.oracle_id, printings.image_data, oracle_cards.name FROM printings INNER JOIN oracle_cards ON oracle_cards.id = printings.oracle_id) AS joined
    )
    dups WHERE dups.Row > 1 ORDER BY oracle_id)
TO '/Users/gregmacwilliam/Desktop/dups.csv' (format CSV);


SELECT illustration_id, COUNT(illustration_id) AS Occurences (
  SELECT printings.id, printings.illustration_id, printings.oracle_id, oracle_cards.name FROM printings INNER JOIN oracle_cards ON oracle_cards.id = printings.oracle_id) AS Joined
) FROM Joined

SELECT printings.id, printings.oracle_id, printings.illustration_id, COUNT(printings.illustration_id) AS Occurences FROM printings GROUP BY printings.illustration_id


SELECT * FROM (
  SELECT illustration_id, COUNT(illustration_id) AS Occurences FROM printings GROUP BY illustration_id
) AS ;


COPY (SELECT
  oracle_cards.name,
  dups.id,
  dups.oracle_id,
  dups.illustration_id
FROM (
  SELECT id, oracle_id, illustration_id FROM printings WHERE illustration_id IN (
    SELECT illustration_id FROM printings GROUP BY illustration_id HAVING COUNT(*) > 1
  )
) AS dups
INNER JOIN oracle_cards ON oracle_cards.id = dups.oracle_id ORDER BY dups.oracle_id)
TO '/Users/gregmacwilliam/Desktop/dups.csv' (format CSV);


COPY printing_illustrations TO '/Users/gregmacwilliam/Desktop/pi.csv' DELIMITER ',' CSV HEADER;