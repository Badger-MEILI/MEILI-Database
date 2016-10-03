--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = raw_data, pg_catalog;

--
-- Data for Name: user_table; Type: TABLE DATA; Schema: raw_data; Owner: postgres
--

INSERT INTO user_table (id, username, password, phone_model, phone_os) VALUES (10, 'adi@kth.se', '$2a$08$VzitFl03hNsEf0UCEzNMwu9IVdGleExA9enaDidGODTI9Jyb4FrGi', 'android', 'android model');


--
-- Name: user_table_id_seq; Type: SEQUENCE SET; Schema: raw_data; Owner: postgres
--

SELECT pg_catalog.setval('user_table_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

