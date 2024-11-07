module lib.parsing;

import lib;

string[] classMethodTokens = [
    "abstract", "final", "override", "static", "public", "protected", "private",
    "package"
];
string[] interfaceMethodTokens = [
    "final", "static", "public", "protected", "private", "package"
];
string[] fundamentalTypes = [
    "bool", "byte", "ubyte", "short", "ushort", "int", "uint", "long", "ulong",
    "cent", "ucent",
    "char", "wchar", "dchar", "float", "double", "real", "ifloat", "idouble",
    "ireal", "cfloat", "cdouble", "creal", "void"
];

bool hasModuleName(string[] lines) {
    return lines.any!(line => line.strip.startsWith("package "));
}

size_t posModuleName(string[] lines) {
    foreach (pos, line; lines) {
        if (line.strip.startsWith(["//", "/*", "*", "@", "-"]))
            continue;

        if (line.strip.startsWith("module ")) {
            return pos;
        }
        if (pos > 1000) {
            break;
        }
    }
    return -1;
}

size_t posInterfaceHeader(string[] content) {
    foreach (i, line; content) {
        if (line.strip.startsWith(["//", "/*", "*", "@", "-"]))
            continue;

        if (line.isInterface) {
            return i;
        }
    }
    return 0;
}

size_t posFirstLineWithIntendation(string[] lines, size_t intend, size_t start = 0) {
    if (start >= lines.length)
        return 0;
    foreach (i, line; lines) {
        if (line.intendation == intend) {
            return i;
        }
    }
    return 0;
}

size_t posNextLineWithIntendation(string[] lines, size_t intend, size_t start = 0) {
    if (start + 1 >= lines.length)
        return 0;
    foreach (i, line; lines[start + 1 .. $]) {
        if (line.intendation == intend) {
            return i;
        }
    }
    return 0;
}

size_t posFirstLineWithGreaterIntendation(string[] lines, size_t intend, size_t start = 0) {
    if (start >= lines.length)
        return 0;
    foreach (i, line; lines) {
        if (line.intendation > intend) {
            return i;
        }
    }
    return 0;
}

size_t posNextLineWithGreaterIntendation(string[] lines, size_t intend, size_t start = 0) {
    if (start + 1 >= lines.length)
        return 0;

    foreach (i, line; lines[start + 1 .. $]) {
        if (line.intendation > intend) {
            return i;
        }
    }
    return 0;
}

size_t posFirstLineWithLessIntendation(string[] lines, size_t intend, size_t start = 0) {
    if (start >= lines.length)
        return 0;

    foreach (i, line; lines) {
        if (line.intendation < intend) {
            return i;
        }
    }
    return 0;
}

size_t posNextLineWithLessIntendation(string[] lines, size_t intend, size_t start = 0) {
    if (start + 1 >= lines.length)
        return 0;

    foreach (i, line; lines[start + 1 .. $]) {
        if (line.intendation < intend) {
            return i;
        }
    }
    return 0;
}

string[] allLinesWithIntendation(string[] lines, size_t intend) {
    return lines.filter!(line => line.intendation == intend).array;
}

string[] allLinesWithGreaterIntendation(string[] lines, size_t intend) {
    return lines.filter!(line => line.intendation > intend).array;
}

string[] allLinesWithLessIntendation(string[] lines, size_t intend) {
    return lines.filter!(line => line.intendation > intend).array;
}

// #region classes

// [abstract] class name [: parent [, interface...]]
Json parseClassHeader(string line) {
    line = line.strip;
    Json info = Classes.create(line);

    if (line.startsWith("//"))
        return info;
    if (line.contains("//"))
        line = line.split("//")[0].strip;

    auto items = line.split();
    if (items.length == 0)
        return info;

    if (!items.hasValue("class"))
        return info;

    if (items.hasValue("abstract")) {
        info["isAbstract"] = true;
        line = line.replace("abstract ", "");
    }

    if (items.hasValue("final")) {
        info["isFinal"] = true;
        line = line.replace("final ", "");
    }

    if (line.hasValue("static")) {
        info["isStatic"] = true;
        line = line.replace("static ", "");
    }

    if (items.hasValue("protected")) {
        info["visibility"] = "protected";
        line = line.replace("protected ", "");
    } else if (items.hasValue("private")) {
        info["visibility"] = "private";
        line = line.replace("private ", "");
    } else {
        line = line.replace("public ", "");
    }

    info["implements"] = Json.emptyArray;
    if (line.indexOf(":") > 0) {
        info["name"] = line.split(":")[0].strip;
    } else {
        info["name"] = line.strip;
        return info;
    }

    if (line.indexOf(":") > 0) {
        line = line.split(":")[1].strip;
    }
    items = line.split(",").map!(line => line.strip).array;

    items
        .each!(item => info["implements"] ~= item);

    items
        .filter!(item => !item.startsWith("I"))
        .each!(item => info["super"] = item);

    return info;
}

