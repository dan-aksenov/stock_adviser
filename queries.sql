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

--deals hist update //draft to be fixed
select * from deal_hist d where price_open = 
(select close from stock_hist s where s.dt = (select max(dt) from stock_hist) 
and d.ticker = s.ticker 
and (
(s.close::float-d.price_open::float)/d.price_open::float>0.05
or
--to be fixed
(s.close::float-d.price_open::float)/d.price_open::float>0.02
));

update deals_hist d set dt_close = now and price_close = close 
where close,ticker = (
select * from stock_hist s on date=date and ticker=ticker
where
(s.close-d.open)=5% or (s.close-d.open)=2%)
