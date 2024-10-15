module lib.collectors.attributes;

import lib;

class DAttributes : DClasses {
    this() {
        super();
        filePath = "attributes.json";
    }

    static DAttributes collection;
}

auto Attributes() {
    if (DAttributes.collection is null)
        DAttributes.collection = new DAttributes;
    return DAttributes.collection;
}
