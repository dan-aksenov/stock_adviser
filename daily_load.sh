# daily reload
rm /tmp/stocks.csv
python get_multiple.py -c /dd -b 90 -d /tmp/stocks.csv
psql -c "truncate table stock_hist" -U stocker stocker
psql -c "copy stock_hist(dt,ticker,open,close,low,high,volume) FROM '/tmp/stocks.csv'" -U stocker stocker