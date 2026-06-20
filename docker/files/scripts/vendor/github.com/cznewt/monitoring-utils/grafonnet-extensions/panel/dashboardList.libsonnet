local g = import 'g.libsonnet';

{
  local dashboardList = g.panel.dashboardList,

  base(title, tags):
    dashboardList.new(title)
    + dashboardList.options.withTags(tags),

  tag(title, tags):
    self.base(title, tags)
    + dashboardList.options.withShowSearch(true)
    + dashboardList.options.withShowHeadings(false)
    + dashboardList.options.withShowStarred(false),
}
