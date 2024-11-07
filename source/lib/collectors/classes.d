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

    override void parseFile(DirEntry file) {
        string path = file.name;
        auto lines = readFileLines(path);
        if (!lines.isClass)
            return;

        size_t cursor = findHeaderPos(lines, "class ");
        string line = lines[cursor];
        Json info = create(line);
        info["origin"] = line;

        info = parseData(info, lines);
        info = copyFileInfo(info, path);
        info.parseComments(lines, cursor);

        info = parseHeader(info, line);
        if (lines.length > cursor + 1) {
            auto intendLines = lines[cursor .. $].filter!(line => line.intendation > 0).array;
            if (intendLines.length > 0) {
                auto minIntend = intendLines.map!(line => line.intendation).minElement;
                intendLines
                    .filter!(line => !line.startsWith(["//", "/*", "assert("]))
                    .filter!(line => line.containsAll(["{", "(", ")"]))
                    .filter!(line => line.intendation == minIntend)
                    .map!(line => line.contains("//") ? line.split("//")[0].strip : line.strip)
                    .map!(line => line.contains("{") ? line.split("{")[0].strip : line.strip)
                    .map!(line => line.replace("{}", "").replace("{", "").strip)
                    .filter!(line => !line.strip.startsWith("/*"))
                    .each!(line =>
                            info["methods"][line] = parseClassMethod(line));
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

        line = (line.contains("//") ? line.split("//")[0].strip : line)
            .replace("{}", "")
            .replace("{", "")
            .replace("class ", "")
            .strip;

        if (line.contains("abstract ")) {
            info["isAbstract"] = true;
            line = line.replace("abstract ", "");
        } else if (line.contains("final ")) {
            info["isFinal"] = true;
            line = line.replace("final ", "");
        }
        if (line.contains("static ")) {
            info["isStatic"] = true;
            line = line.replace("static ", "");
        }
        if (line.contains("protected ")) {
            info["visibility"] = "protected";
            line = line.replace("protected ", "");
        } else if (line.contains("private ")) {
            info["visibility"] = "private";
            line = line.replace("private ", "");
        } else {
            line = line.replace("public ", "");
        }

        info["header"] = line;
        if (line.contains(":")) {
            info["name"] = line.split(":")[0].strip;
            line.split(":")[1].strip.split(",")
                .map!(item => item.strip)
                .each!(item => info["implements"] ~= Json(item));

            line.split(":")[1].strip.split(",")
                .map!(item => item.strip)
                .each!(item => info["parent"] = item.startsWith("D") ? item : "");
        } else {
            info["name"] = line;
        }

        return info;
    }
}

auto Classes() {
    if (DClasses.collection is null)
        DClasses.collection = new DClasses;
    return DClasses.collection;
}
