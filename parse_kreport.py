import pandas as pd
import argparse
import sys

parser = argparse.ArgumentParser(description= 'Script for generating metadata for zoontic rank from prodigal output file')

parser.add_argument('--input', '-i', metavar='kreport.txt',
        help='input file')

parser.add_argument('--output', '-o', metavar='taxreadcount.csv',
        help='output file')

args = parser.parse_args()

f = open(args.input)
tax_dict = {}
family_dict = {}
for line in f.readlines():
    _, _, read_number, level, _, taxname = line.split('\t')
    read_number = int(read_number)
    taxname = taxname.strip()
    if level == 'F':
        family = taxname

    if level == 'S':
        tax_dict[taxname] = read_number
        family_dict[taxname] = family

df = pd.DataFrame.from_dict(tax_dict, orient='index')
df.columns = ['count']
df.reset_index(inplace=True)
df = df.rename(columns = {'index':'species'})
df['family'] = df['species'].map(family_dict)
df.to_csv(args.output, columns=['species', 'family', 'count'], index=False)