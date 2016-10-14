psql -d $1 -U $2 -f populate_with_data.sql 
pg_prove --dbname $1 -U $2 test*.sql
psql -d $1 -U $2 -f remove_test_data.sql
