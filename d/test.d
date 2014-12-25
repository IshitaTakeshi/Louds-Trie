import std.stdio;
import std.format;

import louds;

/* Returns true if the test succeeded. */
bool test() {
    string[] words = ["an", "i", "of", "one", "our", "out"];
    int[] answers = [5, 3, 6, 9, 10, 11];

    louds.Trie trie = new louds.Trie(words);
    foreach(int i, string word; words) {
        int result = trie.search(word);
        writefln("word: %3s  result: %2s  should return: %2s",
                 word, result, answers[i]);
        assert(result == answers[i]);
        assert(result > 0);
    }

    //"hello doesn't exist in the dictionary.
    //should return -1
    assert(trie.search("hello") == -1);
    return true;
}

void main() {
    test();
    writeln("Test succeeded.");
}
