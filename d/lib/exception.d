module lib.exception;

/*
    Raised when a function receives an argument that has the right type.
*/
class ValueError : Error {
    this(string msg) {
        super("ValueError:  " ~ msg);
    }
}


/*
    Raised when a mapping (dictionary) key is not found in the set of existing
    keys.
*/
class KeyError : Error {
    this(string msg) {
        super("KeyError:  " ~ msg);
    }
}


/*
   Raised when a sequence subscript is out of range.
 */
class IndexError : Error {
    this(string msg) {
        super("IndexError:  " ~ msg);
    }
}
