module lib.snippets;

import lib;

string[string] snippetCache;

string css() {
  return `<link href="{{rooturl}}/css/tabler.min.css" rel="stylesheet" />`;
}

string js() {
  return `<script src="{{rooturl}}/js/tabler.min.js"></script>`;
}

string headerFirst() {
  return readCache("headerFirst", "templates\\snippets\\headerfirst.html");
}

string headerSecond() {
  return readCache("headerSecond", "templates\\snippets\\headersecond.html");
}

string api() {
  return readCache("api", "templates\\snippets\\api.html");
}

string librariesNavItem() {
  string navitem = ``;

  navitem ~= `
    <li class="nav-item dropdown">
        <a class="nav-link dropdown-toggle show" href="#navbar-extra" data-bs-toggle="dropdown" data-bs-auto-close="outside" role="button" aria-expanded="true">
        <span class="nav-link-icon d-md-none d-lg-inline-block"><!-- Download SVG icon from http://tabler-icons.io/i/star -->
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon"><path stroke="none" d="M0 0h24v24H0z" fill="none"></path><path d="M12 17.75l-6.172 3.245l1.179 -6.873l-5 -4.867l6.9 -1l3.086 -6.253l3.086 6.253l6.9 1l-5 4.867l1.179 6.873z"></path></svg>
        </span>
        <span class="nav-link-title">
            Extra
        </span>
        </a>
        <div class="dropdown-menu show" data-bs-popper="static">
            <div class="dropdown-menu-columns">
                `
    ~ menuColumn1() ~ `
                `
    ~ menuColumn2() ~ `
            </div>
        </div>
    </li>    
    `;

  return navitem;
}

string menuColumn1() {
  return `
<div class="dropdown-menu-column">
    <a class="dropdown-item" href="./empty.html">
    Empty page
    </a>
    <a class="dropdown-item" href="./cookie-banner.html">
    Cookie banner
    </a>
    <a class="dropdown-item" href="./chat.html">
    Chat
    </a>
    <a class="dropdown-item" href="./activity.html">
    Activity
    </a>
    <a class="dropdown-item" href="./gallery.html">
    Gallery
    </a>
    <a class="dropdown-item" href="./invoice.html">
    Invoice
    </a>
    <a class="dropdown-item" href="./search-results.html">
    Search results
    </a>
    <a class="dropdown-item" href="./pricing.html">
    Pricing cards
    </a>
    <a class="dropdown-item" href="./pricing-table.html">
    Pricing table
    </a>
    <a class="dropdown-item" href="./faq.html">
    FAQ

    </a>
    <a class="dropdown-item" href="./users.html">
    Users
    </a>
    <a class="dropdown-item" href="./license.html">
    License
    </a>
</div>
`;
}

string menuColumn2() {
  return `
<div class="dropdown-menu-column">
    <a class="dropdown-item" href="./logs.html">
        Logs
        
    </a>
    <a class="dropdown-item" href="./music.html">
        Music
    </a>
    <a class="dropdown-item" href="./photogrid.html">
        Photogrid                              
    </a>
    <a class="dropdown-item" href="./tasks.html">
        Tasks
    </a>
    <a class="dropdown-item" href="./uptime.html">
        Uptime monitor
    </a>
    <a class="dropdown-item" href="./widgets.html">
        Widgets
    </a>
    <a class="dropdown-item" href="./wizard.html">
        Wizard
    </a>
    <a class="dropdown-item" href="./settings.html">
        Settings
    </a>
    <a class="dropdown-item" href="./trial-ended.html">
        Trial ended
    </a>
    <a class="dropdown-item" href="./job-listing.html">
        Job listing
    </a>
    <a class="dropdown-item" href="./page-loader.html">
        Page loader
    </a>
</div>
`;
}

string statusBadge(string name) {
  return `<a href="https://github.com/UIMSolutions/uim/actions/workflows/` ~ name ~ `.yml">
    <img src="https://github.com/UIMSolutions/uim/actions/workflows/`
    ~ name ~ `.yml/badge.svg" alt="D" style="max-width: 100%;"></a>`;
}

