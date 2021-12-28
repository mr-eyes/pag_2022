from scipy.cluster.hierarchy import dendrogram, linkage
from scipy.cluster.hierarchy import to_tree
from matplotlib import pyplot as plt
import pandas as pd
import sys

# Thanks to https://stackoverflow.com/a/31878514/3371177
def get_newick(node, parent_dist, leaf_names, newick='') -> str:
    """
    Convert sciply.cluster.hierarchy.to_tree()-output to Newick format.

    :param node: output of sciply.cluster.hierarchy.to_tree()
    :param parent_dist: output of sciply.cluster.hierarchy.to_tree().dist
    :param leaf_names: list of leaf names
    :param newick: leave empty, this variable is used in recursion.
    :returns: tree in Newick format
    """
    if node.is_leaf():
        return "%s:%.2f%s" % (leaf_names[node.id], parent_dist - node.dist, newick)
    else:
        if len(newick) > 0:
            newick = "):%.2f%s" % (parent_dist - node.dist, newick)
        else:
            newick = ");"
        newick = get_newick(node.get_left(), node.dist, leaf_names, newick=newick)
        newick = get_newick(node.get_right(), node.dist, leaf_names, newick=",%s" % (newick))
        newick = "(%s" % (newick)
        return newick

distMat = sys.argv[1]
df = pd.read_csv(distMat, sep = '\t')
names = list(df.columns[1:])
distances = df[df.columns[1:]].to_numpy()

Z = linkage(distances, 'complete')
tree = to_tree(Z, False)

newick = get_newick(tree, tree.dist, names)

with open(distMat + ".newick", 'w') as NW:
    NW.write(newick)