Json parseClass(Json info, string[] lines) {
    auto posHeader = posClassHeader(lines);
    if (posHeader >= 0) {
        info = info
            .set("type", "class")
            .set("header", parseClassHeader(lines[posHeader]));

        auto nextPos = posHeader + 1;
        if (lines.length > posHeader) {
            auto nextIntend = lines[nextPos].intendation;
            info["methods"] = Json.emptyObject;
            lines = lines[nextPos .. $]
                .map!(line => line.strip) // .filter!(line => nextIntend == line.intendation)
                .filter!(line => line.containsAll("(", ")"))
                .filter!(line => !line.startsWith("//", "/*", "*", "}", "?", ":"))
                .filter!(line => !line.containsAny("}", "/*", "*/", "if ", "else ", "new ", "map!", "filter!", "each!"))
                .filter!(line => !line.containsAny("==", "!=", "\"", "while", "any!", "all!", "~=", "**", "assert(", "version("))
                .filter!(line => !line.split("(")[0].containsAny([
                        "=", "[", "]", "}", "{", "/*", "*", "/"
                    ]))
                .map!(line => line.contains("{") ? line.replace("{", "").strip : line.strip)
                .array;

            lines
                .filter!(line => !line.strip.startsWith("/*"))
                .each!((line) {
                    Json json = Json.emptyObject;
                    json["origin"] = line;
                    if (line.values.hasValue("final")) {
                        json["isFinal"] = true;
                        line = line.replace("final ", "");
                    }
                    if (line.values.hasValue("abstract")) {
                        json["isAbstract"] = true;
                        line = line.replace("abstract ", "");
                    }
                    if (line.values.hasValue("static")) {
                        json["isStatic"] = true;
                        line = line.replace("static ", "");
                    }
                    if (line.values.hasValue("override")) {
                        json["isInherited"] = true;
                        line = line.replace("override ", "");
                    }

                    string visibility = parseVisibility(line);
                    json["visibility"] = visibility;
                    line = line.removeFirst(visibility).strip;

                    json["isProperty"] = line.values.hasValue("@property");
                    line = line.replace("@property ", "");

                    json["header"] = line;
                    // .each!(line => info["methods"][line] = readInfo(line));
                });
        }
    }
    info["content"] = Json.emptyArray;
    // info["content"] = lines.getClassContent().map!(line => Json(line)).array;

    info["methods"] = Json.emptyObject;
    /*     info["content"].get!(Json[])
        .map!(json => json.to!string)
        .filter!(line => !line.strip.startsWith("//") && !line.strip.startsWith("/*") && !line.strip.startsWith(
                "}"))
        .filter!(line => line.isMethodHeader)
        .each!(line => info["methods"] ~= readInfo(line)); */

    return info;
}
// #endregion classes

// #region interface
void parseInterface(string path, Json fileInfo = Json.emptyObject) {
    parseInterface(readFileByLine(path));
}

