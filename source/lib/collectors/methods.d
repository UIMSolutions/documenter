module lib.collectors.methods;

import lib;

class DMethods : DCollector {
    this() {
        super();
        filePath = "methods.json";
    }

    static DMethods collection;

    alias create = DCollector.create;
    override Json create(string name) {
        return super.create(name)
            .set("isInherited", false)
            .set("isAbstract", false)
            .set("visibility", "public")
            .set("isFinal", false);
    }
}

auto Methods() {
    if (DMethods.collection is null)
        DMethods.collection = new DMethods;
    return DMethods.collection;
}
