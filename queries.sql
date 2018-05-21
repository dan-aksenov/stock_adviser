--check strategy.
-- ticker, buy signal, week after gane
with a as
(select ticker,count(*) cnt from stock_w_fi_2 where ema10>week_ago_ema10 and ao > week_ago_ao and fi2<0 group by ticker),
b as (select ticker,count(*) cnt from stock_w_fi_2 where ema10>week_ago_ema10 and ao > week_ago_ao and fi2<0 and next_week_close > close group by ticker)
select a.ticker, a.cnt, b.cnt from a join b on a.ticker=b.ticker

--winning positions pct
select ticker,next_week_close/close from stock_w_fi_2 where ema10>week_ago_ema10 and ao > week_ago_ao and fi2<0 and next_week_close > close and ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'
::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text]);

--advisory query
select ticker,close,prev_close from stock_w_fi_2 
where ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO':
:text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text
,'LNTA'::text])
and dt = current_date-3 and
ema10 > week_ago_ema10 and fi2<0 
and fi13>0 
and close < prev_close;

--deals hist inserts
insert into deal_hist("dt_open","ticker","price_open") select now(),ticker,close from long;
insert into deal_hist("dt_open","ticker","price_open") select now(),ticker,-(close) from short;

--deals hist update for longs
select s.dt,s.ticker,s.open as to_close,d.dt_open,d.ticker,d.price_open
from stock_hist s join deal_hist d on d.ticker = s.ticker
where s.dt = (select max(dt) from stock_hist)
and (
(s.close::float-d.price_open::float)/d.price_open::float>0.05
or
(s.close::float-d.price_open::float)/d.price_open::float<0.02
) and d.price_open >0

--working
update deal_hist set
dt_close=subq.dt,
price_close=subq.to_close
from
(select s.dt,s.ticker,s.open as to_close,d.dt_open,d.price_open
from stock_hist s join deal_hist d on d.ticker = s.ticker
where s.dt = (select max(dt) from stock_hist)
and (
(s.close::float-d.price_open::float)/d.price_open::float>0.05
or
(s.close::float-d.price_open::float)/d.price_open::float<0.02
) and d.price_open >0) as subq
where deal_hist.ticker = subq.ticker
and deal_hist.price_open >0
;

  
-- for shorts to check
update deal_hist set
dt_close=subq.dt,
price_close=subq.to_close
from
(select s.dt,s.ticker,-s.open as to_close,d.dt_open,d.price_open
from stock_hist s join deal_hist d on d.ticker = s.ticker
where s.dt = (select max(dt) from stock_hist)
and (
(-s.close::float-d.price_open::float)/-d.price_open::float>0.05
or
(-s.close::float-d.price_open::float)/-d.price_open::float<0.02
) and d.price_open <0) as subq
where deal_hist.ticker = subq.ticker
and deal_hist.price_open <0;

-- select result
select ticker,price_open,price_close,price_close-price_open as result from deal_hist;