import std.string;

/**
 * The implementation of the queue data structure.
 */
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
            throw new Exception("The queue is empty.");
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
        return format("%s", this.items);
    }
}
