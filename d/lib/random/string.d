module lib.random.string;  //FIXME the module name is too nested

import std.random : uniform;
import std.conv : to;


string generateRandomWord(ulong length)
in {
    assert(length > 0);
}
body {
    string word = "";
    for(auto i = 0; i < length; i++) {
        word ~= to!char(uniform(97, 123));
    }
    return word;
}


string[] generateRandomWords(ulong n_words, ulong max_length)
in {
    assert(max_length > 0);
}
body {
    string words[];
    for(auto i = 0; i < n_words; i++) {
        ulong length = uniform(1, max_length+1);
        words ~= generateRandomWord(length);
    }
    return words;
}
