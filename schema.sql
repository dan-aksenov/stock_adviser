--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = stocker, pg_catalog;

ALTER TABLE ONLY stocker.auth_permission DROP CONSTRAINT auth_permission_group_id_fkey;
ALTER TABLE ONLY stocker.auth_membership DROP CONSTRAINT auth_membership_user_id_fkey;
ALTER TABLE ONLY stocker.auth_membership DROP CONSTRAINT auth_membership_group_id_fkey;
ALTER TABLE ONLY stocker.auth_event DROP CONSTRAINT auth_event_user_id_fkey;
ALTER TABLE ONLY stocker.auth_cas DROP CONSTRAINT auth_cas_user_id_fkey;
ALTER TABLE ONLY stocker.stock_hist DROP CONSTRAINT stock_hist_pkey;
ALTER TABLE ONLY stocker.image DROP CONSTRAINT image_pkey;
ALTER TABLE ONLY stocker.auth_user DROP CONSTRAINT auth_user_pkey;
ALTER TABLE ONLY stocker.auth_permission DROP CONSTRAINT auth_permission_pkey;
ALTER TABLE ONLY stocker.auth_membership DROP CONSTRAINT auth_membership_pkey;
ALTER TABLE ONLY stocker.auth_group DROP CONSTRAINT auth_group_pkey;
ALTER TABLE ONLY stocker.auth_event DROP CONSTRAINT auth_event_pkey;
ALTER TABLE ONLY stocker.auth_cas DROP CONSTRAINT auth_cas_pkey;
ALTER TABLE stocker.stock_hist ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.image ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.auth_user ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.auth_permission ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.auth_membership ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.auth_group ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.auth_event ALTER COLUMN id DROP DEFAULT;
ALTER TABLE stocker.auth_cas ALTER COLUMN id DROP DEFAULT;
DROP VIEW stocker.stock_w_fi_2;
DROP VIEW stocker.stock_w_fi;
DROP VIEW stocker.stock_w_ema;
DROP SEQUENCE stocker.stock_hist_id_seq;
DROP TABLE stocker.stock_hist;
DROP SEQUENCE stocker.image_id_seq;
DROP TABLE stocker.image;
DROP SEQUENCE stocker.auth_user_id_seq;
DROP TABLE stocker.auth_user;
DROP SEQUENCE stocker.auth_permission_id_seq;
DROP TABLE stocker.auth_permission;
DROP SEQUENCE stocker.auth_membership_id_seq;
DROP TABLE stocker.auth_membership;
DROP SEQUENCE stocker.auth_group_id_seq;
DROP TABLE stocker.auth_group;
DROP SEQUENCE stocker.auth_event_id_seq;
DROP TABLE stocker.auth_event;
DROP SEQUENCE stocker.auth_cas_id_seq;
DROP TABLE stocker.auth_cas;
DROP AGGREGATE stocker.ema(double precision, numeric);
DROP AGGREGATE stocker.ema(numeric);
DROP FUNCTION stocker.ema_func(state numeric, inval numeric, alpha numeric);
DROP FUNCTION stocker.ema_func(state numeric, inval double precision, alpha numeric);
DROP FUNCTION stocker.ema_func(numeric, numeric);
DROP EXTENSION plpgsql;
DROP SCHEMA stocker;
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
-- Name: stocker; Type: SCHEMA; Schema: -; Owner: pi
--

CREATE SCHEMA stocker;


ALTER SCHEMA stocker OWNER TO pi;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = stocker, pg_catalog;

--
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
-- Name: ema(numeric); Type: AGGREGATE; Schema: stocker; Owner: stocker
--

CREATE AGGREGATE ema(numeric) (
    SFUNC = stocker.ema_func,
    STYPE = numeric
);


ALTER AGGREGATE stocker.ema(numeric) OWNER TO stocker;

--
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
-- Name: auth_cas; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
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
-- Name: auth_cas_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE auth_cas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_cas_id_seq OWNER TO stocker;

--
-- Name: auth_cas_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE auth_cas_id_seq OWNED BY auth_cas.id;


--
-- Name: auth_event; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
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
-- Name: auth_event_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE auth_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_event_id_seq OWNER TO stocker;

--
-- Name: auth_event_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE auth_event_id_seq OWNED BY auth_event.id;


--
-- Name: auth_group; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
--

CREATE TABLE auth_group (
    id integer NOT NULL,
    role character varying(512),
    description text
);


ALTER TABLE auth_group OWNER TO stocker;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_group_id_seq OWNER TO stocker;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE auth_group_id_seq OWNED BY auth_group.id;


--
-- Name: auth_membership; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
--

CREATE TABLE auth_membership (
    id integer NOT NULL,
    user_id integer,
    group_id integer
);


ALTER TABLE auth_membership OWNER TO stocker;

--
-- Name: auth_membership_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE auth_membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_membership_id_seq OWNER TO stocker;

--
-- Name: auth_membership_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE auth_membership_id_seq OWNED BY auth_membership.id;


--
-- Name: auth_permission; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
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
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_permission_id_seq OWNER TO stocker;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE auth_permission_id_seq OWNED BY auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
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
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq OWNER TO stocker;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE auth_user_id_seq OWNED BY auth_user.id;


