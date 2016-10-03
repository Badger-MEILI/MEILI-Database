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
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (3, 'Moped / Motorcycle', 'Moped / Mc');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (4, 'Car as driver', 'Bil som förare');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (5, 'Car as passenger', 'Bil som passagerare');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (6, 'Taxi', 'Taxi');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (7, 'Paratransit', 'Färdtjänst');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (8, 'Bus', 'Buss');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (9, 'Subway', 'Tunnelbana');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (10, 'Tram', 'Spårvagn');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (11, 'Commuter train', 'Pendeltåg');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (12, 'Train', 'Tåg');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (13, 'Ferryboat', 'Färja / båt');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (14, 'Flight', 'Flyg');
INSERT INTO travel_mode_table (id, name_, name_sv) VALUES (15, 'Other', 'Övrigt');


--
-- PostgreSQL database dump complete
--

