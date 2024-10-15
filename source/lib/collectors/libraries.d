module lib.collectors.libraries;

import lib;

class DLibraries : DCollector {
    this() {
        super();
        filePath = "libraries.json";
    }

    static DLibraries collection;
}

auto Libraries() {
    if (DLibraries.collection is null)
        DLibraries.collection = new DLibraries;
    return DLibraries.collection;
}
