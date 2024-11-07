module lib.helper;

import lib;

string correctPath(string path) {
    path = path.strip;
    return path.endsWith("\\")
        ? path : path ~ "\\";
}

string correctUrl(string url) {
    url = url.strip.lower;
    return url.endsWith("/")
        ? url : url ~ "/";
}

string packageName(string namespace) {
    namespace = namespace.strip;
    auto items = namespace.split(".");
    return items.length > 1
        ? items[0 .. $ - 1].join(".") : null;
}

bool addPath(string rootPath, string path) {
    if (!rootPath.exists) {
        return false;
    }

    rootPath = rootPath.strip.lower.correctPath;
    string fullPath = rootPath;
    try {
        /*         string[] pathItems = path.split("\\");
        pathItems.each!((item) {
            fullPath ~= item ~ "\\";
            try {
                if (!fullPath.exists) {
                    fullPath.mkdir;
                }
            } catch (Exception e) {

            }
        });
 */
        mkdirRecurse(fullPath ~ path);
        return true;
    } catch (Exception e) {
        return false;
    }
}

string[] deleteComments(string[] lines) {
    return lines
        .filter!(line => !line.strip.startsWith("//") && !line.strip.startsWith("/*") && !line.strip.startsWith(
                "*"))
        .array;
}

string[] deleteTests(string[] lines) {
    return lines
        .filter!(line => !line.strip.canFind("assert(") && !line.strip.canFind("unittest {"))
        .array;
}

string namespace(string[] lines) {
    foreach (line; lines) {
        if (line.strip.startsWith("module ")) {
            return namespace(line);
        }
    }
    return null;
}

string namespace(string line) {
    return (line.strip.startsWith("module "))
        ? line.replace("module ", "").strip.split(";")[0] : null;
}

string filetype(string[] lines) {
    foreach (line; lines) {
        if (line.hasValue("class")) {
            return "class";
        }

        if (line.hasValue("interface")) {
            return "interface";
        }

        if (line.hasValue("mixin template")) {
            return "template";
        }
    }
    return "unknown";
}

Json readInterface(string[] lines) {
    Json info = Json.emptyObject;
    foreach (line; lines) {
        if (line.startsWith("interface ")) {
            auto items = line.replace("{", "").replace(";", "").split;
            if (items[0] != "interface") {
                return Json(null);
            }

            info["name"] = items[1];
            info["implements"] = Json.emptyArray;
            info["methods"] = Json.emptyObject;
            if (line.indexOf(":") == -1) {
                return info;
            }

            items = line.split(":");
            items = items[1].split(",").map!(line => line.strip).array;

            items
                .each!(item => info["implements"] ~= item);
        }
    }
    return info;
}

ref Json addNamespace(ref Json json, string namespace) {
    if (namespace is null)
        return json;

    auto items = namespace.split(".");
    if (items[0]!in json) {
        json[items[0]] = Json.emptyObject;
    }

    if (items.length > 1) {
        json[items[0]].addNamespace(items[1 .. $].join("."));
    }

    return json;
}

bool createDirectories(Json source, string rootPath) {
    if (source == Json(null)) {
        return false;
    }

    foreach (key, value; source.byKeyValue) {
        string path = (rootPath ~ "\\" ~ key);
        path.mkdirRecurse;
        if (!createDirectories(value, path))
            return false;
    };
    return true;
}

/* void readFile(ref Json json, string filePath) {
    auto fileLines = readFileLines(filePath);

    auto filetype = filetype(fileLines).strip;
    filetype = filetype.strip.length > 0 ? filetype : "file";

    auto namespace = namespace(fileLines).strip;
    namespace = namespace.length > 0 ? namespace : filetype;

    Json info = Json.emptyObject;
    switch (filetype) {
    case "class":
        info = info.parseClass(fileLines);
        break;
    case "interface":
        info = readInterface(fileLines);
        break;
    default:
        info["name"] = namespace;
        break;
    }
    info["namespace"] = namespace;
    info["filepath"] = filePath;
    info["type"] = filetype;

    json[namespace] = info;
}
 */
size_t intendation(string text) {
    return text.length - text.stripLeft.length;
}

void analyseFile(ref Json json, string filePath) {
    auto fileLines = readFileLines(filePath);
    auto namespace = namespace(fileLines);
    auto filetype = filetype(fileLines);
}

bool existsClassName(Json json, string name) {
    string[string] names;
    /* if ((json.type == Json.Type.array)) {
        foreach (value; json) {
            if (value["type"].get!string != "class")
                continue;

            string name = value["name"].get!string;
            if (name in names) {
                json.addFinding(value, "Double class name '" ~ name ~ "' exists");
            }
        }
    } else if (json.type == Json.Type.object) {
        foreach (key, value; json.byKeyValue) {
            if (value["type"].get!string != "class")
                continue;

            string name = value["name"].get!string;
            if (name in names) {
                json.addFinding(value, "Double class name '" ~ name ~ "' exists");
            }
        }
    } */
    return false;
}

