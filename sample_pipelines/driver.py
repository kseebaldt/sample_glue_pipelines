import json
import sys
from functools import partial
from importlib import import_module

import boto3
from awsglue.utils import getResolvedOptions


def etl_job():
    from awsglue.context import GlueContext
    from awsglue.job import Job
    from pyspark.context import SparkContext

    sc = SparkContext.getOrCreate()
    glueContext = GlueContext(sc)
    spark = glueContext.spark_session
    job = Job(glueContext)

    f = _get_job_function()
    f(spark, glueContext)

    job.commit()


def shell_job():
    f = _get_job_function()
    f()


def _get_job_function():
    args = getResolvedOptions(sys.argv, ["job_module", "job_function", "secret_id"])

    job_module = import_module(args["job_module"])
    f = getattr(job_module, args["job_function"])
    return partial(f, secrets(args["secret_id"]))


def secrets(key: str):
    client = boto3.client("secretsmanager")
    return json.loads(client.get_secret_value(SecretId=key)["SecretString"])
