# Utilities scripts from stocker database recreate.
pg_dump --format plain --schema="stocker" --schema-only --verbose --file schema.sql stocker

psql -f schema.sql -U stocker stocker

psql -U stocker stocker -c "copy stock_hist(dt,ticker,open,close,low,high,volume) FROM '/file'"
