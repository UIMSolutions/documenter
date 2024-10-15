module lib.collectors.factories;

import lib;

class DFactories : DClasses {
    this() {
        super();
        filePath = "factories.json";
    }

    static DFactories collection;
}

auto Factories() {
    if (DFactories.collection is null)
        DFactories.collection = new DFactories;
    return DFactories.collection;
}
