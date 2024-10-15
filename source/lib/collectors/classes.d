module lib.collectors.classes;

import lib;

class DClasses : DCollector {
    this() {
        super();
        filePath = "classes.json";
    }

    static DClasses collection;

    alias create = DCollector.create;
    override Json create(string name) {
        return super.create(name)
            .set("origin", name)
            .set("isAbstract", false)
            .set("isInherited", false)
            .set("isStatic", false)
            .set("isFinal", false)
            .set("hasParent", false)
            .set("parent", Json(null))
            .set("implements", Json.emptyArray)
            .set("methods", Json.emptyObject)
            .set("isAbstract", false)
            .set("isFinal", false)
            .set("visibility", "public")
            .set("implements", Json.emptyArray)
            .set("comments", Json.emptyArray);
    }
}

auto Classes() {
    if (DClasses.collection is null)
        DClasses.collection = new DClasses;
    return DClasses.collection;
}
