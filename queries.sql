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
select ticker,close,prev_close from stock_w_fi_2 where ema10 > week_ago_ema10 and fi2<0 and dt = current_date-3 and fi13>0 and close < prev_close;