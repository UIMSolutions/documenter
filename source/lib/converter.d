module lib.converter;

import lib;
 

string markdownToHtml(string[] lines) {
    return lines.map!(line => markdownLineToHtml(line)).join;
}

string markdownLineToHtml(string line) {
    line = line.strip;
    if (line.startsWith("# ")) {
        return "<h1>" ~ line[2 .. $].strip ~ "</h1>";
    }

    if (line.startsWith("## ")) {
        return "<h2>" ~ line[3 .. $].strip ~ "</h2>";
    }

    if (line.startsWith("### ")) {
        return "<h3>" ~ line[4 .. $].strip ~ "</h3>";
    }

    if (line.startsWith("#### ")) {
        return "<h4>" ~ line[5 .. $].strip ~ "</h4>";
    }

    if (line.startsWith("##### ")) {
        return "<h5>" ~ line[6 .. $].strip ~ "</h5>";
    }

    if (line.startsWith("###### ")) {
        return "<h6>" ~ line[7 .. $].strip ~ "</h6>";
    }

    if (line.startsWith("1. ")) {
        return "<li>" ~ line[2 .. $].strip ~ "</li>";
    }

    if (line.startsWith("2. ")) {
        return "<li>" ~ line[2 .. $].strip ~ "</li>";
    }

    if (line.startsWith("- ")) {
        return "<li>" ~ line[2 .. $].strip ~ "</li>";
    }

    if (line.startsWith("![")) {
        // ![Tux, the Linux mascot](/assets/images/tux.png)
    }

    if (line.startsWith("`")) {
        // ![Tux, the Linux mascot](/assets/images/tux.png)
    }

    return "<p>" ~ line ~ "</p>";
}
