
{
  slugify(str)::
      local toLower = std.asciiLower(str);
      local replaceSpaces = std.strReplace(toLower, ' ', '-');
      local removeSpecial = std.strReplace(replaceSpaces, '[^a-z0-9-]', '');
      local cleanDashes = std.strReplace(removeSpecial, '--+', '-');
      local trimDashes = std.stripChars(cleanDashes, '-');
      trimDashes
}
