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

The MEILI Database is built on Postgres 9.3 and uses PostGIS 2.1.7.

### Installation

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
 
### Todos

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
