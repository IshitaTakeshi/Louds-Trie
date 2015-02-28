import std.conv : to;

/*
Count 1 bits in x.

Params:
n_bits = The size of the counted range in bits. The maximum value is 8.
 */
ulong countOneBits(int x, ulong n_bits) {
    assert(n_bits <= 8);
    x = x & ((1 << n_bits) - 1); //bitmask
    x = x - ((x >> 1) & 0x55555555);
    x = (x & 0x33333333)  + ((x >> 2) & 0x33333333);
    x = (x + (x >> 4)) & 0x0f0f0f0f;
    x = x + (x >> 8);
    x = x + (x >> 16);
    x = x & 0x0000003f;
    return x;
}


class BitArray {
    private int[] bitarray;
    private ulong length;  //the length of the bitarray

    this() {
        this.length = 0;
    }

    /*
       Push one bit to the bitarray.
     */
    void push(uint bit) {
        //TODO make sure the bit is 0 or 1
        //in {
        //}
        uint shift = this.length % 8;
        //append 0 to expand bitarray.
        if(shift == 0) {
            this.bitarray ~= 0;
        }

        this.bitarray[$-1] |= (bit & 1) << shift;
        this.length += 1;
    }

    /*
    Get bit at the specified position.
    */
    uint get(ulong position) {
        //TODO
        //in {
        //    assert(position >= this.length);
        //}
        ulong shift = position % 8;
        return 0x1 & (this.bitarray[position/8] >> shift);
    }

    private string bitArrayToString(int bit) {
        string bits = "";

        for(int i = 0; i < 8; i++) {
            int b = bit & (1 << i);
            if(b > 0) {
                bits ~= '1';
            } else {
                bits ~= '0';
            }
        }
        return to!string(bits);
    }

    override string toString() {
        string bits = "";

        foreach(int e; bitarray) {
            bits ~= bitArrayToString(e);
        }
        return bits;
    }

    /*
       Returns the bitarray.
     */
    string dump() {
        return to!string(this.bitarray);
    }
}


unittest {
    import std.random : uniform;
    import tools.random : randomArray;

    ulong size = 20;
    uint[] bits = cast(uint[])randomArray(0, 2, size);
    SuccinctBitVector bitvector = new SuccinctBitVector();
    foreach(uint bit; bits) {
        bitvector.push(bit);
    }

    foreach(ulong i, uint bit; bits) {
        assert(bitvector.get(i) == bit);
    }
}


/*
   The implementation of succinct bit vector.
 */
class SuccinctBitVector : BitArray {
    //HACK tune the size
    private static immutable ulong large_block_size = 1 << 8;
    //the size of a small block is the size of a block in bits.
    private static immutable ulong small_block_size = 8;
    private ulong n_large_blocks;
    private ulong n_small_blocks;
    private ulong[] large_blocks;
    private ulong[] small_blocks;
    private bool built = false;

    void build() {
        //TODO show an error message
        assert(this.length > 0);

        this.n_large_blocks = this.length/this.large_block_size + 1;
        this.n_small_blocks = this.length/this.small_block_size + 1;
        this.fillLargeBlocks();
        this.fillSmallBlocks();
        this.built = true;
    }

    ///
    unittest {
        uint[] bits = [0, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1];
        SuccinctBitVector bitvector = new SuccinctBitVector();
        foreach(uint bit; bits) {
            bitvector.push(bit);
        }

        assert(countOneBits(bitvector.bitarray[0], 2) == 1);
        assert(countOneBits(bitvector.bitarray[0], 3) == 2);
        assert(countOneBits(bitvector.bitarray[1], 2) == 1);
        assert(countOneBits(bitvector.bitarray[1], 8) == 2);
    }

    private ulong countOneBitsInBlock(ulong position) {
        assert(position % 8 == 0);

        ulong n_bits;
        foreach(int block; this.bitarray[0..position/8]) {
            n_bits += countOneBits(block, 8);
        }
        return n_bits;
    }

    unittest {
        uint[] bits = [0, 1, 0, 1, 0, 0, 0, 1, 1, 1];

        SuccinctBitVector bitvector = new SuccinctBitVector();
        foreach(uint bit; bits) {
            bitvector.push(bit);
        }
        bitvector.build();

        assert(bitvector.countOneBitsInBlock(0) == 0);
        assert(bitvector.countOneBitsInBlock(8) == 3);
    }

    void fillLargeBlocks() {
        this.large_blocks = new ulong[this.n_large_blocks];
        for(ulong i = 0; i < this.n_large_blocks; i++) {
            ulong t = i * this.large_block_size;
            this.large_blocks[i] = this.countOneBitsInBlock(t);
        }
    }

    void fillSmallBlocks() {
        this.small_blocks = new ulong[this.n_small_blocks];
        for(ulong i = 0; i < this.n_small_blocks; i++) {
            ulong s = i * this.small_block_size;
            ulong t = s / this.large_block_size;
            this.small_blocks[i] = this.countOneBitsInBlock(s);
            this.small_blocks[i] -= this.large_blocks[t];
        }
    }

    /*
    Returns the number of '0' bits in the bitvector.

    Parameters:
    position = The end point of a counted range in the bitarray.
     */
    ulong rank0(ulong position) {
        assert(this.built);
        return position+1-this.rank1(position);
    }

