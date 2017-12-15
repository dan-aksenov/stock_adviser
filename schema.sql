--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.5

-- Started on 2017-12-15 15:23:46

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12387)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2227 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 205 (class 1255 OID 25478)
-- Name: ema_func(numeric, numeric); Type: FUNCTION; Schema: public; Owner: stocker
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


ALTER FUNCTION public.ema_func(numeric, numeric) OWNER TO stocker;

--
-- TOC entry 206 (class 1255 OID 25479)
-- Name: ema_func(numeric, double precision, numeric); Type: FUNCTION; Schema: public; Owner: stocker
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


ALTER FUNCTION public.ema_func(state numeric, inval double precision, alpha numeric) OWNER TO stocker;

--
-- TOC entry 207 (class 1255 OID 25480)
-- Name: ema_func(numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: stocker
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


ALTER FUNCTION public.ema_func(state numeric, inval numeric, alpha numeric) OWNER TO stocker;

--
-- TOC entry 631 (class 1255 OID 25481)
-- Name: ema(numeric); Type: AGGREGATE; Schema: public; Owner: stocker
--

CREATE AGGREGATE ema(numeric) (
    SFUNC = public.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE public.ema(numeric) OWNER TO stocker;

--
-- TOC entry 632 (class 1255 OID 25482)
-- Name: ema(double precision, numeric); Type: AGGREGATE; Schema: public; Owner: stocker
--

CREATE AGGREGATE ema(double precision, numeric) (
    SFUNC = public.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE public.ema(double precision, numeric) OWNER TO stocker;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 25483)
-- Name: stock_hist; Type: TABLE; Schema: public; Owner: stocker
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
-- TOC entry 186 (class 1259 OID 25489)
-- Name: stock_w_ema; Type: VIEW; Schema: public; Owner: stocker
--

CREATE VIEW stock_w_ema AS
 SELECT stock_hist.id,
    stock_hist.dt,
    stock_hist.ticker,
    stock_hist.close,
    ema(stock_hist.close, 0.1818181818181818) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema10,
    ema(stock_hist.close, 0.0952380952380952) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt) AS ema20,
    (avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) - avg(((stock_hist.high - stock_hist.low) / (2)::double precision)) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt ROWS BETWEEN 34 PRECEDING AND CURRENT ROW)) AS ao,
    round((stock_hist.volume * (stock_hist.close - lag(stock_hist.close) OVER (PARTITION BY stock_hist.ticker ORDER BY stock_hist.dt)))) AS raw_fi,
    stock_hist.volume
   FROM stock_hist;


ALTER TABLE stock_w_ema OWNER TO stocker;

--
-- TOC entry 187 (class 1259 OID 25494)
-- Name: stock_w_fi; Type: VIEW; Schema: public; Owner: stocker
--

CREATE VIEW stock_w_fi AS
 SELECT stock_w_ema.id,
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


ALTER TABLE stock_w_fi OWNER TO stocker;

--
-- TOC entry 188 (class 1259 OID 25499)
-- Name: advice_down_idx; Type: VIEW; Schema: public; Owner: stocker
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
  WHERE ((stock_w_fi.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stock_hist)) AND (stock_w_fi.fi2 > (0)::numeric) AND (stock_w_fi.fi13 < (0)::numeric) AND (stock_w_fi.ema10 < stock_w_fi.week_ago_ema20) AND (stock_w_fi.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])));


ALTER TABLE advice_down_idx OWNER TO stocker;

--
-- TOC entry 189 (class 1259 OID 25504)
-- Name: advice_up_idx; Type: VIEW; Schema: public; Owner: stocker
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
  WHERE ((stock_w_fi.dt = ( SELECT max(stock_hist.dt) AS max
           FROM stock_hist)) AND (stock_w_fi.fi2 < (0)::numeric) AND (stock_w_fi.fi13 > (0)::numeric) AND (stock_w_fi.ema10 > stock_w_fi.week_ago_ema20) AND (stock_w_fi.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text])));


ALTER TABLE advice_up_idx OWNER TO stocker;

--
-- TOC entry 190 (class 1259 OID 25509)
-- Name: auth_cas; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE auth_cas (
    id integer NOT NULL,
    user_id integer,
    created_on timestamp without time zone,
    service character varying(512),
    ticket character varying(512),
    renew character(1)
);


ALTER TABLE auth_cas OWNER TO stocker;

--
-- TOC entry 191 (class 1259 OID 25515)
-- Name: auth_cas_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE auth_cas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_cas_id_seq OWNER TO stocker;

--
-- TOC entry 2228 (class 0 OID 0)
-- Dependencies: 191
-- Name: auth_cas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE auth_cas_id_seq OWNED BY auth_cas.id;


--
-- TOC entry 192 (class 1259 OID 25517)
-- Name: auth_event; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE auth_event (
    id integer NOT NULL,
    time_stamp timestamp without time zone,
    client_ip character varying(512),
    user_id integer,
    origin character varying(512),
    description text
);


ALTER TABLE auth_event OWNER TO stocker;

--
-- TOC entry 193 (class 1259 OID 25523)
-- Name: auth_event_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE auth_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_event_id_seq OWNER TO stocker;

--
-- TOC entry 2229 (class 0 OID 0)
-- Dependencies: 193
-- Name: auth_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE auth_event_id_seq OWNED BY auth_event.id;


--
-- TOC entry 194 (class 1259 OID 25525)
-- Name: auth_group; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    role character varying(512),
    description text
);


ALTER TABLE auth_group OWNER TO stocker;

--
-- TOC entry 195 (class 1259 OID 25531)
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_id_seq OWNER TO stocker;