string[] values(string line) {
    return line.split
        .filter!(item => item.strip.length > 0)
        .map!(item => item.strip)
        .array;
}

bool hasValue(string line, string value) {
    return valueIn(value, line.split(line));
}

bool valueIn(string value, string[] lines) {
    return lines.any!(v => v == value);
}

bool isClass(Json json) {
    if (json == Json(null))
        return false;
    if (json.type != Json.Type.object)
        return false;
    if ("type" !in json)
        return false;

    return json["type"].get!string == "class";
}

bool isInterface(Json json) {
    if (json == Json(null))
        return false;
    if (json.type != Json.Type.object)
        return false;
    if ("type" !in json)
        return false;

    return json["type"].get!string == "interface";
}

bool isFunctionInfo(Json json) {
    if (json == Json(null))
        return false;
    if (json.type != Json.Type.object)
        return false;
    if ("type" !in json)
        return false;

    return json["type"].get!string == "function";
}

bool isMethodInfo(Json json) {
    if (json == Json(null))
        return false;
    if (json.type != Json.Type.object)
        return false;
    if ("type" !in json)
        return false;

    return json["type"].get!string == "function";
}

Json groupByIntendation(string[] lines) {
    Json groupResults = Json.emptyArray;
    /* string lastLine;
    Json lastEntry;
    lines.each!((pos, currentLine) {
        Json currentEntry;
        if (lastLine.length == 0) {
            groupResults[entries] = Json.empty;
            currentEntry = Json.emptyObject;
            currentEntry["intendation"] = 0;
            currentEntry["lines"] = Json.emptyArray;
            currentEntry["lines"] ~= Json(currentLine);
        } else {
            if (lastline.intendation > currentLine.intendation) {
                currentEntry = Json.emptyObject;
                currentEntry["intendation"] = currentLine.intendation;
                currentEntry["lines"] = Json.emptyArray;
                currentEntry["lines"] ~= Json(currentLine);
            }
            if (lastline.intendation == currentLine.intendation) {
                lastEntry["lines"] ~= Json(currentLine);
            }
            if (lastline.intendation < currentLine.intendation) {

                currentEntry = Json.emptyObject;
                currentEntry["intendation"] = 0;
                currentEntry["lines"] = Json.emptyArray;
                currentEntry["lines"] ~= Json(currentLine);
            }
        }
        lastLine = currentline;
        lastEntry = currentEntry;
    }); */
    return groupResults;
}

Json newEntry(string line, string[] lines) {
    Json entry = Json.emptyObject;
    entry["intendation"] = line.intendation;
    entry["line"] = line;
    entry["line"] = Json.emptyArray;
    foreach (subline; lines) {
        if (subline.intendation < line.intendation) {
            entry["sublines"] ~= Json(line);
        } else {
            return entry;
        }
    }
    return entry;
}

string[] sublines(string refLine, string[] lines) {
    string[] results;
    foreach (line; lines) {
        if (line.intendation < refLine.intendation) {
            results ~= line;
        } else {
            return results;
        }
    }
    return results;
}

Json groupingLines(string[] lines) {
    Json results = Json.emptyArray;

    string lastLine;
    Json lastEntry;
    foreach (line; lines) {
        if (lastLine.length == 0) { // Initial entry
            Json entry = Json.emptyObject;
            entry["line"] = line;
            entry["intendation"] = line.intendation;
            entry["sublines"] = Json.emptyArray;

            lastLine = line;
            lastEntry = entry;
            results ~= entry;
        } else if (lastLine.intendation <= line.intendation) {
            Json entry = Json.emptyObject;
            entry["line"] = line;
            entry["intendation"] = line.intendation;
            entry["sublines"] = Json.emptyArray;

            lastEntry = entry;
            results ~= entry;
        } else if (lastLine.intendation > line.intendation) {
            lastEntry["sublines"] ~= Json(line);
        }
    }

    return results;
}

string[] getClassContent(string[] lines) {
    string classLine;
    foreach (i, line; lines) {
        if (i + 1 >= lines.length - 1)
            continue;
        if (lib.prettier.isClass(line)) {
            return allLinesWithGreaterIntendation(lines[i + 1 .. $ - 1], line.intendation);
        }
    }
    return null;
}

