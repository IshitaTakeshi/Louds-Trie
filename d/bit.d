import std.stdio;
import std.bitmanip;

void main() {
    BitArray b;
    b.init([0, 0, 0, 0, 0, 0, 0]);
    writeln(b & 0b0001);
}
