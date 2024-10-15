module lib.generater;

import lib;

const bool test = true;

// #region attributes
void createAttributePages(Json[string] attributes, string rootPath, string rootUrl) {
    if (attributes is null)
        return;

    createAttributesOverview(attributes, rootPath, rootUrl);
    attributes.byKeyValue.each!(item => createAttributePage(item.value, rootPath, rootUrl));
}
// #region overview
void createAttributesOverview(Json[string] attributes, string rootPath, string rootUrl) {
    if (attributes is null) {
        return;
    }

    writeln("Creating overview for ", attributes.length, " attributes");
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;


    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"]
    ]);
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Attributes";
    bindings["posttitle"] = "Found " ~ to!string(attributes.length) ~ " attributes";
    bindings["content"] = `<div class="col">` ~ classesTable(attributes, rootUrl, "attributes") ~ `</div>`;

    savePage(rootPath, rootPath.correctPath ~ "attributes\\index.html",
        overviewTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));

}
// #endregion overview
// #region page
void createAttributePage(Json attribute, string rootPath, string rootUrl) {
    if (attribute == Json(null))
        return;

    writeln("Creating attribute page for ", attribute["name"], " in ", rootPath);
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = attribute.getString("namespace");
    if (namespace.length == 0) {
        return;
    }

    STRINGAA bindings;
    string libraryName = libraryName(namespace);
    bindings["library"] = libraryName;
    bindings["package"] = namespace;

    string name = attribute.getString("name");
    bindings["name"] = name.isEmpty ? "" : name;
    bindings["class"] = "Attribute";
    bindings["title"] = "Attribute " ~ name;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"],
        ["Attributes": "{{rooturl}}/api/attributes"]
    ]);
    bindings["content"] =
        sectionDescription(attribute, "templates\\api\\attributes\\" ~ attribute.getString(
                "name") ~ ".html") ~
        sectionClassProperties(attribute, rootUrl) ~
        sectionClassMethods(attribute, rootUrl);

    savePage(rootPath, rootPath.correctPath ~ "attributes\\" ~ name ~ ".html",
        classTemplate()
            .createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}
// #endregion page
// #endregion attributes

// #region classes
void createClassPages(Json[string] classes, string rootPath, string rootUrl) {
    if (classes is null)
        return;

    createClassesOverview(classes, rootPath, rootUrl);
    classes.byKeyValue.each!(item => createClassPage(item.value, rootPath, rootUrl));
}