bool isMethodHeader(string line) {
    if (line.strip.startsWith("//") || line.strip.startsWith("/*"))
        return false;
    if (line.indexOf("(") == -1 || line.indexOf(")") == -1 || line.indexOf("{") == -1)
        return false;
    if (line.indexOf("{") == -1 && line.indexOf(";") == -1)
        return false;
    return true;
}

Json readMethodHeader(string line) {
    Json method = Json.emptyObject;
    line = line.strip;
    if (line.indexOf("//") >= 0)
        line = line.split("//")[0];

    line = line.strip;
    if (line.endsWith("{"))
        line = line[0 .. $ - 1];

    string visibility = parseVisibility(line);
    method["visibility"] = visibility;
    line = line.removeFirst(visibility).strip;

    return method;
}

/* string parseLines(string[] lines) {
	string namespace;
	string[] namespaceItems;
	string fileType;

	Json json = Json.emptyObject;
	Json entry = Json.emptyObject;
	Json mod = Json.emptyObject;

	json["fullname"] = name;
	json["path"] = Json.emptyArray;
	name.split("\\")[0 .. $ - 1].each!(item => json["path"] ~= item);
	json["filename"] = name.split("\\")[$ - 1 .. $].join("");

	json["content"] = Json.emptyArray;
	lines.each!((pos, line) {
		json["content"] ~= line;
		line = line.strip;
		if (!line.startsWith("//") && !line.startsWith("version()") && !line
		.startsWith("unittest {") && !line.startsWith("static this()")) {
			if (line.indexOf("//")) {
				line = line.split("//").length > 0 ? line.split("//")[0] : line;
			}
			if (line.startsWith("package ")) {
				namespace = line.replace("package ", "").replace(";", "").strip;
				namespaceItems = namespace.split(".");
				if (namespaceItems.length > 1) {
					mod["namespace"] = namespace;
					mod["library"] = namespaceItems[0 .. $ - 1].join(
						".");
					mod["name"] = namespace.split(".")[$ - 1 .. $].join();
					mod["imports"] = Json.emptyArray;
				}
			} else {
				if (line.startsWith("class ")) {
					fileType = "class";
					line = line.replace("class ", "").replace("{", "")
						.strip;
					string[] nameItems = line.strip.split;
					entry["implements"] = Json.emptyArray;
					if (line.indexOf(":") > 0) {
						line.split(":")[1].split(",")
							.each!(item => entry["implements"] ~= item.strip);
					}
					entry["name"] = nameItems[0];
					entry["namespace"] = namespace;
					entry["methods"] = Json.emptyObject;
				} else if (
					line.startsWith("interface ")) {
					fileType = "interface";
					line = line.replace("interface ", "").replace("{", "")
						.strip;
					string[] nameItems = line.strip.split;
					entry["implements"] = Json.emptyArray;
					if (
						line.indexOf(":") > 0) {
						line.split(":")[1].split(",")
							.each!(item => entry["implements"] ~= item.strip);
					}
					entry["name"] = nameItems[0];
					entry["namespace"] = namespace;
					entry["methods"] = Json.emptyObject;
				} else {
					if (fileType !is null
					&& line.indexOf("(") > 0
					&& line.indexOf("{") > 0
					&& !line.startsWith("//")
					&& !line.startsWith("/*")
					&& !line.startsWith("*")
					&& !line.startsWith("\"")
					&& !line.startsWith("`")
					&& !line.startsWith("if")
					&& !line.startsWith("for")
					&& !line.startsWith("else")
					&& !line.startsWith("while")
					&& !line.startsWith("throw")
					&& line.indexOf("}") == -1) {
						entry["methods"] ~= line.replace("{", "").strip;
					}
				}
			}
		}
	});

	switch (fileType) {
	case "class":
		classes ~= entry;
		break;
	case "interface":
		parseClass( ~= entry;
		break;
	default:
		libraries ~= entry;
		break;
	}
	packages ~= mod;
	files ~= json;
	fileType = null;

	return namespace;
}
 */

string removeFirst(string origin, string[] values) {
    foreach (value; values) {
        if (value.valueIn(origin.split)) {
            return origin.removeFirst(value);
        }
    }
    return origin;
}

string removeFirst(string origin, string value) {
    return origin.split().removeFirst(value).join(" ");
}

string[] removeFirst(string[] items, string[] values) {
    foreach (value; values) {
        if (value.valueIn(items)) {
            return items.removeFirst(value);
        }
    }
    return items;
}

string[] removeFirst(string[] items, string value) {
    foreach (i, item; items) {
        if (item == value) {
            return items.remove(i);
        }
    }
    return items;
}

Json copyFileInfo(Json info, string path) {
    Json fileInfo = Files.get(path);
    if (!fileInfo.isNull)
        return info;

    fileInfo.byKeyValue.each!(item => info[item.key] = item.value);
    return info;
}
