--check strategy.
-- ticker, buy signal, week after gane
with a as
(select ticker,count(*) cnt from stock_w_fi_2 where ema10>week_ago_ema10 and ao > week_ago_ao and fi2<0 group by ticker),
b as (select ticker,count(*) cnt from stock_w_fi_2 where ema10>week_ago_ema10 and ao > week_ago_ao and fi2<0 and next_week_close > close group by ticker)
select a.ticker, a.cnt, b.cnt from a join b on a.ticker=b.ticker