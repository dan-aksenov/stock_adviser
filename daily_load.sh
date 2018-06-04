#!/bin/bash
# daily reload
rm /tmp/stocks.csv
cd ~/projects/stock_adviser/
/usr/bin/python ~/projects/stock_adviser/get_multiple.py -c ~/moex.json -b 90 -d /tmp/stocks.csv
psql -c "truncate table stock_hist" -h pi.home -U stocker stocker
psql -c "copy stock_hist(dt,ticker,open,close,low,high,volume) FROM '/tmp/stocks.csv'" -h pi.home -U stocker stocker
psql -h pi.home -U stocker -H -c "select ticker Longs from long" stocker > /var/www/html/index.html
psql -h pi.home -U stocker -H -c "select ticker Shorts from short" stocker >> /var/www/html/index.html
