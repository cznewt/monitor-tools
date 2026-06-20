local g = import 'g.libsonnet';

{
  local alertList = g.panel.alertList,

  base(title, filter):
    alertList.new(title)
    + alertList.options.UnifiedAlertListOptions.withAlertInstanceLabelFilter(filter),
}
