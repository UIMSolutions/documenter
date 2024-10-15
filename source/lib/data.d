module lib.data;

import lib;
 

Json[string] filterSubPackages(Json[string] infos, string packageName) {
    packageName = packageName.strip;
    if (!packageName.endsWith(".")) packageName ~= ".";

    Json[string] selected;
    infos.byKeyValue
        .filter!(item => item.value.getString("namespace").startsWith(packageName))
        .each!(item => selected[item.value.getString("namespace")] = item.value);

    return selected;
}

Json[string] inLibrary(Json infos, string libraryName) {
    libraryName = libraryName.strip;
    Json[string] selected;

    if (infos.isObject) {
        infos.byKeyValue
            .filter!(item => item.value.getString("library") == libraryName)
            .each!(item => selected[item.value.getString("namespace")] = item.value);
    }
    else if (infos.isArray) {
        infos.getArray
            .filter!(item => item.getString("library") == libraryName)
            .each!(item => selected[item.getString("namespace")] = item);
    }
    return selected;
}
Json[string] inLibrary(Json[string] infos, string libraryName) {
    libraryName = libraryName.strip;
    Json[string] selected;

    infos.byKeyValue
        .filter!(item => item.value.getString("library") == libraryName)
        .each!(item => selected[item.value.getString("namespace")] = item.value);

    return selected;
}
unittest {
    Json obj = Json.emptyObject;

    Json json = Json.emptyObject;
    json["namespace"] = "4.5.6";
    json["package"] = "a.b.c";
    json["library"] = "a-b";
    obj["a"] = json;

    json = Json.emptyObject;
    json["namespace"] = "1.2.3";
    json["package"] = "x.y.z";
    json["library"] = "x-y";
    obj["b"] = json;

    assert(!obj.inLibrary("a-b").hasKey("1.2.3"));
    assert(obj.inLibrary("a-b").hasKey("4.5.6"));
    assert(obj.inLibrary("a-b")["4.5.6"].getString("library") == "a-b");
}

Json[string] inPackage(Json infos, string packageName) {
    packageName = packageName.strip~".";
    Json[string] selected;
    if (infos.isObject) {
        infos.byKeyValue        
            .filter!(item => item.value.getString("namespace").startsWith(packageName))
            .each!(item => selected[item.value.getString("namespace")] = item.value);
    }
    else if (infos.isArray) {
        infos.getArray        
            .filter!(item => item.getString("namespace").startsWith(packageName))
            .each!(item => selected[item.getString("namespace")] = item);
    }
    return selected;
}
Json[string] inPackage(Json[string] infos, string packageName) {
    packageName = packageName.strip~".";
    Json[string] selected;
    infos.byKeyValue        
        .filter!(item => item.value.getString("namespace").startsWith(packageName))
        .each!(item => selected[item.value.getString("namespace")] = item.value);

    return selected;
}
unittest {
    Json obj = Json.emptyObject;

    Json json = Json.emptyObject;
    json["namespace"] = "4.5.6";
    json["package"] = "a.b.c";
    obj["a"] = json;

    json = Json.emptyObject;
    json["namespace"] = "1.2.3";
    json["package"] = "x.y.z";
    obj["b"] = json;

    assert(!obj.inPackage("a.b").hasKey("1.2.3"));
    assert(!obj.inPackage("a.b").hasKey("4.5.6"));
    assert(obj.inPackage("a.b")["4.5.6"].getString("package") == "a.b.c");
}

Json[string] subClasses(Json classes, string className) {
    className = className.strip;
    Json[string] selected;
    
    if (classes.isObject) {
        classes.byKeyValue
            .filter!(item => item.value.getString("parent") == className)
            .each!(item => selected[item.value.getString("namespace")] = item.value);
    }
    else if (classes.isArray) {
        classes.getArray
            .filter!(item => item.getString("parent") == className)
            .each!(item => selected[item.getString("namespace")] = item);
    }    
    
    return selected;
}
unittest {
    Json obj = Json.emptyObject;

    Json json = Json.emptyObject;
    json["namespace"] = "4.5.6";
    json["package"] = "a.b.c";
    obj["a"] = json;

    json = Json.emptyObject;
    json["namespace"] = "1.2.3";
    json["package"] = "x.y.z";
    obj["b"] = json;

/*     assert(!obj.inPackage("a.b").hasKey("1.2.3"));
    assert(obj.inPackage("a.b").hasKey("4.5.6"));
    assert(obj.inPackage("a.b")["4.5.6"].getString("package") == "a.b.c");
 */
}

Json[string] implementsInterface(Json[string] infos, string interfaceName) {
    interfaceName = interfaceName.strip;

    Json[string] selected;
    infos.byKeyValue
//        .filter!(item => item.value.getArray("implements").hasValue(interfaceName))
        .each!(item => selected[item.value.getString("namespace")] = item.value);

    return selected;
}