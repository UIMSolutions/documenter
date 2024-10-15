module lib.prettier;

import lib;
 

string[] header =
  [
    `/****************************************************************************************************************`,
    `* Copyright: © 2017-2024 Ozan Nurettin Süel (aka UIManufaktur)                                                  *`,
    `* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.         *`,
    `* Authors: Ozan Nurettin Süel (aka UIManufaktur)                                                                *`,
    `*****************************************************************************************************************/`,
    ``
  ];

bool prettyDFilesInPath(string path) {
  string[] fileNames = namesOfDFilesInPath(path);
  fileNames.each!(name => prettyDFile(name));
  return true;
}

bool prettyDFile(string path) {
  auto fileContent = readFileLines(path);
  fileContent = fileContent.replaceTabsWithSpace;

  auto posPackage = posModuleName(fileContent);
  if (posPackage < 1000) {
    fileContent = [header.join("\n")] ~
      (posPackage == 0
          ? fileContent : fileContent[posPackage .. $]);

    writeFileContent(path, fileContent);
  }
  return true;
}

string[] replaceTabsWithSpace(string[] lines) {
  return lines
    .map!(line => line.replace("\t", "  "))
    .array;
}

bool isAbstract(string line) {
  return line.values.hasValue("abstract");
}

bool isClass(string[] lines) {
  return lines.any!(line => line.isClass);
}

bool isClass(string line) {
  line = line.strip;
  return line.startsWith(["//", "/*", "*", "@", "-"])
    ? false
    : line.values.hasValue("class");
}

bool isFinal(string line) {
  return line.values.hasValue("final");
}

bool isProtected(string line) {
  return line.values.hasValue("protected");
}

bool isInterface(string[] lines) {
  return lines.any!(line => line.isInterface);
}

bool isInterface(string line) {
  line = line.strip;
  return line.startsWith(["//", "/*", "*", "@", "-"])
    ? false
    : line.values.hasValue("interface");
}

bool isString(string line) {
  return line.values.hasValue("string");
}

bool isVoid(string line) {
  return line.values.hasValue("void");
}
