def transform_raw(secrets, spark, glueContext):
    df = (
        spark.read.format("csv")
        .option("header", True)
        .option("inferSchema", True)
        .load(f"{secrets['raw_path']}/sample/austin_traffic/")
    )

    df.write.format("parquet").mode("overwrite").save(
        f"{secrets['stage_path']}/sample/austin_traffic/"
    )