    /*
    Returns the number of '1' bits in the blocks.

    Parameters:
    position = The end point of a counted range in the bitarray.
     */
    ulong rank1(ulong position)
    in {
        assert(this.built);
    }
    out(n_bits) {
        assert(n_bits <= this.length);
    }
    body {
        ulong s = position/this.large_block_size;
        ulong t = position/this.small_block_size;
        ulong u = t*this.small_block_size;
        ulong n_bits = 0;

        n_bits += this.large_blocks[s];
        n_bits += this.small_blocks[t];

        //count bits in a remaining range
        int block = this.bitarray[position/this.small_block_size];
        n_bits += countOneBits(block, position-u+1);
        return n_bits;
    }

    /*
    The basic function of select.
    */
    ulong selectBase(ulong delegate(ulong) rank, ulong n)
    in {
    }
    out(location) {
        //if select(n) doesn't exist
        if(location >= this.length) {
            import tools.exception : ValueError;
            import std.string : format;
            throw new ValueError(format("select(%d) doesn't exist.", n));
        }
    }
    body {
        //search the location by Binary Search.
        //rank(select(i)) = i+1
        long lower = 0;
        long upper = this.length - 1;
        long middle;

        while(lower <= upper) {
            middle = lower + (upper-lower) / 2;
            long r = rank(middle);
            if(r < n+1) {
                lower = middle+1;
            } else if(r == n+1) {
                break;
            } else {
                upper = middle-1;
            }
        }

        while(middle >= 0 && rank(middle) == n+1) {
            middle -= 1;
        }

        return middle+1;
    }

    /*
    Return the location of the (n+1)th '0' bit in the bitarray.
     */
    ulong select0(ulong n) {
        return this.selectBase(&this.rank0, n);
    }

    /*
    Return the location of the (n+1)th '1' bit in the bitarray.
     */
    ulong select1(ulong n) {
        return this.selectBase(&this.rank1, n);
    }
}


//smoke test
unittest {
    uint[] bits = [0, 1, 0, 1, 0, 0, 0, 1, 1, 1];

    SuccinctBitVector bitvector = new SuccinctBitVector();
    foreach(uint bit; bits) {
        bitvector.push(bit);
    }
    bitvector.build();

    ulong rank0_answers[] = [1, 1, 2, 2, 3, 4, 5, 5, 5, 5];
    ulong rank1_answers[] = [0, 1, 1, 2, 2, 2, 2, 3, 4, 5];
    for(auto i = 0; i < 10; i++) {
        assert(bitvector.rank0(i) == rank0_answers[i]);
        assert(bitvector.rank1(i) == rank1_answers[i]);
    }

    ulong select0_answers[] = [0, 2, 4, 5, 6];
    ulong select1_answers[] = [1, 3, 7, 8, 9];

    for(auto i = 0; i < 5; i++) {
        assert(bitvector.select0(i) == select0_answers[i]);
        assert(bitvector.select1(i) == select1_answers[i]);
    }
}

/*
//boundary value analysis
unittest {
    uint bits[10];
    bits[0..$] = 0;

    SuccinctBitVector bitvector = new SuccinctBitVector();
    foreach(uint bit; bits) {
        bitvector.push(bit);
    }
    bitvector.build();

    assert(bitvector.rank0(bits.length-1) == bits.length);
    assert(bitvector.rank1(bits.length-1) == 0);

}
*/


unittest {
    uint bits[10];
    bits[0..$] = 0;

    SuccinctBitVector bitvector = new SuccinctBitVector();
    foreach(uint bit; bits) {
        bitvector.push(bit);
    }
    bitvector.build();

    //Asserterror should be thrown because select1(0) does not exist
    bool error_thrown = false;
    try {
        bitvector.select1(0);
    } catch(Error e) {
        error_thrown = true;
    }
    assert(error_thrown);
}

/*
//random test of select and rank
unittest {
    import std.random : uniform;
    import tools.random : randomArray;

    ulong select(uint bits[], ulong n, uint targetBit) {
        ulong n_appearances = 0;
        for(ulong i = 0; i < bits.length; i++) {
            if(bits[i] == targetBit) {
                n_appearances += 1;
                if(n_appearances == n+1) {
                    return i;
                }
            }
        }
        return bits.length;
    }

    ulong rank(uint bits[], ulong position, uint targetBit) {
        ulong n = 0;
        foreach(uint bit; bits[0..position+1]) {
            if(bit == targetBit) {
                n += 1;
            }
        }
        return n;
    }

    void test_random() {
        ulong size = uniform(10, 1000);
        uint bits[] = cast(uint[])randomArray(0, 2, size);

        SuccinctBitVector bitvector = new SuccinctBitVector();
        foreach(uint bit; bits) {
            bitvector.push(bit);
        }
        bitvector.build();

        ulong position = uniform(0, size);
        assert(bitvector.rank0(position) == rank(bits, position, 0));
        assert(bitvector.rank1(position) == rank(bits, position, 1));

        ulong n = uniform(0, size);

        if(n < rank(bits, size-1, 0)) {
            assert(bitvector.select0(n) == select(bits, n, 0));
        } else {
            //AssertError should be thrown if n is greater than or
            //equal to the number of 0 bits in bitvector.
            bool error_thrown = false;
            try {
                bitvector.select0(n);
            } catch(Error e) {
                error_thrown = true;
            }
            assert(error_thrown);
        }

        if(n < rank(bits, size-1, 1)) {
            assert(bitvector.select1(n) == select(bits, n, 1));
        } else {
            //AssertError should be thrown if n is greater than or
            //equal to the number of 1 bits in bitvector.
            bool error_thrown = false;
            try {
                bitvector.select1(n);
            } catch(Error e) {
                error_thrown = true;
            }
            assert(error_thrown);
        }
    }

    for(auto i = 0; i < 200; i++) {
        test_random();
    }
}
*/
