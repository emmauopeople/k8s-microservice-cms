--
-- PostgreSQL database dump
--

\restrict PNIFmX3Oh9hdpKPNydKS7V8JvA8ommyxua4Zm8pn7sz4rtub9ZAOmWA2imBycgS

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_activity_logs; Type: TABLE; Schema: public; Owner: auth_db_user
--

CREATE TABLE public.auth_activity_logs (
    id bigint NOT NULL,
    church_id uuid,
    user_id uuid,
    email_attempted text,
    action character varying(20) NOT NULL,
    status character varying(20) NOT NULL,
    failure_reason text,
    ip_address text,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.auth_activity_logs OWNER TO auth_db_user;

--
-- Name: auth_activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: auth_db_user
--

CREATE SEQUENCE public.auth_activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auth_activity_logs_id_seq OWNER TO auth_db_user;

--
-- Name: auth_activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: auth_db_user
--

ALTER SEQUENCE public.auth_activity_logs_id_seq OWNED BY public.auth_activity_logs.id;


--
-- Name: churches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.churches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    country character varying(100) NOT NULL,
    city character varying(100),
    address text,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_church_status CHECK (((status)::text = ANY (ARRAY[('ACTIVE'::character varying)::text, ('INACTIVE'::character varying)::text])))
);


ALTER TABLE public.churches OWNER TO postgres;

--
-- Name: login_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    email_attempted character varying(255) NOT NULL,
    ip_address inet,
    user_agent text,
    status character varying(20) NOT NULL,
    failure_reason character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_login_status CHECK (((status)::text = ANY (ARRAY[('SUCCESS'::character varying)::text, ('FAILED'::character varying)::text])))
);


