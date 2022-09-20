import json
import h3
import pyspark.sql.functions as F
from shapely.geometry import Polygon, mapping


def _geo_to_h3(lat, lng, res):
    return h3.geo_to_h3(lat, lng, res)


def _to_wkt(index):
    coords = h3.h3_to_geo_boundary(index, geo_json=True)
    return Polygon(coords).wkt


def _to_geojson(index):
    coords = h3.h3_to_geo_boundary(index, geo_json=True)
    return json.dumps(mapping(Polygon(coords)))


def aggregate_incidents(paths, secrets, spark, glueContext):
    geo_to_h3 = F.udf(_geo_to_h3)
    to_wkt = F.udf(_to_wkt)
    to_geojson = F.udf(_to_geojson)

    df = spark.read.format("parquet").load(
        f"{paths['stage_path']}/sample/austin_traffic/"
    )

    df = (
        df.where(F.col("latitude").isNotNull() & F.col("longitude").isNotNull())
        .withColumn("h3_index", geo_to_h3("latitude", "longitude", F.lit(9)))
        .withColumn(
            "wkt",
            to_wkt("h3_index"),
        )
        .withColumn(
            "geojson",
            to_geojson("h3_index"),
        )
        .withColumn("month", F.trunc("published_date", "MM"))
        .groupBy("month", "h3_index", "issue_reported")
        .agg(
            F.count("*").alias("count"),
            F.first("wkt").alias("wkt"),
            F.first("geojson").alias("geojson"),
        )
    )

    df.write.format("parquet").mode("overwrite").save(
        f"{paths['analytics_path']}/sample/austin_traffic/"
    )
