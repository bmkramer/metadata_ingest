import argparse
import glob
import json
import logging
import os
import datetime
import gzip
from collections import OrderedDict, defaultdict
from concurrent.futures import as_completed, ProcessPoolExecutor
from json import JSONEncoder
from pathlib import Path
from collections import Counter
from typing import Any, List, Tuple, Union, Callable

import jsonlines
import json_lines
import pandas as pd
from numpy.ma.core import empty


def target_from_path(obj:dict, path: Union[list,str])->(tuple[dict, Any] | tuple[None, None]):
    """Given an object dict and a path or field, return] the target object and field"""
    if isinstance(path, str):
        path = [path]

    if len(path) == 1:
        if path[0] in obj:
            return obj, path[0]
        else:
            return None, None

    else:
        target = obj
        for element in path[0:-1]:
            target = target.get(element)
            if not target:
                return None, None

    return target, path[-1]

def list_import_files(folder_path, file_suffix):
    """Recursively identify all files within a folder that match the specified suffix"""

    filepaths = os.path.join(folder_path, '**', f'*{file_suffix}')
    filelist = glob.glob(filepaths, recursive=True)
    return filelist

def get_chunks(*, input_list: List[Any], chunk_size: int = 8) -> List[Any]:
    """Generator that splits a list into chunks of a fixed size.

    :param input_list: Input list.
    :param chunk_size: Size of chunks.
    :return: The next chunk from the input list.
    """

    n = len(input_list)
    for i in range(0, n, chunk_size):
        yield input_list[i : i + chunk_size]


def yield_jsonl(file_path: Union[Path, str]):
    """Return or yield row of a JSON lines file as a dictionary. If the file
    is gz compressed then it will be extracted.

    :param file_path: the path to the JSON lines file.
    :return: generator.
    """

    with json_lines.open(file_path) as file:
        for row in file:
            yield row


def split_files(
        file_path: Path,
        output_path: Path,
        chunk_number: int,
        file_number: int,
        elements: List[Union[List[str], str]]):

    # files = defaultdict(list)
    empty_file = True
    lines = 0
    filename = f'{chunk_number}_{file_number}.jsonl.gz'

    for obj in yield_jsonl(file_path):
        kv = [target_from_path(obj, p) for p in elements]
        ks = [i[0].get(i[1]) for i in kv]
        k = '/'.join([elem for elem in ks])

        inner_path = Path(k)
        file_dir = output_path / inner_path
        file_dir.mkdir(parents=True, exist_ok=True)

        with gzip.open(file_dir / filename, mode='ab') as f:
            with jsonlines.Writer(f) as writer:
                writer.write(obj)

        empty_file = False
        lines += 1

    # lines = 0
    # for k in files.keys():
    #     inner_path = Path(k)
    #     file_dir = output_path / inner_path
    #     file_dir.mkdir(parents=True, exist_ok=True)
    #     filename = f'{chunk_number}_{file_number}.jsonl'
    #     with open(file_dir / filename, mode='w', encoding='utf-8') as f:
    #         with jsonlines.Writer(f) as writer:
    #             writer.write_all(files.get(k))
    #         lines += (len(files.get(k)))

    return None, lines, empty_file


def count_relations(file_path, **kwargs):
    """Count the number of relations in each file."""

    objs = []
    empty_file = True
    for obj in yield_jsonl(file_path):
        source_type = obj.get('sourceType')
        target_type = obj.get('targetType')
        relation_type = obj['relType'].get('name')
        objs.append((source_type, target_type, relation_type))
        empty_file = False

    return Counter(objs), len(objs), empty_file


def count_through_files(input_folder: Path,
                        output_path: Union[Path, None] = None,
                        elements: Union[List[str], str] = None,
                        func: Callable = count_relations,
                        max_workers: int = os.cpu_count() - 2,
                        file_suffix: str = '.json.gz',):

    files = list_import_files(input_folder, file_suffix=file_suffix)
    kwargs = dict(
                output_path=output_path,
                elements=elements)
    total_files = len(files)
    i = 1
    lines = 0

    print(datetime.datetime.now())
    print(f'Starting run of {input_folder}')

    total_counts = Counter()

    for c, chunk in enumerate(get_chunks(input_list=files, chunk_size=100)):
        with ProcessPoolExecutor(max_workers=max_workers) as executor:
            futures = []

            for f, input_path in enumerate(chunk):
                kwargs.update(dict(file_path=input_path, chunk_number=c, file_number=f))
                futures.append(executor.submit(func, **kwargs))

            for future in as_completed(futures):
                counts, read_lines, empty_file = future.result()
                # total_counts.update(counts)
                if not empty_file:
                    lines += read_lines

                percent = i / total_files * 100
                print(f"Progress: {i} / {total_files}, {percent:.2f}%. {lines} lines written.")
                with open(output_path / 'run.txt', 'a', encoding='utf-8') as f:
                    f.write(f"Progress: {i} / {total_files}, {percent:.2f}%. {lines} lines written.\n")
                i += 1

    # print(total_counts.total())
    # df = pd.DataFrame.from_dict(total_counts, orient='index')
    # df.index = pd.MultiIndex.from_tuples(df.index)
    # df.to_csv('relations.csv')
    pass

if __name__ == '__main__':
    filepath = Path('20250912/source/17098012/')
    output_path = Path('20250912/split/17098012/whole')
    count_through_files(filepath, output_path=output_path,
                        elements=['sourceType', 'targetType', ['relType', 'name']], func=split_files,
                        max_workers=10)
