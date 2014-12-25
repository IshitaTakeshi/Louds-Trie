from trie import Trie

#constructs a tree of this shape ('*' means root)
#
#      *
#     /|\
#    a i o
#   /   /|\
#  n   f n u
#        | |\
#        e r t
#
#The LOUDS bit-string is then
#[1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]

words = ['an', 'i', 'of', 'one', 'our', 'out']
test_set = {
    'out': 11,   #'t' in 'out' is at 11th node in the tree
    'our': 10,   #'r' in 'our' is at 10th node in the tree
    'of': 6,
    'i': 3,
    'an': 5,
    'one': 9,
    'ant': None  #'ant' is not in the tree
}

trie = Trie(words)
for query, answer in test_set.items():
    result = trie.search(query)
    print("query: {!s:>5}  result: {!s:>5}  answer: {!s:>5}".format(
        query, result, answer))

##parent    [0, 0, 1, 1, 1, 1, 2, 2, 3, 4, 4, 4, 4, 5, 6, 7, 7, 8, 8, 8, 9, 0, 1]
##bit_array [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]
##child     [1, -, 2, 3, 4, -, 5, -, -, 6, 7, 8, -, -, -, 9, -, 0, 1, -, -, -, -]
##index     [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2]

#labels ['', '', 'a', 'i', 'o', 'n', 'f', 'n', 'u', 'e', 'r', 't']
##index [ 0,  1,   2,   3,   4,   5,   6,   7,   8,   9,   0,  1]
