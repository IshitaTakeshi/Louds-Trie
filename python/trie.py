from constructor import ArrayConstructor

"""
NOTE:
It would be quite difficult to understand this code if you are not familiar
with LOUDS.
"""

class Trie(object):
    def __init__(self, words):
        bit_array, labels = self.words_to_arrays(words)
        self.bit_array = bit_array
        self.labels = labels

        self.select0 = self.get_select(0)
        self.select1 = self.get_select(1)
        self.rank0 = self.get_rank(0)
        self.rank1 = self.get_rank(1)  # index to node

    def lower(self, words):
        words = [word.lower() for word in words]
        words.sort()
        return words

    def words_to_arrays(self, words):
        """
        Convert words to a LOUDS bit-string
        """
        words = self.lower(words)

        constructor = ArrayConstructor()
        for word in words:
            constructor.add(word)
        bit_array, labels = constructor.dump()
        return bit_array, labels

    def select(self, n, target_bit):
        """Returns the location of the nth target bit"""
        for i in range(len(self.bit_array)):
            if(self.bit_array[i] == target_bit):
                n -= 1
            if(n == 0):
                return i
        return None

    def rank(self, position, target_bit):
        """Returns the number of target bits from head to the position in
           the bit string."""
        n = 0
        for bit in self.bit_array[:position+1]:
            if(bit == target_bit):
                n += 1
        return n

    def get_select(self, target_bit):
        return lambda n: self.select(n, target_bit)

    def get_rank(self, target_bit):
        return lambda position: self.rank(position, target_bit)

    def trace_children(self, current_node, character):
        """
        If the character is found among the children of current_node,
        this method returns the node number of the child, None otherwise.
        """
        index = self.select0(current_node) + 1
        # search brothers
        while(self.bit_array[index] == 1):
            node = self.rank1(index)
            if(self.labels[node] == character):
                return node
            index += 1
        return None

    def search(self, query):
        """
        Returns the leaf node number if the query exists in the tree
        None otherwise
        """
        query = query.lower()

        node = 1
        for c in query:
            node = self.trace_children(node, c)
            if(node is None):  #the query is not in the tree
                return None
        return node
