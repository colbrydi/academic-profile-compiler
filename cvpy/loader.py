from pathlib import Path
import json
import bibtexparser


def load_json_file(path):
    with open(path) as f:
        return json.load(f)


def load_bibtex_file(path):
    with open(path) as f:
        bib = bibtexparser.load(f)
    return bib.entries   # list of dicts


def load_all_data(data_dir="data"):
    base = Path(data_dir)
    result = {}

    # JSON files
    for p in base.glob("*.json"):
        result[p.stem] = load_json_file(p)

    # BibTeX files
    for p in base.glob("*.bib"):
        result[p.stem] = load_bibtex_file(p)

    return result
