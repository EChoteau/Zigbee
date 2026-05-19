#!/usr/bin/env python3
import argparse
import os
import re
from collections import defaultdict

FILE_RE = re.compile(r"(?P<file>[^\s]+\.(?:sv|svh|v|vh))")
PCT_RE = re.compile(r"(?P<pct>\d+(?:\.\d+)?)%")


def classify(path):
    norm = path.replace("\\", "/")
    if "/rtl/top/wrappers/" in norm:
        return "wrappers", "wrappers"
    if "/rtl/" in norm:
        rest = norm.split("/rtl/", 1)[1]
        block = rest.split("/", 1)[0]
        return "blocks", block
    return "other", "other"


def parse_byfile(text):
    rows = {}
    for line in text.splitlines():
        file_match = FILE_RE.search(line)
        pct_matches = PCT_RE.findall(line)
        if not file_match or not pct_matches:
            continue
        file_path = file_match.group("file")
        if "/rtl/" not in file_path.replace("\\", "/"):
            continue
        pct = float(pct_matches[-1])
        rows[file_path] = pct
    return rows


def parse_total(summary_text):
    for line in summary_text.splitlines():
        if "total" not in line.lower():
            continue
        pct_match = PCT_RE.search(line)
        if pct_match:
            return float(pct_match.group("pct"))
    return None


def write_csv(path, rows):
    with open(path, "w", encoding="ascii", newline="") as f:
        f.write("file,percent\n")
        for file_path, pct in rows:
            f.write(f"{file_path},{pct:.2f}\n")


def write_txt(path, title, rows, avg):
    with open(path, "w", encoding="ascii") as f:
        f.write(f"{title}\n")
        f.write(f"Average: {avg:.2f}%\n\n")
        for file_path, pct in rows:
            f.write(f"{pct:6.2f}%  {file_path}\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--byfile", required=True)
    parser.add_argument("--summary", required=True)
    parser.add_argument("--outdir", required=True)
    args = parser.parse_args()

    with open(args.byfile, "r", encoding="utf-8", errors="ignore") as f:
        byfile_text = f.read()

    with open(args.summary, "r", encoding="utf-8", errors="ignore") as f:
        summary_text = f.read()

    rows = parse_byfile(byfile_text)
    if not rows:
        raise SystemExit("No RTL file entries found in vcover by-file report.")

    grouped = defaultdict(list)
    for file_path, pct in rows.items():
        group_type, group_name = classify(file_path)
        grouped[(group_type, group_name)].append((file_path, pct))

    outdir = args.outdir
    raw_dir = os.path.join(outdir, "raw")
    os.makedirs(raw_dir, exist_ok=True)

    # Global summary files
    summary_csv = os.path.join(outdir, "coverage_summary.csv")
    summary_txt = os.path.join(outdir, "coverage_summary.txt")

    all_rows = sorted(rows.items())
    total_from_summary = parse_total(summary_text)
    avg_all = sum(pct for _, pct in all_rows) / len(all_rows)
    total_display = total_from_summary if total_from_summary is not None else avg_all

    with open(summary_csv, "w", encoding="ascii", newline="") as f:
        f.write("group,file,percent\n")
        for file_path, pct in all_rows:
            group_type, group_name = classify(file_path)
            f.write(f"{group_name},{file_path},{pct:.2f}\n")

    with open(summary_txt, "w", encoding="ascii") as f:
        f.write("Coverage Summary (RTL files)\n")
        f.write(f"Overall: {total_display:.2f}%\n\n")
        f.write("Per file:\n")
        for file_path, pct in all_rows:
            f.write(f"{pct:6.2f}%  {file_path}\n")
        f.write("\nPer group:\n")
        for (group_type, group_name), items in sorted(grouped.items()):
            avg = sum(pct for _, pct in items) / len(items)
            f.write(f"{group_name}: {avg:.2f}% ({len(items)} files)\n")

    # Per-group raw files
    for (group_type, group_name), items in grouped.items():
        group_dir = os.path.join(raw_dir, group_name)
        os.makedirs(group_dir, exist_ok=True)
        items_sorted = sorted(items)
        avg = sum(pct for _, pct in items_sorted) / len(items_sorted)
        write_csv(os.path.join(group_dir, "byfile.csv"), items_sorted)
        write_txt(os.path.join(group_dir, "byfile.txt"), f"{group_name} coverage", items_sorted, avg)


if __name__ == "__main__":
    main()
