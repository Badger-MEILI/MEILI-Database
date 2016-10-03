BEGIN;
\i Extensions/extensions.sql;
\i Schemas_Tables/raw.sql; 
\i Schemas_Tables/apiv2.sql; 
\i Functions/raw_functions.sql;
\i Triggers/raw_triggers.sql;
\i Functions/apiv2_functions.sql;
\i Triggers/apiv2_triggers.sql;
COMMIT;
