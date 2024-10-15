module lib.collectors.registries;

import lib;

class DRegistries : DClasses {
    this() {
        super();
        filePath = "registries.json";
    }

    static DRegistries collection;
}

auto Registries() {
    if (DRegistries.collection is null)
        DRegistries.collection = new DRegistries;
    return DRegistries.collection;
}
