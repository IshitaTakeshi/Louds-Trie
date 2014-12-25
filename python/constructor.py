class Node(object):
    """
    The node of the tree.
    Each node has one character as its member.
    """
    def __init__(self, value):
        self.value = value
        self.children = []
        self.visited = False

    def __str__(self):
        return str(self.value)

    def add_child(self, child):
        self.children.append(child)


class ArrayConstructor(object):
    """
    This class has:
        a function which constructs a tree by words
        a function which dumps the tree as a LOUDS bit-string
    """
    def __init__(self):
        self.tree = Node('')  #The root node

    def add(self, word):
        """
        Add a word to the tree
        """
        self.build(self.tree, word)

    def build(self, node, word, depth=0):
        """
        Build a tree
        """
        if(depth == len(word)):
            return

        for child in node.children:
            # if the child which its value is word[depth] exists,
            # continue building the tree from the next to the child.
            if(child.value == word[depth]):
                self.build(child, word, depth+1)
                return

        # if the child which its value is word[depth] doesn't exist,
        # make a node and continue constructing the tree.
        child = Node(word[depth])
        node.add_child(child)
        self.build(child, word, depth+1)
        return

    def show(self):
        self.show_(self.tree)

    def show_(self, node, depth=0):
        print("{}{}".format('  '*depth, node))
        for child in node.children:
            self.show_(child, depth+1)

    def dump(self):
        """
        Dump a LOUDS bit-string
        """
        from collections import deque

        bit_array = [1, 0]  # [1, 0] indicates the 0th node
        labels = ['']

        #dumps by Breadth-first search
        queue = deque()
        queue.append(self.tree)

        while(len(queue) != 0):
            node = queue.popleft()
            labels.append(node.value)

            bit_array += [1] * len(node.children) + [0]

            for child in node.children:
                child.visited = True
                queue.append(child)
        return bit_array, labels
