module lib.html;

import lib;

// #region namespaceToUrl
string namespaceToUrl(string rootUrl, string namespace) {
    auto items = namespace.strip.split(".");
    if (items.length < 2)
        return null;

    auto postUrl = items[0 .. 2].join("-");
    if (items.length > 2)
        postUrl ~= "/" ~ items[2 .. $].join("/");
    return rootUrl.correctUrl ~ postUrl;
}

unittest {
    assert(namespaceToUrl("http://root", "a.b.c.d") == "http://root/a-b/c/d");
    assert(namespaceToUrl("http://root", "a.b") == "http://root/a-b");

    assert(namespaceToUrl("http://root/", "a.b.c.d") == "http://root/a-b/c/d");
    assert(namespaceToUrl("http://root/", "a.b") == "http://root/a-b");
}
// #endregion namespaceToUrl

// #region libraryNavigation
string createLibraryNavigation(Json infos, string rootUrl) {
    rootUrl = rootUrl.correctUrl;

    string[string] libraries;
    infos.byKeyValue
        .map!(item => item.value)
        .filter!(info => info != Json(null))
        .map!(info => info.getString("namespace"))
        .filter!(namespace => !namespace.isEmpty)
        .each!((namespace) {
            if (namespace.split(".").length == 2) {
                auto libraryName = namespace.replace(".", "-");
                libraries[libraryName] = namespaceToUrl(rootUrl ~ "api/libraries/", namespace).correctUrl ~ "index.html";
            }
        });

    return libraries.keys.sort
        .map!(key => LI(`<a class="dropdown-item" href="` ~ libraries[key] ~ `">` ~ key ~ `</a>`))
        .join;
}
// #endregion libraryNavigation

string createHTMLPage(string source, STRINGAA bindings) {
    return source.doubleMustache(bindings).doubleMustache(bindings).doubleMustache(bindings);
}

string createBreadcrumbs(string rootUrl, string namespace) {
    rootUrl = rootUrl.correctUrl;

    string[] items = namespace.split(".");
    string result = `<ol aria-label="breadcrumbs" class="breadcrumb">`
        ~ breadcrumbItem(A(rootUrl ~ "index.html", "api"));
    rootUrl ~= "libraries/";
    result ~= breadcrumbItem(A(rootUrl ~ "index.html", "libraries"));
    if (items.length == 2) {
        result ~= breadcrumbItem(libraryName(namespace), true);
    }
    if (items.length > 2) {
        result ~= breadcrumbItem(A(libraryUrl(rootUrl, namespace) ~ `/index.html`, items[0 .. 2].join(
                "-")));
        items[2 .. $].each!((i, item) {
            auto url = namespaceToUrl(rootUrl, items[0 .. 3 + i].join(".")).correctUrl;
            result ~= item != items[$ - 1]
                ? breadcrumbItem(A(url ~ `index.html`, item)) : breadcrumbItem(item, true);
        });
    }
    result ~= `</ol>`;
    return result;
}

string libraryUrl(string rootUrl, string namespace) {
    return rootUrl.correctUrl ~ libraryName(namespace);
}

string libraryCards(Json infos) {
    return DIV(["row", "row-cards"],
        infos.byKeyValue
            .map!(item => item.value)
            .map!(info =>
                DIV(["col-md-6", "col-lg-3"],
                DIV(["card"],
                DIV(["card-header"],
                H3(["card-title"], "%s")
                ) ~
                DIV(["card-body"],
                "Simple card"
                )
                )
            ).format(info.getString("library")))
        .join
    );
}

// #endregion libraries

string cardTable(string header, string content) {
    return DIV(["card"],
        DIV(["table-responsive"],
            TABLE(THEAD(header) ~ TBODY(content))
        )
    );
}

// #region LI
string LI(string[] content...) {
    return LI(content.dup);
}

string LI(string[] content) {
    return `<li>` ~ content.join ~ `</li>`;
}
// #endregion LI

// #region A
string A(string href, string content) {
    return A(null, href, content);
}

string A(string href, string[] content) {
    return A(null, href, content.join);
}

string A(string[] classes, string href, string[] content) {
    return A(classes, href, content.join);
}

