module lib.array;


/*
 *  Multiply a given scalar value to a given array, element-wise.
 *  The given array itself is not changed, a new copied array is returned
 *  instead.
 */
int[] multiply(int[] array, int k) {
    int[] multiplied = new int[array.length];
    foreach(i, e; array) {
        multiplied[i] = e * k;
    }
    return multiplied;
}


/* Generate an array of given size, filled with zeros. */
int[] generateZeros(ulong size) {
    int[] zeros = new int[size];
    return zeros;
}


/* Generate an array of given size, filled with ones. */
int[] generateOnes(ulong size) {
    int[] array = new int[size];
    foreach(ref e; array) {
        e = 1;
    }
    return array;
}
