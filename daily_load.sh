# daily reload
rm /tmp/stocks.csv
python get_multiple.py -c ~/moex.json -b 90 -d /tmp/stocks.csv
psql -c "truncate table stock_hist" -h pi.home -U stocker stocker
psql -c "copy stock_hist(dt,ticker,open,close,low,high,volume) FROM '/tmp/stocks.csv'" -h pi.home -U stocker stocker
