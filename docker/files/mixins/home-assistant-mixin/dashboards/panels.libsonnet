local g = import 'g.libsonnet';

function(config, variables) {
  local queries = (import './queries.libsonnet')(config, variables),

  alertList: g.ext.panel.alertList {
    local alertList = g.panel.alertList,

    criticalAlerts(title, filter):
      self.base(title, filter),

    allAlerts(title, filter):
      self.base(title, filter)
      + alertList.options.UnifiedAlertListOptions.stateFilter.withNormal(true),

  },

  table: g.ext.panel.table {
    local table = g.panel.table,
    local override = table.standardOptions.override,
    local step = table.standardOptions.threshold.step,
    local transform = table.queryOptions.transformation,

    cellOptions(title, targets):
      self.base(title, targets)
      + table.queryOptions.withTransformations([
        transform.withId('organize')
        + transform.withOptions({
          indexByName: {
            id: 0,
            'Catch phrase': 1,
            Image: 2,
            Something: 3,
            Value: 4,
          },
          renameByName: {},
        }),
      ])
      + table.standardOptions.withOverrides([
        override.byName.new('id')
        + override.byName.withProperty('custom.width', 80),
        override.byType.new('number')
        + override.byType.withProperty('custom.align', 'center'),
        override.byName.new('Image')
        + override.byName.withProperty('custom.align', 'center')
        + override.byName.withProperty('custom.width', 64)
        + override.byName.withProperty('custom.cellOptions', {
          type: 'image',
        }),
      ]),

    cellTypeImage(title, targets):
      self.base(title, targets)
      + table.queryOptions.withTransformations([
        transform.withId('organize')
        + transform.withOptions({
          indexByName: {
            id: 0,
            'Catch phrase': 1,
            Image: 2,
            Something: 3,
            Value: 4,
          },
          renameByName: {},
        }),
      ])
      + table.standardOptions.withOverrides([
        override.byName.new('id')
        + override.byName.withProperty('custom.width', 80),
        override.byType.new('number')
        + override.byType.withProperty('custom.align', 'center'),
        override.byName.new('Image')
        + override.byName.withProperty('custom.align', 'center')
        + override.byName.withProperty('custom.width', 64)
        + override.byName.withProperty('custom.cellOptions', {
          type: 'image',
        }),
      ]),

    cellType(title, targets):
      self.base(title, targets)
      + table.queryOptions.withTransformations([
        transform.withId('filterFieldsByName')
        + transform.withOptions({
          include: {
            names: ['Sensor'],
          },
        }),
      ]),

    cellTypeGaugeBarBasic(title, targets):
      self.cellType(title, targets)
      + table.standardOptions.withOverrides([
        override.byName.new('Sensor')
        + override.byName.withProperty('custom.cellOptions', {
          mode: 'basic',
          type: 'gauge',
        }),
      ]),

    cellTypeGaugeBarGradient(title, targets):
      self.cellType(title, targets)
      + table.standardOptions.withOverrides([
        override.byName.new('Sensor')
        + override.byName.withProperty('custom.cellOptions', {
          mode: 'gradient',
          type: 'gauge',
        }),
      ]),

    cellTypeGaugeBarLcd(title, targets):
      self.cellType(title, targets)
      + table.standardOptions.withOverrides([
        override.byName.new('Sensor')
        + override.byName.withProperty('custom.cellOptions', {
          mode: 'lcd',
          type: 'gauge',
        }),
      ]),

    cellTypeSparkline(title, targets):
      self.base(title, targets)
      + table.queryOptions.withTransformations([
        transform.withId('seriesToColumns')
        + transform.withOptions({
          byField: 'pod',
        }),
      ])
      + table.standardOptions.withOverrides([
        override.byName.new('pod')
        + override.byName.withProperty('custom.cellOptions', {
          type: 'sparkline',
        }),
      ]),

  },

  timeSeries: g.ext.panel.timeSeries {
    local timeSeries = g.panel.timeSeries,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local options = timeSeries.options,
    local color = timeSeries.standardOptions.color,
    local step = timeSeries.standardOptions.threshold.step,
    local override = timeSeries.standardOptions.override,

    tiny(title, targets):
      self.short(title, targets)
      + custom.withLineWidth(1)
      + timeSeries.options.legend.withShowLegend(false),

    styleLine(title, targets):
      self.tiny(title, targets)
      + custom.withDrawStyle('line'),

    stylePoints(title, targets):
      self.tiny(title, targets)
      + custom.withLineWidth(0)
      + custom.withDrawStyle('points'),

    styleBars(title, targets):
      self.tiny(title, targets)
      + custom.withFillOpacity(0.1)
      + custom.withDrawStyle('bars'),

    fillOpacityNone(title, targets):
      self.styleLine(title, targets)
      + color.withFixedColor('red')
      + custom.withFillOpacity(0),

    fillOpacityFaint(title, targets):
      self.styleLine(title, targets)
      + color.withFixedColor('blue')
      + color.withMode('fixed')
      + custom.withFillOpacity(20),

    fillOpacityFull(title, targets):
      self.styleLine(title, targets)
      + custom.withFillOpacity(100),

    lineWidth1(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineWidth(1),

    lineWidth3(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineWidth(3),

    lineWidth5(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineWidth(5),

    lineInterpolationLinear(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineInterpolation('linear'),

    lineInterpolationSmooth(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineInterpolation('smooth'),

    lineInterpolationStepBefore(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineInterpolation('stepBefore'),

    lineInterpolationStepAfter(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withLineInterpolation('stepAfter'),

    lineStyleSolid(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.lineStyle.withFill('solid'),

    lineStyleDash(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.lineStyle.withFill('dash'),

    lineStyleDot(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.lineStyle.withFill('dot'),

    lineStyleSquare(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.lineStyle.withFill('square'),

    gradientModeNone(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withGradientMode('none'),

    gradientModeOpacity(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withGradientMode('opacity'),

    gradientModeHue(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withGradientMode('hue'),

    gradientModeScheme(title, targets):
      self.fillOpacityFaint(title, targets)
      + custom.withGradientMode('scheme')
      + color.withMode('continuous-RdYlGr'),

    thresholdUpper(title, targets):
      self.fillOpacityFaint(title, targets)
      + timeSeries.standardOptions.thresholds.withSteps([
        step.withColor('transparent') + step.withValue(null),
        step.withColor('yellow') + step.withValue(80),
        step.withColor('red') + step.withValue(90),
      ])
      + custom.thresholdsStyle.withMode('line+area'),

    thresholdLower(title, targets):
      self.fillOpacityFaint(title, targets)
      + timeSeries.standardOptions.thresholds.withSteps([
        step.withColor('red') + step.withValue(null),
        step.withColor('yellow') + step.withValue(10),
        step.withColor('transparent') + step.withValue(20),
      ])
      + custom.thresholdsStyle.withMode('line'),

    thresholdBoth(title, targets):
      self.fillOpacityFaint(title, targets)
      + timeSeries.standardOptions.thresholds.withSteps([
        step.withColor('red') + step.withValue(null),
        step.withColor('yellow') + step.withValue(10),
        step.withColor('transparent') + step.withValue(20),
        step.withColor('yellow') + step.withValue(80),
        step.withColor('red') + step.withValue(90),
      ])
      + custom.thresholdsStyle.withMode('area'),

    minMaxAuto(title, targets):
      self.fillOpacityNone(title, targets)
      + timeSeries.standardOptions.withMin(null)
      + timeSeries.standardOptions.withMax(null),

    minMaxHard(title, targets):
      self.fillOpacityNone(title, targets)
      + timeSeries.standardOptions.withMin(0)
      + timeSeries.standardOptions.withMax(30),

    minMaxSoft(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.withAxisSoftMin(0)
      + custom.withAxisSoftMax(30),

    yAxes2(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.withAxisSoftMin(0)
      + custom.withAxisSoftMax(30)
      + timeSeries.standardOptions.withOverrides([
        override.byName.new('Temperature')
        + override.byName.withProperty('unit', 'celsius')
        + override.byName.withProperty('custom.axisPlacement', 'right'),
        override.byName.new('Energy')
        + override.byName.withProperty('unit', 'watt')
        + override.byName.withProperty('custom.axisPlacement', 'left'),
      ]),

    yAxes3(title, targets):
      self.fillOpacityNone(title, targets)
      + custom.withAxisSoftMin(0)
      + custom.withAxisSoftMax(30)
      + timeSeries.standardOptions.withOverrides([
        override.byName.new('Temperature')
        + override.byName.withProperty('unit', 'celsius')
        + override.byName.withProperty('custom.axisPlacement', 'right'),
        override.byName.new('Pressure')
        + override.byName.withProperty('unit', 'pressurekpa')
        + override.byName.withProperty('custom.axisPlacement', 'right'),
        override.byName.new('Energy')
        + override.byName.withProperty('unit', 'watt')
        + override.byName.withProperty('custom.axisPlacement', 'left'),
      ]),

  },

  canvas: g.ext.panel.canvas {
    local canvas = g.panel.canvas,

    homeSolarDay(title, targets):
      self.base(title, targets)
      + {

        fieldConfig: {
          defaults: {
            unitScale: true,
            mappings: [],
            thresholds: {
              mode: 'absolute',
              steps: [
                {
                  color: 'green',
                  value: null,
                },
                {
                  color: 'red',
                  value: 80,
                },
              ],
            },
            color: {
              mode: 'thresholds',
            },
            unit: 'kwatt',
          },
          overrides: [],
        },
        options: {
          inlineEditing: true,
          showAdvancedTypes: false,
          panZoom: false,
          root: {
            background: {
              color: {
                fixed: 'transparent',
              },
              image: {
                field: '',
                fixed: 'https://www.sunnova.com/-/media/Marketing-Components/Infographic/Solar-Storage-For-Non-Export-Markets/Solar-Storage-Export-Outage-Day.ashx',
                mode: 'fixed',
              },
              size: 'original',
            },
            border: {
              color: {
                fixed: 'red',
              },
              width: 0,
            },
            constraint: {
              horizontal: 'left',
              vertical: 'top',
            },
            elements: [
              {
                background: {
                  color: {
                    fixed: 'super-light-blue',
                  },
                  image: {
                    fixed: '',
                  },
                },
                border: {
                  color: {
                    fixed: 'dark-green',
                  },
                },
                config: {
                  align: 'center',
                  color: {
                    fixed: 'dark-blue',
                  },
                  size: 16,
                  text: {
                    field: 'solar_output',
                    fixed: '',
                    mode: 'field',
                  },
                  valign: 'middle',
                },
                constraint: {
                  horizontal: 'left',
                  vertical: 'top',
                },
                name: 'Solar output',
                placement: {
                  height: 30,
                  left: 752,
                  top: 253,
                  width: 75,
                },
                type: 'metric-value',
              },
              {
                background: {
                  color: {
                    fixed: '#ffffff',
                  },
                  image: {
                    fixed: '',
                  },
                },
                border: {
                  color: {
                    fixed: 'dark-green',
                  },
                },
                config: {
                  align: 'center',
                  color: {
                    fixed: '#000000',
                  },
                  valign: 'middle',
                },
                constraint: {
                  horizontal: 'left',
                  vertical: 'top',
                },
                name: 'Hide logo',
                placement: {
                  height: 93,
                  left: 27,
                  top: 467,
                  width: 222,
                },
                type: 'rectangle',
              },
              {
                background: {
                  color: {
                    fixed: 'super-light-green',
                  },
                  image: {
                    fixed: '',
                  },
                },
                border: {
                  color: {
                    fixed: 'dark-green',
                  },
                },
                config: {
                  align: 'center',
                  color: {
                    fixed: 'dark-green',
                  },
                  size: 16,
                  text: {
                    field: 'battery_charge',
                    fixed: '',
                    mode: 'field',
                  },
                  valign: 'middle',
                },
                constraint: {
                  horizontal: 'left',
                  vertical: 'top',
                },
                name: 'Battery charge',
                placement: {
                  height: 30,
                  left: 648,
                  top: 349,
                  width: 75,
                },
                type: 'metric-value',
              },
              {
                background: {
                  color: {
                    fixed: 'super-light-red',
                  },
                  image: {
                    fixed: '',
                  },
                },
                border: {
                  color: {
                    fixed: 'dark-green',
                  },
                },
                config: {
                  align: 'center',
                  color: {
                    fixed: 'dark-red',
                  },
                  size: 16,
                  text: {
                    field: 'house_draw',
                    fixed: '',
                    mode: 'field',
                  },
                  valign: 'middle',
                },
                constraint: {
                  horizontal: 'left',
                  vertical: 'top',
                },
                name: 'House draw',
                placement: {
                  height: 30,
                  left: 747,
                  top: 352,
                  width: 75,
                },
                type: 'metric-value',
              },
            ],
            name: 'Element 1659400716798',
            placement: {
              height: 100,
              left: 0,
              top: 0,
              width: 100,
            },
            type: 'frame',
          },
        },
      },
  },

  nodeGraph: g.ext.panel.canvas {
    local nodeGraph = g.panel.nodeGraph,

    base(title, targets):
      self.base(title, targets)

  },


}


/*
{
  "datasource": {
    "type": "yesoreyeram-infinity-datasource",
    "uid": "infinity-universal"
  },
  "description": "Displays a node graph with JSON format to visualize server performance like CPU usage, memory, and disk size. It also shows the interaction and data flow among different servers.",
  "gridPos": {
    "h": 12,
    "w": 12,
    "x": 12,
    "y": 55
  },
  "id": 17,
  "options": {
    "nodes": {},
    "edges": {}
  },
  "targets": [
    {
      "columns": [
        {
          "selector": "id",
          "text": "",
          "type": "string"
        },
        {
          "selector": "title",
          "text": "",
          "type": "string"
        },
        {
          "selector": "sub-title",
          "text": "subTitle",
          "type": "string"
        },
        {
          "selector": "cpu",
          "text": "mainStat",
          "type": "number"
        },
        {
          "selector": "memory",
          "text": "secondaryStat",
          "type": "number"
        },
        {
          "selector": "c_disk_size",
          "text": "arc__cpu",
          "type": "number"
        },
        {
          "selector": "d",
          "text": "arc__memory",
          "type": "number"
        },
        {
          "selector": "c_disk_size color",
          "text": "arc__cpu_color",
          "type": "string"
        },
        {
          "selector": "d color",
          "text": "arc__memory_color",
          "type": "string"
        },
        {
          "selector": "detail__hello",
          "text": "",
          "type": "string"
        }
      ],
      "data": "[\n {\n   \"id\": \"A\",\n   \"title\": \"Server A\",\n   \"sub-title\": \"Application Server\",\n   \"cpu\": 12,\n   \"memory\": 10,\n   \"c_disk_size\": 0.1,\n   \"d\": 0.9,\n   \"c_disk_size color\": \"blue\",\n   \"d color\": \"red\",\n   \"detail__hello\": \"world\"\n },\n {\n   \"id\": \"B\",\n   \"title\": \"Server B\",\n   \"sub-title\": \"DB Server\",\n   \"cpu\": 90,\n   \"memory\": 87,\n   \"c_disk_size\": 0.1,\n   \"d\": 0.9,\n   \"c_disk_size color\": \"blue\",\n   \"d color\": \"red\",\n   \"detail__hello\": \"hello\"\n },\n {\n   \"id\": \"C\",\n   \"title\": \"Server C\",\n   \"sub-title\": \"Application Server\",\n   \"cpu\": 20,\n   \"memory\": 23,\n   \"c_disk_size\": 0.2,\n   \"d\": 0.8,\n   \"c_disk_size color\": \"blue\",\n   \"d color\": \"red\",\n   \"detail__hello\": \"hello\"\n },\n {\n   \"id\": \"D\",\n   \"title\": \"Server D\",\n   \"sub-title\": \"Middleware Server\",\n   \"cpu\": 47,\n   \"memory\": 98,\n   \"c_disk_size\": 0.9,\n   \"d\": 0.1,\n   \"c_disk_size color\": \"blue\",\n   \"d color\": \"red\",\n   \"detail__hello\": \"world\"\n }\n]",
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "infinity-universal"
      },
      "filters": [],
      "format": "node-graph-nodes",
      "global_query_id": "",
      "parser": "simple",
      "refId": "A",
      "root_selector": "",
      "source": "inline",
      "type": "json",
      "uql": "parse-csv",
      "url": "https://github.com/grafana/grafana-infinity-datasource/blob/main/testdata/users.json",
      "url_options": {
        "data": "",
        "method": "GET"
      }
    },
    {
      "columns": [],
      "data": "[\n {\n   \"id\": 1,\n   \"source\": \"A\",\n   \"target\": \"B\",\n   \"mainStat\": 30,\n   \"secondaryStat\": \"mb/s\",\n   \"detail__one\": \"abc\"\n },\n {\n   \"id\": 2,\n   \"source\": \"A\",\n   \"target\": \"C\",\n   \"mainStat\": 20,\n   \"secondaryStat\": \"mb/s\",\n   \"detail__one\": \"def\"\n },\n {\n   \"id\": 3,\n   \"source\": \"B\",\n   \"target\": \"D\",\n   \"mainStat\": 24.2,\n   \"secondaryStat\": \"mb/s\",\n   \"detail__one\": \"ghi\"\n }\n]",
      "datasource": {
        "type": "yesoreyeram-infinity-datasource",
        "uid": "infinity-universal"
      },
      "filters": [],
      "format": "node-graph-edges",
      "global_query_id": "",
      "parser": "simple",
      "refId": "B",
      "root_selector": "",
      "source": "inline",
      "type": "json",
      "uql": "parse-csv",
      "url": "https://github.com/grafana/grafana-infinity-datasource/blob/main/testdata/users.json",
      "url_options": {
        "data": "",
        "method": "GET"
      }
    }
  ],
  "title": "Node Graph + JSON ",
  "type": "nodeGraph"
}
*/
