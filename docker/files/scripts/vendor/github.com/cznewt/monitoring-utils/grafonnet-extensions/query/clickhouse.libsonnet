{
  '#': { help: 'grafonnet-ext.query.clickhouse', name: 'clickhouse' },
  '#withDatasource': { 'function': { args: [{ default: null, enums: null, name: 'value', type: ['string'] }], help: "For mixed data sources the selected datasource is on the query level.\nFor non mixed scenarios this is undefined.\nTODO find a better way to do this ^ that's friendly to schema\nTODO this shouldn't be unknown but DataSourceRef | null" } },
  withDatasource(value): { datasource: value },
  '#withFormat': { 'function': { args: [{ default: true, enums: [1, 2, 3, 4], name: 'value', type: ['integer'] }], help: '' } },
  withFormat(value=true): { format: value },
  '#withQueryType': { 'function': { args: [{ default: null, enums: ['sql'], name: 'value', type: ['string'] }], help: '' } },
  withQueryType(value): { queryType: value },
  '#withRawSql': { 'function': { args: [{ default: null, enums: null, name: 'value', type: ['string'] }], help: '' } },
  withRawSql(value): { rawSql: value },
  '#withRefId': { 'function': { args: [{ default: null, enums: null, name: 'value', type: ['string'] }], help: 'A unique identifier for the query within the list of targets.\nIn server side expressions, the refId is used as a variable name to identify results.\nBy default, the UI will assign A->Z; however setting meaningful names may be useful.' } },
  withRefId(value): { refId: value },
}
