import os
from pathlib import Path

from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pytest import fixture


@fixture(scope="session")
def glueContext():
    sc = SparkContext.getOrCreate()
    return GlueContext(sc)


@fixture(scope="session")
def spark(glueContext):
    return glueContext.spark_session


@fixture(scope="session")
def data_path():
    dirname = os.path.dirname(__file__)
    return Path(dirname) / "data"


@fixture(autouse=True)
def mock_all_requests(requests_mock):
    return requests_mock
