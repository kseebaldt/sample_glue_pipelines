import itertools
from datetime import datetime

import boto3
import requests
import smart_open

DATASET_URL = "https://data.austintexas.gov/resource/dx9v-zd7x.csv"
LIMIT = 10000000


def import_csv(paths, secrets):
    now_timestamp = _now()
    s3 = boto3.client("s3")

    where = f"traffic_report_status_date_time <= '{now_timestamp}'"
    last_timestamp = _get_last_timestamp(s3, paths["raw_path"])
    if last_timestamp:
        where = f"{where} and traffic_report_status_date_time > '{last_timestamp}'"

    response = requests.get(
        DATASET_URL, params={"$where": where, "$limit": LIMIT}, stream=True
    )

    url = f"{paths['raw_path']}sample/austin_traffic/load_time={now_timestamp}/data.csv.gz"

    results = response.iter_lines()

    try:
        header = next(results)
        first = next(results)
        with smart_open.open(url, "wb", transport_params={"client": s3}) as fout:
            for line in itertools.chain([header, first], results):
                fout.write(line)
                fout.write(b"\n")
    except StopIteration:
        return None

    _write_last_timestamp(s3, paths["raw_path"], now_timestamp)


def _get_last_timestamp(s3, base_url):
    try:
        with smart_open.open(
            f"{base_url}sample/austin_traffic/last_timestamp",
            transport_params={"client": s3},
        ) as fin:
            return fin.readline().strip()
    except OSError:
        return None


def _write_last_timestamp(s3, base_url, timestamp):
    with smart_open.open(
        f"{base_url}sample/austin_traffic/last_timestamp",
        "wb",
        transport_params={"client": s3},
    ) as fout:
        fout.write(timestamp.encode("utf-8"))


def _now():
    return datetime.now().isoformat()
