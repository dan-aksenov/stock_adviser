# MOEX stock trading DSS.
Getting moex data with pandas DataReader

## Links:
http://pandas-datareader.readthedocs.io/en/latest/readers/moex.html 	 	
http://pandas-datareader.readthedocs.io/en/latest/remote_data.html#remote-data-moex

## Blueprints:
```
import pandas_datareader.data as web
df = web.DataReader('SBER', 'moex', start='2017-07-01', end='2017-07-31')
df = web.DataReader('SBER', 'moex', start='2018-01-01')
df.loc[(df['BOARDID'] == 'TQBR'), 'CLOSE']
```
