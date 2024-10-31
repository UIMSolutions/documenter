import vibe.vibe;
import std.stdio;
import std.file;
import std.algorithm;
import std.range;
import std.string;

import uim.core;
import uim.oop;

import lib;

void init() {
	docsPath = documenterPath ~ "\\docs";
	templatePath = documenterPath ~ "\\templates";
}

string projectsRootPath = "C:\\Users\\ONS\\PROJECTS2023\\uim";
string targetPath = "C:\\Users\\ONS\\PROJECTS2023\\uim\\docs";
string projectsPath = "C:\\Users\\ONS\\PROJECTS2023\\uim";

string documenterPath = "C:\\Users\\ONS\\PROJECTS2023\\documenter";
string docsPath = "C:\\Users\\ONS\\PROJECTS2023\\documenter\\docs";
string templatePath;

string rootUrl = `https://uimsolutions.github.io/uim`;

void main() {
	init;
	// prettyDFilesInPath(projectsPath);

	readSdlFiles(projectsPath);
	Libraries.save;

	readDFiles(projectsPath);
	Files.save;
	Interfaces.save;
	Modules.save;
	Packages.save;
	Classes.save;

	Classes.infos.byKeyValue
		.each!((info) {
			string name = info.value.getString("name");
			if (name.endsWith("Attribute")) {
				Attributes.set(info.key, info.value);
			} else if (name.endsWith("Element")) {
				Elements.set(info.key, info.value);
			} else if (name.endsWith("Error")) {
				Errors.set(info.key, info.value);
			} else if (name.endsWith("Exception")) {
				Exceptions.set(info.key, info.value);
			} else if (name.endsWith("Factory")) {
				Factories.set(info.key, info.value);
			} else if (name.endsWith("Registry")) {
				Registries.set(info.key, info.value);
			} else if (name.endsWith("Entity")) {
				Entities.set(info.key, info.value);
			}
		});

	writeln("Saving data files");
	Attributes.save;
	Elements.save;
	Entities.save;
	Errors.save;
	Exceptions.save;
	Factories.save;
	Registries.save;

	Findings.save;

	/* 	foreach (key, value; files.byKeyValue) {
		string namespace = value["namespace"].get!string;
		tree.addNamespace(namespace);
	}
	createDirectories(tree, docsPath ~ "\\api");
	tree.save("tree.json");
 */
/*  	foreach (key, value; Files.infos.byKeyValue) {
		if (value == Json(null))
			continue;

		string namespace = value.getString("namespace");
		if (namespace.length == 0)
			continue;

		string type = value.getString("type");
		STRINGAA bindings;
		bindings["type"] = type;
		if (type.isEmpty)
			continue;

		string content = "";
		string page = readText("templates\\" ~ type ~ ".html");
		bindings["package"] = "";
		bindings["library"] = "";
		bindings["title"] = "";
		bindings["breadcrumbs"] = "";
		switch (bindings["type"]) {
		case "class":
			string text = "<table>";
			foreach (k, v; value.byKeyValue)
				text ~= "<tr><td>" ~ k ~ ":" ~ v.to!string ~ "</td></tr>";
			text ~= "</table>";
			break;
		default:
			break;
		}
		bindings["library"] = libraryName(namespace);
		bindings["package"] = namespace;
		bindings["title"] = type.capitalize ~ " " ~ value.getString("name");
		bindings["breadcrumbs"] = createBreadcrumbs(rootUrl ~ "/api", namespace);
		bindings["navigation"] = navigation;
		bindings["footer"] = footer;
		bindings["libraries"] = files.createLibraryNavigation(
			rootUrl ~ "/api");

		string newPath = namespaceToPath(
			docsPath ~ "\\api\\libraries", namespace);
		/* 		savePage(newPath, newPath ~ "\\index.html", 
			page.createHTMLPage(bindings).createHTMLPage(bindings).createHTMLPage(bindings)); * /
		// page = readText("templates\\libraries.html"); * /
	}
 */
	writeln("HTML Generation...");
	getFilesInPath(templatePath, ".html")
		.each!(file => savePage(file.name.replace(templatePath, docsPath), readText(file)));

	// #region Documentation pages
	writeln("Creating Documentation pages...");
	auto docFiles = getFilesInPath(templatePath ~ "\\documentation", ".html");

	savePage(
		docsPath.correctPath ~ "documentation\\index.html",
		docTemplate(templatePath ~ "\\overview.html"),
		[
			"breadcrumbs": breadcrumbs([["Home": "{{rooturl}}"]]),
			"title": readHTMLParameter(templatePath ~ "\\overview.html", "Documentation"),
			"content": "docTable(docFiles)"
		]);

	foreach (file; docFiles) { // for every doc
		string content = readText(file.name);
		savePage(
			file.name.replace(templatePath, docsPath),
			docTemplate(templatePath ~ "\\documentation.html"),
			[
				"breadcrumbs": breadcrumbs([
					["Home": "{{rooturl}}"],
					["Documentation": "{{rooturl}}/documentation"]
				]),
				"title": readHTMLParameter(file.name, "Title"),
				"modified": file.name.timeLastModified.toTimestamp.germanDate,
				"content": content,
			]);
	}
	// #endregion Documentation pages

	// #region Community pages
	writeln("Creating community pages...");
	auto comFiles = getFilesInPath(templatePath ~ "\\community", ".html");

	savePage(
		docsPath.correctPath ~ "community\\index.html",
		docTemplate(templatePath ~ "\\overview.html"),
		[
			"breadcrumbs": breadcrumbs([["Home": "{{rooturl}}"]]),
			"title": readHTMLParameter(templatePath ~ "\\overview.html", "community"),
			"content": docCards(comFiles)
		]);

	foreach (file; comFiles) { // for every doc
		string content = readText(file.name);
		savePage(
			file.name.replace(templatePath, docsPath),
			docTemplate(templatePath ~ "\\community.html"),
			[
				"breadcrumbs": breadcrumbs([
					["Home": "{{rooturl}}"], [
						"Community": "{{rooturl}}/community"
					]
				]),
				"title": readHTMLParameter(file.name, "Title"),
				"modified": file.name.timeLastModified.toTimestamp.germanDate,
				"content": content,
			]);
	}
	// #endregion Community pages

	// #region About pages
	writeln("Creating about pages...");
	auto aboutFiles = getFilesInPath(templatePath ~ "\\about", ".html");

	savePage(
		docsPath.correctPath ~ "about\\index.html",
		docTemplate(templatePath ~ "\\overview.html"),
		[
			"breadcrumbs": breadcrumbs([["Home": "{{rooturl}}"]]),
			"title": readHTMLParameter(templatePath ~ "\\overview.html", "about"),
			"content": docCards(aboutFiles)
		]);

	foreach (file; aboutFiles) { // for every doc
		string content = readText(file.name);
		savePage(
			file.name.replace(templatePath, docsPath),
			docTemplate(templatePath ~ "\\about.html"),
			[
				"breadcrumbs": breadcrumbs([
					["Home": "{{rooturl}}"], ["About": "{{rooturl}}/about"]
				]),
				"title": readHTMLParameter(file.name, "Title"),
				"modified": file.name.timeLastModified.toTimestamp.germanDate,
				"content": content,
			]);
	}
	// #endregion About pages

	string apiPath = docsPath.correctPath ~ "api\\";
	string apiUrl = rootUrl.correctUrl ~ "api/";

	writeln("Create folders...");
	[
		"attributes", "classes", "elements", "entities", "errors", "exceptions",
		"factories", "interfaces",
		"libraries", "modules", "packages", "registries"
	].each!(
		(folder) {
		try {
			(apiPath ~ folder).mkdirRecurse;
		} catch (Exception e) {
			writeln("no newPath ", (apiPath ~ folder));
		}
	});

	writeln("Create pages...");
	try {
		auto classes = Classes.infos;
		auto interfaces = Interfaces.infos;
		Attributes.infos.createAttributePages(apiPath, apiUrl);
		Classes.infos.createClassPages(apiPath, apiUrl);
		Elements.infos.createErrorPages(apiPath, apiUrl);
		Entities.infos.createErrorPages(apiPath, apiUrl);
		Errors.infos.createErrorPages(apiPath, apiUrl);
		Exceptions.infos.createExceptionPages(apiPath, apiUrl);
		Factories.infos.createFactoryPages(apiPath, apiUrl);
		Interfaces.infos.createInterfacePages(apiPath, apiUrl);
		Libraries.infos.createLibraryPages(apiPath, apiUrl, classes, interfaces, Packages.infos);
		Packages.infos.createPackagePages(apiPath, apiUrl, classes, interfaces);
		Registries.infos.createRegistryPages(apiPath, apiUrl);

	} catch (Exception e) {
		writeln(e);
	}
	copyDirectory(docsPath, targetPath);
}