--
-- Name: image; Type: TABLE; Schema: stocker; Owner: stocker; Tablespace: 
--

CREATE TABLE image (
    id integer NOT NULL,
    name character varying(512),
    file character varying(512)
);


ALTER TABLE image OWNER TO stocker;

--
-- Name: image_id_seq; Type: SEQUENCE; Schema: stocker; Owner: stocker
--

CREATE SEQUENCE image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE image_id_seq OWNER TO stocker;

--
-- Name: image_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE image_id_seq OWNED BY image.id;


--
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
-- Name: stock_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: stocker; Owner: stocker
--

ALTER SEQUENCE stock_hist_id_seq OWNED BY stock_hist.id;


--
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
-- Name: stock_w_fi; Type: VIEW; Schema: stocker; Owner: stocker
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
   FROM stock_w_ema
  WHERE (stock_w_ema.ticker = ANY (ARRAY['SBER'::text, 'SBERP'::text, 'GAZP'::text, 'LKOH'::text, 'MGNT'::text, 'GMKN'::text, 'NVTK'::text, 'SNGS'::text, 'SNGSP'::text, 'ROSN'::text, 'VTBR'::text, 'TATN'::text, 'TATNP'::text, 'MTSS'::text, 'ALRS'::text, 'CHMF'::text, 'MOEX'::text, 'NLMK'::text, 'IRAO'::text, 'YNDX'::text, 'POLY'::text, 'PLZL'::text, 'TRNFP'::text, 'AFLT'::text, 'RUAL'::text, 'PHOR'::text, 'HYDR'::text, 'PIKK'::text, 'MAGN'::text, 'RTKM'::text, 'MFON'::text, 'FEES'::text, 'AFKS'::text, 'RNFT'::text, 'MTLR'::text, 'EPLN'::text, 'UPRO'::text, 'LSRG'::text, 'CBOM'::text, 'DSKY'::text, 'RSTI'::text, 'NMTP'::text, 'TRMK'::text, 'MVID'::text, 'AGRO'::text, 'MSNG'::text, 'UWGN'::text, 'AKRN'::text, 'DIXY'::text, 'LNTA'::text]));


ALTER TABLE stock_w_fi OWNER TO stocker;

--
-- Name: stock_w_fi_2; Type: VIEW; Schema: stocker; Owner: stocker
--

CREATE VIEW stock_w_fi_2 AS
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


ALTER TABLE stock_w_fi_2 OWNER TO stocker;

--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_cas ALTER COLUMN id SET DEFAULT nextval('auth_cas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_event ALTER COLUMN id SET DEFAULT nextval('auth_event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_group ALTER COLUMN id SET DEFAULT nextval('auth_group_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_membership ALTER COLUMN id SET DEFAULT nextval('auth_membership_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_permission ALTER COLUMN id SET DEFAULT nextval('auth_permission_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_user ALTER COLUMN id SET DEFAULT nextval('auth_user_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY image ALTER COLUMN id SET DEFAULT nextval('image_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY stock_hist ALTER COLUMN id SET DEFAULT nextval('stock_hist_id_seq'::regclass);


--
-- Name: auth_cas_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY auth_cas
    ADD CONSTRAINT auth_cas_pkey PRIMARY KEY (id);


--
-- Name: auth_event_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY auth_event
    ADD CONSTRAINT auth_event_pkey PRIMARY KEY (id);


--
-- Name: auth_group_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_membership_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_pkey PRIMARY KEY (id);


--
-- Name: auth_permission_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: image_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: stock_hist_pkey; Type: CONSTRAINT; Schema: stocker; Owner: stocker; Tablespace: 
--

ALTER TABLE ONLY stock_hist
    ADD CONSTRAINT stock_hist_pkey PRIMARY KEY (id);


--
-- Name: auth_cas_user_id_fkey; Type: FK CONSTRAINT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_cas
    ADD CONSTRAINT auth_cas_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- Name: auth_event_user_id_fkey; Type: FK CONSTRAINT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_event
    ADD CONSTRAINT auth_event_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- Name: auth_membership_group_id_fkey; Type: FK CONSTRAINT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE;


--
-- Name: auth_membership_user_id_fkey; Type: FK CONSTRAINT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_membership
    ADD CONSTRAINT auth_membership_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth_user(id) ON DELETE CASCADE;


--
-- Name: auth_permission_group_id_fkey; Type: FK CONSTRAINT; Schema: stocker; Owner: stocker
--

ALTER TABLE ONLY auth_permission
    ADD CONSTRAINT auth_permission_group_id_fkey FOREIGN KEY (group_id) REFERENCES auth_group(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: stocker; Type: ACL; Schema: -; Owner: pi
--

REVOKE ALL ON SCHEMA stocker FROM PUBLIC;
REVOKE ALL ON SCHEMA stocker FROM pi;
GRANT ALL ON SCHEMA stocker TO pi;
GRANT ALL ON SCHEMA stocker TO postgres;
GRANT ALL ON SCHEMA stocker TO PUBLIC;


--
-- PostgreSQL database dump complete
--

