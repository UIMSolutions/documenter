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

/*     Json getWith(string key, string value) {
        auto findings = _infos.byKeyValue
            .map!(info => info.value)
            .filter!(infoValue => infoValue.getString(key) == value)
            .array;

        return findings.length > 0
            ? findings[0] : Json(null);
    } */

    void set(Json info) {
        _infos[info.getString("name")] = info;
    }

    void set(string name, Json info) {
        /* if (name in _infos) {
            Json finding = Json(createMap!(string, Json)
                    .set("name", name)
                    .set("category", this.classname)
                    .set("message", "name exists"));

            Findings.set(name, finding);
        } */
        _infos[name] = info;
    }

    Json create(DirEntry file) {
        Json info = create(file.name);
        return readFileData(info, file);
    }

    Json readFileData(Json info, DirEntry file) {
        return info;
    }

    void parse(DirEntry[] files) {
        files
            .filter!(file => file.isFile)
            .each!(file => parse(file));
    }

    void parse(DirEntry file) {
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
