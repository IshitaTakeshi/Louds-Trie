module lib.array;

/**
Multiply a scalar value to a given array, element-wise.
The given array itself is not changed, a new copied array is returned
instead.

Params:
    array = An array to be multiplied.
    k = A coefficient.
 */
int[] multiply(int[] array, int k) {
    int[] multiplied = new int[array.length];
    foreach(i, e; array) {
        multiplied[i] = e * k;
    }
    return multiplied;
}


///
unittest {
    immutable int size = 10;
    int k = 2;
    int ones[size];

    ones[0..size] = 1;

    int[] array = multiply(ones, k);

    assert(array.length == size);
    foreach(int e; array) {
        assert(e == k);
    }
}


/**
Generate an array of the given size, filled with zeros.
 */
int[] generateZeros(ulong size) {
    int[] zeros = new int[size];
    return zeros;
}


///
unittest {
    int size = 10;
    int[] zeros = generateZeros(size);

    assert(zeros.length == size);
    foreach(int e; zeros) {
        assert(e == 0);
    }
}


/**
Generate an array of the given size, filled with ones.
 */
int[] generateOnes(ulong size) {
    int[] array = new int[size];

    foreach(ref e; array) {
        e = 1;
    }
    return array;
}


///
unittest {
    immutable size = 10;
    int[] ones = generateOnes(size);

    assert(ones.length == size);
    foreach(int e; ones) {
        assert(e == 1);
    }
}
