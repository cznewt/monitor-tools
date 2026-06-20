local g = import 'g.libsonnet';

function(config) {

  base(title, description=null, slug=null, tags=null):
    g.ext.base.dashboards(config).base(title, description, slug, tags)

}
