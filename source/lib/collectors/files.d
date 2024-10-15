module lib.collectors.files;

import lib;

class DFiles : DCollector {
    this() {
        super();
        filePath = "files.json";
    }

    static DFiles collection;

    override Json create(string name) {
        return super.create(name)
            .set("path", "")
            .set("name", "")
            .set("size", 0)
            .set("created", 0)
            .set("lastAccessed", 0)
            .set("lastAccessedDe", "")
            .set("lastModified", 0)
            .set("lastModifiedDe", "")
            .set("namespace", "");
    }

    override Json create(DirEntry file) {
        Json info = super.create(file);
        return readFileData(info, file);
    }

    override Json readFileData(Json info, DirEntry file) {
        if (!file.isFile)
            return info;

        string path = file.name;
        return info
            .set("path", path.split("\\")[0 .. $ - 1].join("\\"))
            .set("name", path.split("\\")[$ - 1 .. $].join)
            .set("size", file.size)
            .set("created", file.timeCreated.toTimestamp)
            .set("lastAccessed", file.timeLastAccessed.toTimestamp)
            .set("lastAccessedDe", file.timeLastAccessed.toTimestamp.germanDate)
            .set("lastModified", file.timeLastModified.toTimestamp)
            .set("lastModifiedDe", file.timeLastModified.toTimestamp.germanDate)
            .set("namespace", namespace(readFileLines(path)));
    }

    void set(DirEntry file) {
        string path = file.name;
        Json fileInfo = Files.create(path);
        super.set(path, readFileData(fileInfo, file));
    }
}

auto Files() {
    if (DFiles.collection is null)
        DFiles.collection = new DFiles;
    return DFiles.collection;
}
