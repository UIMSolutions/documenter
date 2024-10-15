module lib.collectors.modules;

import lib;

class DModules : DCollector {
    this() {
        super();
        filePath = "modules.json";
    }

    static DModules collection;

    alias create = DCollector.create;
    override Json create(string name) {
        return super.create(name)
            .set("imports", Json.emptyArray);
    }
}

auto Modules() {
    if (DModules.collection is null)
        DModules.collection = new DModules;
    return DModules.collection;
}
