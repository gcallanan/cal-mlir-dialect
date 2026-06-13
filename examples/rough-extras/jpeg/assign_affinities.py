#!/usr/bin/env python3
"""
Apply cal.device_affinity annotations to a flattened CAL MLIR file
using assignments from actor_affinities.csv.

Usage: assign_affinities.py <csv> <src.mlir> <dst.mlir>

CSV columns used: instance, channel, cpu
  - instance: the quoted instance name in cal.create_instance
  - channel:  Y / Cb / Cr (maps to %c0/%c1/%c2 argument) or any string for unique actors
  - cpu:      integer core index; rows with '?' are skipped
"""
import csv, re, sys

# Maps channel label in CSV to the integer constant in the MLIR argument (%cN_i32)
CHANNEL_TO_ARG = {'Y': '0', 'Cb': '1', 'Cr': '2'}
ARG_TO_CHANNEL = {v: k for k, v in CHANNEL_TO_ARG.items()}


def load_csv(path):
    """Return {instance_name: {channel_label: cpu_str}}, skipping unassigned rows."""
    table = {}
    with open(path) as f:
        for row in csv.DictReader(f):
            inst = row['instance'].strip()
            ch   = row['channel'].strip()
            cpu  = row['cpu'].strip()
            if not cpu or cpu == '?':
                continue
            table.setdefault(inst, {})[ch] = cpu
    return table


def lookup_cpu(table, inst_name, arg_val):
    """
    Return cpu string for this create_instance line, or None if not found.

    For actors whose instance name is unique in the CSV, the channel lookup is
    skipped and the single entry is used directly.

    For repeated names (scale/shift/transpose/etc. appear once per channel),
    the MLIR argument value (%c0_i32=Y, %c1_i32=Cb, %c2_i32=Cr) disambiguates.

    The fanout actor has a long auto-generated MLIR instance name; we fall back
    to a substring search so the short CSV key "fanout" still matches.
    """
    arg_chan = ARG_TO_CHANNEL.get(arg_val)  # Y / Cb / Cr, or None

    # 1. Exact instance-name match
    if inst_name in table:
        ch_map = table[inst_name]
        if len(ch_map) == 1:
            return next(iter(ch_map.values()))
        if arg_chan and arg_chan in ch_map:
            return ch_map[arg_chan]

    # 2. CSV key is a substring of the (long) MLIR instance name — handles fanout
    for key, ch_map in table.items():
        if key != inst_name and key in inst_name:
            if len(ch_map) == 1:
                return next(iter(ch_map.values()))

    return None


def process(csv_path, src_path, dst_path):
    table = load_csv(csv_path)

    with open(src_path) as f:
        lines = f.readlines()

    out = []
    for line in lines:
        if 'cal.create_instance' in line and 'device_affinity' not in line:
            m = re.search(r'"([^"]*)"', line)
            inst_name = m.group(1) if m else ''

            arg_m = re.search(r'%c(\d+)_i32', line)
            arg_val = arg_m.group(1) if arg_m else None

            cpu = lookup_cpu(table, inst_name, arg_val)
            if cpu is not None:
                line = re.sub(r' \(', f' device_affinity="cpu{cpu}" (', line, count=1)

        out.append(line)

    with open(dst_path, 'w') as f:
        f.writelines(out)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f'Usage: {sys.argv[0]} <csv> <src.mlir> <dst.mlir>', file=sys.stderr)
        sys.exit(1)
    process(sys.argv[1], sys.argv[2], sys.argv[3])
