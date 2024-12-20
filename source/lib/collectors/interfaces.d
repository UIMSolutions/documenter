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

    override void parseFile(DirEntry file) {
        string path = file.name;
        auto lines = readFileLines(path);
        if (!lines.isInterface)
            return;

        size_t cursor = findHeaderPos(lines, "interface ");
        string line = lines[cursor];
        Json info = create(line);
        info = parseData(info, lines);
        info = copyFileInfo(info, path);

        info.parseComments(lines, cursor);
        info["origin"] = line;

        info = parseHeader(info, line);
        if (lines.length > cursor+1) {
            auto intendLines = lines[cursor .. $].filter!(line => line.intendation > 0).array;
            if (intendLines.length > 0) {
                auto minIntend = intendLines.map!(line => line.intendation).minElement;
                intendLines
                    .filter!(line => line.intendation == minIntend)
                    .map!(line => line.replace(";", "").strip)
                    .filter!(line => !line.startsWith(["//", "/*"]))
                    .filter!(line => line.containsAll(["(", ")"]))
                    .each!(line => info["methods"][line] = parseInterfaceMethod(line));
            }
        }

        set(path, info);
    }

    Json parseData(Json info, string[] lines) {
        if (info.isNull)
            info = Json.emptyObject;
        info["namespace"] = namespace(lines);
        info["library"] = libraryName(info.getString("namespace"));
        info["package"] = packageName(info.getString("namespace"));
        return info;
    }

    Json parseHeader(Json info, string line) {
        if (info.isNull)
            info = Json.emptyObject;

        if (line.isEmpty)
            return info;

        line = line.contains("//") ? line.split("//")[0].strip : line;
        line = line.replace("{}", "").replace("{", "").replace("interface", "").strip;

        string visibility = parseVisibility(line);
        info["visibility"] = visibility;
        line = line.removeFirst(visibility).strip;

        info["header"] = line;
        if (line.contains(":")) {
            info["name"] = line.split(":")[0].strip;
            line.split(":")[1].strip.split(",")
                .map!(item => item.strip)
                .each!(item => info["implements"] ~= Json(item));
        } else {
            info["name"] = line;
        }

        return info;
    }
}

auto Interfaces() {
    if (DInterfaces.collection is null)
        DInterfaces.collection = new DInterfaces;
    return DInterfaces.collection;
}
