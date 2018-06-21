--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3
-- Dumped by pg_dump version 10.3

-- Started on 2018-05-21 16:15:34

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 16386)
-- Name: stocker; Type: SCHEMA; Schema: -; Owner: stocker
--

CREATE SCHEMA stocker;


ALTER SCHEMA stocker OWNER TO stocker;

--
-- TOC entry 211 (class 1255 OID 16387)
-- Name: ema_func(numeric, numeric); Type: FUNCTION; Schema: stocker; Owner: stocker
--

CREATE FUNCTION stocker.ema_func(numeric, numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$
declare
  alpha numeric := 0.5;
begin
  -- uncomment the following line to see what the parameters mean
  -- raise info 'ema_func: % %', $1, $2;
  return case
              when $1 is null then $2
              else alpha * $2 + (1 - alpha) * $1
         end;
end
$_$;


ALTER FUNCTION stocker.ema_func(numeric, numeric) OWNER TO stocker;

--
-- TOC entry 217 (class 1255 OID 16388)
-- Name: ema_func(numeric, double precision, numeric); Type: FUNCTION; Schema: stocker; Owner: stocker
--

CREATE FUNCTION stocker.ema_func(state numeric, inval double precision, alpha numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
begin
  return case
         when state is null then inval
         else alpha * inval + (1-alpha) * state
         end;
end
$$;


ALTER FUNCTION stocker.ema_func(state numeric, inval double precision, alpha numeric) OWNER TO stocker;

--
-- TOC entry 213 (class 1255 OID 16389)
-- Name: ema_func(numeric, numeric, numeric); Type: FUNCTION; Schema: stocker; Owner: stocker
--

CREATE FUNCTION stocker.ema_func(state numeric, inval numeric, alpha numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
begin
  return case
         when state is null then inval
         else alpha * inval + (1-alpha) * state
         end;
end
$$;


ALTER FUNCTION stocker.ema_func(state numeric, inval numeric, alpha numeric) OWNER TO stocker;

--
-- TOC entry 626 (class 1255 OID 16390)
-- Name: ema(numeric); Type: AGGREGATE; Schema: stocker; Owner: stocker
--

CREATE AGGREGATE stocker.ema(numeric) (
    SFUNC = stocker.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE stocker.ema(numeric) OWNER TO stocker;

--
-- TOC entry 627 (class 1255 OID 16391)
-- Name: ema(double precision, numeric); Type: AGGREGATE; Schema: stocker; Owner: stocker
--

CREATE AGGREGATE stocker.ema(double precision, numeric) (
    SFUNC = stocker.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE stocker.ema(double precision, numeric) OWNER TO stocker;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 205 (class 1259 OID 16431)
-- Name: deal_hist; Type: TABLE; Schema: stocker; Owner: stocker
--

CREATE TABLE stocker.deal_hist (
    id integer NOT NULL,
    dt_open date,
    dt_close date,
    ticker text,
    price_open double precision,
    price_close double precision
);


ALTER TABLE stocker.deal_hist OWNER TO stocker;

--
-- TOC entry 206 (class 1259 OID 16438)
-- Name: deal_analyzer; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stocker.deal_analyzer AS
 SELECT deal_hist.dt_open,
    deal_hist.dt_close,
    (deal_hist.dt_close - deal_hist.dt_open) AS days_total,
    deal_hist.ticker,
    deal_hist.price_open,
    deal_hist.price_close,
    (deal_hist.price_close - deal_hist.price_open) AS result,
    (((deal_hist.price_close * (100)::double precision) / deal_hist.price_open) - (100)::double precision) AS result_pct
   FROM stocker.deal_hist;


ALTER TABLE stocker.deal_analyzer OWNER TO stocker;

--
-- TOC entry 204 (class 1259 OID 16429)
-- Name: deal_hist_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE stocker.deal_hist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stocker.deal_hist_id_seq OWNER TO stocker;

--
-- TOC entry 2199 (class 0 OID 0)
-- Dependencies: 204
-- Name: deal_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE stocker.deal_hist_id_seq OWNED BY stocker.deal_hist.id;


--
-- TOC entry 197 (class 1259 OID 16392)
-- Name: stock_hist; Type: TABLE; Schema: stocker; Owner: stocker
--

CREATE TABLE stocker.stock_hist (
    id integer NOT NULL,
    dt date,
    ticker text,
    open double precision,
    close double precision,
    low double precision,
    high double precision,
    volume double precision
);


ALTER TABLE stocker.stock_hist OWNER TO stocker;

--
-- TOC entry 198 (class 1259 OID 16398)
-- Name: stock_w_ema; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stocker.stock_w_ema AS
 SELECT stock_hist.id,
    stock_hist.dt,
    stock_hist.ticker,
    stock_hist.open,
    stock_hist.close,
    stock_hist.low,
    stock_hist.high,
    stocker.ema(stock_hist.close, 0.1818181818181818) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema10,
    stocker.ema(stock_hist.close, 0.0952380952380952) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema20,
    (avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) - avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)) AS ao,
    round((stock_hist.volume * (stock_hist.close - lag(stock_hist.close) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt)))) AS raw_fi,
    stock_hist.volume
   FROM stocker.stock_hist;


ALTER TABLE stocker.stock_w_ema OWNER TO stocker;

--
-- TOC entry 199 (class 1259 OID 16403)
-- Name: stock_w_fi_2; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stocker.stock_w_fi_2 AS
 SELECT stock_w_ema.id,
    stock_w_ema.dt,
    stock_w_ema.ticker,
    stock_w_ema.close,
    lag(stock_w_ema.close) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_close,
    lag(stock_w_ema.close, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_close,
    stock_w_ema.ema10,
    lag(stock_w_ema.ema10) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_ema10,
    lag(stock_w_ema.ema10, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_ema10,
    lag(stock_w_ema.ema10, 14) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS iiweek_ago_ema10,
    stock_w_ema.ema20,
    lag(stock_w_ema.ema20) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_ema20,
    lag(stock_w_ema.ema20, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_ema20,
    lag(stock_w_ema.ema20, 14) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS iiweek_ago_ema20,
    stock_w_ema.ao,
    lag(stock_w_ema.ao) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS prev_ao,
    lag(stock_w_ema.ao, 7) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS week_ago_ao,
    stocker.ema(stock_w_ema.raw_fi, 0.6666666666666667) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi2,
    stocker.ema(stock_w_ema.raw_fi, 0.1428571428571429) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi13,
    stock_w_ema.volume
   FROM stocker.stock_w_ema;


ALTER TABLE stocker.stock_w_fi_2 OWNER TO stocker;

--
-- TOC entry 200 (class 1259 OID 16408)
-- Name: long; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stocker.long AS
 SELECT stock_w_fi_2.ticker,
    stock_w_fi_2.close,
    stock_w_fi_2.prev_close
   FROM stocker.stock_w_fi_2
  WHERE ((stock_w_fi_2.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])) AND (stock_w_fi_2.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stocker.stock_hist)) AND (stock_w_fi_2.ema10 > stock_w_fi_2.week_ago_ema10) AND (stock_w_fi_2.ema10 > stock_w_fi_2.iiweek_ago_ema10) AND (stock_w_fi_2.fi2 < (0)::numeric) AND (stock_w_fi_2.fi13 > (0)::numeric) AND (stock_w_fi_2.ema20 > stock_w_fi_2.week_ago_ema20) AND (stock_w_fi_2.ema20 > stock_w_fi_2.iiweek_ago_ema20));


ALTER TABLE stocker.long OWNER TO stocker;

--
-- TOC entry 201 (class 1259 OID 16413)
-- Name: short; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stocker.short AS
 SELECT stock_w_fi_2.ticker,
    stock_w_fi_2.close,
    stock_w_fi_2.prev_close
   FROM stocker.stock_w_fi_2
  WHERE ((stock_w_fi_2.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])) AND (stock_w_fi_2.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stocker.stock_hist)) AND (stock_w_fi_2.ema10 < stock_w_fi_2.week_ago_ema10) AND (stock_w_fi_2.ema10 < stock_w_fi_2.iiweek_ago_ema10) AND (stock_w_fi_2.fi2 > (0)::numeric) AND (stock_w_fi_2.fi13 < (0)::numeric) AND (stock_w_fi_2.ema20 < stock_w_fi_2.week_ago_ema20) AND (stock_w_fi_2.ema20 < stock_w_fi_2.iiweek_ago_ema20));


