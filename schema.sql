--
-- PostgreSQL database dump
--

-- Dumped from database version 9.4.15
-- Dumped by pg_dump version 9.4.15
-- Started on 2018-05-07 20:02:22 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 8 (class 2615 OID 33232)
-- Name: stocker; Type: SCHEMA; Schema: -; Owner: stocker
--

CREATE SCHEMA stocker;


ALTER SCHEMA stocker OWNER TO stocker;

SET search_path = stocker, pg_catalog;

--
-- TOC entry 193 (class 1255 OID 33233)
-- Name: ema_func(numeric, numeric); Type: FUNCTION; Schema: stocker; Owner: stocker
--

CREATE FUNCTION ema_func(numeric, numeric) RETURNS numeric
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
-- TOC entry 194 (class 1255 OID 33234)
-- Name: ema_func(numeric, double precision, numeric); Type: FUNCTION; Schema: stocker; Owner: stocker
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


ALTER FUNCTION stocker.ema_func(state numeric, inval double precision, alpha numeric) OWNER TO stocker;

--
-- TOC entry 195 (class 1255 OID 33235)
-- Name: ema_func(numeric, numeric, numeric); Type: FUNCTION; Schema: stocker; Owner: stocker
--

CREATE FUNCTION ema_func(state numeric, inval numeric, alpha numeric) RETURNS numeric
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
-- TOC entry 556 (class 1255 OID 33236)
-- Name: ema(numeric); Type: AGGREGATE; Schema: stocker; Owner: stocker
--

CREATE AGGREGATE ema(numeric) (
    SFUNC = stocker.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE stocker.ema(numeric) OWNER TO stocker;

--
-- TOC entry 557 (class 1255 OID 33237)
-- Name: ema(double precision, numeric); Type: AGGREGATE; Schema: stocker; Owner: stocker
--

CREATE AGGREGATE ema(double precision, numeric) (
    SFUNC = stocker.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE stocker.ema(double precision, numeric) OWNER TO stocker;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 174 (class 1259 OID 33238)
-- Name: stock_hist; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
--

CREATE TABLE stock_hist (
    id integer NOT NULL,
    dt date,
    ticker text,
    open double precision,
    close double precision,
    low double precision,
    high double precision,
    volume double precision
);


ALTER TABLE stock_hist OWNER TO stocker;

--
-- TOC entry 176 (class 1259 OID 33246)
-- Name: stock_w_ema; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stock_w_ema AS
 SELECT stock_hist.id,
    stock_hist.dt,
    stock_hist.ticker,
    stock_hist.open,
    stock_hist.close,
    stock_hist.low,
    stock_hist.high,
    ema(stock_hist.close, 0.1818181818181818) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema10,
    ema(stock_hist.close, 0.0952380952380952) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema20,
    (avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) - avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)) AS ao,
    round((stock_hist.volume * (stock_hist.close - lag(stock_hist.close) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt)))) AS raw_fi,
    stock_hist.volume
   FROM stock_hist;


ALTER TABLE stock_w_ema OWNER TO stocker;

--
-- TOC entry 178 (class 1259 OID 33294)
-- Name: stock_w_fi_2; Type: VIEW; Schema: stocker; Owner: pi
--

CREATE VIEW stock_w_fi_2 AS
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
    ema(stock_w_ema.raw_fi, 0.6666666666666667) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi2,
    ema(stock_w_ema.raw_fi, 0.1428571428571429) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi13,
    stock_w_ema.volume
   FROM stock_w_ema;


ALTER TABLE stock_w_fi_2 OWNER TO pi;

--
-- TOC entry 180 (class 1259 OID 33304)
-- Name: long; Type: VIEW; Schema: stocker; Owner: pi
--

CREATE VIEW long AS
 SELECT stock_w_fi_2.ticker,
    stock_w_fi_2.close,
    stock_w_fi_2.prev_close
   FROM stock_w_fi_2
  WHERE ((((((((stock_w_fi_2.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])) AND (stock_w_fi_2.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stock_hist))) AND (stock_w_fi_2.ema10 > stock_w_fi_2.week_ago_ema10)) AND (stock_w_fi_2.ema10 > stock_w_fi_2.iiweek_ago_ema10)) AND (stock_w_fi_2.fi2 < (0)::numeric)) AND (stock_w_fi_2.fi13 > (0)::numeric)) AND (stock_w_fi_2.ema20 > stock_w_fi_2.week_ago_ema20)) AND (stock_w_fi_2.ema20 > stock_w_fi_2.iiweek_ago_ema20));


ALTER TABLE long OWNER TO pi;

--
-- TOC entry 179 (class 1259 OID 33299)
-- Name: short; Type: VIEW; Schema: stocker; Owner: pi
--

CREATE VIEW short AS
 SELECT stock_w_fi_2.ticker,
    stock_w_fi_2.close,
    stock_w_fi_2.prev_close
   FROM stock_w_fi_2
  WHERE ((((((((stock_w_fi_2.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])) AND (stock_w_fi_2.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stock_hist))) AND (stock_w_fi_2.ema10 < stock_w_fi_2.week_ago_ema10)) AND (stock_w_fi_2.ema10 < stock_w_fi_2.iiweek_ago_ema10)) AND (stock_w_fi_2.fi2 > (0)::numeric)) AND (stock_w_fi_2.fi13 < (0)::numeric)) AND (stock_w_fi_2.ema20 < stock_w_fi_2.week_ago_ema20)) AND (stock_w_fi_2.ema20 < stock_w_fi_2.iiweek_ago_ema20));


ALTER TABLE short OWNER TO pi;

--
-- TOC entry 175 (class 1259 OID 33244)
-- Name: stock_hist_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE stock_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stock_hist_id_seq OWNER TO stocker;

--
-- TOC entry 2034 (class 0 OID 0)
-- Dependencies: 175
-- Name: stock_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE stock_hist_id_seq OWNED BY stock_hist.id;


--
-- TOC entry 177 (class 1259 OID 33251)
-- Name: stock_w_fi; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stock_w_fi AS
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
    ema(stock_w_ema.raw_fi, 0.6666666666666667) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi2,
    ema(stock_w_ema.raw_fi, 0.1428571428571429) OVER (PARTITION BY stock_w_ema.ticker ORDER BY stock_w_ema.dt) AS fi13,
    stock_w_ema.volume
   FROM stock_w_ema
  WHERE (stock_w_ema.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text]));


ALTER TABLE stock_w_fi OWNER TO stocker;

--
-- TOC entry 1912 (class 2604 OID 33261)
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY stock_hist ALTER COLUMN id SET DEFAULT nextval('stock_hist_id_seq'::regclass);


--
-- TOC entry 1914 (class 2606 OID 33263)
-- Name: stock_hist_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY stock_hist
    ADD CONSTRAINT stock_hist_pkey PRIMARY KEY (id);


--
-- TOC entry 2033 (class 0 OID 0)
-- Dependencies: 8
-- Name: stocker; Type: ACL; Schema: -; Owner: stocker
--

REVOKE ALL ON SCHEMA stocker FROM PUBLIC;
REVOKE ALL ON SCHEMA stocker FROM stocker;
GRANT ALL ON SCHEMA stocker TO stocker;
GRANT ALL ON SCHEMA stocker TO PUBLIC;
GRANT ALL ON SCHEMA stocker TO postgres;


-- Completed on 2018-05-07 20:02:23 UTC

--
-- PostgreSQL database dump complete
--

