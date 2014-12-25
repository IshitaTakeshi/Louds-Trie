import std.stdio;
import std.algorithm;

class C {
    int[] array;
    this() {
        array ~= 0;
        writeln(array);
    }
}

int main() {
    C c = new C();
    string[] array = ["hello", "world", "this", "out", "a"];
    writeln(sort(array));
    return 0;
}
