--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP VIEW public.advice_up_idx;
DROP VIEW public.advice_down_idx;
DROP VIEW public.stock_w_fi;
DROP VIEW public.stock_w_ema;
DROP TABLE public.stock_hist;
DROP AGGREGATE public.ema(double precision, numeric);
DROP FUNCTION public.ema_func(state numeric, inval double precision, alpha numeric);
DROP PROCEDURAL LANGUAGE plpythonu;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: plpythonu; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: pi
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpythonu;


ALTER PROCEDURAL LANGUAGE plpythonu OWNER TO pi;

SET search_path = public, pg_catalog;

--
-- Name: ema_func(numeric, double precision, numeric); Type: FUNCTION; Schema: public; Owner: pi
--

CREATE FUNCTION ema_func(state numeric, inval double precision, alpha numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
begin
  return case
         when state is null then inval
         else alpha * inval + (1-alpha) * state
         end;
end
$$;


ALTER FUNCTION public.ema_func(state numeric, inval double precision, alpha numeric) OWNER TO pi;

--
-- Name: ema(double precision, numeric); Type: AGGREGATE; Schema: public; Owner: pi
--

CREATE AGGREGATE ema(double precision, numeric) (
    SFUNC = ema_func,
    STYPE = numeric
);


ALTER AGGREGATE public.ema(double precision, numeric) OWNER TO pi;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: stock_hist; Type: TABLE; Schema: public; Owner: pi; Tablespace: 
--

CREATE TABLE stock_hist (
    id SERIAL PRIMARY KEY,
    dt date,
    ticker text,
    open double precision,
    close double precision,
    low double precision,
    high double precision,
    volume double precision
);


ALTER TABLE stock_hist OWNER TO pi;

--
-- Name: stock_w_ema; Type: VIEW; Schema: public; Owner: pi
--

CREATE VIEW stock_w_ema AS
 SELECT stock_hist.id, stock_hist.dt,
    stock_hist.ticker,
    stock_hist.close,
    ema(stock_hist.close, 0.1818181818181818) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema10,
    ema(stock_hist.close, 0.0952380952380952) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema20,
    (avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) - avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)) AS ao,
    round((stock_hist.volume * (stock_hist.close - lag(stock_hist.close) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt)))) AS raw_fi,
    stock_hist.volume
   FROM stock_hist;


ALTER TABLE stock_w_ema OWNER TO pi;

--
-- Name: stock_w_fi; Type: VIEW; Schema: public; Owner: pi
--

CREATE VIEW stock_w_fi AS
 SELECT 
    stock_w_ema.id,
    stock_w_ema.dt,
    stock_w_ema.ticker,
    stock_w_ema.close,
    lag(stock_w_ema.close) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_close,
    lag(stock_w_ema.close, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_close,
    stock_w_ema.ema10,
    lag(stock_w_ema.ema10) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_ema10,
    lag(stock_w_ema.ema10, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_ema10,
    stock_w_ema.ema20,
    lag(stock_w_ema.ema20) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_ema20,
    lag(stock_w_ema.ema20, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_ema20,
    stock_w_ema.ao,
    lag(stock_w_ema.ao) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_ao,
    lag(stock_w_ema.ao, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_ao,
    ema(stock_w_ema.raw_fi, 0.6666666666666667) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi2,
    ema(stock_w_ema.raw_fi, 0.1428571428571429) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi13,
    stock_w_ema.volume
   FROM stock_w_ema;


ALTER TABLE stock_w_fi OWNER TO pi;

--
-- Name: advice_down_idx; Type: VIEW; Schema: public; Owner: pi
--

CREATE VIEW advice_down_idx AS
 SELECT stock_w_fi.dt,
    stock_w_fi.ticker,
    round((stock_w_fi.close)::numeric, 2) AS close,
    round((stock_w_fi.ao)::numeric, 2) AS ao,
    round((stock_w_fi.prev_ao)::numeric, 2) AS prev_ao,
    round(stock_w_fi.ema10, 2) AS ema10,
    round(stock_w_fi.ema20, 2) AS ema20,
    round(stock_w_fi.fi2, 2) AS fi2,
    round(stock_w_fi.fi13, 2) AS fi13,
    round((stock_w_fi.volume)::numeric, 2) AS volume
   FROM stock_w_fi
  WHERE (((((stock_w_fi.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stock_hist)) AND (stock_w_fi.fi2 > (0)::numeric)) AND (stock_w_fi.fi13 < (0)::numeric)) AND (stock_w_fi.ema10 < stock_w_fi.week_ago_ema20)) AND (stock_w_fi.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])));


ALTER TABLE advice_down_idx OWNER TO pi;

--
-- Name: advice_up_idx; Type: VIEW; Schema: public; Owner: pi
--

CREATE VIEW advice_up_idx AS
 SELECT stock_w_fi.dt,
    stock_w_fi.ticker,
    round((stock_w_fi.close)::numeric, 2) AS close,
    round((stock_w_fi.ao)::numeric, 2) AS ao,
    round((stock_w_fi.prev_ao)::numeric, 2) AS prev_ao,
    round(stock_w_fi.ema10, 2) AS ema10,
    round(stock_w_fi.ema20, 2) AS ema20,
    round(stock_w_fi.fi2, 2) AS fi2,
    round(stock_w_fi.fi13, 2) AS fi13,
    round((stock_w_fi.volume)::numeric, 2) AS volume
   FROM stock_w_fi
  WHERE (((((stock_w_fi.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stock_hist)) AND (stock_w_fi.fi2 < (0)::numeric)) AND (stock_w_fi.fi13 > (0)::numeric)) AND (stock_w_fi.ema10 > stock_w_fi.week_ago_ema20)) AND (stock_w_fi.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])));


ALTER TABLE advice_up_idx OWNER TO pi;

--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

