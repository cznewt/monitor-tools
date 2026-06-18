"""mkdocs-gen-files hook.

Builds the documentation pages at `mkdocs build` time from the rendered
monitor-tools output:

  * Alert catalog  <- /build/*/mimirtool/mimir-rules/*.yaml  (rendered ruler rules)
  * Runbooks       <- /mixins/*/runbooks/*.md and /source/*/mixins/*/runbooks/*.md
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


# ---- Alert catalog from rendered ruler rules ----
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
with mkdocs_gen_files.open("alerts/index.md", "w") as f:
    print(f"# Alert catalog\n\n**{total}** alerting rules across **{len(alerts)}** mixins.\n", file=f)
nav["Alerts", "Overview"] = "alerts/index.md"
for mixin in sorted(alerts):
    path = f"alerts/{mixin}.md"
    with mkdocs_gen_files.open(path, "w") as f:
        print(f"# {mixin} — alerts\n", file=f)
        print("| Alert | Severity | Summary | Runbook |", file=f)
        print("|---|---|---|---|", file=f)
        for a, sev, summ, rb in alerts[mixin]:
            rbl = f"[runbook]({rb})" if rb else ""
            print(f"| `{a}` | {sev} | {summ} | {rbl} |", file=f)
    nav["Alerts", mixin] = path

# ---- Runbooks shipped with the mixins ----
seen = set()
for rb in sorted(glob.glob("/mixins/*/runbooks/*.md") + glob.glob("/source/*/mixins/*/runbooks/*.md")):
    try:
        mixin = rb.split("/mixins/")[1].split("/")[0].replace("-mixin", "")
    except Exception:
        continue
    name = os.path.basename(rb)[:-3]
    if (mixin, name) in seen:
        continue
    seen.add((mixin, name))
    path = f"runbooks/{mixin}/{name}.md"
    with mkdocs_gen_files.open(path, "w") as f:
        f.write(open(rb).read())
    nav["Runbooks", mixin, name] = path

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
