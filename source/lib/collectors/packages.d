module lib.collectors.packages;

import lib;

class DPackages : DCollector  {
    this() {
        super();
        filePath = "packages.json";
    }

    static DPackages packages;

    alias create = DCollector.create;
    override Json create(string name) {
        return super.create(name)
            .set("imports", Json.emptyArray);
    }
}

auto Packages() {
    if (DPackages.packages is null)
        DPackages.packages = new DPackages;
    return DPackages.packages;
}
