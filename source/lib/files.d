module lib.files;

import lib;

bool copyDirectory(string sourcePath, string targetPath) {
  sourcePath = sourcePath.correctPath;
  targetPath = targetPath.correctPath;
  foreach (string name; dirEntries(sourcePath, SpanMode.depth)) {
    if (name.startsWith("."))
      continue;

    try {
      auto target = name.replace(sourcePath, targetPath);
      if (name.isDir)
        target.mkdirRecurse;
    } catch (Exception e) {
      writeln(e.message);
    }
  }

  foreach (string name; dirEntries(sourcePath, SpanMode.depth)) {
    if (name.startsWith("."))
      continue;

    try {
      auto target = name.replace(sourcePath, targetPath);
      if (name.isFile)
        name.copy(target);
    } catch (Exception e) {
      writeln(e.message);
    }
  }
  return true;
}

string[] namesOfDFilesInPath(string path) {
  return getFilesNamesInPath(path)
    .filter!(name => name.endsWith(".d"))
    .array;
}

string[] readFileLines(string filename) {
  return File(filename).byLine()
    .map!(line => to!string(line))
    .array;
}

string[] readFileByLine(string filename) {
  string[] fileContent = readFileLines(filename)
    .map!(line => to!string(line).replace("\r", "\n")).array;

  string[] results;
  fileContent
    .each!(line => results ~= line.split("\n"));

  return results
    .map!(line => line.stripRight)
    .filter!(line => line.length > 0)
    .array;
}

auto getFilesInPath(string path) {
  return dirEntries(path, SpanMode.depth)
    .filter!(dirEntry => dirEntry.isFile).array;
}

auto getFilesInPath(string path, string extension) {
  return getFilesInPath(path)
    .filter!(dirEntry => dirEntry.name.endsWith(extension))
    .array;
}

auto getFilesNamesInPath(string path) {
  return getFilesInPath(path)
    .map!(dirEntry => dirEntry.name).array;
}

auto getFilesNamesInPath(string path, string extension) {
  return getFilesInPath(path, extension)
    .map!(dirEntry => dirEntry.name).array;
}

auto getFilesEndsWithInPath(string path, string endText) {
  return dirEntries(path, SpanMode.depth)
    .filter!(dirEntry => dirEntry.isFile && dirEntry.name.endsWith(endText)).array;
}

auto getDirsInPath(string path) {
  return dirEntries(path, SpanMode.depth)
    .filter!(dirEntry => dirEntry.isDir).array;
}

auto getSubPathsInPath(string path) {
  return getDirsInPath(path)
    .map!(dirEntry => dirEntry.name).array;
}

bool writeFileContent(string path, string[] content) {
  auto output = File(path, "w");
  content.each!(line => output.write(line));
  output.close;

  return true;
}

void save(Json json, string path) {
  auto output = File(path.lower, "w");
  output.writeln(json.toPrettyString);
  output.close;
}

string namespaceToPath(string rootPath, string namespace) {
  rootPath = rootPath.correctPath.lower;

  auto items = namespace.strip.split(".");
  auto path = items.length > 2
    ? items[0 .. 2].join("-") ~ "\\" ~ items[2 .. $].join("\\") : items.join("-");

  return rootPath ~ path;
}

void saveFile(string newPath, string filename, string content) {
  try {
    newPath.mkdirRecurse;
  } catch (Exception e) {
    writeln("no newPath ", newPath);
  }
  try {
    if (filename.length > 0) {
      // writeln("Creating file -> ", filename);
      std.file.write(filename, content); /* page.createHTMLPage(bindings)
          .createHTMLPage(bindings).createHTMLPage(bindings)); */
    }
  } catch (Exception e) {
    writeln("no ", filename);
  }
}

void savePage(string filename, string content, STRINGAA contentBindings = null) {
  auto path = filename;
  if (path.contains(".")) {
    path = path.split("\\")[0 .. $ - 1].join("\\");
  }
  savePage(path, filename, content, contentBindings);
}

void savePage(string newPath, string filename, string content, STRINGAA contentBindings = null) {
  content = content.createHTMLPage(contentBindings)
    .createHTMLPage(contentBindings).createHTMLPage(contentBindings);

  newPath = newPath.lower;
  filename = filename.lower;
  try {
    newPath.mkdirRecurse;
  } catch (Exception e) {
    writeln(e);
  }
  try {
    if (filename.length == 0)
      return;

    if (filename.startsWith([".", "-", "@", "/", "\\", "*"]))
      return;

    if (filename.endsWith(".html")) {
      STRINGAA bindings =
        [
          "headerfirst": headerFirst(),
          "headersecond": headerSecond(),
          "css": css(),
          "js": js(),
          "api": api(),
          "navigation": navigation(),
          "aboutitems": aboutItems(),
          "about": about(),
          "docitems": docItems(),
          "documentation": documentation(),
          "comitems": comItems(),
          "community": community(),
          "solitems": solItems(),
          "solutions": solutions(),
          "solitems": solItems(),
          "solutions": solutions(),
          "extItems": extItems(),
          "extensions": extensions(),
          "srvItems": srvItems(),
          "services": services(),
          "footer": footer(),
          "rooturl": "https://uimsolutions.github.io/uim"
        ];

      contentBindings.byKeyValue.each!(item => bindings[item.key] = item.value);

      std.file.write(filename,
        content.doubleMustache(bindings)
          .doubleMustache(bindings).doubleMustache(bindings));
    }
  } catch (Exception e) {
    writeln(e);
  }
}

// #region isModuleFile
bool isModuleFile(DirEntry file) {
  return isModuleFile(file.name);
}

bool isModuleFile(string path) {
  return path.isFile && isModuleFile(readFileLines(path));
}

bool isModuleFile(string[] lines) {
  return lines
    .any!(line => line.startsWith("module "));
}
// #endregion isModuleFile

// #region isPackageFile
bool isPackageFile(DirEntry file) {
  return isPackageFile(file.name);
}

bool isPackageFile(string filename) {
  return filename.endsWith("package.d");
}
// #endregion isPackageFile

// #region isClassFile
bool isClassFile(DirEntry file) {
  return isClassFile(file.name);
}

bool isClassFile(string path) {
  return path.isFile && isClassFile(readFileLines(path));
}

bool isClassFile(string[] lines) {
  return lines
    .any!(line => to!string(line).isClass);
}
// #endregion isClassFile

// #region isInterfaceFile
bool isInterfaceFile(DirEntry file) {
  return isInterfaceFile(file.name);
}

bool isInterfaceFile(string path) {
  return path.isFile && isInterfaceFile(readFileLines(path));
}

bool isInterfaceFile(string[] lines) {
  return lines
    .any!(line => to!string(line).isInterface);
}
// #endregion isInterfaceFile
