import os

import boto3
from moto import mock_secretsmanager
from pytest import fixture

from sample_pipelines.driver import secrets


@fixture(autouse=True)
def mock_secrets():
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"

    with mock_secretsmanager():
        client = boto3.client("secretsmanager", region_name="us-east-1")
        yield client


@fixture()
def paths_key(mock_secrets):
    key = "my-paths"
    mock_secrets.create_secret(
        Name=key,
        SecretString='{"raw_path": "s3://abc/123"}',
    )
    return key


def test_returns_parsed_secrets(paths_key):
    result = secrets(paths_key)
    assert result == {"raw_path": "s3://abc/123"}


def test_returns_empty_dict_when_key_is_not_found():
    result = secrets("other")
    assert result == {}
