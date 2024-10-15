module lib.collectors.interfaces;

import lib;

class DInterfaces : DCollector {
    this() {
        super();
        filePath = "interfaces.json";
    }

    static DInterfaces collection;

    alias create = DCollector.create;
    override Json create(string name) {
        return super.create(name)
            .set("visibility", "public")
            .set("implements", Json.emptyArray)
            .set("methods", Json.emptyObject);
    }
}

auto Interfaces() {
    if (DInterfaces.collection is null)
        DInterfaces.collection = new DInterfaces;
    return DInterfaces.collection;
}
