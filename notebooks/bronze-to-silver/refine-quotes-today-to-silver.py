# Databricks notebook source
# Set Day Month Year
from datetime import datetime, timedelta

today = datetime.utcnow()
year = today.year
month = today.month
day = today.day

# COMMAND ----------

# Recursive data load for all files from a day from every partition in the Event Hub Namespace
sourcefolderpath = f"abfss://crypto-stream@dltalakehousebronze.dfs.core.windows.net/ehns-quote-streams/eh-crypto-stream/*/{year}/{month:0>2d}/{day:0>2d}"

df = spark.read.option("recursiveFileLookup","true").option("header","true").format("avro").load(sourcefolderpath)

# COMMAND ----------

# Change the Body field from Binary to JSON 
from pyspark.sql.functions import from_json, col
from pyspark.sql.types import StringType, DoubleType, StructType, StructField, LongType, TimestampType

sourceSchema = StructType([
        StructField("Symbol", StringType(), False),
        StructField("Price", DoubleType(), True),
        StructField("Name", StringType(), True),
        StructField("VolumeLastHourUSD", DoubleType(), True),
        StructField("SymbolsCount", LongType(), True),
        StructField("TradeCount", LongType(), True),
        StructField("QuoteCount", LongType(), True),
        StructField("PriceTimeStamp", TimestampType(), True)])

df = df.withColumn("StringBody", col("Body").cast("string"))
jsonOptions = {"dateFormat" : "yyyy-MM-dd HH:mm:ss.SSS"}
df = df.withColumn("JsonBody", from_json(df.StringBody, sourceSchema, jsonOptions))

# COMMAND ----------

# Flatten the Body JSON field into columns of the DataFrame
for c in df.schema["JsonBody"].dataType:
    df = df.withColumn(c.name, col("JsonBody." + c.name))

# COMMAND ----------

# Remove 0 priced assets
df = df.filter("Price > 0")

# COMMAND ----------

# Sort the data
df = df.sort("Symbol", "PriceTimeStamp")

# COMMAND ----------

# Select only the meaningful columns for the export to Silver data zone
exportDF = df.select("Symbol", "Price", "Name", "VolumeLastHourUSD", "SymbolsCount", "TradeCount", "QuoteCount", "PriceTimeStamp")

# COMMAND ----------

# Cast Price to Decimal
from pyspark.sql.types import DecimalType

exportDF = exportDF.withColumn("Price", df.Price.cast(DecimalType(38,15)))

# COMMAND ----------

# Write the parquet file in the bronze crypto data zone
manualpartitionfolderpath = f"abfss://crypto-data@dltalakehousesilver.dfs.core.windows.net/quotes-by-day/{year}/{month:0>2d}/{day:0>2d}"

exportDF.write.mode("overwrite").parquet(manualpartitionfolderpath)
