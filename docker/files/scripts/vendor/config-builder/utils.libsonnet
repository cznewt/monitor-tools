{
  // lower-case, spaces and any character outside [a-z0-9_-] become '-', runs
  // of '-' collapse, leading/trailing '-' trimmed: 'CI/CD' -> 'ci-cd',
  // 'Platform (observ-viz)' -> 'platform-observ-viz'. (std.strReplace is a
  // literal replace, so the character class has to be applied per char.)
  slugify(str)::
    local allowed = 'abcdefghijklmnopqrstuvwxyz0123456789_-';
    local mapped = std.join('', [if std.member(allowed, c) then c else '-' for c in std.stringChars(std.asciiLower(str))]);
    local collapsed = std.foldl(function(acc, c) if c == '-' && std.endsWith(acc, '-') then acc else acc + c, std.stringChars(mapped), '');
    std.stripChars(collapsed, '-'),

  // a Grafana uid: 1-40 chars of [A-Za-z0-9_-].
  validUid(uid)::
    local allowed = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';
    std.isString(uid) && std.length(uid) > 0 && std.length(uid) <= 40
    && std.all([std.member(allowed, c) for c in std.stringChars(uid)]),
}
