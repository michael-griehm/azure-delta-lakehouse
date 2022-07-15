# Databricks notebook source
service_credential = dbutils.secrets.get(scope="my-simple-azure-keyvault-scope",key="delta-lakehouse-dbx-crypto-job-runner-secret")

spark.conf.set("fs.azure.account.auth.type.dltalakehousebronze.dfs.core.windows.net", "OAuth")
spark.conf.set("fs.azure.account.oauth.provider.type.dltalakehousebronze.dfs.core.windows.net", "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider")
spark.conf.set("fs.azure.account.oauth2.client.id.dltalakehousebronze.dfs.core.windows.net", "53df3811-1549-4f9b-9568-8c67829cd08a")
spark.conf.set("fs.azure.account.oauth2.client.secret.dltalakehousebronze.dfs.core.windows.net", service_credential)
spark.conf.set("fs.azure.account.oauth2.client.endpoint.dltalakehousebronze.dfs.core.windows.net", "https://login.microsoftonline.com/f4cb4c38-d7d4-4c0f-888c-05e0ce4d7437/oauth2/token")

spark.conf.set("fs.azure.account.auth.type.dltalakehousesilver.dfs.core.windows.net", "OAuth")
spark.conf.set("fs.azure.account.oauth.provider.type.dltalakehousesilver.dfs.core.windows.net", "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider")
spark.conf.set("fs.azure.account.oauth2.client.id.dltalakehousesilver.dfs.core.windows.net", "53df3811-1549-4f9b-9568-8c67829cd08a")
spark.conf.set("fs.azure.account.oauth2.client.secret.dltalakehousesilver.dfs.core.windows.net", service_credential)
spark.conf.set("fs.azure.account.oauth2.client.endpoint.dltalakehousesilver.dfs.core.windows.net", "https://login.microsoftonline.com/f4cb4c38-d7d4-4c0f-888c-05e0ce4d7437/oauth2/token")

# COMMAND ----------

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
