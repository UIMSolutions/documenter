module lib.collectors.documents;

import lib;

class DDocuments : DCollector {
    this() {
        super();
        filePath = "documents.json";
    }

    static DDocuments collection;

    alias create = DCollector.create;
    override Json create(string name) {
        return super.create(name)
            .set("isInherited", false)
            .set("isAbstract", false)
            .set("visibility", "public")
            .set("isFinal", false);
    }
}

auto Documents() {
    if (DDocuments.collection is null)
        DDocuments.collection = new DDocuments;
    return DDocuments.collection;
}
