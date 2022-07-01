# Azure Delta Lakehouse

This repo contains information on the Delta Lakehouse Design pattern.

## What is the Delta Lakehouse?

The Delta Lakehouse is a pattern for creating repositories for raw data in a variety of formats that provides that brings data reliability and fast .analytics

To better understand what a Delta Lakehouse is, we should first review the two enterprise data storage patterns that came before it:

- The Data Warehouse
- The Data Lakehouse

### The Data Warehouse

The Data Warehouse was the first enterprise data storage pattern to gain dominance in the data architecture world.  The Data Warehouse was familiar, normally using a SQL type of database that contains by a managed and structured data model.  The data model was normally implemented utilizing the tenants of the Star Schema methodology.  This enabled utilizing the Data Warehouse for Reporting and Auditing.  A key characteristic was disciplined usage.

### The Data Lake

As organizations began to realize the value of data in the internet age, the need to capture and store all types of data arose.  Data has been called 'The Oil' of the 21st century, and organizations knew they needed to collect as much raw data as possible and would figure out a way to refine the raw data. The Data Lakehouse pattern emerged as an alternative to the structure and discipline required by the Data Warehouse pattern and allowed organizations to collect terabytes of raw data in many different formats.  

### The Benefits and Drawbacks of Each Pattern

- Data Warehouse
  - Benefits
    - Familiar
    - Managed Strucutred Data model we can give to the business
  - Drawbacks
    - Too rigid
    - Too slow
    - Not quick enough to adapt
- Data Lake
  - Benefits
    - Flexible
    - Distributed
  - Drawbacks
    - Disorganized set of files
    - Inconsistent set of file formats
    - Inefficient file formats

### Data Lake File Formats

Below is a list of the main file formats used in data lakes

- CSV
- Avro
- Parquet
- Delta

#### CSV



- Benefits
  - Human Readable
  - Easy to read and write
  - Flexible
- Brawbacks
  - Schema-on-Read, no metadata
  - No compression
  - No ACID compliance
  - Unfamiliar data processing pattern

#### Avro

- Benefits
  - Some compression
  - Human readable metadata
- Drawbacks
  - No ACID compliance
  - Must have a data processing engine to read and write
  - Unfamiliar processing pattern

#### Parquet

#### Delta



## A Brief History of Big Data

In the initial phase of the computer age, Moores law drove the increases in storage and computing capabilities year over year.

> "Moore's law is a term used to refer to the observation made by Gordon Moore in 1965 that the number of transistors in a dense integrated circuit (IC) doubles about every two years.
> Moore’s law isn’t really a law in the legal sense or even a proven theory in the scientific sense (such as E = mc2). Rather, it was an observation by Gordon Moore in 1965 while he was working at Fairchild Semiconductor: the number of transistors on a microchip (as they were called in 1965) doubled about every year."

This was a natual Vertical Scaling.  Thereby Vertical Scaling was the initial paradigm to meet the world's desire for more complex computing solutions, and hence more computing power.

However with the transition from the initial computer age to the internet age and the slow down of the doubling of Moore's law due to science reaching physical limitations, Vertical Scaling was no longer able to meet the growing desire for global scale computing capacity.  Horizontal Scaling was the answer to that problem.

### Google's Contribution

Google is likely the most well known organization that defined a technical solution using the Horizontal Scaling pattern to realize the world's desire for global computing solutions.

Google's open source midset led them to publish white papers on the two pillars of their Horizontal Scaling pattern they used to collect, catalogue, and index all the webpages of the internet.

