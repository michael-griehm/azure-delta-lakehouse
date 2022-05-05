# azure-deltalake

This repo contains a demo of how to ingest data from either a Snowflake data warehouse or FTP folder into a Delta Lake.

## Data Source

Example set of Sales data from <https://eforexcel.com/wp/downloads-18-sample-csv-files-data-sets-for-testing-sales/>.

## Dimensional Modeling

### Dimension Types

There are 8 dimension types in dimensional modeling, however only 3 are used:

- Type 0
  - Data cannot change
- Type 1
  - Data can change but no historical records are kept
- Type 2
  - Data can change and historical records are kept predominantly via record expiration using Start and End Date fields.

### Key Types Denoting Uniqueness

There are two main key types in dimensional modeling that provide types of record uniqueness:

- Natural Key
  - The Primary Key from the Transactional Source System
- Surrogate Key
  - The warehouse's Primary Key
  - Should be kept to a single field, no compund surrogate keys, because we do not want to have multiple keys on our Fact table to tie back to the Dimensional table.
