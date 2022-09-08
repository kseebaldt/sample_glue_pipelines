from typing import Tuple
import re


def parse_path(path: str) -> Tuple[str, str]:
    parts = re.sub(r"^/", "", path.replace("s3://", "")).split("/", 1)
    return parts[0], re.sub(r"/$", "", parts[1])
