import std.stdio;
import std.functional;


class Trie {
    int delegate(int) index_to_node, get_parent;
    int[] bit_array;
    char[] labels;

    this(int[] bit_array, char[] labels) {
        this.index_to_node = this.get_rank(bit_array, 1);
        this.get_parent = this.get_select(bit_array, 0);
        this.bit_array = bit_array;
        this.labels = labels;
    }

    /* Returns the location of nth target_bit. */
    int select(int n, int target_bit) {
        int i;
        for(i=0; i<bit_array.length; i++) {
            if(bit_array[i] == target_bit) {
                n -= 1;
            }
            if(n == 0) {
                return i;
            }
        }
        return -1;
    }

    /* Returns the number of target_bits between head and position of
     * bit_array. */
    int rank(int position, int target_bit) {
        int n = 0;
        foreach(bit; bit_array[0..position+1]) {
            if(bit == target_bit) {
                n += 1;
            }
        }
        return n;
    }
    
    //TODO rewrite in lambda
    int delegate(int) get_select(int[] bit_array, int target_bit) {
        int select_(int n) {
            return this.select(n, target_bit);
        }
        return &select_;
    }

    int delegate(int) get_rank(int[] bit_array, int target_bit) {
        int rank_(int position) {
            return this.rank(position, target_bit);
        }
        return &rank_;
    }
    
    /* Returns the node number if the character is found -1 otherwise. */
    int trace(int current_node, char character) {
        int index, node; 
        
        index = this.get_parent(current_node);

        if(index < 0) {
            return -1;
        }

        index += 1;
        //search brothers
        while(this.bit_array[index] == 1) {
            node = this.index_to_node(index);
            if(this.labels[node] == character) {
                return node;
            }
            index += 1;
        }
        return -1;
    }

    int search(string query) {
        int node = 1;
        foreach(c; query) {
            node = this.trace(node, c);
            if(node < 0) {
                return -1;
            }
        }
        return node;
    }
}

void main() {
    int[] bit_array = [
        1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0
    ];
    char[] labels = [
        '\0', '\0', 'a', 'i', 'o', 'n', 'f', 'n', 'u', 'e', 'r', 't'
    ];
    
    Trie trie = new Trie(bit_array, labels);  

    int index = trie.search("our");
    writeln(index);
}
