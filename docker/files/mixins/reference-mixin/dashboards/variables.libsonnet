local g = import 'g.libsonnet';
local var = g.dashboard.variable;

function(config) {

  datasource:
    var.datasource.new('datasource', 'prometheus')
    + var.datasource.generalOptions.withLabel('Data source'),

  testDatasource:
    var.datasource.new('test_datasource', 'testdata')
    + var.datasource.generalOptions.withLabel('Data source (test)'),

}
