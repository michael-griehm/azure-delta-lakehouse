# Azure Delta Lakehouse

This repo contains a demo of how to ingest data from either a Snowflake data warehouse or FTP folder into a Delta Lake.

## Data Source

Example set of Sales data from <https://eforexcel.com/wp/downloads-18-sample-csv-files-data-sets-for-testing-sales/>.

## Dimensional Modeling

The question of whether Dimensional Modeling is still relevant within a Delta Lakehouse, it is imporant to review the aspects and benefits of Dimensional Modeling.

Per wikipedia, Dimensional Modeling is described as:

  "Dimensional modeling always uses the concepts of facts (measures), and dimensions (context). Facts are typically (but not always) numeric values that can be aggregated, and dimensions are groups of hierarchies and descriptors that define the facts. For example, sales amount is a fact; timestamp, product, register#, store#, etc. are elements of dimensions. Dimensional models are built by business process area, e.g. store sales, inventory, claims, etc. Because the different business process areas share some but not all dimensions, efficiency in design, operation, and consistency, is achieved using conformed dimensions, i.e. using one copy of the shared dimension across subject areas.

  Dimensional modeling does not necessarily involve a relational database. The same modeling approach, at the logical level, can be used for any physical form, such as multidimensional database or even flat files. It is oriented around understandability and performance."

Along with Fact and Dimension datasets, several other key concepts are used within standard data modeling techniques:

- Keys and Key Types
- Dimension Type

### Keys and Key Types

Keys within Data Warehouses are used to denote uniqueness and allow the joining of records from Fact datasets to records within Dimension datasets.

There are two main types of Keys in dimensional modeling that provide types of record uniqueness:

- Natural Key
  - The Primary Key from the Transactional Source System.
- Surrogate Key
  - The warehouse's Primary Key.
  - Should be kept to a single field, no compund surrogate keys, because we do not want to have multiple keys on our Fact table to tie back to the Dimensional table.
  - Should be an Integer value instead of a Globaly Unique Identifier (GUID) becuase GUID's require 16 bytes where Integers require only 4 bytes.
  - Used to insulate the data warehouse from changes in the Natural Key, such as a new Transactional Source System or acquisition of other companies, therefore should not be a derivitive of the Natural Key(s).

### Dimension Types

There are 8 dimension types in dimensional modeling, however only 3 are used:

- Type 0
  - Data cannot change
- Type 1
  - Data can change but no historical records are kept
- Type 2
  - Data can change and historical records are kept predominantly via record expiration using Start and End Date fields.

## References

<https://www.youtube.com/watch?v=F4tK0dwJKU4>