// #region overview
void createClassesOverview(Json[string] classes, string rootPath, string rootUrl) {
    if (classes is null) {
        return;
    }

    writeln("Creating overview for ", classes.length, " classes");
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"]
    ]);
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Classes";
    bindings["posttitle"] = "Found " ~ to!string(classes.keys.length) ~ " classes";
    bindings["content"] = `<div class="col">` ~ classesTable(classes, rootUrl, "classes") ~ `</div>`;

    savePage(rootPath, rootPath.correctPath ~ "classes\\index.html",
        overviewTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string classesTable(Json[string] classes, string rootUrl, string category = "classes") {
    return classes is null
        ? null : cardTable(classesTableHeader(), classesTableBody(classes, rootUrl, category));
}

string classesTableHeader() {
    return TR(
        TH("Name"),
        TH("Library"),
        TH("Package"),
        TH("Implements"));
}

string classesTableBody(Json[string] classes, string rootUrl, string category = "classes") {
    rootUrl = rootUrl.correctUrl;
    category = category.lower;
    return classes is null
        ? null : classes.byKeyValue
        .map!(info => info.value)
        .array
        .sort!(`a["name"].get!string < b["name"].get!string`)
        .map!(info => TR(
                cell(`<a href="%s` ~ category ~ `/%s.html">%s</a>`, false),
                `<td class="text-nowrap text-secondary w-1"><a href="%slibraries/%s.html">%s</a></td>`,
                `<td class="text-nowrap text-secondary w-1"><a href="%spackages/%s.html">%s</a></td>`,
                cell(`%s`, true, false)
        ).format(
            rootUrl,
            info.getString("name").lower,
            info.getString("name"),
            rootUrl,
            info.getString("library").lower,
            info.getString("library"),
            rootUrl,
            info.getString("package").lower,
            info.getString("package"),
            info["implements"]
                .get!(Json[])
                .map!(json => json.to!string)
                .map!(value => value.startsWith("I")
                    ? A(`%sinterfaces/` ~ value.lower ~ `.html`, value) : A(
                    `%s` ~ category ~ `/` ~ value.lower ~ `.html`, value))
                .map!(value => value.format(rootUrl))
                .join(", ")
        )
    )
        .join;
}
// #endregion overview

// #region page
void createClassPage(Json class_, string rootPath, string rootUrl) {
    if (class_ == Json(null))
        return;

    writeln("Comments in createClassPage: ", class_["comments"].get!(Json[]));

    writeln("Creating class page for ", class_["name"], " in ", rootPath);
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = class_.getString("namespace");
    if (namespace.length == 0) {
        return;
    }

    STRINGAA bindings;
    string libraryName = libraryName(namespace);
    bindings["library"] = libraryName;
    bindings["package"] = namespace;

    string name = class_.getString("name");
    bindings["name"] = name.isEmpty ? "" : name;
    bindings["class"] = "Class";
    bindings["title"] = "Class " ~ name;
    bindings["modified"] = class_.getString("lastModifiedDe");
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"]
    ]);
    bindings["content"] =
        sectionDescription(class_, "templates\\api\\classes\\" ~ class_.getString("name")
                .lower ~ ".html") ~
        sectionClassProperties(class_, rootUrl) ~
        sectionClassMethods(class_, rootUrl);

    string page = classTemplate();
    savePage(rootPath, rootPath ~ "classes\\" ~ name.lower ~ ".html",
        page.dup.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string sectionClassProperties(Json class_, string rootUrl) {
    return sectionProperties(class_, rootUrl);
}

string sectionClassMethods(Json class_, string rootUrl) {
    auto methods =
        class_["methods"].byKeyValue
        .map!(item => item.value)
        .filter!(value => value != Json(null))
        .array;

    return sectionClassMethods(methods, rootUrl);
}

string sectionClassMethods(Json[] methods, string rootUrl) {
    auto rows =
        methods
        .filter!(value => value != Json(null))
        .map!(value => TR(
                `<td class="text-center">` ~ checkbox("", value.getBoolean("isInherited")) ~ "</td>",
                `<td class="text-center">` ~ checkbox("", value.getBoolean("isAbstract")) ~ "</td>",
                `<td class="text-center">` ~ checkbox("", value.getBoolean("isFinal")) ~ "</td>",
                `<td class="text-center">` ~ checkbox("", value.getBoolean("isStatic")) ~ "</td>",
                TD(value.getString("datatype")),
                TD(value.getString("header"))
        ))
        .join;

    auto methodsTable =
        cardTable(TR(
                TH(["w-1", "text-center"], "Inherited"),
                TH(["w-1", "text-center"], "Abstract"),
                `<th class="w-1 text-center">Final</th>`,
                `<th class="w-1 text-center">Static</th>`,
                `<th class="w-1 text-center">Datatype</th>`,
                TH("Header")),
            rows);

    return methods == null
        ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Methods
                    </h3>
                    <p class="text-secondary">
                        {{methods}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("methods", methodsTable);
}
// #endregion page
// #endregion classes

// #region errors
void createErrorPages(Json[string] errors, string rootPath, string rootUrl) {
    createOverview(errors, rootPath, rootUrl, "Errors", "errors");
}
// #endregion errors

// #region exceptions
void createExceptionPages(Json[string] exceptions, string rootPath, string rootUrl) {
    createOverview(exceptions, rootPath, rootUrl, "Exceptions", "exceptions");
}
// #endregion exceptions

// #region factories
void createFactoryPages(Json[string] factories, string rootPath, string rootUrl) {
    createOverview(factories, rootPath, rootUrl, "Factories", "factories");
}
// #endregion factories

// #region interfaces
void createInterfacePages(Json[string] interfaces, string rootPath, string rootUrl) {
    if (interfaces is null)
        return;

    createInterfacesOverview(interfaces, rootPath, rootUrl);
    interfaces.byKeyValue.each!(item => createInterfacePage(item.value, rootPath, rootUrl));
}

// #region overview
void createInterfacesOverview(Json[string] interfaces, string rootPath, string rootUrl) {
    if (interfaces is null)
        return;

    writeln("Creating overview for ", interfaces.length, " interfaces");
    string pathToTemplate = "templates\\overview.html";

    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    STRINGAA bindings;
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Interfaces";
    bindings["posttitle"] = "Found " ~ to!string(interfaces.keys.length) ~ " interfaces";
    bindings["content"] = `<div class="col">` ~ interfacesTable(interfaces, rootUrl) ~ `</div>`;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"]
    ]);

    string page = readText(pathToTemplate);
    savePage(rootPath, rootPath ~ "interfaces\\index.html",
        page.dup.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string interfacesTable(Json[string] interfaces, string rootUrl) {
    return cardTable(interfacesTableHeader(), interfacesTableBody(interfaces, rootUrl));
}

string interfacesTableHeader() {
    return TR(
        TH("Name"),
        TH("Library"),
        TH("package"),
        TH("Implements"));
}

string interfacesTableBody(Json[string] interfaces, string rootUrl) {
    return interfaces is null ? null : interfaces.keys
        .sort
        .map!(key => interfaces[key])
        .map!(info => TR(`
                <td class="w-1"><a href="%sinterfaces/%s.html">%s</a></td>
                <td class="text-nowrap text-secondary w-1"><a href="%slibraries/%s.html">%s</a></td>
                <td class="text-nowrap text-secondary w-1"><a href="%spackages/%s.html">%s</a></td>
                <td class="text-secondary">%s</td>
            `).format(
                rootUrl,
                info.getString("name").lower,
                info.getString("name"),
                rootUrl,
                info.getString("library").lower,
                info.getString("library"),
                rootUrl,
                info.getString("package").lower,
                info.getString("package"),
                info.getArray("implements")
                .map!(json => json.to!string)
                .map!(value => value.startsWith("I")
                ? `<a href="%sinterfaces/` ~ value.lower ~ `.html">` ~ value ~ `</a>` : `<a href="%sclasses/` ~ value
                .lower ~ `.html">` ~ value ~ `</a>`)
                .map!(value => value.format(rootUrl))
                .join(", ")
        ))
        .join;
}
// #endregion overview

// #region page
void createInterfacePage(Json interface_, string rootPath, string rootUrl) {
    if (interface_ == Json(null))
        return;

    writeln("Creating interface_ page for ", interface_["name"], " in ", rootPath);
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = interface_.getString("namespace");
    if (namespace.length == 0)
        return;

    string name = interface_.getString("name");
    if (name.isEmpty)
        return;

    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Interfaces": "{{rooturl}}/api/interfaces"]
    ]);
    bindings["package"] = "";
    bindings["name"] = name;
    bindings["title"] = "Interface " ~ name;
    bindings["library"] = libraryName(namespace);
    bindings["package"] = packageName(namespace);
    bindings["namespace"] = namespace;
    bindings["modified"] = interface_.getString("lastModifiedDe");
    bindings["content"] =
        sectionDescription(interface_, "templates\\api\\interfaces\\" ~ interface_.getString(
                "name") ~ ".html") ~
        sectionPropertiesInInterface(
            interface_, rootUrl) ~
        sectionMethodsInInterface(
            interface_, rootUrl);

    string page = readText("templates\\interface.html");
    try {
        savePage(rootPath, rootPath.correctPath ~ "interfaces\\" ~ name ~ ".html", page, bindings);
    } catch (Exception e) {
        writeln(e);
    }
}

