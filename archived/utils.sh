# Utilities scripts from stocker database recreate.
pg_dump --format plain --schema="stocker" --schema-only --verbose --file schema.sql stocker

psql -f schema.sql -U stocker stocker

psql -c "copy stock_hist(dt,ticker,open,close,low,high,volume) FROM '/tmp/stocks.csv'" -U stocker stocker

# Create HTML Report
psql -U stocker -H -c "select ticker Longs from long" stocker > d:\tmp\stock.html
psql -U stocker -H -c "select ticker Shorts from short" stocker >> d:\tmp\stock.html

