import h3_pyspark
import pyspark.sql.functions as F


def aggregate_incidents(paths, secrets, spark, glueContext):
    df = spark.read.format("parquet").load(
        f"{paths['stage_path']}/sample/austin_traffic/"
    )
    df.show()
    print(df.schema)
    df = (
        df.withColumn(
            "h3_index", h3_pyspark.geo_to_h3("latitude", "longitude", F.lit(9))
        )
        .withColumn("month", F.date_format("published_date", "yyyy-MM"))
        .groupBy("month", "h3_index", "issue_reported")
        .count()
    )
    df.show()

    df.write.format("parquet").mode("overwrite").save(
        f"{paths['analytics_path']}/sample/austin_traffic/"
    )
