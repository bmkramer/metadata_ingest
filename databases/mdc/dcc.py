from typing import Union
from pathlib import Path
import json
import os
import jsonlines


def json_array_to_jsonl(infilepath: Union[str, Path],
                        outfilepath: Union[str, Path]):
    """Convert a json array (like ROR dump) to jsonl

    Assumes that the top level array is the correct place to engage and write out records
    """

    with open(infilepath, "r") as f:
        j = json.load(f)

    with open(outfilepath, mode='w', encoding='utf-8') as f:
        with jsonlines.Writer(f) as writer:
            writer.write_all([line for line in j])

if __name__ == '__main__':
    folder_location = Path('../../../datacite/datacitationcorpus')
    out_location = Path('../../../datacite/datacitationcorpus/out/')
    os.makedirs(out_location, exist_ok=True)
    for file in folder_location.glob('*.json'):
        json_array_to_jsonl(file, (out_location / file.stem).with_suffix('.jsonl'))
