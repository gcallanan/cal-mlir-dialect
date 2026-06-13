#!/usr/bin/env python3
"""Generate a StreamBlocks partition XML distributing actors across cores.

Usage: generate_partition.py <template.xml> <output.xml> <num_cores> <mode>
  mode: round-robin or block
"""

import sys
import re


def main():
    if len(sys.argv) != 5:
        print(f"Usage: {sys.argv[0]} <template.xml> <output.xml> <num_cores> <mode>")
        sys.exit(1)

    template_file, output_file = sys.argv[1], sys.argv[2]
    num_cores = int(sys.argv[3])
    mode = sys.argv[4]

    with open(template_file) as f:
        content = f.read()

    actors = re.findall(r'<instance id="([^"]+)"', content)
    connections_match = re.search(r'(\t<connections>.*?\t</connections>)', content, re.DOTALL)
    connections = connections_match.group(1) if connections_match else ""

    total = len(actors)
    partitions = {i: [] for i in range(num_cores)}
    for n, actor in enumerate(actors):
        core = int(n * num_cores / total) if mode == "block" else (n % num_cores)
        partitions[core].append(actor)

    with open(output_file, "w") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f.write("<configuration>\n")
        f.write("\t<partitioning>\n")
        for core_id in range(num_cores):
            f.write(f'\t\t<partition id="{core_id}" scheduling="ROUND_ROBIN">\n')
            for actor in partitions[core_id]:
                f.write(f'\t\t\t<instance id="{actor}"/>\n')
            f.write("\t\t</partition>\n")
        f.write("\t</partitioning>\n")
        f.write(connections + "\n")
        f.write("</configuration>\n")


if __name__ == "__main__":
    main()
