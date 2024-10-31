module lib.collectors.findings;

import lib;

class DFindings : DClasses {
    this() {
        super();
        filePath = "findings.json";
    }

    static DFindings collection;
}

auto Findings() {
    if (DFindings.collection is null)
        DFindings.collection = new DFindings;
    return DFindings.collection;
}
