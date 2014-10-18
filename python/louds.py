#parent     [0, 0, 1, 1, 1, 1, 2, 2, 3, 4, 4, 4, 4, 5, 6, 7, 7, 8, 8, 8, 9, 0, 1]
bit_array = [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]
#child      [1, -, 2, 3, 4, -, 5, -, -, 6, 7, 8, -, -, -, 9, -, 0, 1, -, -, -, -]
#index      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2]

labels = ['', '', 'a', 'i', 'o', 'n', 'f', 'n', 'u', 'e', 'r', 't']
#index   [0,   1,   2,    3,   4,  5,   6,   7,   8,   9,   0,  1]


def select(bit_array, n, target_bit):
    """Returns the location of nth target_bit"""
    for i in range(len(bit_array)):
        if(bit_array[i] == target_bit):
            n -= 1
        if(n == 0):
            return i
    return None


def rank(bit_array, position, target_bit):
    """Returns the number of target_bits from head to position"""
    n = 0
    for bit in bit_array[:position+1]:
        if(bit == target_bit):
            n += 1
    return n


def get_select(bit_array, target_bit):
    return lambda n: select(bit_array, n, target_bit)


def get_rank(bit_array, target_bit):
    return lambda position: rank(bit_array, position, target_bit)


select0 = get_select(bit_array, 0)
select1 = get_select(bit_array, 1)
rank0 = get_rank(bit_array, 0)
rank1 = get_rank(bit_array, 1)


def trace(current_node, character):
    """Returns the node number if the character is found None otherwise"""
    index = select0(current_node) + 1
    #search brothers
    while(bit_array[index] == 1):
        print("index:{} node:{}".format(index, rank1(index)))
        node = rank1(index)
        if(labels[node] == character):
            return node
        index += 1
    return None


def search(query):
    """Returns the node number if the query is found None otherwise"""
    node = 1
    for c in query: 
        node = trace(node, c)
        if(node is None):
            return None
    return node

#node = search('out')
#print(node)

