from pytest import fixture
import boto3
from moto import mock_s3
import smart_open

from sample_pipelines.traffic.raw import import_csv, DATASET_URL, _write_last_timestamp


@fixture
def now(mocker):
    timestamp = "2022-09-07T21:30:46.717814"
    mock = mocker.patch("sample_pipelines.traffic.raw._now")
    mock.return_value = timestamp
    return timestamp


@fixture
def bucket_name():
    return "my-test-bucket"


@fixture(autouse=True)
def s3_bucket(bucket_name):
    with mock_s3():
        conn = boto3.resource("s3")
        yield conn.create_bucket(Bucket=bucket_name)


@fixture
def secrets(bucket_name):
    return {"raw_path": f"s3://{bucket_name}/raw/"}


@fixture
def previous_timestamp(bucket_name, secrets):
    previous_timestamp = "2022-09-06T21:30:46.717814"
    s3 = boto3.client("s3")
    _write_last_timestamp(s3, secrets["raw_path"], previous_timestamp)
    return previous_timestamp


def test_queries_all_records(secrets, now, requests_mock):
    requests_mock.get(
        DATASET_URL,
        text="a,b,c",
    )

    import_csv(secrets)

    where = f"traffic_report_status_date_time <= '{now.lower()}'"
    assert where in requests_mock.last_request.qs["$where"]


def test_queries_records_since_last_timestamp(
    secrets, requests_mock, now, previous_timestamp
):
    requests_mock.get(
        DATASET_URL,
        text="a,b,c",
    )

    import_csv(secrets)
    where = f"traffic_report_status_date_time <= '{now.lower()}' and traffic_report_status_date_time > '{previous_timestamp.lower()}'"
    assert where in requests_mock.last_request.qs["$where"]


def test_writes_nothing_if_only_header_returned(
    secrets, requests_mock, now, bucket_name
):
    requests_mock.get(
        DATASET_URL,
        text="a,b,c",
    )

    import_csv(secrets)

    s3 = boto3.resource("s3")

    keys = [o.key for o in s3.Bucket(bucket_name).objects.all()]

    assert keys == []


def test_writes_csv_file(secrets, requests_mock, now, bucket_name):
    rows = ["col1,col2\n", "foo,bar\n", "abc,def\n"]
    requests_mock.get(
        DATASET_URL,
        text="".join(rows),
    )

    import_csv(secrets)

    url = f"{secrets['raw_path']}sample/austin_traffic/load_time={now}/data.csv.gz"

    lines = list(smart_open.open(url, transport_params={"client": boto3.client("s3")}))

    assert lines == rows


def test_writes_last_timestamp(secrets, requests_mock, now, bucket_name):
    requests_mock.get(
        DATASET_URL,
        text="col1,col2\nfoo,bar\nabc,def\n",
    )

    import_csv(secrets)

    s3 = boto3.resource("s3")

    keys = [o.key for o in s3.Bucket(bucket_name).objects.all()]
    path_prefix = "raw/sample/austin_traffic"

    assert f"{path_prefix}/last_timestamp" in keys
    content = (
        s3.Object(bucket_name, f"{path_prefix}/last_timestamp")
        .get()["Body"]
        .read()
        .decode("utf-8")
    )
    assert content == now
