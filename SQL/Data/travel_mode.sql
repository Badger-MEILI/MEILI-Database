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
-- Data for Name: travel_mode_table; Type: TABLE DATA; Schema: apiv2; Owner: postgres
--

INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (1, 'Walk', 'Till fots');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (2, 'Bicycle', 'Cykel');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (3, 'Bus', 'Buss');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (4, 'Car', 'Bil');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (5, 'Tram', 'Spårvagn');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (6, 'Train', 'Tåg');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (7, 'Other', 'Övrigt');



--
-- PostgreSQL database dump complete
--

