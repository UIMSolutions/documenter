module lib.collectors.elements;

import lib;

class DElements : DClasses {
    this() {
        super();
        filePath = "elements.json";
    }

    static DElements collection;
}

auto Elements() {
    if (DElements.collection is null)
        DElements.collection = new DElements;
    return DElements.collection;
}