ALTER TABLE public.login_logs OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    church_id uuid NOT NULL,
    full_name character varying(150) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    role character varying(20) DEFAULT 'USER'::character varying NOT NULL,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_user_role CHECK (((role)::text = ANY (ARRAY[('ADMIN'::character varying)::text, ('USER'::character varying)::text]))),
    CONSTRAINT chk_user_status CHECK (((status)::text = ANY (ARRAY[('ACTIVE'::character varying)::text, ('INACTIVE'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: auth_activity_logs id; Type: DEFAULT; Schema: public; Owner: auth_db_user
--

ALTER TABLE ONLY public.auth_activity_logs ALTER COLUMN id SET DEFAULT nextval('public.auth_activity_logs_id_seq'::regclass);


--
-- Data for Name: auth_activity_logs; Type: TABLE DATA; Schema: public; Owner: auth_db_user
--

COPY public.auth_activity_logs (id, church_id, user_id, email_attempted, action, status, failure_reason, ip_address, user_agent, created_at) FROM stdin;
1	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	admin@diocese.bf	USER_DEACTIVATED	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 15:37:19.521769+00
2	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 15:39:02.305285+00
3	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 15:39:04.974557+00
4	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	admin@diocese.bf	USER_ACTIVATED	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 15:42:45.734157+00
5	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	admin@diocese.bf	USER_DEACTIVATED	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 15:52:06.909168+00
6	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	admin@diocese.bf	USER_ACTIVATED	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 15:52:29.979063+00
7	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-06-25 16:25:52.414349+00
8	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-06-25 17:35:12.423037+00
9	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 18:56:24.426854+00
10	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-25 21:38:49.257824+00
11	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-26 10:32:42.402543+00
12	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-26 10:32:44.798426+00
13	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36 EdgA/147.0.0.0	2026-06-26 12:21:36.730369+00
14	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-26 14:45:56.04108+00
15	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-26 14:46:24.081163+00
16	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-27 09:43:51.762858+00
17	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-06-28 10:34:39.571451+00
18	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	2026-06-28 21:48:56.626273+00
19	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 16:33:42.091057+00
20	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	2026-06-29 18:26:17.766785+00
21	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-06-29 18:27:44.223416+00
22	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-06-30 18:19:32.048849+00
23	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-03 10:14:02.088663+00
24	\N	\N	mbimunyui87@yahoo.com	LOGIN	FAILED	USER_NOT_FOUND	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	2026-07-03 21:40:32.13928+00
25	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	2026-07-03 21:41:00.598512+00
26	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	FAILED	INVALID_PASSWORD	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	2026-07-03 21:44:03.181569+00
27	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	2026-07-03 21:44:47.659054+00
28	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	2026-07-03 23:16:22.186524+00
29	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36 EdgA/147.0.0.0	2026-07-03 23:38:16.384539+00
30	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-05 10:21:05.044847+00
31	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-08 03:28:36.118705+00
32	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-08 05:21:13.549934+00
33	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-08 10:51:36.457298+00
34	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-08 16:54:33.168341+00
35	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-08 19:56:50.872642+00
36	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-11 13:18:47.129882+00
37	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGOUT	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-11 13:31:41.232462+00
38	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-13 16:09:08.623279+00
39	\N	\N	mbimunyui87@yahoo.com	LOGIN	FAILED	USER_NOT_FOUND	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:06:39.997053+00
40	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	FAILED	INVALID_PASSWORD	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:08:19.729304+00
41	\N	\N	\N	LOGOUT	FAILED	TOKEN_NOT_VALID	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:08:56.682836+00
42	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:09:10.007782+00
43	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	FAILED	INVALID_PASSWORD	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:09:43.711949+00
44	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:12:08.135645+00
45	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:20:50.437634+00
46	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:20:54.108105+00
47	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:21:04.499109+00
48	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	FAILED	INVALID_PASSWORD	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:21:10.347987+00
49	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:21:33.724848+00
50	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:39:28.575648+00
51	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-14 21:39:31.824463+00
52	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 11:51:46.18103+00
53	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 12:01:43.845618+00
54	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 12:01:47.597494+00
55	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 12:09:46.735719+00
56	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 12:09:49.502011+00
57	\N	\N	\N	LOGOUT	FAILED	TOKEN_NOT_VALID	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 16:12:20.893603+00
58	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 16:12:23.580901+00
59	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-15 17:34:58.906247+00
60	\N	\N	\N	LOGOUT	FAILED	TOKEN_NOT_VALID	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-16 05:32:35.341079+00
61	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-16 05:32:38.495364+00
62	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-16 06:14:29.910214+00
63	\N	\N	\N	LOGOUT	FAILED	TOKEN_NOT_VALID	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-16 12:40:42.761246+00
64	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-16 12:40:45.399096+00
65	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-16 20:32:35.578315+00
66	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-17 17:08:39.189396+00
67	\N	\N	\N	LOGOUT	FAILED	TOKEN_NOT_VALID	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-18 10:47:27.520505+00
68	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-18 10:47:30.971784+00
69	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-18 15:11:54.471088+00
70	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	2026-07-18 15:11:59.069944+00
71	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 01:12:11.101966+00
72	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	recruiter@gmail.com	USER_CREATED	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 01:15:24.129077+00
73	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	LOGOUT	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 01:15:28.289573+00
74	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 01:15:55.565127+00
75	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 02:33:07.744171+00
76	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 03:25:41.075316+00
77	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 03:45:45.052246+00
78	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-22 03:49:02.739842+00
79	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-23 15:33:15.916469+00
80	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	2026-07-23 15:54:22.00996+00
81	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-27 12:04:37.061268+00
82	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	LOGIN	SUCCESS	\N	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	2026-07-27 13:02:13.466442+00
\.


--
-- Data for Name: churches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.churches (id, name, country, city, address, status, created_at, updated_at) FROM stdin;
7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	St. Joseph Parish	Burkina Faso	Ouagadougou	Main Parish Office	ACTIVE	2026-06-17 15:01:47.182373+00	2026-06-17 15:01:47.182373+00
\.


--
-- Data for Name: login_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.login_logs (id, user_id, email_attempted, ip_address, user_agent, status, failure_reason, created_at) FROM stdin;
5099ed64-ef0d-44b2-a137-58e5135a5e9d	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-17 21:16:40.611715+00
71260d61-c23e-4952-a36d-64b6ec3958e3	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-17 21:23:11.501042+00
81822bbd-5d6e-47e4-8792-898426a591f1	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-17 21:32:04.624111+00
7ad6fc41-54e0-4f22-bac7-1f6935ac729b	36259031-e255-4cf3-b5d7-54e1466ddcc3	clerk@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-17 21:34:50.690337+00
04674276-495c-42ed-8319-abd22643770c	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-17 23:30:11.147799+00
8cacd575-eab3-4149-a8d4-79becad64740	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-18 00:38:41.425823+00
29d00bc5-6ade-4b35-990f-16e3daa31dcc	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-18 00:42:25.209637+00
cb9cd803-3f30-468d-9c58-c5f8bc311dd2	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	127.0.0.1	curl/8.4.0	SUCCESS	\N	2026-06-18 10:19:32.355531+00
b5656e7a-791c-402b-a902-87923d6b5771	\N	mbimunyui87@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	FAILED	USER_NOT_FOUND	2026-06-18 22:52:19.440062+00
e294b4d3-fb6f-4ef8-906e-67d5411ad004	\N	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	FAILED	USER_NOT_FOUND	2026-06-18 22:54:33.482787+00
a77f2291-0ed7-43c7-b599-faa4aa9e1463	\N	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	FAILED	USER_NOT_FOUND	2026-06-18 22:54:35.16803+00
4a0f9bc1-e75c-4cfc-b0cf-e0f7a973c550	\N	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	FAILED	USER_NOT_FOUND	2026-06-18 22:54:54.139277+00
aacd16b0-d7af-4836-9765-091176dae97a	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 00:13:44.773164+00
01fccc62-a127-4b39-92d1-36428030c219	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 00:14:03.729456+00
c1fd9da8-f12c-41ab-acc3-8d44d794e733	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 00:20:20.297567+00
0d2443be-f156-42ac-8ea1-846c59bb8759	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 00:32:29.583258+00
2a2bd789-6918-4d87-aca6-129f53256bbd	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 00:45:04.838837+00
436dcf54-d1fa-432c-acc9-a5493a3bab9e	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 02:06:53.829206+00
a89f2ddb-c3ca-4446-9ed5-d87c437c738b	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 04:41:11.179473+00
2d3027b2-233d-4b49-84c4-7d924b65f12c	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 04:46:10.532314+00
c606e6b5-9bf5-4247-baf7-7511b6bfa5d1	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 09:14:54.959963+00
7926ec29-056b-49f1-9fcb-e3f273700c1a	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-19 10:31:51.350515+00
7c8dfa73-2320-4371-ac0d-0fa3b6f15dc4	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-20 01:25:39.910087+00
01d0ff42-7fb8-4453-b0a0-c1502d1d13f5	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-20 03:16:49.175871+00
7c66f0b8-2831-4423-8f84-537a532a4431	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-20 10:37:27.188499+00
78d06770-6894-48fb-b555-18cb8ec8cfbd	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-21 09:47:58.644277+00
95f83660-b274-4a37-a702-c0837ded5673	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 01:24:23.651673+00
d6461aa3-c8d5-4207-9e31-31a46534d627	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 04:08:56.654138+00
79cde1e9-956f-4105-95b1-4cca03a54bef	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 08:58:22.163519+00
f8638ff6-4b8a-4881-a7ae-4c9d3858caca	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 11:01:58.779311+00
2482524f-7e3f-4106-b0db-5d3720b09543	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 12:17:18.352708+00
878c2bfc-b148-49e9-85d3-446749d1ec4b	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 13:22:14.549386+00
65748348-fad2-4c22-9405-bf8cff5da5f7	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 16:01:09.37447+00
a6bb5c94-c2da-457b-872c-83a85a63461b	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 17:10:06.568309+00
44c137fa-ba68-446e-8aac-020508dbf84f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 18:23:51.407601+00
4b290f4b-b318-4f40-a173-c856807d515b	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 19:29:27.845873+00
e8450bc2-f872-4175-a191-df28ab846189	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 20:31:39.234619+00
7f35ba1d-67a0-40b4-847d-f80194d4b13f	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 21:40:35.897037+00
d16ba52c-b562-456f-ba11-6c2051dc9afc	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-22 23:11:34.443694+00
a9ec1469-6e16-4208-ac1e-4e074f2ee5af	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-23 04:11:14.800725+00
9abeb067-ec30-4c84-ba2a-5e7c3056a7bb	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-23 10:21:17.380697+00
8a741bc5-e918-4eb4-bf6c-36889f4cec9c	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-23 14:34:21.935189+00
b0ee176c-efc7-4c1f-8616-48d12ef448a4	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-23 18:28:59.020467+00
87211945-a93f-41ff-9606-eac400495a7e	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-23 22:21:02.474148+00
e274214c-11e7-45f7-bdf3-ca3689833324	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 00:18:40.884639+00
1c5f7b0e-a18e-42ed-b535-2e4cf69c21c3	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	10.0.0.2	curl/8.5.0	SUCCESS	\N	2026-06-24 00:39:47.596588+00
24f888cd-9ab9-4308-b14f-477559aeb836	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	10.0.0.2	curl/8.5.0	SUCCESS	\N	2026-06-24 00:42:33.822263+00
9af97946-4517-4736-8f63-bccf9ba3d2fb	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	10.0.0.2	curl/8.5.0	SUCCESS	\N	2026-06-24 02:44:34.551312+00
f239a32f-0d04-4d78-bc78-46ef5a448701	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	10.0.0.2	curl/8.5.0	SUCCESS	\N	2026-06-24 02:46:23.48087+00
3dfe6793-a75f-461b-9772-6aaf395276e4	c2b665d8-282f-4c5e-8a0c-5de7f60491a1	admin@stjoseph.local	10.0.0.2	curl/8.5.0	SUCCESS	\N	2026-06-24 02:48:19.740137+00
e9c2c2d7-9aed-427a-b2e4-7d15f1e1a127	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 02:49:31.481401+00
44930665-d56a-4fc0-8d60-9cec1f7f74e5	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 04:42:25.891705+00
7dbd5520-93da-400f-898b-4caaee54b622	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 05:46:32.20004+00
8ed7c9cc-f1b3-4d9a-b77c-fb341e3f3fb1	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	FAILED	INVALID_PASSWORD	2026-06-24 06:08:29.550307+00
b1858abc-33cd-4a2c-a660-54ebe37d1ea9	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	FAILED	INVALID_PASSWORD	2026-06-24 06:23:59.895962+00
d47d0aa6-db23-4230-976c-82ebb2ec0f70	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 06:24:32.113558+00
dd97526b-0de6-43d4-a8f1-10c17820736d	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 12:19:26.552727+00
a7ab4531-b1db-4a60-a312-741ea34708b5	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 12:32:59.900219+00
4de23bb8-e8d6-4e5b-816f-a9cc96ca70ff	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 12:42:14.16219+00
5341dbd9-7583-4f6e-9abc-00274c7441e4	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 12:44:30.074723+00
2b953a30-ebd1-4e51-977c-17f004527584	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 12:49:57.819067+00
813c8a02-1efd-43c5-a555-edcca0402c69	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 13:07:54.380068+00
225c9dfc-3862-4df8-b6fb-9dd3fcad8783	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 14:07:11.49125+00
68536198-dcfb-4699-a971-7f92eac41f78	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 14:08:14.48626+00
3df8024b-44bd-4baa-91db-5c5eb5e8bd38	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-24 15:27:36.239591+00
29431656-3269-4348-8b08-cac34c6266e5	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 15:31:22.610537+00
76f46d49-ab3f-4ce2-9399-8cab76fdba72	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36 EdgA/147.0.0.0	SUCCESS	\N	2026-06-24 16:42:04.028039+00
5558a348-638d-43bd-a0a9-085501821c34	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36 EdgA/147.0.0.0	SUCCESS	\N	2026-06-24 16:42:43.554975+00
ab445fe1-56cf-4a2d-b31b-f2643b135932	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-24 18:07:13.449634+00
1c6c28dd-dd1a-43d8-ac73-12b0b5187e3f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-25 00:36:48.469998+00
51953308-b64a-43bf-9c39-a224bd0d6980	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-25 05:49:35.765892+00
609e026f-5c7b-4fc8-8546-972bca8d5be8	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-25 10:00:43.474437+00
a44b620d-02c4-4108-a006-6a095c2a54cf	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-25 15:09:28.122882+00
c07c133a-2843-48c1-abf3-b184046d516d	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-25 15:39:04.846515+00
598c7b5c-0f22-4d7f-ae53-d70b75dd993b	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-25 16:25:52.406763+00
04951fdf-3c68-4bfe-a3ab-1295e8a9efe3	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-25 17:35:12.420798+00
1d7e54b0-d9af-487e-b3a0-771d77e286d3	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-25 18:56:24.298817+00
47ec6d3e-9c80-4f0d-be95-2d850fc0e9da	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-25 21:38:49.131174+00
9987d999-3785-45e3-bc96-38fa5d720dc7	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-26 10:32:42.27317+00
0adf5bb6-99bf-4e56-af35-c9f1b7bc695d	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36 EdgA/147.0.0.0	SUCCESS	\N	2026-06-26 12:21:36.728267+00
83a81765-2abb-4a5b-8a3a-e9fda5e98b32	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-26 14:45:56.038221+00
98503c02-1fce-4b90-81a4-8f013d9286a7	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-27 09:43:51.634923+00
0743159c-9e33-406f-b0c0-467e51fa856c	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-28 10:34:39.569352+00
d9558a5b-5fdb-491b-bd41-0e60e639c753	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	SUCCESS	\N	2026-06-28 21:48:56.62408+00
972a27e4-bdf1-460b-96a4-ee70e30171d3	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-29 16:33:41.947753+00
4e9964b9-95cf-46cd-9bcf-f6b8052089d2	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	SUCCESS	\N	2026-06-29 18:26:17.631144+00
e2140290-5ec8-454f-b31f-d9f49a4e8970	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-29 18:27:44.216625+00
285b7aa1-7c26-4b44-80e7-19beb62a74af	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-06-30 18:19:32.046615+00
3dd8bae9-d5a6-42c2-bb04-1c0770b3b720	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-03 10:14:02.085961+00
69ae48fb-efba-4883-8e91-c121a3fa6d47	\N	mbimunyui87@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	FAILED	USER_NOT_FOUND	2026-07-03 21:40:32.136753+00
16a15b6d-3e2a-4bf0-866d-a1f5a5661b73	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	SUCCESS	\N	2026-07-03 21:41:00.596321+00
9ba41450-26ce-4c45-bd49-711466b7726b	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	FAILED	INVALID_PASSWORD	2026-07-03 21:44:03.177844+00
ac811f11-86d5-439b-a24e-c27992d756fa	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	SUCCESS	\N	2026-07-03 21:44:47.657014+00
c3326b82-30ac-4c69-a217-37e6f3296189	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.0.0	SUCCESS	\N	2026-07-03 23:16:22.184418+00
74a70047-b7fd-4437-944b-927463c80973	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36 EdgA/147.0.0.0	SUCCESS	\N	2026-07-03 23:38:16.381283+00
2e7886f4-5ff5-4edb-b38a-e76c85585476	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-05 10:21:05.042321+00
8ae229e5-55e5-410a-b377-fce9a1039dcb	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-08 03:28:36.11462+00
351ada91-8fdb-49ff-b312-56072bb722a6	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-08 05:21:13.547778+00
7c5a00b0-4c94-4275-abc9-e2a820758168	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-08 10:51:36.455399+00
35f5e9df-dfce-4b94-a65b-b5e543cc1b6e	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-08 16:54:33.166319+00
638e6e20-3a89-4976-8905-5655878b1f4a	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-08 19:56:50.868473+00
1da5719e-39a3-49ea-9051-0c5d37a946e6	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-11 13:18:47.1242+00
b1abb6d7-6544-4ca9-821e-a590a6bb9d21	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-13 16:09:08.621424+00
92abfd7e-96d2-49c8-84ab-72c3e3a59e59	\N	mbimunyui87@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	FAILED	USER_NOT_FOUND	2026-07-14 21:06:39.432491+00
e3b594ce-61ec-4aa1-8567-649aa298fd4b	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	FAILED	INVALID_PASSWORD	2026-07-14 21:08:19.586509+00
f5d069e9-afe6-44d6-9701-1fc7d0b41340	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-14 21:09:10.006091+00
f54824e1-b24c-4546-9f7b-2634ee2d4e87	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	FAILED	INVALID_PASSWORD	2026-07-14 21:09:43.569138+00
49b3804d-15c1-4d99-be26-a13bfa0c7807	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-14 21:12:07.993701+00
bc5c1897-1546-4798-9d0b-9e40d85d68e2	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-14 21:20:53.974328+00
932d51d9-f282-488f-87d6-370540c44cc7	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	FAILED	INVALID_PASSWORD	2026-07-14 21:21:10.212612+00
45cdcbef-f859-4b8e-bc82-2b0adfad9c8c	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-14 21:21:33.589979+00
cc401e08-12c5-4f83-adc3-788f3a08cb6b	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-14 21:39:31.689497+00
c5cabd33-471c-44ef-9085-a2141e54b97a	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-15 11:51:45.586176+00
c04b26a9-afcb-4685-af45-112c29d44082	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-15 12:01:47.457792+00
a22a4ddc-5c15-4e5e-a6e3-23d208b775e9	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-15 12:09:49.361292+00
6e50dc69-9f63-4aa8-8621-8266e9ffdc4d	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-15 16:12:23.432465+00
5397ecc3-de2d-45bf-bf86-0c202dc6b97b	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-15 17:34:58.774521+00
238dadbb-95ff-4e0b-bb8a-2ae71b9c46f4	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-16 05:32:38.361966+00
6c662f00-1cfc-4b5c-a0ba-a2232c739e5e	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-16 06:14:29.770784+00
9511cc25-240f-404e-923c-899a2f39f573	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-16 12:40:45.25513+00
0133a024-9bb4-4d93-9f49-f0507370ec86	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-16 20:32:35.430166+00
b665e0b1-1fc0-4951-9ba8-c12c4cc52afa	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-17 17:08:39.187498+00
4b2864af-2a3e-4958-bf9b-91e525bf7959	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	127.0.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-18 10:47:30.827884+00
25ec6e23-3c3b-4a38-af47-324864e4a91f	74f7c802-7cd1-4c3f-9318-a809fff267c3	mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0	SUCCESS	\N	2026-07-18 15:11:54.469218+00
ff9f3231-0716-4ef1-a33a-445ec012119f	74f7c802-7cd1-4c3f-9318-a809fff267c3	Mbimunyui_gethub@yahoo.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-22 01:12:11.099949+00
fd86978f-545b-4367-951c-200b409c326e	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-22 01:15:55.563301+00
be327713-cc46-4708-8c9f-9d698a7a14a3	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-22 02:33:07.742323+00
34fe6566-3806-4703-b3de-27227dbee194	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-22 03:25:41.07336+00
2c01e439-0be2-4406-b07d-54a5c6b2e6e0	81edac6a-771f-4545-9751-dbc2f1cc2b63	admin@diocese.bf	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-22 03:45:45.050085+00
0417d80f-524b-4554-b966-a33fa90e562c	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-22 03:49:02.737586+00
b36712f6-5c93-49c0-89ca-8d15af9e6ff5	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-23 15:33:15.913948+00
41160632-7edf-4270-ad3e-ff4243975dbc	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	SUCCESS	\N	2026-07-23 15:54:22.008147+00
57252362-ab56-4875-81dd-d9204edb34f2	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-27 12:04:37.058645+00
27dcd63d-66a1-431b-9bf8-98c9a07c1190	8737b3de-6a94-491c-9151-6233153f48ac	recruiter@gmail.com	10.0.0.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0	SUCCESS	\N	2026-07-27 13:02:13.464383+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, church_id, full_name, email, password_hash, role, status, last_login_at, created_at, updated_at) FROM stdin;
36259031-e255-4cf3-b5d7-54e1466ddcc3	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	Parish Clerk	clerk@stjoseph.local	$2a$12$cKUyRcOJbxQoWyzYeTGNL.4DEGWtaXKdEO1WzeCZmTrCRLucYafQe	USER	ACTIVE	2026-06-17 21:34:50.681917+00	2026-06-17 21:33:44.007848+00	2026-06-17 21:34:50.681917+00
c2b665d8-282f-4c5e-8a0c-5de7f60491a1	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	System Administrator	admin@stjoseph.local	$2a$06$Ain0NAm.R760z2gmlFu.q.YPNqV.c/2fxN38t6U0dWdxCkZEEJEJC	ADMIN	ACTIVE	2026-06-24 02:48:19.738064+00	2026-06-17 15:01:47.182373+00	2026-06-24 02:48:19.738064+00
74f7c802-7cd1-4c3f-9318-a809fff267c3	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	mbimunyui emmanuel	mbimunyui_gethub@yahoo.com	$2a$12$GSh6hlci9YH8/CE7ICTJYOuQoaCHPmpesW2TIk.X/sldi6QDLWl2G	ADMIN	ACTIVE	2026-07-22 01:12:11.097383+00	2026-06-24 14:07:53.259884+00	2026-07-22 01:12:11.097383+00
81edac6a-771f-4545-9751-dbc2f1cc2b63	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	System Administrator	admin@diocese.bf	$2a$12$iC9TMntX4.c0UY/1tJEoBOQIDVxstw/1baZ9kViFsNQXgf.TPIA3S	ADMIN	ACTIVE	2026-07-22 03:45:45.047154+00	2026-06-19 00:13:34.216169+00	2026-07-22 03:45:45.047154+00
8737b3de-6a94-491c-9151-6233153f48ac	7c73d7a3-a43a-4f2e-957f-4d4f58d47b1f	Recruiter	recruiter@gmail.com	$2a$12$fLkkSLpfCK.HQAdG9mwauuA7NsIXrJZbk2nke7.8RvbAe.O4odS8m	USER	ACTIVE	2026-07-27 13:02:13.461723+00	2026-07-22 01:15:24.123687+00	2026-07-27 13:02:13.461723+00
\.


--
-- Name: auth_activity_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: auth_db_user
--

SELECT pg_catalog.setval('public.auth_activity_logs_id_seq', 82, true);


--
-- Name: auth_activity_logs auth_activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: auth_db_user
--

ALTER TABLE ONLY public.auth_activity_logs
    ADD CONSTRAINT auth_activity_logs_pkey PRIMARY KEY (id);


--
-- Name: churches churches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.churches
    ADD CONSTRAINT churches_pkey PRIMARY KEY (id);


--
-- Name: login_logs login_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_logs
    ADD CONSTRAINT login_logs_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_auth_activity_logs_church_created; Type: INDEX; Schema: public; Owner: auth_db_user
--

CREATE INDEX idx_auth_activity_logs_church_created ON public.auth_activity_logs USING btree (church_id, created_at DESC);


--
-- Name: idx_auth_activity_logs_user_created; Type: INDEX; Schema: public; Owner: auth_db_user
--

CREATE INDEX idx_auth_activity_logs_user_created ON public.auth_activity_logs USING btree (user_id, created_at DESC);


--
-- Name: idx_churches_country_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_churches_country_city ON public.churches USING btree (country, city);


--
-- Name: idx_churches_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_churches_name ON public.churches USING btree (name);


--
-- Name: idx_login_logs_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_login_logs_created_at ON public.login_logs USING btree (created_at DESC);


--
-- Name: idx_login_logs_email_attempted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_login_logs_email_attempted ON public.login_logs USING btree (email_attempted);


--
-- Name: idx_login_logs_status_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_login_logs_status_created_at ON public.login_logs USING btree (status, created_at DESC);


--
-- Name: idx_login_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_login_logs_user_id ON public.login_logs USING btree (user_id);


--
-- Name: idx_users_church_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_church_id ON public.users USING btree (church_id);


--
-- Name: idx_users_church_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_church_role ON public.users USING btree (church_id, role);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- Name: login_logs login_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_logs
    ADD CONSTRAINT login_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users users_church_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_church_id_fkey FOREIGN KEY (church_id) REFERENCES public.churches(id) ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO auth_db_user;


--
-- Name: TABLE churches; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.churches TO auth_db_user;


--
-- Name: TABLE login_logs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.login_logs TO auth_db_user;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO auth_db_user;


--
-- PostgreSQL database dump complete
--

\unrestrict PNIFmX3Oh9hdpKPNydKS7V8JvA8ommyxua4Zm8pn7sz4rtub9ZAOmWA2imBycgS