string A(string[] classes, string href, string content) {
    return `<a`~(classes.isEmpty ? null : ` class="%s"`.format(classes.join(" ")))~` href="` ~ href ~ `">` ~ content ~ `</a>`;
}
// #endregion A

// #region TABLE
string TABLE(string[] content...) {
    return TABLE(content.dup);
}

string TABLE(string[] content) {
    return `<table class="table card-table">` ~ content.join ~ `</table>`;
}

string TABLE(string[] classes, string content) {
    return !classes.isEmpty
        ? `<table class="` ~ classes.join(
            " ") ~ `">` ~ content ~ `</table>` : `<table>` ~ content ~ `</table>`;
}
// #endregion TABLE

// #region TBODY
string TBODY(string[] content...) {
    return TBODY(content.dup);
}

string TBODY(string[] content) {
    return `<tbody>` ~ content.join ~ `</tbody>`;
}
// #endregion TBODY

// #region THEAD
string THEAD(string[] content...) {
    return THEAD(content.dup);
}

string THEAD(string[] content) {
    return `<thead>` ~ content.join ~ `</thead>`;
}
// #endregion THEAD

// #region TH
string TH(string[] content...) {
    return TH(content.dup);
}

string TH(string[] content) {
    return `<th>` ~ content.join ~ `</th>`;
}

string TH(string[] classes, string content) {
    return !classes.isEmpty
        ? `<th class="` ~ classes.join(
            " ") ~ "\">" ~ content ~ `</th>` : TH(content);
}
// #endregion TH

// #region TR
string TR(string[] content...) {
    return TR(content.dup);
}

string TR(string[] content) {
    return `<tr>` ~ content.join ~ `</tr>`;
}
// #endregion TR

// #region TD
string TD(string[] content...) {
    return TD(content.dup);
}

string TD(string[] content) {
    return `<td>` ~ content.join ~ `</td>`;
}

string TD(string[] classes, string content) {
    return !classes.isEmpty
        ? `<td class="` ~ classes.join(
            " ") ~ "\">" ~ content ~ `</td>` : `<td>` ~ content ~ `</td>`;
}
// #endregion TD

// #region H3
string H3(string[] content...) {
    return H3(content.dup);
}

string H3(string[] content) {
    return `<h3>` ~ content.join ~ `</h3>`;
}

string H3(string[] classes, string content) {
    return !classes.isEmpty
        ? `<h3 class="` ~ classes.join(
            " ") ~ "\">" ~ content ~ `</h3>` : `<h3>` ~ content ~ `</h3>`;
}
// #endregion H3

string formLabel(string name) {
    return `<label class="form-label">%s</label>`.format(name);
}

string DIV(string[] classes, string content) {
    return !classes.isEmpty
        ? `<div class="` ~ classes.join(
            " ") ~ `"\">` ~ content ~ `</div>` : `<div>` ~ content ~ `</div>`;
}

string formControlPlaintext(string text) {
    return DIV(["form-control-plaintext"], text);
}

string checkForm(bool checked, string text = null) {
    return `
        <input class="form-check-input" type="checkbox" `
        ~ checked ? `checked` : `checked=""` ~ `>
        <span class="form-check-label">`
        ~ text ~ `</span>    `;
}

string formControlPlaintext(string label, string value) {
    return `<div class="mb-3">
        <label class="form-label">`
        ~ label ~ `</label>
        <input type="text" class="form-control" name="example-text-input" readonly="" value="`
        ~ value ~ `">
    </div>`;
}

string checkbox(string label, bool value) {
    return label.isEmpty
        ? `<input class="form-check-input" type="checkbox"%s>`.format(value ? "checked=\"true\""
                : "") : `
    <label class="form-check">
        <input class="form-check-input" type="checkbox"%s>
        <span class="form-check-label">%s</span>
    </label>`.format(value ? "checked=\"true\"" : "", label);
}

// #region breadcrumb-item
string breadcrumbItem(string content, bool active = false) {
    return active
        ? `<li class="breadcrumb-item active" aria-current="page">%s</a>`.format(
            content) : `<li class="breadcrumb-item">%s</a>`.format(content);
}
// #endregion breadcrumb-item