ALTER TABLE stocker.short OWNER TO stocker;

--
-- TOC entry 202 (class 1259 OID 16418)
-- Name: stock_hist_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE stocker.stock_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stocker.stock_hist_id_seq OWNER TO stocker;

--
-- TOC entry 2200 (class 0 OID 0)
-- Dependencies: 202
-- Name: stock_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE stocker.stock_hist_id_seq OWNED BY stocker.stock_hist.id;


--
-- TOC entry 203 (class 1259 OID 16420)
-- Name: stock_w_fi; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stocker.stock_w_fi AS
 SELECT stock_w_ema.id,
    stock_w_ema.dt,
    stock_w_ema.ticker,
    stock_w_ema.open,
    stock_w_ema.close,
    stock_w_ema.low,
    stock_w_ema.high,
    stock_w_ema.ema10,
    stock_w_ema.ema20,
    stock_w_ema.ao,
    stocker.ema(stock_w_ema.raw_fi, 0.6666666666666667) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi2,
    stocker.ema(stock_w_ema.raw_fi, 0.1428571428571429) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi13,
    stock_w_ema.volume
   FROM stocker.stock_w_ema
  WHERE (stock_w_ema.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text]));


ALTER TABLE stocker.stock_w_fi OWNER TO stocker;

--
-- TOC entry 2063 (class 2604 OID 16434)
-- Name: deal_hist id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY stocker.deal_hist ALTER COLUMN id SET DEFAULT nextval('stocker.deal_hist_id_seq'::regclass);


--
-- TOC entry 2062 (class 2604 OID 16428)
-- Name: stock_hist id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY stocker.stock_hist ALTER COLUMN id SET DEFAULT nextval('stocker.stock_hist_id_seq'::regclass);


--
-- TOC entry 2065 (class 2606 OID 16427)
-- Name: stock_hist stock_hist_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY stocker.stock_hist
    ADD CONSTRAINT stock_hist_pkey PRIMARY KEY (id);


--
-- TOC entry 2198 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA stocker; Type: ACL; Schema: -; Owner: stocker
--

GRANT ALL ON SCHEMA stocker TO postgres;
GRANT ALL ON SCHEMA stocker TO PUBLIC;


-- Completed on 2018-05-21 16:15:36

--
-- PostgreSQL database dump complete
--

