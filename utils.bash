# Utilities scripts from stocker database recreate.
pg_dump --format plain --schema="stocker" --clean --schema-only --verbose --file schema.sql stocker

psql -f schema.sql -U stocker stocker

psql -U stocker stocker -c "copy.."