void parseInterface(string[] lines, Json fileInfo = Json.emptyObject) {
    string line;
    size_t cursor;
    foreach (i, l; lines) {
        if (l.strip.startsWith(["//", "/*", "*", "/+"]))
            continue;

        if (l.contains("interface ")) {
            cursor = i;
            line = l;
            break;
        }
    }

    if (line.isEmpty)
        return;

    Json info = Interfaces.create(line);
    fileInfo.byKeyValue.each!(item => info[item.key] = item.value);
    info.parseComments(lines, cursor);
    info["namespace"] = namespace(lines);
    info["library"] = libraryName(info.getString("namespace"));
    info["package"] = packageName(info.getString("namespace"));
    info["origin"] = line;

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

    if (lines.length > cursor) {
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

    Interfaces.set(info.getString("name"), info);
}

// #region parseVisibility
string parseVisibility(string line) {
    if (line.values.hasValue("protected")) {
        return "protected";
    }
    if (line.values.hasValue("private")) {
        return "private";
    }
    if (line.values.hasValue("package")) {
        return "package";
    }
    return "public";
}

unittest {
    string test = "void test()";
    assert(parseVisibility(test) == "public");
    assert(parseVisibility(test) == test);

    test = "protected void test()";
    assert(parseVisibility(test) == "protected");
    assert(parseVisibility(test) == test);
}
// #endregion parseVisibility

/* Json parseInterface(Json info, string[] content) {
    auto posHeader = posInterfaceHeader(content);
    if (posHeader >= 0) {
        auto info = content[posHeader].strip;

        info["info"] = info;
        info["type"] = "interface";
        info = info
            .replace("interface ", "")
            .replace("{", "")
            .replace("}", "")
            .strip;

        info["implements"] = Json.emptyArray;
        if (info.indexOf(":") > 0) {
            auto items = info.split(":").map!(item => item.strip).array;
            info["name"] = items[0];
            info["implements"] = items[1].split(",").map!(item => Json(item.strip)).array;
        } else {
            info["name"] = info;
        }

        auto nextPos = posHeader + 1;
        if (content.length > nextPos) {
            auto nextIntend = content[nextPos].intendation;
            info["methods"] = Json.emptyObject;
            auto lines = content[nextPos .. $]
                .filter!(line => nextIntend == line.intendation)
                .filter!(line => line.containsAll("(", ")"))
                .filter!(line => !line.startsWith("//", "/*", "*", "}", "?", ":"))
                .filter!(line => !line.containsAny("}", "/*", "* /", "if ", "else ", "new ", "map!", "filter!", "each!"))
                .filter!(line => !line.containsAny("==", "!=", "\"", "while", "any!", "all!", "~=", "**", "assert(", "version("))
                .array;

            lines.each!((line) {
                Json json = Json.emptyObject;
                json["origin"] = line;
                if (line.values.hasValue("final")) {
                    json["isFinal"] = true;
                    line = line.replace("final ", "");
                }
                json["info"] = line;
                info["methods"][line] = json;
            });
        }

    }
    return info;
} */
// #endregion interface

Json packageInfo(Json info, string[] content) {
    info["type"] = "package";
    return info;
}

size_t posClassHeader(string[] content) {
    foreach (i, line; content) {
        if (line.strip.startsWith(["//", "/*", "*", "@"]))
            continue;

        if (line.isClass) {
            return i;
        }
    }
    return 0;
}

Json fileInfo(Json info, string name) {
    return !name.exists
        ? Json(null) : fileInfo(name, readFileLines(name));
}

Json fileInfo(string name, string[] content) {
    Json info = Json.emptyObject;
    info["filePath"] = name;
    auto namespace = namespace(content).strip;
    info["namespace"] = namespace;
    info["library"] = libraryName(namespace);

    return info;
}

string libraryName(string namespace) {
    auto items = namespace.strip.split(".").map!(item => item.strip).array;
    return items.length < 2
        ? null : items[0 .. 2].join("-");
}

// #region module
void parseModule(string path) {
    parseModule(readFileByLine(path), path);
}

void parseModule(string[] lines, string path) {
    string line;
    size_t cursor;
    foreach (i, l; lines) {
        if (l.startsWith("module ")) {
            cursor = i;
            line = l;
            break;
        }
    }

    if (line.isEmpty)
        return;

    line = line.replace("module ", "").replace(";", "").strip;
    if (line.contains("//"))
        line = line.split("//")[0].strip;

    auto info = Modules.create(line);
    info["namespace"] = line;
    info["library"] = libraryName(line);
    info["package"] = packageName(line);
    lines
        .map!(line => line.strip)
        .filter!(line => line.startsWith("import"))
        .each!((line) {
            line = line.replace("import ", "").replace(";", "");
            if (line.contains("//"))
                line = line.split("//")[0].strip;
            info["imports"] ~= Json(line);
        });

    Modules.set(path, info);
}
// #endregion module 

// #region package
void parsePackage(string path) {
    parsePackage(readFileByLine(path), path);
}

void parsePackage(string[] lines, string path) {
    string line;
    size_t cursor;
    foreach (i, l; lines) {
        if (l.startsWith("module ")) {
            cursor = i;
            line = l;
            break;
        }
    }

    if (line.isEmpty)
        return;

    line = line.replace("module ", "").replace(";", "").strip;
    if (line.contains("//"))
        line = line.split("//")[0].strip;

    auto info = Packages.create(line);
    info["namespace"] = line;
    info["library"] = libraryName(line);
    info["package"] = packageName(line);
    lines
        .map!(line => line.strip)
        .filter!(line => line.startsWith("import"))
        .each!((line) {
            line = line.replace("import ", "").replace(";", "");
            if (line.contains("//"))
                line = line.split("//")[0].strip;
            info["imports"] ~= Json(line);
        });
    Packages.set(path, info);
}
// #endregion package 

// #region library
void parseLibrary(string path) {
    parseLibrary(readFileByLine(path), path);
}

void parseLibrary(string[] lines, string path) {
    string line;
    size_t cursor;
    foreach (i, l; lines) {
        if (l.startsWith("module ")) {
            cursor = i;
            line = l;
            break;
        }
    }

    if (line.isEmpty)
        return;

    line = line.replace("module ", "");
    line = line.split(";")[0];
    if (line.split(".").length != 2)
        return;

    auto info = Libraries.create(line);
    info["namespace"] = line;
    info["package"] = line;
    info["library"] = libraryName(line);
    info["name"] = libraryName(line);
    Libraries.set(path, info);
}
// #endregion library 

// #region files
void parseFiles(string path) {
    parseFiles(readFileByLine(path), path);
}

void parseFiles(string[] lines, string path) {
    /*     string line;
    size_t cursor;
    foreach (i, l; lines) {
        if (l.startsWith("module ")) {
            cursor = i;
            line = l;
            break;
        }
    }

    if (line.isEmpty)
        return;

    line = line.replace("module ", "");
    line = line.split(";")[0];
    if (line.split(".").length != 2) return;
    
    auto info = Files.create(line);
    info["namespace"] = line;
    info["library"] = libraryName(line);
    info["path"] = path;
    Files.set(path, info);
 */
}
// #endregion files 

Json parseMethod(string line) {
    Json info = Json.emptyObject;
    info["origin"] = line;

    auto lineItems = line.split;
    info["isFinal"] = line.values.hasValue("final");
    line = line.removeFirst("final");

    return info;
}

Json parseClassMethod(string line) {
    Json info = parseMethod(line);

    if ("isInherited" in info) {
        info["isInherited"] = line.hasValue("override");
        line = line.removeFirst("override");
    }

    info["isProperty"] = line.values.hasValue("@property");
    line = line.removeFirst("@property");

    info["isConst"] = line.values.hasValue("const");
    line = line.removeFirst("const");

    info["isSafe"] = line.values.hasValue("@safe");
    line = line.removeFirst("@safe");

    info["isAbstract"] = line.values.hasValue("abstract");
    line = line.removeFirst("abstract");

    info["isStatic"] = line.values.hasValue("static");
    line = line.removeFirst("static");

    info["isInherited"] = line.values.hasValue("override");
    line = line.removeFirst("override");

                    string visibility = parseVisibility(line);
                    info["visibility"] = visibility;
                    line = line.removeFirst(visibility).strip;

    info["header"] = line.strip;
    info["datatype"] = line.split().length > 0 ? line.split()[0] : "";
    line = line.removeFirst(info.getString("datatype"));
    string parameters = line.split("(").length > 1 ? line.split("(")[1 .. $].join("(") : "";
    info["parameters"] = parameters.split(")").length > 1 ? parameters.split(
        ")")[0 .. $ - 1].join(")") : "";

    return info;
}

Json parseInterfaceMethod(string line) {
    line = line.strip;
    if (line.contains("//"))
        line = line.split("//")[0];
    if (line.contains("{"))
        line = line.split("{")[0];

    Json info = parseMethod(line);

    info["isStatic"] = line.hasValue("static");
    line = line.removeFirst("static");

    info["header"] = line.replace("{", "").strip;

    info["isProperty"] = line.hasValue("@property");
    line = line.removeFirst("@property");

    info["header"] = line.replace("{", "").strip;

    auto methodHeader = info.getString("header");
    if (methodHeader.to!string.startsWith("this(")) {
        info["datatype"] = Json(null);
        info["name"] = "this";
    } else {
        auto items = methodHeader.split();
        if (items.length > 0) {
            info["datatype"] = items[0];
            items = items.removeFirst(info.getString("datatype"));
            info["name"] = items.join(" ");

            string methodName = info.getString("name");
            info["name"] = methodName.indexOf("(") > 0 ? methodName.split("(")[0] : null;
            auto parameter = methodName.indexOf("(") > 0 ? methodName.split("(")[1] : null;
            parameter = parameter.endsWith(")") ? parameter[0 .. $ - 1] : parameter;
            info["parameters"] = parameter.split(",").map!(item => Json(item.strip)).array;
        }
    }

    return info;
}

Json parseComments(Json info, string[] lines, size_t startPos) {
    if (startPos == 0) {
        return info;
    }

    string[] comments;
    while (startPos > 0) {
        auto cursor = startPos - 1;
        auto line = lines[cursor].strip;

        if (line.startsWith(["//", "/*", "*", "*/", "///", "/+", "+/"])) {
            line = line.removeFirst([
                "//", "/*", "*", "*/", "/**", "///", "/+", "+/"
            ]);
            comments ~= line.strip;
        } else
            break;

        startPos = cursor;
    }

    info["comments"] = Json.emptyArray;
    foreach_reverse (string line; comments) {
        info["comments"] ~= Json(line);
    }

    return info;
}

// #region d files
DirEntry[] readDFiles(string path) {
    auto files = getFilesInPath(path, ".d");

    files.each!((file) {
        Files.set(file);        

        if (file.isModuleFile) {
            writeln("File ", file.name, " is module");
            parseModule(file);
        }

        if (file.isPackageFile) {
            parsePackage(file);
        }

        if (file.isClassFile) {
            Classes.parseFile(file);
        }

        if (file.isInterfaceFile) {
            Interfaces.parseFile(file);
        }
    });

    return files;
}
// #endregion dfiles

// #region sdl
void readSdlFiles(string path) {
    foreach (file; getFilesInPath(path, ".sdl")) {   
        auto lines = file.readFileByLine;
        auto name = sdlName(lines);
        if (name.isEmpty) continue;

        auto library = Libraries.create(name);
        if (library != Json(null)) { // found
            debug writeln("Found ", file.name);     
            library["license"] = sdlLicense(lines);
            library["dependencies"] = Json.emptyArray;
            library["dependencies"] = sdlDependencies(lines).map!(item => Json(item)).array;
            Libraries.set(file.name, library);
        }
    }
}

string sdlName(string[] lines) {
    foreach (string line; lines) {
        if (line.strip.startsWith("targetName \"")) {
            return line.strip.split("\"")[1];
        }
    }
    return null;
}

string sdlLicense(string[] lines) {
    foreach (string line; lines) {
        if (line.strip.startsWith("license \"")) {
            return line.strip.split("\"")[1];
        }
    }
    return null;
}

string[] sdlDependencies(string[] lines) {
    return lines
        .filter!(line => line.startsWith("dependency \""))
        .map!(line => line.split("\"")[1])
        .array;
}
// #endregion sdl

bool hasHeader(string[] lines, string keyword) {
    return lines
        .filter!(line => !line.strip.startsWith(["//", "/*", "*", "/+"]))
        .any!(line => line.contains(keyword));
}

size_t findHeaderPos(string[] lines, string keyword) {
    size_t cursor;
    foreach (i, l; lines) {
        if (l.strip.startsWith(["//", "/*", "*", "/+"]))
            continue;

        if (l.contains(keyword)) {
            cursor = i;
            break;
        }
    }
    return cursor;
}
