import std.string;

class Queue(T) {
    T items[];

    void append(T item) {
        this.items ~= item;
    }

    T pop() {
        if(this.isempty()) {
            throw new Exception("The queue is empty.");
        }
        T item = items[0];
        this.items = this.items[1..$];
        return item;
    }

    bool isempty() {
        return this.size() == 0;
    }

    ulong size() {
        return items.length;
    }

    override string toString() {
        return format("%s", this.items);
    }
}