- [The Google File System](https://static.googleusercontent.com/media/research.google.com/en//archive/gfs-sosp2003.pdf)
- [MapReduce](https://static.googleusercontent.com/media/research.google.com/en//archive/mapreduce-osdi04.pdf)

### The Google File System

The Google File System is defined in the Google whitepaper:

> "We have designed and implemented the Google File System, a scalable distributed file system for large distributed data-intensive applications. It provides fault tolerance while running on inexpensive commodity hardware, and it delivers high aggregate performance to a large number of clients."

The Google File System led to the open source project named [Hadoop Distributed File System](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html).  Per the Hadoop documentation:

> "The Hadoop Distributed File System (HDFS) is a distributed file system designed to run on commodity hardware. It has many similarities with existing distributed file systems. However, the differences from other distributed file systems are significant. HDFS is highly fault-tolerant and is designed to be deployed on low-cost hardware. HDFS provides high throughput access to application data and is suitable for applications that have large data sets. HDFS relaxes a few POSIX requirements to enable streaming access to file system data. HDFS was originally built as infrastructure for the Apache Nutch web search engine project. HDFS is now an Apache Hadoop subproject. The project URL is <https://hadoop.apache.org/hdfs/>."

### MapReduce

MapReduce is defined in the Google whitepaper as follows:

> "MapReduce is a programming model and an associated implementation for processing and generating large
data sets. Users specify a map function that processes a key/value pair to generate a set of intermediate key/value pairs, and a reduce function that merges all intermediate values associated with the same intermediate key....
>
> Programs written in this functional style are automatically parallelized and executed on a large cluster of commodity machines. The run-time system takes care of the
details of partitioning the input data, scheduling the program’s execution across a set of machines, handling machine failures, and managing the required inter-machine
communication. This allows programmers without any
experience with parallel and distributed systems to easily utilize the resources of a large distributed system."

MapReduce led to the open source project named [Apache Spark]([documents/spark-the-definitive-guide.pdf](https://analyticsdata24.files.wordpress.com/2020/02/spark-the-definitive-guide40www.bigdatabugs.com_.pdf)).  Per the book "Spark The Definitive Guide":

> "Apache Spark is a unified computing engine and a set of libraries for parallel data processing on
computer clusters. As of this writing, Spark is the most actively developed open source engine
for this task, making it a standard tool for any developer or data scientist interested in big data.
Spark supports multiple widely used programming languages (Python, Java, Scala, and R),
includes libraries for diverse tasks ranging from SQL to streaming and machine learning, and
runs anywhere from a laptop to a cluster of thousands of servers. This makes it an easy system to
start with and scale-up to big data processing or incredibly large scale."

The Apache Spark architecture is shown below, most of the development done using Apache Spark is against the Structured APIs.

![Apache Spark Architecture](diagrams/spark-architecture.drawio.svg)

### Spark



## Databricks


## Data Modeling in a Lakehouse

With the rise in the ETL and ELT marketshare of platforms such as Databricks and Azure Data Lake Gen 2, it is clear that the Delta Lakehouse data ingestion and storage pattern is here to stay.  With that, the question becomes 'What is the best data modeling technique for the Delta Lakehouse'.

### Dimensional Modeling

The question of whether Dimensional Modeling is still relevant within a Delta Lakehouse, it is imporant to review the aspects and benefits of Dimensional Modeling.

Per wikipedia, Dimensional Modeling is described as:

> "Dimensional modeling always uses the concepts of facts (measures), and dimensions (context). Facts are typically (but not always) numeric values that can be aggregated, and dimensions are groups of hierarchies and descriptors that define the facts. For example, sales amount is a fact; timestamp, product, register#, store#, etc. are elements of dimensions. Dimensional models are built by business process area, e.g. store sales, inventory, claims, etc. Because the different business process areas share some but not all dimensions, efficiency in design, operation, and consistency, is achieved using conformed dimensions, i.e. using one copy of the shared dimension across subject areas.
>
> Dimensional modeling does not necessarily involve a relational database. The same modeling approach, at the logical level, can be used for any physical form, such as multidimensional database or even flat files. It is oriented around understandability and performance."

Along with Fact and Dimension datasets, several other key concepts are used within standard data modeling techniques:

- Keys and Key Types
- Dimension Type

#### Keys and Key Types

Keys within Data Warehouses are used to denote uniqueness and allow the joining of records from Fact datasets to records within Dimension datasets.

There are two main types of Keys in dimensional modeling that provide record uniqueness:

- Natural Key
  - The Primary Key from the Transactional Source System.
- Surrogate Key
  - The warehouse's Primary Key.
  - Should be kept to a single field, no compund surrogate keys, because we do not want to have multiple keys on our Fact table to tie back to the Dimensional table.
  - Should be an Integer value instead of a Globaly Unique Identifier (GUID) becuase GUID's require 16 bytes where Integers require only 4 bytes.
  - Used to insulate the data warehouse from changes in the Natural Key, such as a new Transactional Source System or acquisition of other companies, therefore should not be a derivitive of the Natural Key(s).

#### Dimension Types

There are 8 dimension types in dimensional modeling, however only 3 are used:

- Type 0
  - Data cannot change
- Type 1
  - Data can change but no historical records are kept
- Type 2
  - Data can change and historical records are kept predominantly via record expiration using Start and End Date fields.

### Canonical Data Objects

An alternate to Dimensional Modeling is Canonical Data Modeling.  Canonical Data Modeling aims to present entities and relationships in the simplest possible form.  Canonical Data Modeling first started with system integration where the Canonical Data Model was used to communicate between seperate systems.  It was intended to reduce costs by standardizing on agreed data definitions associated with integrating business systems.

## References

- [Apache Spark](https://slower.udemy.com/course/apache-spark-programming-in-python-for-beginners/learn/lecture/20156416#overview)
- [Databricks, Delta Lake and You - Simon Whiteley](https://www.youtube.com/watch?v=y91r_DLMEq8)
- [Data Modelling: From Single Table To Star Schema - Chris Barber](https://www.youtube.com/watch?v=F4tK0dwJKU4)
- [Hadoop Distributed File System](https://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
- [Moore's Law](https://www.synopsys.com/glossary/what-is-moores-law.html#:~:text=Definition,as%20E%20%3D%20mc2)
- [MapReduce](https://static.googleusercontent.com/media/research.google.com/en//archive/mapreduce-osdi04.pdf)
- [The Delta Lake Series Lakehouse](https://databricks.com/wp-content/uploads/2021/04/The-Delta-Lake-Series-Lakehouse-012921.pdf?itm_data=nurturety-card-lakehouse-pdf)
- [The Google File System](https://static.googleusercontent.com/media/research.google.com/en//archive/gfs-sosp2003.pdf)

## Potential Demo Data Source

- [Example set of Sales Data](https://eforexcel.com/wp/downloads-18-sample-csv-files-data-sets-for-testing-sales/)
