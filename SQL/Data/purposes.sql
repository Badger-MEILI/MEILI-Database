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
INSERT INTO purpose_table (id, name_, name_sv) VALUES (4, 'Restaurant/Café', 'Restaurang/Café');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (5, 'Leisure travel (e.g. go to cinema, theater)', 'Nöje (t ex bio, teater)');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (6, 'Sport/hobby related travel', 'Motion/friluftsliv');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (7, 'Food/grocery shopping', 'Inköp av livsmedel');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (8, 'Non-food shopping', 'Annat inköp');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (9, 'Personal business (e.g. medical visit, bank, cutting hair)', 'Service (t ex vårdcentral, bank, frisör)');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (10, 'Visit relatives and friends', 'Besöka släkt och vänner');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (11, 'Pick-up or drop-off children/other persons', 'Hämta eller lämna barn/annan person');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (12, 'Return home', 'Åter till bostaden');
INSERT INTO purpose_table (id, name_, name_sv) VALUES (13, 'Other (incl. walk/travel without specific purpose)', 'Annat/övrigt (inkl. resa utan ärende');


--
-- PostgreSQL database dump complete
--

