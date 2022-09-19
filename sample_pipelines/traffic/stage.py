def transform_raw(paths, secrets, spark, glueContext):
    df = (
        spark.read.format("csv")
        .option("header", True)
        .option("inferSchema", True)
        .load(f"{paths['raw_path']}/sample/austin_traffic/")
    )

    df.write.format("parquet").mode("overwrite").save(
        f"{paths['stage_path']}/sample/austin_traffic/"
    )
