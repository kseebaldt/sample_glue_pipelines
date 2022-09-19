from chispa.dataframe_comparer import assert_df_equality
from dateutil.parser import isoparse
from pytest import fixture

from sample_pipelines.traffic.analytics import aggregate_incidents


@fixture
def paths(tmp_path):
    return {
        "stage_path": str(tmp_path / "stage"),
        "analytics_path": str(tmp_path / "analytics"),
    }


@fixture
def secrets():
    return {"some_secret": "abc123"}


@fixture
def input_df(spark, paths):
    df = spark.createDataFrame(
        [
            (
                "Incident 1",
                isoparse("2018-06-13T06:35:59.000Z"),
                30.266666,
                -97.73333,
            ),
            (
                "Incident 1",
                isoparse("2018-06-23T10:15:36.000Z"),
                30.266666,
                -97.73333,
            ),
            (
                "Incident 1",
                isoparse("2018-07-13T10:15:36.000Z"),
                30.266666,
                -97.73333,
            ),
            (
                "Incident 2",
                isoparse("2018-06-18T13:20:52.000Z"),
                30.266666,
                -97.73333,
            ),
        ],
        ["issue_reported", "published_date", "latitude", "longitude"],
    )
    df.write.format("parquet").mode("overwrite").save(
        f"{paths['stage_path']}/sample/austin_traffic/"
    )
    return df


def test_aggregation(paths, secrets, spark, glueContext, input_df):
    aggregate_incidents(paths, secrets, spark, glueContext)
    df = spark.read.format("parquet").load(
        f"{paths['analytics_path']}/sample/austin_traffic/"
    )

    expected = spark.createDataFrame(
        [
            ("2018-06", "89489e3464fffff", "Incident 1", 2),
            ("2018-06", "89489e3464fffff", "Incident 2", 1),
            ("2018-07", "89489e3464fffff", "Incident 1", 1),
        ],
        ["month", "h3_index", "issue_reported", "count"],
    )

    assert_df_equality(
        df.select("month", "h3_index", "issue_reported", "count"),
        expected,
        ignore_row_order=True,
    )
