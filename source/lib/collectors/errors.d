module lib.collectors.errors;

import lib;

class DErrors : DClasses {
    this() {
        super();
        filePath = "errors.json";
    }

    static DErrors collection;
}

auto Errors() {
    if (DErrors.collection is null)
        DErrors.collection = new DErrors;
    return DErrors.collection;
}
