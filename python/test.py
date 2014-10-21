from trie import Trie

words = ['an', 'i', 'of', 'one', 'our', 'out']
test_set = {
    'out': 11, 'our': 10, 'of': 6, 'i': 3, 'an': 5, 'one': 9, 'ant': None
}

trie = Trie(words)
for query, answer in test_set.items():
    result = trie.search(query)
    print("result:{!s:>5}  answer:{:>5}  result==answer:{!s}".format(
          result, answer, result==answer)) 

##parent     [0, 0, 1, 1, 1, 1, 2, 2, 3, 4, 4, 4, 4, 5, 6, 7, 7, 8, 8, 8, 9, 0, 1]
#bit_array = [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]
##child      [1, -, 2, 3, 4, -, 5, -, -, 6, 7, 8, -, -, -, 9, -, 0, 1, -, -, -, -]
##index      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2]
#
#labels = ['', '', 'a', 'i', 'o', 'n', 'f', 'n', 'u', 'e', 'r', 't']
##index   [0,   1,   2,    3,   4,  5,   6,   7,   8,   9,   0,  1]
#
#index = trie.search('our')
#print(index)
##node = search('out')
##print(node)
