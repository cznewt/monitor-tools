"""mkdocs-gen-files hook.

Builds the documentation pages at `mkdocs build` time from the rendered
monitor-tools output:

  * Runbooks       <- /mixins/*/runbooks/*.md and /source/*/mixins/*/runbooks/*.md
                      (this includes any runbooks dropped in before the build,
                      e.g. a clone of prometheus-operator/runbooks restructured
                      into /mixins/<group>/runbooks/<Alert>.md)
  * Alert catalog  <- /build/*/mimirtool/mimir-rules/*.yaml  (rendered ruler rules)
                      each alert deep-links to its self-hosted runbook when the
                      alert name matches a runbook page, else to the upstream
                      runbook_url annotation.
  * Inventory      <- the active config files in $CONFIG_DIR

Run `render-all-resources` first so /build is populated.
"""
import glob
import os

import mkdocs_gen_files
import yaml

nav = mkdocs_gen_files.Nav()
nav["Home"] = "index.md"


def esc(s):
    return (s or "").replace("|", "\\|").replace("\n", " ").strip()


# ---- Runbooks -> pages + an alert-name -> local-page map ----
runbook_pages = {}   # AlertName -> "runbooks/<group>/<AlertName>.md"
seen = set()
for rb in sorted(glob.glob("/mixins/*/runbooks/*.md") + glob.glob("/source/*/mixins/*/runbooks/*.md")):
    name = os.path.basename(rb)[:-3]
    if name.startswith("_"):          # skip Hugo _index.md section files
        continue
    try:
        group = rb.split("/mixins/")[1].split("/")[0].replace("-mixin", "")
    except Exception:
        continue
    if (group, name) in seen:
        continue
    seen.add((group, name))
    path = f"runbooks/{group}/{name}.md"
    with mkdocs_gen_files.open(path, "w") as f:
        f.write(open(rb).read())
    nav["Runbooks", group, name] = path
    runbook_pages.setdefault(name, path)   # first match wins

# ---- Alert catalog (deep-link to the local runbook when we have one) ----
alerts = {}
for rf in sorted(glob.glob("/build/*/mimirtool/mimir-rules/*.yaml")):
    mixin = os.path.basename(rf)[:-5]
    try:
        doc = yaml.safe_load(open(rf)) or {}
    except Exception:
        continue
    for g in doc.get("groups", []):
        for r in g.get("rules", []):
            if "alert" not in r:
                continue
            lab, ann = r.get("labels", {}), r.get("annotations", {})
            alerts.setdefault(mixin, []).append((
                r["alert"],
                lab.get("severity", ""),
                esc(ann.get("summary") or ann.get("description", ""))[:200],
                ann.get("runbook_url", ""),
            ))

total = sum(len(v) for v in alerts.values())
local = sum(1 for v in alerts.values() for a in v if a[0] in runbook_pages)
with mkdocs_gen_files.open("alerts/index.md", "w") as f:
    print(f"# Alert catalog\n", file=f)
    print(f"**{total}** alerting rules across **{len(alerts)}** mixins — "
          f"**{local}** deep-link to a self-hosted runbook, the rest to upstream.\n", file=f)
nav["Alerts", "Overview"] = "alerts/index.md"
for mixin in sorted(alerts):
    path = f"alerts/{mixin}.md"
    with mkdocs_gen_files.open(path, "w") as f:
        print(f"# {mixin} — alerts\n", file=f)
        print("| Alert | Severity | Summary | Runbook |", file=f)
        print("|---|---|---|---|", file=f)
        for a, sev, summ, rb in alerts[mixin]:
            if a in runbook_pages:
                link = f"[runbook](../{runbook_pages[a]})"
            elif rb:
                link = f"[upstream ↗]({rb})"
            else:
                link = ""
            print(f"| `{a}` | {sev} | {summ} | {link} |", file=f)
    nav["Alerts", mixin] = path

# ---- Inventory from the active config ----
with mkdocs_gen_files.open("inventory.md", "w") as f:
    print("# Deployed inventory\n", file=f)
    for cf in sorted(glob.glob(os.path.join(os.environ.get("CONFIG_DIR", "/config"), "*.y*ml"))):
        try:
            c = yaml.safe_load(open(cf))
        except Exception:
            continue
        if not isinstance(c, dict):
            continue
        mx = sorted((c.get("mixins") or {}).keys())
        db = sorted((c.get("dashboards") or {}).keys())
        if not (mx or db):
            continue
        print(f"## `{os.path.basename(cf)}`\n", file=f)
        if mx:
            print(f"**Mixins ({len(mx)}):** " + ", ".join(mx) + "\n", file=f)
        if db:
            print(f"**Dashboards ({len(db)}):** " + ", ".join(db) + "\n", file=f)
nav["Inventory"] = "inventory.md"

with mkdocs_gen_files.open("SUMMARY.md", "w") as f:
    f.writelines(nav.build_literate_nav())
