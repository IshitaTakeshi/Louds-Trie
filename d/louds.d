import std.functional;
import std.typecons;
import std.algorithm;
import std.string;

import queue : Queue;
import bitarray: SuccinctBitVector;
import tools.exception : ValueError, KeyError;

/**
 * The node of the tree.
 * Each node has one character as its member.
 */
class Node {
    char label;
    private Node[] children;
    bool visited;

    this(char label) {
        this.label = label;
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
    private Node tree;
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
    private void build(Node node, string word, ulong depth) {
        if(depth == word.length) {
            return;
        }

        foreach(Node child; node.children) {
            if(child.label == word[depth]) {
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
    Tuple!(SuccinctBitVector, string) dump() {
        //construct a bit vector by Breadth-first search
        SuccinctBitVector bitvector = new SuccinctBitVector();
        string labels;

        //set the root node
        bitvector.push(1);
        bitvector.push(0);
        labels = " ";

        Queue!Node queue = new Queue!Node();
        queue.append(this.tree);

        while(queue.size() != 0) {
            Node node = queue.pop();
            labels ~= node.label;

            // append N ones and 0
            // N is the number of children of the current node
            for(auto i = 0; i < node.getNChildren(); i++) {
                bitvector.push(1);
            }
            bitvector.push(0);

            foreach(Node child; node.children) {
                if(child.visited) {
                    continue;
                }

                child.visited = true;
                queue.append(child);
            }
        }

        bitvector.build();
        return tuple(bitvector, labels);
    }
}


//smoke test
unittest {
    string[] words = ["an", "i", "of", "one", "our", "out"];

    auto constructor = new ArrayConstructor(words);
    auto t = constructor.dump();
    SuccinctBitVector bitvector = t[0];

    //the length of the bitvector should be a multiple of 8
    assert(bitvector.toString() == "101110100111000101100000");
}


//Ensure the same bit string generated if the word order is randomized.
unittest {
    string[] words = ["our", "out", "i", "an", "of", "one"];

    auto constructor = new ArrayConstructor(words);
    auto t = constructor.dump();
    SuccinctBitVector bitvector = t[0];

    //the length of the bitvector should be a multiple of 8
    assert(bitvector.toString() == "101110100111000101100000");
}


unittest {
    string[] words = ["the", "then", "they"];

    auto constructor = new ArrayConstructor(words);
    auto t = constructor.dump();
    SuccinctBitVector bitvector = t[0];
    assert(bitvector.toString() == "1010101011000000");
}


class Trie {
    private SuccinctBitVector bitvector;
    private string labels;

    this(string[] words) {
        //convert words to a LOUDS bit-string
        auto t = new ArrayConstructor(words).dump();
        this.bitvector = t[0];  //LOUDS bit-string
        this.labels = t[1]; //labels of each node
    }

    /*
    Return the node number of the child if exists.
     */
    ulong traceChildren(ulong current_node_number, char character) {
        ulong node_number;

        //get the corresponding index of the node number
        ulong index = this.bitvector.select0(current_node_number-1);

        //numbers next to the index of the node mean the node's children
        //search brothers
        index += 1;
        while(this.bitvector.get(index) == 1) {
            node_number = this.bitvector.rank1(index);
            if(this.labels[node_number] == character) {
                return node_number;
            }
            index += 1;
        }

        throw new ValueError("Child not found");
    }

    /*
     * Returns the leaf node number if the query exists in the tree and
     * throws KeyError if not exist.
     */
    ulong search(string query) {
        ulong node_number = 1;
        foreach(char character; query) {
            try {
                node_number = this.traceChildren(node_number, character);
            } catch(ValueError e) {
                throw new KeyError(query);
            }
        }
        return node_number;
    }
}


//smoke test
unittest {
    void testKeysFound(string[] keys, int[] answers,
                       string[] words_not_in_keys) {
        Trie trie = new Trie(keys);
        foreach(ulong i, string key; keys) {
            //the set of keys in the dictionary should be found
            ulong result = trie.search(key);
            assert(result == answers[i]);
        }

        //KeyError should be thrown if the key is not found
        foreach(string word; words_not_in_keys) {
            bool error_thrown = false;
            try {
                trie.search(word);
            } catch(KeyError e) {
                error_thrown = true;
            }
            assert(error_thrown);
        }
    }

    testKeysFound(["an", "i", "of", "one", "our", "out"],
                  [5, 3, 6, 9, 10, 11],
                  ["hello", "ant", "ones", "ours"]);
    testKeysFound(["the", "then", "they"], [4, 5, 6],
                  ["hi", "thus", "that", "them"]);
}
