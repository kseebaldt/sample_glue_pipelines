from chispa.dataframe_comparer import assert_approx_df_equality, assert_df_equality
from dateutil.parser import isoparse
from pytest import fixture

from sample_pipelines.traffic.stage import transform_raw


@fixture
def paths(tmp_path, data_path):
    return {
        "raw_path": str(data_path / "raw"),
        "stage_path": str(tmp_path / "stage"),
    }


@fixture
def secrets():
    return {"some_secret": "abc123"}


def test_converts_dates(paths, secrets, spark, glueContext):
    transform_raw(paths, secrets, spark, glueContext)
    df = spark.read.format("parquet").load(
        f"{paths['stage_path']}/sample/austin_traffic/"
    )

    expected = spark.createDataFrame(
        [
            (
                "C163BCD1CF90C984E9EDA4DBA311BCA369A7D1A1_1528871759",
                isoparse("2018-06-13T06:35:59.000Z"),
                isoparse("2018-06-13T09:00:03.000Z"),
            ),
            (
                "6B20382196FB454E9FD06A33E60142902A2F0706_1528884936",
                isoparse("2018-06-13T10:15:36.000Z"),
                isoparse("2018-06-13T11:20:03.000Z"),
            ),
            (
                "6F0179C78C19C896ABF478785283768080523714_1587216052",
                isoparse("2020-04-18T13:20:52.000Z"),
                isoparse("2020-04-18T14:10:04.000Z"),
            ),
        ],
        ["traffic_report_id", "published_date", "traffic_report_status_date_time"],
    )

    assert_df_equality(
        df.select(
            "traffic_report_id", "published_date", "traffic_report_status_date_time"
        ),
        expected,
    )


def test_converts_latitude_longitude(paths, secrets, spark, glueContext):
    transform_raw(paths, secrets, spark, glueContext)
    df = spark.read.format("parquet").load(
        f"{paths['stage_path']}/sample/austin_traffic/"
    )

    expected = spark.createDataFrame(
        [
            (
                "C163BCD1CF90C984E9EDA4DBA311BCA369A7D1A1_1528871759",
                30.283797,
                -97.741906,
            ),
            (
                "6B20382196FB454E9FD06A33E60142902A2F0706_1528884936",
                30.339593,
                -97.700963,
            ),
            (
                "6F0179C78C19C896ABF478785283768080523714_1587216052",
                30.336023,
                -97.702255,
            ),
        ],
        ["traffic_report_id", "latitude", "longitude"],
    )

    assert_approx_df_equality(
        df.select("traffic_report_id", "latitude", "longitude"), expected, 0.00001
    )
