from constructor import ArrayConstructor


class Trie(object):
    def __init__(self, words):
        bit_array, labels = self.words_to_arrays(words)        
        self.bit_array = bit_array
        self.labels = labels

        self.select0 = self.get_select(0)
        self.select1 = self.get_select(1)
        self.rank0 = self.get_rank(0)
        self.rank1 = self.get_rank(1)
    
    def lower(self, words):
        words = [word.lower() for word in words]
        words.sort()
        return words

    def words_to_arrays(self, words):
        words = self.lower(words)

        constructor = ArrayConstructor()
        for word in words:
            constructor.add(word)
        bit_array, labels = constructor.dump()
        return bit_array, labels

    def select(self, n, target_bit):
        """Returns the location of nth target_bit"""
        for i in range(len(self.bit_array)):
            if(self.bit_array[i] == target_bit):
                n -= 1
            if(n == 0):
                return i
        return None

    def rank(self, position, target_bit):
        """Returns the number of target_bits from head to position"""
        n = 0
        for bit in self.bit_array[:position+1]:
            if(bit == target_bit):
                n += 1
        return n

    def get_select(self, target_bit):
        return lambda n: self.select(n, target_bit)

    def get_rank(self, target_bit):
        return lambda position: self.rank(position, target_bit)

    def trace(self, current_node, character):
        """Returns the node number if the character is found None otherwise"""
        index = self.select0(current_node) + 1
        #search brothers
        while(self.bit_array[index] == 1):
            node = self.rank1(index)
            if(self.labels[node] == character):
                return node
            index += 1
        return None

    def search(self, query):
        query = query.lower()
        """Returns the node number if the query is found None otherwise"""
        node = 1
        for c in query:
            node = self.trace(node, c)
            if(node is None):
                return None
        return node