string sectionPropertiesInInterface(Json interface_, string rootUrl) {
    string properties =
        formControlPlaintext("Visibility", interface_.getString("visibility")) ~
        formControlPlaintext("Implements", interface_.getString("implements"));

    return interface_ == Json(null)
        ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Properties
                    </h3>
                    <p class="text-secondary">
                        {{properties}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("properties", properties);
}

string sectionMethodsInInterface(Json interface_, string rootUrl) {
    auto methods =
        interface_["methods"].byKeyValue
        .map!(item => TR(
                TD(checkbox("", item.value.getBoolean("isFinal"))),
                TD(item.value.getString("datatype")),
                TD(item.value.getString("header"))
        )).join;

    auto methodsTable =
        cardTable(TR(
                `<th class="w-1">Final</th>`,
                `<th class="w-1">Datatype</th>`,
                TH("Header")),
            methods);

    return interface_ == Json(null)
        ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Methods
                    </h3>
                    <p class="text-secondary">
                        {{methods}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("methods", methodsTable);
}
// #endregion page
// #endregion interfaces

// #region libraries
void createLibraryPages(Json[string] libraries, string rootPath, string rootUrl, Json[string] classes, Json[string] interfaces, Json[string] packages) {
    createLibraryOverview(libraries, rootPath, rootUrl);
    libraries.byKeyValue.each!(item => createLibraryPage(item.value, rootPath, rootUrl, classes, interfaces, packages));
}

// #region overview
void createLibraryOverview(Json[string] libraries, string rootPath, string rootUrl) {
    if (libraries is null)
        return;

    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string pathToTemplate = "templates\\overview.html";
    string page = readText(pathToTemplate);

    STRINGAA bindings;
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Libraries";
    bindings["posttitle"] = "Found " ~ to!string(libraries.keys.length) ~ " libraries";
    bindings["content"] = `<div class="col">` ~ cardTable(librariesTableHeader(), librariesTableBody(libraries, rootUrl)) ~ `</div>`;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"]
    ]);

    savePage(rootPath, rootPath ~ "libraries\\index.html",
        page.dup.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string librariesTable(Json[string] libraries, string rootUrl) {
    return libraries is null
        ? "" : cardTable(librariesTableHeader(), librariesTableBody(libraries, rootUrl));
}

string librariesTableHeader() {
    return TR(TH(`Name`), TH("Status"), TH("Short Description"));
}

string librariesTableBody(Json[string] libraries, string rootUrl) {
    return libraries is null
        ? "" : libraries.byKeyValue
        .map!(info => info.value)
        .array
        .sort!(`a["name"].get!string < b["name"].get!string`)
        .map!(info => TR(
                `<td class="text-nowrap w-1"><a href="%slibraries/%s.html">%s</a></td>`
                .format(
                rootUrl,
                info.getString("name").lower,
                info.getString("name"),
                ),
                TD(statusBadge(info.getString("name"))),
                TD(("templates\\libraries\\short-" ~ info.getString("name").lower ~ ".html").exists ? readText(
                "templates\\libraries\\short-" ~ info.getString("name").lower ~ ".html") : "")
        ))
        .join;
}
// #endregion overview

// #region page
void createLibraryPage(Json library, string rootPath, string rootUrl, Json[string] classes, Json[string] interfaces, Json[string] packages) {
    if (library == Json(null))
        return;

    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = library.getString("namespace");
    if (namespace.length == 0)
        return;

    string name = library.getString("name");
    if (name.isEmpty)
        return;

    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Libraries": "{{rooturl}}/api/libraries"]
    ]);
    bindings["name"] = name;
    bindings["package"] = "";
    bindings["library"] = libraryName(name);
    bindings["title"] = "Library " ~ name;

    bindings["content"] =
        sectionDescriptionOfLibrary(library, rootUrl) ~
        sectionPropertiesOfLibrary(library, rootUrl) ~
        classes.inLibrary(name)
        .sectionClassesInLibrary(rootUrl) ~
        interfaces.inLibrary(name)
        .sectionInterfacesInLibrary(rootUrl) ~
        packages.inLibrary(name)
        .sectionPackagesInLibrary(rootUrl);

    string page = readText("templates\\library.html");
    savePage(rootPath, rootPath ~ "libraries\\" ~ name ~ ".html",
        page.dup.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string sectionDescriptionOfLibrary(Json library, string rootUrl) {
    return sectionDescription(library, "templates\\api\\libraries\\" ~ library.getString(
            "name") ~ ".html");
}

string sectionPropertiesOfLibrary(Json library, string rootUrl) {
    if (library == Json(null))
        return null;

    string properties =
        formControlPlaintext("License", library.getString("license")) ~
        formControlPlaintext("Dependencies", library.getArray("dependencies")
                .map!(json => json.get!string).join(", "));

    return `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Properties
                    </h3>
                    <p class="text-secondary">
                        {{properties}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("properties", properties);
}

string sectionClassesInLibrary(Json[string] classes, string rootUrl) {
    return sectionClasses(classes, rootUrl);
}

string sectionInterfacesInLibrary(Json[string] interfaces, string rootUrl) {
    return sectionInterfaces(interfaces, rootUrl);
}

string sectionPackagesInLibrary(Json[string] packages, string rootUrl) {
    return sectionPackages(packages, rootUrl);
}
// #endregion page
// #endregion libraries

// #region packages
void createPackagePages(Json[string] packages, string rootPath, string rootUrl, Json[string] classes, Json[string] interfaces) {
    if (packages is null)
        return;

    createPackagesOverview(packages, rootPath, rootUrl);
    packages.byKeyValue.each!(item => createPackagePage(item.value, rootPath, rootUrl, classes, interfaces, packages));
}

// #region overview
void createPackagesOverview(Json[string] packages, string rootPath, string rootUrl) {
    if (packages is null)
        return;

    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    STRINGAA bindings;
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Packages";
    bindings["posttitle"] = "Found " ~ to!string(packages.keys.length) ~ " packages";
    bindings["content"] = `<div class="col">` ~ packagesTable(packages, rootUrl) ~ `</div>`;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"]
    ]);

    string pathToTemplate = "templates\\overview.html";
    string page = readText(pathToTemplate);
    savePage(rootPath, rootPath ~ "packages\\index.html",
        page.dup.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string packagesTable(Json[string] packages, string rootUrl) {
    return packages is null
        ? "" : cardTable(packagesTableHeader(), packagesTableBody(packages, rootUrl));
}

string packagesTableHeader() {
    return TR(
        TH("Name"),
        TH("Library"));
}

string packagesTableBody(Json[string] packages, string rootUrl) {
    rootUrl = rootUrl.correctUrl;

    return packages is null
        ? "" : packages.byKeyValue
        .map!(info => info.value)
        .array
        .sort!(`a["name"].get!string < b["name"].get!string`)
        .map!(info => TR(
                TD(["text-nowrap", "w-1"], "%s") ~
                TD(["text-nowrap", "text-secondary", "w-1"], "%s")
        ).format(
            A(rootUrl ~ "packages/" ~ info.getString("name")
                .lower ~ ".html", info.getString("name")),
            A(rootUrl ~ "libraries/" ~ info.getString("library")
                .lower ~ ".html", info.getString(
                "library")))
    )
        .join;
}
// #endregion overview

// #region page
void createPackagePage(Json package_, string rootPath, string rootUrl, Json[string] classes, Json[string] interfaces, Json[string] packages) {
    if (package_ == Json(null))
        return;

    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = package_.getString("namespace");
    if (namespace.length == 0)
        return;

    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Packages": "{{rooturl}}/api/packages"]
    ]);
    bindings["library"] = libraryName(namespace);
    bindings["package"] = namespace;

    string name = package_.getString("name");
    if (name.isEmpty)
        return;

    bindings["name"] = name;
    bindings["title"] = "Package " ~ name;

    bindings["content"] =
        sectionDescriptionOfPackage(package_, rootUrl) ~
        classes.inPackage(name)
        .sectionClassesInPackage(rootUrl) ~
        interfaces.inPackage(name)
        .sectionInterfacesInPackage(rootUrl) ~
        packages.inPackage(name)
        .sectionPackagesInPackage(rootUrl);

    string page = readText("templates\\package.html");
    savePage(rootPath, rootPath.correctPath ~ "packages\\" ~ name ~ ".html",
        page.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}

string sectionDescriptionOfPackage(Json package_, string rootUrl) {
    return sectionDescription(package_, "templates\\api\\packages\\" ~ package_.getString(
            "name") ~ ".html");
}

string sectionClassesInPackage(Json[string] classes, string rootUrl) {
    return sectionClasses(classes, rootUrl);
}

string sectionInterfacesInPackage(Json[string] interfaces, string rootUrl) {
    return sectionInterfaces(interfaces, rootUrl);
}

string sectionPackagesInPackage(Json[string] packages, string rootUrl) {
    return sectionPackages(packages, rootUrl);
}
// #endregion page
// #endregion packages

// #region registries
void createRegistryPages(DRegistries registries, string rootPath, string rootUrl) {
    createRegistryPages(registries.infos, rootPath, rootUrl);
}
void createRegistryPages(Json[string] registries, string rootPath, string rootUrl) {
    if (registries is null)
        return;

    createRegistriesOverview(registries, rootPath, rootUrl);
    registries.byKeyValue.each!(registry => createRegistryPage(registry.value, rootPath, rootUrl));
}
// #region overview
void createRegistriesOverview(Json[string] registries, string rootPath, string rootUrl) {
    if (registries is null) {
        return;
    }

    writeln("Creating overview for ", registries.length, " registries");
    rootPath = rootPath.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    STRINGAA bindings;
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Registries";
    bindings["posttitle"] = "Found " ~ to!string(registries.length) ~ " registries";
    bindings["content"] = `<div class="col">` ~ classesTable(registries, rootUrl, "registries") ~ `</div>`;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"]
    ]);

    savePage(rootPath, rootPath.correctPath ~ "registries\\index.html",
        overviewTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));

}
// #endregion overview
// #region page
void createRegistryPage(Json registry, string rootPath, string rootUrl) {
    if (registry == Json(null))
        return;

    writeln("Creating registry page for ", registry["name"], " in ", rootPath);
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = registry.getString("namespace");
    if (namespace.length == 0) {
        return;
    }

    string libraryName = libraryName(namespace);
    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"],
        ["Registries": "{{rooturl}}/api/registries"]
    ]);
    bindings["library"] = libraryName;
    bindings["package"] = namespace;

    string name = registry.getString("name");
    bindings["name"] = name.isEmpty ? "" : name;
    bindings["class"] = "Registry";
    bindings["title"] = "Registry " ~ name;
    bindings["modified"] = registry.getString("lastModifiedDe");
    bindings["content"] =
        sectionDescription(registry, "templates\\api\\registries\\" ~ registry.getString(
                "name") ~ ".html") ~
        sectionClassProperties(registry, rootUrl) ~
        sectionClassMethods(registry, rootUrl);

    savePage(rootPath, rootPath.correctPath ~ "registries\\" ~ name ~ ".html",
        classTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}
// #endregion page
// #endregion registries

// #region docs
void createDocPages(Json[string] docs, string rootPath, string rootUrl) {
    if (docs is null)
        return;

/*     createDocsOverview(docs, rootPath, rootUrl);
    docs.byKeyValue.each!(doc => createDocPage(doc.value, rootPath, rootUrl)); */
}
// #region overview
void createDocsOverview(DirEntry[] docFiles, string rootPath, string rootUrl) {
    if (docFiles is null) {
        return;
    }

    writeln("Creating overview for ", docFiles.length, " docs");
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;


    auto docInfos = docFiles.map!(docFile => Documents.create(docFile));
    STRINGAA bindings;
    bindings["pretitle"] = "Overview";
    bindings["title"] = "Documentation";
    bindings["posttitle"] = "Found " ~ to!string(docInfos.length) ~ " documents";
    // bindings["content"] = DIV(["col"], classesTable(docInfos, rootUrl, "docs"));
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"]
    ]);

    savePage(rootPath, rootPath.correctPath ~ "docs\\index.html",
        overviewTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));

}
// #endregion overview
// #region page
void createDocPage(Json doc, string rootPath, string rootUrl) {
    if (doc == Json(null))
        return;

    writeln("Creating doc page for ", doc["name"], " in ", rootPath);
    rootPath = rootPath.strip.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    string namespace = doc.getString("namespace");
    if (namespace.length == 0) {
        return;
    }

    STRINGAA bindings;
    string libraryName = libraryName(namespace);
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"], ["Docs": "{{rooturl}}/api/docs"]
    ]);
    bindings["library"] = libraryName;
    bindings["package"] = namespace;

    string name = doc.getString("name");
    bindings["name"] = name.isEmpty ? "" : name;
    bindings["class"] = "Doc";
    bindings["title"] = "Doc " ~ name;
    bindings["modified"] = doc.getString("lastModifiedDe");
    bindings["content"] =
        sectionDescription(doc, "templates\\api\\docs\\" ~ doc.getString(
                "name") ~ ".html") ~
        sectionClassProperties(doc, rootUrl) ~
        sectionClassMethods(doc, rootUrl);

    savePage(rootPath, rootPath.correctPath ~ "docs\\" ~ name ~ ".html",
        classTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}
// #endregion page
// #endregion docs

void createOverview(Json[string] classes, string rootPath, string rootUrl, string title, string category) {
    if (classes is null)
        return;

    writeln("Creating overview for ", classes.length, " " ~ category);
    rootPath = rootPath.lower.correctPath;
    rootUrl = rootUrl.correctUrl;

    STRINGAA bindings;
    bindings["breadcrumbs"] = breadcrumbs([
        ["Home": "{{rooturl}}"], ["API": "{{rooturl}}/api"],
        ["Classes": "{{rooturl}}/api/classes"]
    ]);
    bindings["pretitle"] = "Overview";
    bindings["title"] = title;
    bindings["posttitle"] = "Found " ~ to!string(classes.length) ~ " " ~ category;
    bindings["content"] = DIV(["col"], classesTable(classes, rootUrl, "classes"));

    savePage(rootPath, rootPath ~ category ~ "\\index.html",
        overviewTemplate.createHTMLPage(bindings)
            .createHTMLPage(bindings).createHTMLPage(bindings));
}