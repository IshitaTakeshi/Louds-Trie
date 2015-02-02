import std.functional;
import std.typecons;
import std.algorithm;
import std.string;

import queue : Queue;
import lib.array : generateOnes;

/**
 * The node of the tree.
 * Each node has one character as its member.
 */
class Node {
    char value;
    private Node[] children;
    bool visited;

    this(char value) {
        this.value = value;
        this.children = [];
        this.visited = false;
    }

    void addChild(Node child) {
        this.children ~= child;
    }

    ulong getNChildren() {
        return this.children.length;
    }
}

/**
 * This class has:
 *     a function which constructs a tree by inserted words
 *     a function which dumps the tree as a LOUDS bit-string
 */
class ArrayConstructor {
    Node tree;
    this(string[] words) {
        this.tree = new Node(' ');  //make root
        words = this.lower(words);
        foreach(string word; words) {
            this.build(this.tree, word, 0);
        }
    }

    /* Convert words to lower case element-wise and sort them in alphabetical
     * order.*/
    string[] lower(string[] words) {
        foreach(ref string word; words) {
            word = toLower(word);
        }
        //sort words in alphabetical order
        sort!("a < b", SwapStrategy.stable)(words);
        return words;
    }

    /* Build a tree. */
    private void build(Node node, string word, int depth) {
        if(depth == word.length) {
            return;
        }

        foreach(Node child; node.children) {
            if(child.value == word[depth]) {
                this.build(child, word, depth+1);
                return;
            }
        }

        Node child = new Node(word[depth]);
        node.addChild(child);
        this.build(child, word, depth+1);
        return;
    }

    /* Dumps a LOUDS bit-string. */
    Tuple!(int[], char[]) dump() {
        //set the root node
        int bitArray[] = [1, 0];
        char labels[] = ['-'];

        Queue!Node queue = new Queue!Node();
        queue.append(this.tree);

        while(queue.size() != 0) {
            Node node = queue.pop();
            labels ~= node.value;

            // append N ones and 0
            // N is the number of children of the current node
            int ones[] = generateOnes(node.getNChildren());
            bitArray = bitArray ~ ones ~ [0];

            foreach(Node child; node.children) {
                if(child.visited) {
                    continue;
                }

                child.visited = true;
                queue.append(child);
            }
        }
        return tuple(bitArray, labels);
    }
}


unittest {
    string[] words = ["an", "i", "of", "one", "our", "out"];

    auto constructor = new ArrayConstructor(words);
    auto t = constructor.dump();
    int[] bitstring = t[0];

    assert(
        bitstring ==
        [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]);
}


//Ensure the same bit string generated if the word order is randomized.
unittest {
    string[] words = ["our", "out", "i", "an", "of", "one"];

    auto constructor = new ArrayConstructor(words);
    auto t = constructor.dump();
    int[] bitstring = t[0];

    assert(
        bitstring ==
        [1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0]);
}


unittest {
    string[] words = ["the", "then", "they"];

    auto constructor = new ArrayConstructor(words);
    auto t = constructor.dump();
    int[] bitstring = t[0];

    assert(
        bitstring ==
        [1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0]);
}


class Trie {
    int delegate(int) indexToNodeNumber, getParentIndex;
    int[] bitArray;
    char[] labels;

    this(string[] words) {
        auto t = this.wordsToArrays(words);
        this.bitArray = t[0];  //LOUDS bit-string
        this.labels = t[1];
        this.indexToNodeNumber = this.getRank(1);
        this.getParentIndex = this.getSelect(0);
        this.bitArray = bitArray;
        this.labels = labels;  //labels of each node
    }

    /* Convert words to a LOUDS bit-string. */
    Tuple!(int[], char[]) wordsToArrays(string[] words) {

        auto constructor = new ArrayConstructor(words);
        return constructor.dump();
    }

    /* Returns the location of nth targetBit. */
    int select(int n, int targetBit) {
        int i;
        for(i = 0; i < bitArray.length; i++) {
            if(bitArray[i] == targetBit) {
                n -= 1;
            }
            if(n == 0) {
                return i;
            }
        }
        return -1;
    }

    /* Returns the number of target bits from head to the position in
       the bit string. */
    int rank(int position, int targetBit) {
        int n = 0;
        foreach(bit; bitArray[0..position+1]) {
            if(bit == targetBit) {
                n += 1;
            }
        }
        return n;
    }

    int delegate(int) getSelect(int targetBit) {
        int select_(int n) {
            return this.select(n, targetBit);
        }
        return &select_;
    }

    int delegate(int) getRank(int targetBit) {
        int rank_(int position) {
            return this.rank(position, targetBit);
        }
        return &rank_;
    }

    /* If the character is found among the children of current_node,
       this method returns the node number of the child, -1 otherwise. */
    int trace_children(int currentNodeNumber, char character) {
        int index, nodeNumber;

        index = this.getParentIndex(currentNodeNumber);

        if(index < 0) {
            //TODO throw new Exception();
            return -1;
        }
        index += 1;
        //search brothers
        while(this.bitArray[index] == 1) {
            nodeNumber = this.indexToNodeNumber(index);
            if(this.labels[nodeNumber] == character) {
                return nodeNumber;
            }
            index += 1;
        }
        return -1;
    }

    /* Returns the leaf node number if the query exists in the tree
       -1 otherwise. */
    int search(string query) {
        int nodeNumber = 1;
        foreach(c; query) {
            nodeNumber = this.trace_children(nodeNumber, c);
            if(nodeNumber < 0) {
                return -1;
            }
        }
        return nodeNumber;
    }
}


unittest {
    string[] words = ["an", "i", "of", "one", "our", "out"];
    int[] answers = [5, 3, 6, 9, 10, 11];

    Trie trie = new Trie(words);
    foreach(int i, string word; words) {
        int result = trie.search(word);
        assert(result == answers[i]);
        assert(result > 0);
    }

    //"hello doesn't exist in the dictionary.
    //should return -1
    assert(trie.search("hello") == -1);
}


unittest {
    string[] words = ["the", "then", "they"];
    int[] answers = [4, 5, 6];

    Trie trie = new Trie(words);
    foreach(int i, string word; words) {
        int result = trie.search(word);
        assert(result == answers[i]);
        assert(result > 0);
    }

    //"hello doesn't exist in the dictionary.
    //should return -1
    assert(trie.search("hello") == -1);
}
