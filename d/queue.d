import lib.exception : IndexError;

/**
 * The queue data structure.
 */
//TODO add tests
class Queue(T) {
    T items[];

    /**
     * Insert an item to the queue.
     */
    void append(T item) {
        this.items ~= item;
    }

    /**
     * Pick one item and remove it from the queue.
     */
    T pop() {
        if(this.isempty()) {
            throw new IndexError("The queue is empty.");
        }
        T item = items[0];
        this.items = this.items[1..$];
        return item;
    }

    /**
     * Returns true if the queue is empty.
     */
    bool isempty() {
        return this.size() == 0;
    }

    /**
     * Returns the number of items in the queue.
     */
    ulong size() {
        return items.length;
    }

    override string toString() {
        import std.string : format;
        return format("%s", this.items);
    }
}


unittest {
    Queue!int queue = new Queue!int();
    int items[] = [10, 20, 50];

    foreach(int item; items) {
        queue.append(item);
    }

    foreach(int item; items) {
        assert(item == queue.pop());
    }

    bool error_thrown = false;
    try {
        queue.pop();
    } catch(IndexError e) {
        error_thrown = true;
    }
    assert(error_thrown);
}
