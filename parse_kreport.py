import pandas as pd
import argparse

parser = argparse.ArgumentParser(description= 'Script for generating metadata for zoontic rank from prodigal output file')

parser.add_argument('--input', '-i', metavar='kreport.txt',
        help='input file')

parser.add_argument('--output', '-o', metavar='taxreadcount.csv',
        help='output file')

args = parser.parse_args()

f = open(args.input)
hantaExists = False
tax_dict = {}
genus_dict = {}
for line in f.readlines():
    _, _, read_number, level, taxid, taxname = line.split('\t')
    read_number = int(read_number)
    taxname = taxname.strip()
    if taxid == '1980413':
        hantaExists = True
        continue
    if hantaExists and level == 'F':
        break
    if hantaExists and level == 'G':
        genus = taxname
    if hantaExists and level == 'S':
        tax_dict[taxname] = read_number
        genus_dict[taxname] = genus

df = pd.DataFrame.from_dict(tax_dict, orient='index')
df.columns = ['count']
df.reset_index(inplace=True)
df = df.rename(columns = {'index':'species'})
df['genus'] = df['species'].map(genus_dict)
df.to_csv(args.output, columns=['species', 'genus', 'count'], index=False)