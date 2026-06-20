local g = import 'g.libsonnet';

{

  app(title, _config, _rows, _variables=null):

    local config = g.ext.kubernetes.config + _config;
    local dashboards = g.ext.kubernetes.dashboards(config);
    local variables =
      g.ext.kubernetes.variables.app(config);
      //+ if _variables != null then _variables(config) else [];
    //local rows =
    //  (import './rows.libsonnet')(config, variables)
    //  + g.ext.kubernetes.rows(config, variables)
    //  + g.ext.jvm.rows(config, variables);
    dashboards.base(title)
    + g.dashboard.withVariables(variables.toList())
    + g.dashboard.withPanels(
      g.ext.kubernetes.rows.rows(config, variables).toList()
      //+ std.flattenArrays([
      //  row(config, variables).toList()
      //  for row in _rows
      //])



      //rowsInput(config, variables).toList()

      //+ rows.keycloakRealm
      //+ rows.keycloakClient
      // rows.jvmStats
      //+ rows.kubernetesContainerLogs
    ),


  //g.ext.base.dashboards(config).base(title, description, slug, tags)

}

/*
      g.ext.kubernetes.dashboard.app(
        'Keycloak server',
        $._config,
        [(import './rows.libsonnet'), g.ext.jvm.rows],
        (import './variables.libsonnet'),
      ),

*/
