/*with recursive t as (
    select dt, 
           0.5 as alpha,
           row_number() over (),
           raw_fi
    from stock_w_ma where ticker = 'SBER'        
),
ema as (
    select *, raw_fi as sales_ema from t 
    where row_number = 1
    union all
    select t2.dt, 
           t2.alpha, 
           t2.row_number, 
           t2.raw_fi, 
           t2.alpha * t2.raw_fi + (1.0 - t2.alpha) * ema.raw_fi as sales_ema
    from ema
    join t t2 on ema.row_number = t2.row_number - 1
)
select dt, raw_fi, sales_ema
from ema;	
*/
--more https://stackoverflow.com/questions/8871426/how-to-calculate-an-exponential-moving-average-on-postgres
create or replace function ema_func(state numeric, inval float, alpha numeric)
  returns numeric
  language plpgsql as $$
begin
  return case
         when state is null then inval
         else alpha * inval + (1-alpha) * state
         end;
end
$$;

create aggregate ema(float, numeric) (sfunc = ema_func, stype = numeric);

--select dt,close,ema(close, 0.5) over (partition by ticker order by dt asc) from stock_hi st where ticker = 'SBER'