string sectionDescription(Json info, string sourceFile = null) {
  sourceFile = sourceFile.lower;
  return info == Json(null)
    ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Description
                    </h3>
                    <p class="text-secondary markdown">
                        {{description}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("description", comments(info, sourceFile));
}

string sectionPackages(Json[string] infos, string rootUrl) {
  rootUrl = rootUrl.lower;
  return infos is null
    ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Packages
                    </h3>
                    <p class="text-secondary">
                        {{packages}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("packages", infos.packagesTable(rootUrl));
}

string sectionInterfaces(Json[string] infos, string rootUrl) {
  rootUrl = rootUrl.lower;
  return infos is null
    ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Interface
                    </h3>
                    <p class="text-secondary">
                        {{interfaces}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("interfaces", infos.interfacesTable(rootUrl));
}

string sectionClasses(Json[string] infos, string rootUrl) {
  rootUrl = rootUrl.lower;
  return infos is null
    ? "" : `                    
    <div class="row align-items-center mw-100">
        <div class="col">
            <div class="card">
                <div class="card-body">
                    <h3 class="card-title">
                        Classes
                    </h3>
                    <p class="text-secondary">
                        {{classes}}
                    </p>
                </div>
            </div>
        </div>
    </div>
    `.doubleMustache("classes", classesTable(infos, rootUrl));
}

string sectionProperties(Json info, string rootUrl) {
  rootUrl = rootUrl.lower;
  if (info == Json(null))
    return null;

  string properties =
    (info.hasKey("visibility") ? formControlPlaintext("Visibility", info.getString("visibility"))
        : "") ~
    (info.hasKey("isAbstract") ? checkbox("Is Abstract", info.getBoolean("isAbstract")) : "") ~
    (info.hasKey("isFinal") ? checkbox("Is Final", info.getBoolean("isFinal")) : "") ~
    (info.hasKey("isStatic") ? checkbox("Is Static", info.getBoolean("isStatic")) : "") ~
    (info.hasKey("implements") ? formControlPlaintext("Implements", info.getString("implements"))
        : "") ~
    (info.hasKey("datatype") ? formControlPlaintext("Datatype", info.getString("datatype")) : "");

  /*     return info == Json(null)
        ? null : cardTable(
            TR(TH("Name"), TH("Value")),
            info.byKeyValue
                .map!(item => TR(TD(item.key), TD(item.value.to!string))).join());
 */

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

string cell(Json content, bool secondary = true, bool compact = true) {
  return cell(content.toString, secondary, compact);
}

string cell(long content, bool secondary = true, bool compact = true) {
  return cell(to!string(content), secondary, compact);
}

string cell(string content, bool secondary = true, bool compact = true) {
  return `<td class="` ~ (secondary ? "text-secondary" : "") ~ " " ~ (compact ? "w-1" : "") ~ `">%s</td>`.format(
    content);
}

string packagesCell(string rootUrl, string name, bool secondary = true) {
  return cell(A(rootUrl.correctUrl ~ "packages/" ~ name ~ ".html", name), secondary);
}

string libraryCell(string rootUrl, string name, bool secondary = true) {
  return cell(A(rootUrl.correctUrl ~ "libraries/" ~ name ~ ".html", name), secondary);
}

string comments(Json info, string sourceFile = null) {
  writeln("coments in ", sourceFile);
  if (!sourceFile.isNull && sourceFile.exists && sourceFile.isFile)
    return readText(sourceFile);

  return info == Json(null)
    ? "" : info.getArray("comments").map!(json => json.to!string).join(" ");
}

string navigation(string path = "templates\\snippets\\navigation.html") {
  return readCache("navigation", path);
}

string documentation(string path = "templates\\snippets\\documentation.html") {
  return readCache("documentation", path);
}

string community(string path = "templates\\snippets\\community.html") {
  return readCache("community", path);
}

string solutions(string path = "templates\\snippets\\solutions.html") {
  return readCache("solutions", path);
}

string services(string path = "templates\\snippets\\services.html") {
  return readCache("services", path);
}

string extensions(string path = "templates\\snippets\\extensions.html") {
  return readCache("extensions", path);
}

string about(string path = "templates\\snippets\\about.html") {
  return readCache("about", path);
}

string footer(string path = "templates\\snippets\\footer.html") {
  return readCache("footer", path);
}

// #region Dropdown Menues
string docItems() {
  return dropdownMenu("docitems", "templates\\documentation", "/documentation/");
}

string extItems() {
  return dropdownMenu("extitems", "templates\\extensions", "/extensions/");
}

string solItems() {
  return dropdownMenu("solitems", "templates\\solutions", "/solutions/");
}

string srvItems() {
  return dropdownMenu("srvitems", "templates\\services", "/services/");
}

string comItems() {
  return dropdownMenu("comitems", "templates\\community", "/community/");
}

string aboutItems() {
  return dropdownMenu("aboutitems", "templates\\about", "/about/");
}
// #endregion Dropdown Menues

string readHTMLParameter(DirEntry file, string parameter) {
  return file.isFile
    ? readHTMLParameter(file.name, parameter)
    : "";
}

string readHTMLParameter(string path, string parameter) {
  return path.isFile
    ? readHTMLParameter(readFileByLine(path), parameter)
    : "";
}

string readHTMLParameter(string[] lines, string parameter) {
  foreach (line; lines) {
    line = line.strip;
    if (line.startsWith("<!-- " ~ parameter ~ ":")) {
      return line.replace("<!-- " ~ parameter ~ ":", "").replace("-->", "").strip;
    }
  }
  return null;
}

string breadcrumbs(STRINGAA[] items) {
  return `<ol class="breadcrumb breadcrumb-dots" aria-label="breadcrumbs">`
    ~
    items.map!(
      item => `<li class="breadcrumb-item"><a href="` ~ item[item.keys[0]] ~ `">` ~ item.keys[0] ~ `</a></li>`).join
    ~
    "</ol>";
}

string classTemplate(string path = "templates\\class.html") {
  return readCache(path, path);
}

string overviewTemplate(string path = "templates\\overview.html") {
  return readCache(path, path);
}

string docTemplate(string path = "templates\\documentation.html") {
  return readCache(path, path);
}

string readCache(string key, string path = null) {
  if (key in snippetCache) {
    return snippetCache[key];
  }

  snippetCache[key] = !path.isEmpty && path.exists
    ? path.readText : "";

  return snippetCache[key];
}

string dropdownItem(string url, string title) {
  return A(["dropdown-item"], "{{rooturl}}"~url, title);
}

string docCards(DirEntry[] files) {
	auto cards = files
		.filter!(file => file.isFile && file.name.endsWith(".html"))
		.map!(file => docCard(file))
    .join;

  return DIV(["row", "row-cards"], cards);
}

string docCard(DirEntry file) {
return DIV(["col-md-6", "col-lg-3"],
  DIV(["card"],
    DIV(["card-header"], H3(["card-title"], 
      A("{{rooturl}}/documentation/"~file.name.split("\\")[$-1..$].join, readHTMLParameter(file.name, "Title"))))~
    DIV(["card-body"], readHTMLParameter(file.name, "Summary"))
  ));
}

string dropdownMenu(string name, string path, string url) {
  if (name in snippetCache) {
    return snippetCache[name];
  }

  auto files = getFilesNamesInPath(path)
    .filter!(name => name.isFile)
    .filter!(name => name.endsWith(".html"))
    .array;

  string[] items;
  foreach (file; files) {
    auto content = readFileByLine(file);
    string navtitle = content.readHTMLParameter("Navtitle");
    items ~= dropdownItem(url ~ file.split("\\")[$ - 1 .. $].join, navtitle);
  }

  snippetCache[name] = items.join();
  return snippetCache[name];
}
// #endregion aboutItems
