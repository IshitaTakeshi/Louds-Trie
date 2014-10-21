class Node(object):
    def __init__(self, value):
        self.value = value
        self.children = []
        self.visited = False

    def __str__(self):
        return str(self.value)

    def add_child(self, child):
        self.children.append(child)


class ArrayConstructor(object):
    def __init__(self):
        self.tree = Node('')

    def add(self, string):
        self.construct(self.tree, string)

    def construct(self, node, string, depth=0):
        if(depth == len(string)):
            return

        for child in node.children:
            if(child.value == string[depth]):
                self.construct(child, string, depth+1)
                return

        child = Node(string[depth])
        node.children.append(child)
        self.construct(child, string, depth+1)
        return

    def show(self):
        self.show_(self.tree)

    def show_(self, node, depth=0):
        print("{}{}".format('  '*depth, node))
        for child in node.children:
            self.show_(child, depth+1)

    def dump(self):
        from collections import deque

        bit_array = [1, 0]
        labels = ['']

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