--
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 195
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;


--
-- TOC entry 196 (class 1259 OID 25533)
-- Name: auth_membership; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE auth_membership (
    id integer NOT NULL,
    user_id integer,
    group_id integer
);


ALTER TABLE auth_membership OWNER TO stocker;

--
-- TOC entry 197 (class 1259 OID 25536)
-- Name: auth_membership_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE auth_membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_membership_id_seq OWNER TO stocker;

--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 197
-- Name: auth_membership_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE auth_membership_id_seq OWNED BY auth_membership.id;


--
-- TOC entry 198 (class 1259 OID 25538)
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE auth_permission (
    id integer NOT NULL,
    group_id integer,
    name character varying(512),
    table_name character varying(512),
    record_id integer
);


ALTER TABLE auth_permission OWNER TO stocker;

--
-- TOC entry 199 (class 1259 OID 25544)
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_permission_id_seq OWNER TO stocker;

--
-- TOC entry 2232 (class 0 OID 0)
-- Dependencies: 199
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;


--
-- TOC entry 200 (class 1259 OID 25546)
-- Name: auth_user; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE auth_user (
    id integer NOT NULL,
    first_name character varying(128),
    last_name character varying(128),
    email character varying(512),
    password character varying(512),
    registration_key character varying(512),
    reset_password_key character varying(512),
    registration_id character varying(512)
);


ALTER TABLE auth_user OWNER TO stocker;

--
-- TOC entry 201 (class 1259 OID 25552)
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq OWNER TO stocker;

--
-- TOC entry 2233 (class 0 OID 0)
-- Dependencies: 201
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;


--
-- TOC entry 202 (class 1259 OID 25554)
-- Name: image; Type: TABLE; Schema: public; Owner: stocker
--

CREATE TABLE image (
    id integer NOT NULL,
    name character varying(512),
    file character varying(512)
);


ALTER TABLE image OWNER TO stocker;

--
-- TOC entry 203 (class 1259 OID 25560)
-- Name: image_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE image_id_seq OWNER TO stocker;

--
-- TOC entry 2234 (class 0 OID 0)
-- Dependencies: 203
-- Name: image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE image_id_seq OWNED BY image.id;


--
-- TOC entry 204 (class 1259 OID 25562)
-- Name: stock_hist_id_seq; Type: SEQUENCE; Schema: public; Owner: stocker
--

CREATE SEQUENCE stock_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stock_hist_id_seq OWNER TO stocker;

--
-- TOC entry 2235 (class 0 OID 0)
-- Dependencies: 204
-- Name: stock_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: stocker
--

ALTER SEQUENCE stock_hist_id_seq OWNED BY stock_hist.id;


--
-- TOC entry 2072 (class 2604 OID 25576)
-- Name: auth_cas id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_cas ALTER COLUMN id SET DEFAULT nextval('auth_cas_id_seq'::regclass);


--
-- TOC entry 2073 (class 2604 OID 25577)
-- Name: auth_event id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_event ALTER COLUMN id SET DEFAULT nextval('auth_event_id_seq'::regclass);


--
-- TOC entry 2074 (class 2604 OID 25578)
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);


--
-- TOC entry 2075 (class 2604 OID 25579)
-- Name: auth_membership id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_membership ALTER COLUMN id SET DEFAULT nextval('auth_membership_id_seq'::regclass);


--
-- TOC entry 2076 (class 2604 OID 25580)
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);


--
-- TOC entry 2077 (class 2604 OID 25581)
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);


--
-- TOC entry 2078 (class 2604 OID 25582)
-- Name: image id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY image ALTER COLUMN id SET DEFAULT nextval('image_id_seq'::regclass);


--
-- TOC entry 2071 (class 2604 OID 25583)
-- Name: stock_hist id; Type: DEFAULT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY stock_hist ALTER COLUMN id SET DEFAULT nextval('stock_hist_id_seq'::regclass);


--
-- TOC entry 2082 (class 2606 OID 25585)
-- Name: auth_cas auth_cas_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_cas
    ADD CONSTRAINT auth_cas_pkey PRIMARY KEY (id);


--
-- TOC entry 2084 (class 2606 OID 25587)
-- Name: auth_event auth_event_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_event
    ADD CONSTRAINT auth_event_pkey PRIMARY KEY (id);


--
-- TOC entry 2086 (class 2606 OID 25589)
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- TOC entry 2088 (class 2606 OID 25591)
-- Name: auth_membership auth_membership_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_pkey PRIMARY KEY (id);


--
-- TOC entry 2090 (class 2606 OID 25593)
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- TOC entry 2092 (class 2606 OID 25595)
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- TOC entry 2094 (class 2606 OID 25597)
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- TOC entry 2080 (class 2606 OID 25599)
-- Name: stock_hist stock_hist_pkey; Type: CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY stock_hist
    ADD CONSTRAINT stock_hist_pkey PRIMARY KEY (id);


--
-- TOC entry 2095 (class 2606 OID 25600)
-- Name: auth_cas auth_cas_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_cas
    ADD CONSTRAINT auth_cas_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- TOC entry 2096 (class 2606 OID 25605)
-- Name: auth_event auth_event_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_event
    ADD CONSTRAINT auth_event_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- TOC entry 2097 (class 2606 OID 25610)
-- Name: auth_membership auth_membership_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE;


--
-- TOC entry 2098 (class 2606 OID 25615)
-- Name: auth_membership auth_membership_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- TOC entry 2099 (class 2606 OID 25620)
-- Name: auth_permission auth_permission_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: stocker
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE;


-- Completed on 2017-12-15 15:23:47

--
-- PostgreSQL database dump complete
--

