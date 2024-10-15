module lib.collectors.entities;

import lib;

class DEntities : DClasses {
    this() {
        super();
        filePath = "entities.json";
    }

    static DEntities collection;
}

auto Entities() {
    if (DEntities.collection is null)
        DEntities.collection = new DEntities;
    return DEntities.collection;
}
