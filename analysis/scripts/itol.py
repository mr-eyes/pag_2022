import pandas as pd
import sys

if len(sys.argv) != 2:
    sys.exit("run: python itol.py <distance_matrix.tsv>")

colors = {"Germany": "#d73027",
          "Italy": "#f46d43",
          "Poland": "#fdae61",
          "Bulgaria": "#fee090",
          "Netherlands": "#ffffbf",
          "Denmark": "#e0f3f8",
          "France": "#abd9e9",
          "Spain": "#74add1",
          "Belgium": "#4575b4",
          "poultry": "#5ab4ac",
          "pig": "#d8b365"
          }

HEADER1 = """DATASET_COLORSTRIP

SEPARATOR SPACE

#label is used in the legend table (can be changed later)
DATASET_LABEL Countries
COLOR #ff0000

LEGEND_TITLE Countries
LEGEND_POSITION_X 94
LEGEND_POSITION_Y 239
LEGEND_SHAPES 1 1 1 1 1 1 1 1 1
LEGEND_COLORS #d73027 #f46d43 #fdae61 #fee090 #ffffbf #e0f3f8 #abd9e9 #74add1 #4575b4
LEGEND_LABELS Germany Italy Poland Bulgaria Netherlands Denmark France Spain Belgium
LEGEND_SHAPE_SCALES 1 1 1 1 1 1 1 1 1

DATA
"""

HEADER2 = """DATASET_COLORSTRIP

SEPARATOR SPACE

#label is used in the legend table (can be changed later)
DATASET_LABEL Species

COLOR #ff0100
LEGEND_TITLE Species
LEGEND_POSITION_X 96
LEGEND_POSITION_Y 78
LEGEND_SHAPES 1 1 1 1
LEGEND_COLORS #d8b365 #5ab4ac #f052e3 #00ff00
LEGEND_LABELS Pigs Poultry Replicate_Herd_1 Replicate_Herd_2
LEGEND_SHAPE_SCALES 1 1 1 1

DATA
ERR2241785_SAMEA104467288_pig_Belgium #f052e3 Replicate_Herd_1
ERR2241786_SAMEA104467289_pig_Belgium #f052e3 Replicate_Herd_1
ERR2241787_SAMEA104467290_pig_Belgium #f052e3 Replicate_Herd_1
ERR2241624_SAMEA104467127_pig_Netherlands #00ff00 Replicate_Herd_2
ERR2241625_SAMEA104467128_pig_Netherlands #00ff00 Replicate_Herd_2
ERR2241626_SAMEA104467129_pig_Netherlands #00ff00 Replicate_Herd_2
"""

distMat = sys.argv[1]
df = pd.read_csv(distMat, sep = '\t')
names = list(df.columns[1:])

with open(f"itol_dataset_countries.txt", 'w') as DATASET:
    DATASET.write(HEADER1)
    for full_name in names:
        country = full_name.split('_')[-1]
        color = colors[country]
        line = f"{full_name} {color} {country}\n"
        DATASET.write(line)

REPLICATES = ["ERR2241785","ERR2241786","ERR2241787","ERR2241624","ERR2241625","ERR2241626"]
with open(f"itol_dataset_species.txt", 'w') as DATASET:
    DATASET.write(HEADER2)
    for full_name in names:
        if full_name.split('_')[0] in REPLICATES:
            continue
        species = full_name.split('_')[2]
        color = colors[species]
        line = f"{full_name} {color} {species}\n"
        DATASET.write(line)