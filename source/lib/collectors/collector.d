module lib.collectors.collector;

import lib;

class DCollector {
    this() {
    }

    mixin(TProperty!("Json[string]", "infos"));
    mixin(TProperty!("string", "filePath"));

    Json create(string name) {
        Json defaults = Json.emptyObject;
        
        return defaults
            .set("name", name)
            .set("comments", Json.emptyArray);
    }

    Json get(string name) {
        return _infos.get(name, Json(null));
    }

    Json getWith(string key, string value) {
        auto findings = _infos.byKeyValue
            .map!(info => info.value)
            .filter!(info => info.getString(key) == value)
            .array;

        return findings.length > 0
            ? findings[0]
            : Json(null);
    }

    void set(Json info) {
        _infos[info.getString("name")] = info;
    }

    void set(string name, Json info) {
        _infos[name] = info;
    }

    Json create(DirEntry file) {
        Json info = create(file.name);
        return readFileData(info, file);
    }

    Json readFileData(Json info, DirEntry file) {
        return info;
    }

    Json toJson() {
        return Json(_infos);
    }

    void save() {
        auto output = File(filePath, "w");
        output.writeln(Json(_infos).toPrettyString);
        output.close;
    }
}
