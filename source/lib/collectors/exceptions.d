module lib.collectors.exceptions;

import lib;

class DExceptions : DClasses {
    this() {
        super();
        filePath = "exceptions.json";
    }

    static DExceptions collection;
}

auto Exceptions() {
    if (DExceptions.collection is null)
        DExceptions.collection = new DExceptions;
    return DExceptions.collection;
}
