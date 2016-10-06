--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = apiv2, pg_catalog;

--
-- Data for Name: purpose_table; Type: TABLE DATA; Schema: apiv2; Owner: postgres
--

INSERT INTO purpose_table (id, name_, name_sv) VALUES (1, 'Travel to work', 'Resa till arbete');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (2, 'Travel to school', 'Resa till skola');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (3, 'Business travel', 'Resa i tjänsten');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (4, 'Other private related travel', 'Övrigt privat');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (5, 'Sport/hobby related travel', 'Motion/friluftsliv');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (6, 'Shopping', 'Shopping/inköp');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (7, 'Pick-up or drop-off children/other persons', 'Hämta eller lämna barn/annan person');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (8, 'Return home', 'Åter till bostaden');

--
-- PostgreSQL database dump complete
--

