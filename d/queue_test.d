import queue;
import std.stdio;
import std.conv;

int main() {
    Queue!int queue = new Queue!int();
    int item;

    queue.append(10);
    writeln(queue);
    queue.append(20);
    writeln(queue);
    writeln("isempty: ", queue.isempty());
    item = queue.pop();
    writeln(queue);
    writeln(item);

    item = queue.pop();
    writeln(queue);
    writeln(item);
    writeln("isempty: ", queue.isempty());

    try {
        item = queue.pop();
    } catch(Error e) {
        writeln(e.msg);
    }

    writeln(queue);
    writeln(item);
    return 0;
}
