#!/usr/bin/env bash
set -e

OUTPUT="timing_table.tex"

python3 << 'PYEOF' > "$OUTPUT"
import csv

CSV_FILE = "aggregated_results.csv"

rows = []
with open(CSV_FILE) as f:
    reader = csv.DictReader(f)
    for row in reader:
        rows.append(row)

def lookup(app, backend, cores, mode, other=''):
    for row in rows:
        if row['application'] != app: continue
        if row['backend'] != backend: continue
        if row['num_cores'] != str(cores): continue
        if mode is not None and row['assignment_mode'] != mode: continue
        if row['other_parameters'] != other: continue
        return int(row['avg_ms'])
    return None

def get_actors(app, other=''):
    for row in rows:
        if row['application'] != app: continue
        if row['other_parameters'] != other: continue
        return row['num_actors']
    return '?'

def c(val, baseline):
    if val is None or baseline is None:
        return '-'
    return f'{val / baseline:.2f}'

# (display, app, actors_other, has_tycho, sb_mode, sb_other, mlir_mode, mlir_other)
configs = [
    ('IDCT',             'idct', '',              True,  'round-robin', '',              'round-robin', ''            ),
    ('QRD',              'qrd',  '',              True,  'block',       '',              'block',       ''            ),
    ('FFT ($N{=}1024$)', 'fft',  'fft_size=1024', False, None,          'fft_size=1024', 'block',       'fft_size=1024'),
    ('JPEG',             'jpeg', '',              True,  'custom',      '',              'custom',      'pop=y push=y'),
]

out = []
out.append(r'% Requires \usepackage{booktabs} in preamble')
out.append(r'\begin{table}[!t]')
out.append(r'    \centering')
out.append(r'    \caption{Normalised execution time relative to Tycho (or 1-core MLIR backend for the FFT application) across backends and core counts (lower is better)}')
out.append(r'    \footnotesize')
out.append(r'    \begin{tabular}{ll|r|rrr|rrr}')
out.append(r'        \toprule')
out.append(r'        \multicolumn{2}{l|}{} & Tycho & \multicolumn{3}{c|}{StreamBlocks} & \multicolumn{3}{c}{MLIR} \\')
out.append(r'        Application & Total Actors & 1 core & 1 core & 2 cores & 4 cores & 1 core & 2 cores & 4 cores \\')
out.append(r'        \midrule')

for display, app, act_other, has_tycho, sb_mode, sb_other, mlir_mode, mlir_other in configs:
    na = get_actors(app, act_other)
    tycho = lookup(app, 'tycho', 'NA', 'NA') if has_tycho else None
    sb    = [lookup(app, 'streamblocks', cores, sb_mode, sb_other) if sb_mode else None for cores in [1, 2, 4]]
    mlir  = [lookup(app, 'mlir', cores, mlir_mode, mlir_other) for cores in [1, 2, 4]]

    # Baseline: Tycho if available, otherwise MLIR 1-core
    baseline = tycho if tycho is not None else mlir[0]

    row = (f'        {display} & {na} & {c(tycho, baseline)} & '
           + ' & '.join(c(v, baseline) for v in sb) + ' & '
           + ' & '.join(c(v, baseline) for v in mlir)
           + r' \\')
    out.append(row)

out.append(r'        \bottomrule')
out.append(r'    \end{tabular}')
out.append(r'    \label{tab:timing_results}')
out.append(r'\end{table}')

print('\n'.join(out))
PYEOF

echo "LaTeX table written to $OUTPUT"
