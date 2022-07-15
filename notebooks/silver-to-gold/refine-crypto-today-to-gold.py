# Databricks notebook source
service_credential = dbutils.secrets.get(scope="my-simple-azure-keyvault-scope",key="delta-lakehouse-dbx-crypto-job-runner-secret")

spark.conf.set("fs.azure.account.auth.type.dltalakehousesilver.dfs.core.windows.net", "OAuth")
spark.conf.set("fs.azure.account.oauth.provider.type.dltalakehousesilver.dfs.core.windows.net", "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider")
spark.conf.set("fs.azure.account.oauth2.client.id.dltalakehousesilver.dfs.core.windows.net", "53df3811-1549-4f9b-9568-8c67829cd08a")
spark.conf.set("fs.azure.account.oauth2.client.secret.dltalakehousesilver.dfs.core.windows.net", service_credential)
spark.conf.set("fs.azure.account.oauth2.client.endpoint.dltalakehousesilver.dfs.core.windows.net", "https://login.microsoftonline.com/f4cb4c38-d7d4-4c0f-888c-05e0ce4d7437/oauth2/token")

spark.conf.set("fs.azure.account.auth.type.dltalakehousegold.dfs.core.windows.net", "OAuth")
spark.conf.set("fs.azure.account.oauth.provider.type.dltalakehousegold.dfs.core.windows.net", "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider")
spark.conf.set("fs.azure.account.oauth2.client.id.dltalakehousegold.dfs.core.windows.net", "53df3811-1549-4f9b-9568-8c67829cd08a")
spark.conf.set("fs.azure.account.oauth2.client.secret.dltalakehousegold.dfs.core.windows.net", service_credential)
spark.conf.set("fs.azure.account.oauth2.client.endpoint.dltalakehousegold.dfs.core.windows.net", "https://login.microsoftonline.com/f4cb4c38-d7d4-4c0f-888c-05e0ce4d7437/oauth2/token")

# COMMAND ----------

# Set Day Month Year
from datetime import datetime, timedelta

today = datetime.utcnow()
year = today.year
month = today.month
day = today.day

# COMMAND ----------

spark.sql("CREATE SCHEMA IF NOT EXISTS crypto")

# COMMAND ----------

sql_table_create = "CREATE TABLE IF NOT EXISTS crypto.fact \
                      (symbol STRING NOT NULL, price DECIMAL(38,15) NOT NULL, volume_last_hour_usd DECIMAL(38,15) NOT NULL, price_time_stamp TIMESTAMP NOT NULL, price_date DATE NOT NULL) \
                    USING DELTA \
                    PARTITIONED BY (price_date) \
                    LOCATION 'abfss://crypto-data@dltalakehousegold.dfs.core.windows.net/crypto-fact'"

spark.sql(sql_table_create)

# COMMAND ----------

sql_table_create = "CREATE TABLE IF NOT EXISTS crypto.dim \
                      (symbol STRING NOT NULL, name STRING NOT NULL) \
                    USING DELTA \
                    LOCATION 'abfss://crypto-data@dltalakehousegold.dfs.core.windows.net/crypto-dim'"

spark.sql(sql_table_create)

# COMMAND ----------

# Recursive data load for all files from a day from every partition in the Event Hub Namespace
sourcefolderpath = f"abfss://crypto-data@dltalakehousesilver.dfs.core.windows.net/quotes-by-day/{year}/{month:0>2d}/{day:0>2d}"

df = spark.read.parquet(sourcefolderpath)

# COMMAND ----------

# Add Price Date column
from pyspark.sql.functions import to_date

df = df.withColumn("PriceDate", to_date("PriceTimeStamp"))

# COMMAND ----------

df_fact = df.select("Symbol", "Price", "VolumeLastHourUSD", "PriceTimeStamp", "PriceDate")

df_fact = df_fact.withColumnRenamed("Symbol", "symbol") \
                 .withColumnRenamed("Price", "price") \
                 .withColumnRenamed("VolumeLastHourUSD", "volume_last_hour_usd") \
                 .withColumnRenamed("PriceTimeStamp", "price_time_stamp") \
                 .withColumnRenamed("PriceDate", "price_date")

df_fact = df_fact.select("symbol", "price", "volume_last_hour_usd", "price_time_stamp", "price_date")

df_fact.write \
  .format("delta") \
  .saveAsTable("crypto.fact_temp")

# COMMAND ----------

# MAGIC %sql
# MAGIC 
# MAGIC MERGE INTO crypto.fact
# MAGIC USING crypto.fact_temp
# MAGIC ON crypto.fact.symbol = crypto.fact_temp.symbol
# MAGIC   AND crypto.fact.price_time_stamp = crypto.fact_temp.price_time_stamp
# MAGIC WHEN NOT MATCHED
# MAGIC   THEN INSERT * 

# COMMAND ----------

# MAGIC %sql
# MAGIC 
# MAGIC DROP TABLE crypto.fact_temp

# COMMAND ----------

df_dim = df.select("Symbol", "Name").distinct()

df_dim = df_dim.withColumnRenamed("Symbol", "symbol") \
                 .withColumnRenamed("Name", "name") \

df_dim.write \
  .format("delta") \
  .saveAsTable("crypto.dim_temp")

# COMMAND ----------

# MAGIC %sql
# MAGIC 
# MAGIC MERGE INTO crypto.dim
# MAGIC USING crypto.dim_temp
# MAGIC ON crypto.dim.symbol = crypto.dim_temp.symbol
# MAGIC WHEN MATCHED
# MAGIC   THEN UPDATE SET
# MAGIC     name = crypto.dim_temp.name
# MAGIC WHEN NOT MATCHED
# MAGIC   THEN INSERT * 

# COMMAND ----------

# MAGIC %sql
# MAGIC 
# MAGIC DROP TABLE crypto.dim_temp
