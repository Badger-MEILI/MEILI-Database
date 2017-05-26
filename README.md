# MEILI Database

The MEILI Database is the backend storage module for the MEILI System and has the following functionality:

- Storage
    - data collected by the **MEILI Mobility Collector** clients (GPS locations fused with accelerometer readings) 
    - data annotated by the same clients using the **MEILI Travel Diary** (trips and triplegs)
- Functions for
  - CRUD operations for **MEILI Travel Diary**
  - pagination operations for **MEILI Travel Diary**
  - API specific operations for the backend part of **MEILI Travel Diary** 

> The MEILI Database is written (and licensed) for academic purposes, and as such, it is a proof of concept and **SHOULD NOT** be used as it is in production. Complex issues such as performance tunning, security, anonymization and any further development should be addressed by experts before running it in production.

### Version
1.0.0

### Tech

The MEILI Database is built on **Postgres 9.3** and uses **PostGIS 2.1.7**. Tests are built for **pgTAP**.

The data import tool uses **wget** and **osm2pgsql SVN version 0.85.0 (64bit id space)**


### Installation (including POI dataset imports)

This step sets up the database and inserts the available OSM public transportation stations and points of interest for a given area specified by a bounding box. If you are not interested in a prepopulated database with POIs and transport stops, see next step. 

First, create an empty Postgres database, then go to the location of the *initialize_meili.sh* file and run:
```
$ bash initialize_meili.sh <min_lat> <min_lon> <max_lat> <max_lon> <namedb> <username> <hostdb>
```

For example, to create a new database for the Stockholm area, one could use the following sequence of operations:
```
$ createdb meili_stockholm -U postgres
$ bash initialize_meili.sh 59.0836 17.3584 59.8352 18.9679 meili_stockholm postgres localhost 
```

### Installation (database only)

This step sets up the database without any data support. If you are interested in a prepopulated database with POIs and transportation stops, see the previous step.

Set up your database, go to the location of *init.sql* and run:

```sh
$ psql -U yourUsername -d yourDatabase -a -f init.sql -v ON_ERROR_STOP=1
```

### Testing

Install [pgTap](http://pgtap.org/), go to the Unit_Tests folder and run: 

```sh
$ chmod +x script.sh 
$ ./script.sh db_name user_name
```

### Development

Want to contribute? Great! See the Todos list for needed improvements. Also, you can contact me on github or my email address for further details. 

### Contributing to the code base 
Write clean and well documented code. We aim at robust code coverage, as long as it's not superfluous. 
 
### Todos

- Document the LCS functions and add unit tests
- Determine logic for splitting a trip that already contains more than one tripleg (this crashes now) 
- Change flow tests into unit test 
- Add unit tests for authentication 
- Any benchmark ideas? 

Need help setting up MEILI in production
----
For any inquiries regarding setting up MEILI in production, you can contact the team leader for the MEILI system project (see http://adrianprelipcean.github.io/)

License
----

This DATABASE is made available under the Open Data Commons Attribution License (ODC-By) v1.0. It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Copyright &copy; 2014-2017 Adrian C. Prelipcean - http://adrianprelipcean.github.io/ 
Copyright &copy; 2016-2017 Badger AB - https://github.com/Badger-MEILI

You should have received a copy of the Open Data Commons Attribution License (ODC-By) v1.0 along with this program.  If not, see http://opendatacommons.org/wp-content/uploads/2010/01/odc_by_1.0_public_text.txt
