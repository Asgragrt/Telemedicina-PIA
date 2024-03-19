--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    username character varying(50),
    password character varying(300),
    email character varying(255),
    created_on timestamp without time zone,
    full_name character varying(150),
    verif_status character varying(50),
    role_id integer
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accounts_id_seq OWNER TO postgres;

--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: consultas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consultas (
    id integer NOT NULL,
    user_id integer,
    created_on timestamp without time zone,
    motivo character varying(150),
    diagnostico character varying(150),
    prescripcion character varying(150),
    incapacidad character varying(50),
    dispositivo integer
);


ALTER TABLE public.consultas OWNER TO postgres;

--
-- Name: consultas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.consultas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consultas_id_seq OWNER TO postgres;

--
-- Name: consultas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.consultas_id_seq OWNED BY public.consultas.id;


--
-- Name: dispositivos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dispositivos (
    id integer NOT NULL,
    device_number integer,
    assigned_to integer,
    assigned_by integer,
    assigned_date timestamp without time zone,
    assigned_period character varying(20),
    tipo_registro character varying(20),
    remote_ip character varying(20),
    device_type character varying(255)
);


ALTER TABLE public.dispositivos OWNER TO postgres;

--
-- Name: dispositivos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dispositivos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.dispositivos_id_seq OWNER TO postgres;

--
-- Name: dispositivos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dispositivos_id_seq OWNED BY public.dispositivos.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: consultas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consultas ALTER COLUMN id SET DEFAULT nextval('public.consultas_id_seq'::regclass);


--
-- Name: dispositivos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivos ALTER COLUMN id SET DEFAULT nextval('public.dispositivos_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts (id, username, password, email, created_on, full_name, verif_status, role_id) FROM stdin;
2	paciente_1	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	pac01@mail.me	\N	Juan Lopez	\N	1
3	paciente_2	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	pac02@mail.me	\N	Maria Garza	\N	1
4	paciente_3	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	pac03@mail.me	\N	Samuel Ruiz	\N	1
5	doctor_1	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	doc01@mail.me	\N	Antonio SantAnna	\N	3
6	doctor_2	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	doc02@mail.me	\N	Luis Pedraza	\N	3
7	doctor_3	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	doc03@mail.me	\N	Javier Su	\N	3
8	nurse_1	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	nurse01@mail.me	\N	Ricardo Juarez	\N	2
9	nurse_2	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	nurse02@mail.me	\N	Lazaro Esau	\N	2
10	nurse_3	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	nurse03@mail.me	\N	Diana Velasco	\N	2
11	especi_1	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	esp01@mail.me	\N	Ronald McMiller	\N	4
12	especi_2	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	esp02@mail.me	\N	Juliana Shou	\N	4
15	manuel_roza	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	maro@mail.me	\N	Manuel Roza	\N	1
16	nurse_4	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	nurse04@mail.me	\N	Mariana Fernanda Meza Martínez	\N	2
1	admin	$2b$12$4ui4a2dV1swniueEsY./deCrylSZVDIaICF6kZgAHRiYHggREHguO	admin@mail.com	\N	Miguel Perez	\N	0
13	especi_3	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	esp03@mail.me	\N	David Jackson	\N	4
17	paciente_pia	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	pacpia@mail.me	\N	Armando Puentes	\N	1
14	doctor_cervantes	$2b$12$jLtx2HCrA0D1Et8Nmy6N7eHD74WPbLSelFvTzHSF8FjAsHBguyIji	oscer@mail.me	\N	Oscar Cervantes	\N	4
\.


--
-- Data for Name: consultas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consultas (id, user_id, created_on, motivo, diagnostico, prescripcion, incapacidad, dispositivo) FROM stdin;
1	2	2023-01-12 07:40:16	Fractura pierna	Fractura femur grado 3	Paracetamo c/8h	7 dias	\N
2	2	2023-01-23 12:10:15	Retiro de yeso	Recupera movilidad	N/A	N/A	\N
4	15	2023-03-15 09:12:15	Malestar general	Indeterminado	Vitamina D	N/A	\N
5	15	2023-03-20 12:10:35	Malestar mayor	Covid-19	Ibuprofeno c/6h	14 dias	\N
6	15	2023-03-23 09:41:21	Problemas para respirar	Oxigenación baja	Oxígeno suplementario	7 dias	\N
7	15	2023-03-25 07:53:03	Dolor abdominal	Insuficiencia renal aguda	Tratamiento renal sustitutivo	21 dias	\N
8	15	2023-03-26 13:17:28	Complicaciones generales	LInfohistiocitosis hemofagocítica	Inmunomodulares c/8h	21 dias	\N
3	2	2023-01-30 07:10:25	Contractura esp	Torcedura detectada	Diclofenaco c/6h	N/A	129376
9	2	2023-12-06 22:21:33	Dolor muscular	Desgarre	Paracetamol c/6h	Seis años	\N
34	2	2023-12-09 19:24:32	Dolor muscular	Desgarre	Naproxeno c/6h	Ninguna	129376
35	17	2023-12-09 19:28:25	Emergencia	Embolismo cerebro vascular	Anticoagulantes\r\nTerapia de perfusion	5 dias	129376
\.


--
-- Data for Name: dispositivos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dispositivos (id, device_number, assigned_to, assigned_by, assigned_date, assigned_period, tipo_registro, remote_ip, device_type) FROM stdin;
2	226191	\N	\N	\N	\N	\N	\N	ECG
3	320948	\N	\N	\N	\N	\N	\N	Termómetro
1	129376	17	14	2023-12-09 19:28:25	5 dias	\N	192.168.0.104	Oxímetro
\.


--
-- Name: accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accounts_id_seq', 17, true);


--
-- Name: consultas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.consultas_id_seq', 35, true);


--
-- Name: dispositivos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dispositivos_id_seq', 1, true);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: consultas consultas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consultas
    ADD CONSTRAINT consultas_pkey PRIMARY KEY (id);


--
-- Name: dispositivos dispositivos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dispositivos
    ADD CONSTRAINT dispositivos_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

