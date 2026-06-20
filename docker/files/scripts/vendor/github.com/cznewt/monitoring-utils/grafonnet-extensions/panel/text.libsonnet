local g = import 'g.libsonnet';

{
  local text = g.panel.text,

  base(title, content):
    text.new(title)
    + text.options.withContent(content)
    + text.options.withMode('markdown'),

  plain(content):
    self.base('', content)
    + g.panel.text.panelOptions.withTransparent(true),

}
