local g = import 'g.libsonnet';
local prometheusQuery = g.query.prometheus;
local lokiQuery = g.query.loki;
local testdataQuery = g.query.testData;

function(config, variables) {

  testdataSetGauge:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withAlias('Temperature')
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('1,20,30,35,20,50,10,30,40,90,60,70,100'),

  testdataSetLargeGauge:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withAlias('Pressure')
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('320,230,120,180,400,340,50,270'),

  testdataSetLargeRandomGauge:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withAlias('Energy')
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('400,340,50,270,320,230,120,180'),

  /**

  {
    "datasource": {
      "uid": "9cY0WtPMz",
      "type": "grafana-testdata-datasource"
    },
    "fieldConfig": {
      "defaults": {
        "custom": {
          "drawStyle": "line",
          "lineInterpolation": "linear",
          "barAlignment": 0,
          "lineWidth": 2,
          "fillOpacity": 0,
          "gradientMode": "opacity",
          "spanNulls": true,
          "insertNulls": false,
          "showPoints": "never",
          "pointSize": 6,
          "stacking": {
            "mode": "none",
            "group": "A"
          },
          "axisPlacement": "auto",
          "axisLabel": "",
          "axisColorMode": "text",
          "axisBorderShow": false,
          "scaleDistribution": {
            "type": "linear"
          },
          "axisCenteredZero": false,
          "hideFrom": {
            "tooltip": false,
            "viz": false,
            "legend": false,
            "graph": false
          },
          "thresholdsStyle": {
            "mode": "off"
          },
          "axisSoftMax": 60,
          "axisSoftMin": 0
        },
        "unitScale": true,
        "color": {
          "mode": "palette-classic"
        },
        "mappings": [],
      },

      ]
    },
    "gridPos": {
      "h": 8,
      "w": 18,
      "x": 0,
      "y": 28
    },
    "id": 540,
    "maxDataPoints": 50,
    "options": {
      "tooltip": {
        "mode": "multi",
        "sort": "none"
      },
      "legend": {
        "showLegend": true,
        "displayMode": "list",
        "placement": "bottom",
        "calcs": [
          "last"
        ]
      }
    },
    "pluginVersion": "7.4.0-beta1",
    "targets": [
      {
        "alias": "Temperature",
        "csvWave": {
          "timeStep": 60,
          "valuesCSV": "0,0,2,2,1,1"
        },
        "lines": 10,
        "points": [],
        "pulseWave": {
          "offCount": 3,
          "offValue": 1,
          "onCount": 3,
          "onValue": 2,
          "timeStep": 60
        },
        "refId": "A",
        "scenarioId": "csv_metric_values",
        "stream": {
          "bands": 1,
          "noise": 2.2,
          "speed": 250,
          "spread": 3.5,
          "type": "signal"
        },
        "stringInput": "20,25,30,18,35,20,30,25",
        "datasource": {
          "uid": "9cY0WtPMz",
          "type": "grafana-testdata-datasource"
        }
      },
      {
        "alias": "Pressure",
        "csvWave": {
          "timeStep": 60,
          "valuesCSV": "0,0,2,2,1,1"
        },
        "hide": false,
        "lines": 10,
        "points": [],
        "pulseWave": {
          "offCount": 3,
          "offValue": 1,
          "onCount": 3,
          "onValue": 2,
          "timeStep": 60
        },
        "refId": "B",
        "scenarioId": "csv_metric_values",
        "stream": {
          "bands": 1,
          "noise": 2.2,
          "speed": 250,
          "spread": 3.5,
          "type": "signal"
        },
        "stringInput": "320,230,120,180,400,340,50,270",
        "datasource": {
          "uid": "9cY0WtPMz",
          "type": "grafana-testdata-datasource"
        }
      },
      {
        "alias": "Energy",
        "csvWave": {
          "timeStep": 60,
          "valuesCSV": "0,0,2,2,1,1"
        },
        "hide": false,
        "lines": 10,
        "max": 300,
        "min": 100,
        "noise": 10,
        "points": [],
        "pulseWave": {
          "offCount": 3,
          "offValue": 1,
          "onCount": 3,
          "onValue": 2,
          "timeStep": 60
        },
        "refId": "C",
        "scenarioId": "random_walk",
        "spread": 100,
        "startValue": 0,
        "stream": {
          "bands": 1,
          "noise": 2.2,
          "speed": 250,
          "spread": 3.5,
          "type": "signal"
        },
        "stringInput": "",
        "datasource": {
          "uid": "9cY0WtPMz",
          "type": "grafana-testdata-datasource"
        }
      }
    ],
    "title": "Multiple Y-Axes (more than 2!)",
    "type": "timeseries"
  }
   */

  testdataSetLines: [
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('10,10'),
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('8,8'),
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('6,6'),
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('4,4'),
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('2,2'),
  ],

  testdataSetMaxNormal:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('10,11,12,11,10,11,12,12,11,10,9,10,11,12,10,10,11,12,13,11,10,9,10,11,12,13,14,10,10'),

  testdataSetMaxSpike:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_metric_values')
    + testdataQuery.withStringInput('10,11,12,11,10,11,12,12,11,10,9,10,11,12,200,10,11,12,13,11,10,9,10,11,12,13,14,10,10'),

  testdataSetTable:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_content')
    + testdataQuery.withCsvContent(|||
      "id","Catch phrase","Image","Something","Sensor"
      1,Cross-group next generation middleware,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJGSURBVDjLpZNLTxpRFMdd+EX8BixZ6VfxQ9imq3YzSdNVE2MNyEMYAeUNofIKEBjA8CoiM4BCgiQgaJqWtjySAc2/585iogG76eI/czN3/r9z7jnnbgDY+B8pj3w+v5nNZncEQdhLp9N8KpUqJhKJYTwel2OxmByJRIbn5+fFUCjEB4PBPZ/Pt+PxeDZVAJm5SqUCURTRarVUNZtNdd1oNFCtVkHBEA6H4XK5OBWQyWQwnU4xHA7RbrdRr9eVn8vlsiK2ZnC2NxqNMB6PcXZ2BhVAacu3t7eYTCYQbr4jIP2ErzWHt/0I780jnOIUjsoDYlcDjH//UYAOh0NWAXTmbTrzUmpew3bRA196gONqAndrARfJevkLXzJ9fI5dwxkvwG63L09OTrZVABMVTBuNRpfVegPWlIRPvhI+nF7gHZ/FG4sAzl2AP1V8YX4BYKJKa6nSy8srEZakiPeneby1CvjoKeJrurRiXgEwUZu0fr9/+a16iVStC9/FNSLCevNaAJPX69W63e6nxWKhdIfMT+vMrwKYnE6nl7WtVCqB53nbPyfxuSjyFvV4l9pU6Xa7yOVysFgsebPZvGs0GrdeBdBoami6ioFAADQXoPHFYDBQ3lQXUHFxfHwMnU5XPDw81KwAyPxDkiTIsozZbIa7uztFDHJ/f698Y3vJZBIHBwejFQClzbFIhUIBnU4H/X4f8/lcUa/XQ61WU+7A0dER9vf3ubU1sNlsGqvVylGqWZPJ1DEYDNDr9SztLqWdpcgcmTXPPX8BpLUNr3FYePgAAAAASUVORK5CYII=",Engineering,36.7
      2,Horizontal non-volatile system engine,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAEwSURBVDjLpZMxSkNBFEXPD2IhVmKlS8gGXIBdsHQRkt5dWGYfFmYXtsHaQkTQRlDIzHv3WsyPIfiDSh4MU8zlzJ375nW22aX2fhPc3D1v3JA21xcn3Z8BAKdH+9hgm8fXMuzg9v7TBpRgwIbLs4MOQDYSWCarhgEpOD4cIcCCl/cmzDRKkEzKlNgCsCHddhlWugiRaVIiE+oyhwGRNJs9IHtdTTeITOZPByOA6XRq9Q5C6zWZTFyLqSFqiAhRqhiPx94AzGazbuWgLaMU8/m8KyWJFFlFDVOLWCwWP9sYakHKbhn0Tyghovr7CXVbiJki1a0z6E3WZbMvNU0t3hKi4ektyb4jqx9eQkQay62V3gK4Oj/shn5hrUmGkVcQ/W8WIszD4weyBs+7XadxxI71BUieEw+8ru7iAAAAAElFTkSuQmCC",Support,4.80
      3,Open-source analyzing hierarchy,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAITSURBVDjLlZLNi1JhFMaHiP6AvN0Ls4vob2jauYiIFoGBtnFlG1fSws1gDBdXLhIhdaEuvILfjtfK0cyvRflBeHWUEBW1nHGKpmkcpWw+ani6r9DCutn0wuGFl/P8znPOeZcALP0ekUhE7vf7HR6PZ+ByuQZ2u91hsVjkUrl/PITDYbnP5xMajQb6/T46nQ5KpRJMJpNgNBrlkoB4PL7M8zwbCoWaXq93RMStVguVSgXlchmCICCXy8FgMDgkAdFolK1Wq+j1emi326jX6ygUCsjn80ilUkgkEigWi9Dr9ac6nY7TarUrc4BAINDsdruo1WpzQtEZRDiCwSDE1pDJZBCLxaDRaLg5gDispnhmvRKrJJFU/SUWBwqO4+B2u5HNZqFWq8dzAKfTyRIh6ZVAksnkrDpxkk6nIW4F4nxmrghMpVLNO7Barctms5m12Wx46bw23XRf/TF5JsP4qQwHT2QYRWXYW7+Ix6vXT5VKJadQKFYk1/g1x5z/kmUU0+otnHy04Hi4hu8HHD4n6elegr7/z38wyTA3xy+Y7mHvAb69UWDauI0PiSuQEkoCRil663CwhuMddlad3EfbD/F+4zIWAvaf0+dEm48+bdDYjdMYC3dn4snmvYViya9MYoe/NNx/fQdb69R4EKGYMwOGPHVhO0qt7r66gXdhKrJIKAkQq6nehqijflCmOov4ry38T/wEpFjkJMz8PioAAAAASUVORK5CYII=",Legal,79.3
      4,Universal 4th generation alliance,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAHySURBVDjLpVNBaxpBGH2z7rrb6poNG0lSi0VyiA1I6a2XUtBLyD/oyV/gvSD03Gv/Q7El5NZDhBDx1lPpQUyRbg9SoUYTsEs21XVdM9/QWdZePGTgY2beft/33pudYcvlEvcZCu45VLno9Xrni8WizANBEGA+n0fh+34Us9mM5la1Wq1QHSMLvPhVMplsZ7NZkfT/iNvUNA3tdhv9fr9Sq9VaQgFnfGtZFobDIXRdj4rihbQeDAbIZDIoFApEWudwi3U6HcFu2zZc112RS1aokDGGRCIh2E3TRCqVQrPZhOM4FZXYSTp5pSTDMERI9rgSmsMwxHQ6RalUQrfbravE5HkexuOxOCCZRIdJs9xLjPaqqiKdTguV1KBM3WlDCdySkKwoyooC2Sifz4u8XC5HNWWFWMkrBX2QITGJP//2CdbVT1gTB896H6JfrFIDWUQMxWIxkkysEn/y6wJP/3yFzTYxe5TGFceiBvQHpL+4XHl45uf3SO15sPU9oMxg9D0cOCdCHWs0Gqfcy2HslkUzxaF9jH3NwcbONnR3Eziii8Mb/7jF98nDS7buMf1+wRraG7w2sQP92gJecnCDx5jf2Hc3H9c/Jh+j5Rnwd3fELYXA5T/8SwC4GK1X8Jg94E9uAhNJxVeC7ewWYHDkhrcOYd0B0mCFUhT4PX8AAAAASUVORK5CYII=",Support,20.8
      5,Multi-tiered mobile analyzer,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAE3SURBVCjPhZFfK4NxGIZ/R458Dz7B7wv4Go5WpJW8819mSw3bos202DsTNpT3FTbCRs0YkYPFasvKJhw5kpVEu5y8W0uZ7sPnup+e+34EorH+HIRZQsXfLtKkOSPJCXEOiLGNxgarpPniGW9WnPPN5y+9E3p5I4+n6DaLFHmeuOSRFEUSFNgjj04WDVcbQiCOuWBfnrIlE0RkjKDU8ck1VBytCIE45JYkD8QpECOHTpYIGVzYmo0UO5Q5IiyjqFLDKyNMyUVs1GJq1mvuiZJjkzvCZAhyw3ClrocVQiwwhwc3E4xjZ5f+SoOihpr66Hk1gOWWYGAeHzM4cWBnlEF6QZjLBqBaEbPKdMmpVP0WpbtkVjo/DMBv9aJzxTo2RhjAQoA0fkyFuhsmGWestqFL6cDEP9+s6gcdbFPqiEGjeAAAAABJRU5ErkJggg==",Sales,36.7
      6,Profound interactive installation,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAHfSURBVDjLpZO9a5NhFMV/bxowYvNRjf1IoCDo0KFJBVHEVbeCi5N/gM6KruLi6KiDKA6KIC6CQwdtBxfRrUGHFlTQIlikjTFpkua55zo8r7aDipALd3keOOdwzrmJuzPMZF/cOPFXBMmRHJMTTJiJYCIEESy+ZQGqczPIDNxxd/AMDriBu+MSCkJmSA4CJ8Pym+UIIAs0177S3Wz9F3O+WGCiMrmjwM3pbrZ4fvo17kR237XAtcolRvdOA+L+9TscHB/HTGQAlLqwuHWbxa1b9JMVTBDSHRi82qijbgPXNsGEpx5kouYo+2jpI/3kCUudiwzUJBgMAoQAjf4ZFtZP0mq/x0xIYPJUQQoQLHAsX8fMeNk7y4DVCGKw0q7ytHmByx/u/lYgOVnJUbBomAa8azWYr5b50unRGZln48ccYzrH5/VTtHuTKIxQk8dUdgMEE/XyN2YPTFHJHaZWFPIan/KriEccqT5ExJi15FiwWCSTo+CYiYk9h5CL4NvIhSOmctOxCwgh3J3vauAWnc8GEzInt2+U3s1nuEWwmPlOByzthuSUSyV+XUDWTOAJxbEyhcJ+pPgxc/4KnbUFQOTKx3n74B5uQhI4JEkMMHl8ddZ3d/tfzH+aZNhrzDDk/ARfG6G/LNZPQgAAAABJRU5ErkJggg==",Engineering,96.5
      7,Multi-lateral object-oriented collaboration,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKISURBVDjLjZPLTxNRFMb5B/gDkJ0rNy5cYWLcsNNoWLjQlaLxkcjCmLBzYVgVY6WGQBvEhYqaSIsJ1VSYVhBLQIitM20h9oW09jV0SjsttJ3Szue500eKxMRJfnNn5nznu+fec6cDQEc7V3RzZ4gxwk2kiSzhJ0ws9re+PbGTMBKVeVcEvqiMX5KCeOEAscwe7O4oWKyh6Txk0Eiee7PoR7WmIiYD79fzmPHk8S2joESiGsFiTMO0TZOmgZEFchVoV4HUU0s5vFjZhZCrQaVvNECu1eMNE6NmQA+niVokU8HUqoSAVBfZXCWYPksI7UGrIEW3Ao0KQ1WZQY3larNztD6bR8bkUhoTi2l4Y0AwBawGCrScMjJlQCQDmUrJVoE8wdX3xMgMeCGSw8vlHTIQYfoiwuqWMe0MMUGSYVkOo0BJcaomsAsI8SqEiMziPDOQNmL7NLOICUp+RiZr4QILJojuBgl/qgwrbar5e07DGysyjdQyMC2IMDpSGHMksb511MD7uwizS8brtSyRgafNgOe3szAuJLXkd+QekFSwsptLmHaGMcmZcd/Uj9sjfbg6fA4jM6OtJWibuLJVgiAC0SIQzhM5wL9Thi9RhunTWwyZr+Ojbxx8goPBfheXDSfRO3iRb7WxQq0RqUc/s4ArCXyNAPZQFR82FFx7dB6z3qeY3RzVWqx33ILBcQc9A8eUQwcpTe0S0oCTkrmgCuvmASxCCRcenILN9xztl9UzTgZdOHKUY3kVP6gCe7AKq1eBhS/i7L3jeMzdgI7r15J18/2NCrpK//yZ3NsyNpOKtgcPXw3hkv4EnnA3tZnZyN7JQN/xH78zw9072OfqGejeZ2UTeWKY6f8AEAIH5OE7cHsAAAAASUVORK5CYII=",Product Management,22.3
      8,Re-contextualized zero tolerance function,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJFSURBVDjLpZNfaM0BFMc/v7s/pv25tnsXlrzo2nav3d3y4CaelqLw4l1JEVaUl1GeUHtQXpiSUvKqZFFWJtFajO62K/KwlXQn7syfe+3PPX883AkNKefl1KnzOed8zzmBu/M/Vvm74OnMiayZJlTNVfXO2fT5nX8ChJYm9zRhJFrrWok1xAJRTf+tgyWAU6neDwuyUCx5ieJCEREZ+xsgcHfOjJ50M0XV0LL39sa2QEwYnRr7JKKqqiER4cru641LNFBT1tfGMDfMHccCNcMd4s3xsLribjyeePp7EVUVdcPcyBVe83HuI+KCuRMKKjBz1oVjiMgfAKJk81kaqsKsrG3h/dc86loex+dRUwQlUhdhz7VdLiKIKLcPDATBz3dwbPCgx5vjZKczqBnmirihrjRUhVlTvxYzxzEGRx5w99Bg8MsdiCjqimjZ62KymmIz87x5+YLZ2SLF+QJuxR8jHL13wEWUFTUrUDNKXiprYoqYUZ13ossr2Lh1E2uaYtx/fpPh7EPS3S3nQt8rJ1a2syq8isnPE8SbkiSakiQiKTqiKWSqSKqtEw0pnau3oUGJdMdmgCOVACURBCXz7hkbop1MvJ0kl59CVYmGo8x8zlMV1LGjfT8Ax7su0z/eB9yqqQSQkqBmJCJJRI1cfoobe/sDgO2XurxQmOZ5bojR3CN6tl2ld2AfNRXLAObKABGevBpBVFlc0dwPYcWorw2Gx4aCzckt9I/3UR1U8ijzAOBi8K/vnO5u6QUOA/XAF6Bv+EKu5xvVXGolRpHH+AAAAABJRU5ErkJggg==",Accounting,8.40
      9,Re-contextualized multimedia portal,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAL+SURBVBgZXcHPbxRlHMDhz3femdkunZ3Zdrublgptg7W0aig28SAYk8aDUuNFjkRvhBMHNfwL3vGgQcWEGGJiTCQxgjFoECTUqG1AKZj+MqUUum1xdmdnZ3dm9tW1TTQ+jxw5+vLlQqkwqZTiv4T/E4RtAiRpi431jW/NQqkwefb0x4ghJK2YfwmCRiO0hXEACFob6JZGk/L2qbcmTaUUKQkSn6f2zQxdl0PKp/bSmXO4e/c6c7Uz3C/75HIuDzd9lGlRqUW8cURjmQqDHb6/iT9qUwkCwku3CYI1giBAGjM06lXqYZVmPaBeD0iiGiItQDCFbZ5XBB2z62Q3vPMLmdd6KPXtJhsvUE+GyeVz2MrAtGyCMEKkAQgm/xB83ycIqlDKEnUlOJ/Nw3MtdHiVuHGYsGpQbF7hQOUiynma2oUr7Hc7MNnheSXQMXnPxT8xRtf7myQv9JHpabC3uUlB/cqAeZtszzG8oYP8uTTCMxtnMUFoi6IGtSBERFPtTFFPQHRuEf16gXz9DMN9wzj9h9hamMOWJjm3l+6exzCFbdlsHset4bkubdaxQbJvXkNVFaO9Q3hDL9JY+xR7l/DH7B2SluKTuRhD2Fb1awRBA79S46fVB5xfWOLmwS2ypou3b4ro/geI9QjLydERLmNPTFGJFQYiCODme6Ejz2yYsNy0KFYfMXZoHO/xV4lW38OwYpqVQcrfTXPPKGIUB2gz+ZvWmumVJWZW7+A4Oax784w4g5SenKL54EOUrYn8Ada/v8GP+0Ypd3YwZWdoMwUIkxrlNCZjO9iLK4xnR0haJdZuvUtXySba2sPG9Z+58dQE2uuis9kArWkzQBAxyOHiSA5rfpmxw8fJrFzj9ws/MPv1Fje/uoq7uBvD7MTGwsYijRMEMJMkJU1T+rvH6S/A5x+do/nblwwdeB6/vMnKrXn2nzyNld3DhIpRHTbKUKStlCRNkVeOTl0slnpeUpYJCJXZLxgfLPLs6CDlljC9XiDUGdqEHQJJklJ+WL70F3VJO/3fH/GfAAAAAElFTkSuQmCC",Services,98.8
      10,Open-source impactful moderator,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJpSURBVDjLpVNLbxJRFO4P8BfwO2Dp0g07q42iGxM3JmxMXDR15aRWjdYqZMYSxbRpbaCSoEnVNjW2Ip2CNE2BUsrwELBAoTCMMDAwQDnOucCIj52TfJnk5nyPc+65IwAwMoxzs6BRoFOgV2DoQ98/0/xZP0w8o0B7+03F6Nw+Yrz+GLt/cMgHQ2F+azfCvnYlmXFH2Yg1WPubQJ981u7OUcHDBJcvVUCUWtA+7RJU6zJkC2Xw7Ia4ufUEhbUDkYGAFsmhyDex0WwDfpLcgbLYAl5BrdkhZ6Ikw5YvIFpXoyiiJQLYF8ZG5wG5WJGh8EOGo1IDStUW5IQmZMtNVWR908PdXMpjOxoU0DnZ7wzGHiZHs3W4/GgHLtx1qWII/CLJY6AdXga5KKD37EVZ7Bmj5gUZkgWJEEcnXTB236v8P5PzdLEBlXobTgQJ5pffschFAUNg/4DHYWFcLLw4xRIyEhFj97ZhlNogbWAKuX0KS7ZlHrlEwB8MEQGMj0UZvqFGRldMlMj30EvRgvmFV6qA/stOmBXEJlSlNiERZ8URcf7OJ4JLD30QP66Tm4llBKCtNrUFnW0jzqSzJeh2gThcmfHD1ScBMDzeU/94hoNtdbqw+TUMlOWDOkTNLXvRuOH2cXylN+VBXHSM5eqEGMnWiEFccTc/X+SuW2K9axwsEv02SK18dIv5cq9QqLVJmtSJRJYJnWOZMpisdnGCXv21SMOrPG3zUYuOFc4biEM6XyEzwZ7DKR7W3EGYpue4cfP7v1d5+DHdeJkyTr5YY2ZmF1j6mYV/amb4ByYrO2FyMteYyL8f0/8855/NvQk/FX0nyAAAAABJRU5ErkJggg==",Business Development,77.7
      11,User-friendly explicit website,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAACxSURBVDjL7dItC8JQAIXh491HWbDvD1pEDIIKm1zDxqKi0WIULAZFYc1msF3ErEZlMC9Mhxx/gTAR28KpDxx4QRK/DCXwAbDg0oLMTShtQF0F5AlwvwHkqy+Zxxs+lwsmvs8DKrIw8DCh8njNLOxRtxrU4yF3MFRhIBFQ2XxG3W7yXq8xjULGsIsDFwF58zzq0YBpFPDc6XIKp/iFI4S7h5BbWGoFW03gyABVtyzxT8Ab8Xzei+tkcykAAAAASUVORK5CYII=",Training,90.5
      12,Customizable analyzing process improvement,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKSSURBVBgZpcFNaNt1HMfx9+///2VptppujuE21LoNOjcHY6D4gGAUcToY6KVgFdHTTqIICirqdvHgyYPozQfQg9DhQYaSeaiu1DGkaKE6mXuwtqVNSqNJm/wf8vt+zCGDIbjLXi8niRsRcR317x6crVUfENfhJNGYfFgyIeleTLtlOizp+YGdR5FE+8pXyPS1zL6RacqCTcm08fbRn52TxOoPFRV3HqXbmCUqbsNvPsjA9kcgHgQM5Q2S5SmS2jTZ6u+Ubq3w98ynDD894zw9MpWTxWpzy30fgwyFFvk/Z/Hl+3HOk9W+pLDxABv2PgsKrJx7Dwv2GD0RPVsr37csXwcZ+cpJ8pVTWPInyABh6RLp4he0L7wFMtLVS8jsJ3o8fTIBhkIGloMzrDOFi3MUEhQS1E1BgahQpttu7gAanj4FAwksQyHHRQHogMtxSkEJWAoICwELZvR4+mQCGQoZUg6KgQRIESkKOQopkoE5FKxAj6dPwTBLiUp7CGsz4DZAlEHUAZdTO1ejfnae9lIFN+iRwtjIMV739Mns/eZvn708tO8FLJ3HRes4n+N8Rv3HBTpzJQ6NvUFx1110Zqr8eub0q6cfLSw6SVz11/ghDe55ivLeUcLaSQpbihA1mHzuA+5+5h1KFydgYRKGNrPih5munrnsuYaCbVu79G09KgxR3jeGi34BJsiWOwxs3wVHXuEqf3wHsbk7nCSudfnzA/ujQnm2PPIE5f1HiIsDTIw+xD2PP8mmuVOknSXaQKsZc/4iC04S//XHJ3feomAvRn7TmzeNVJgbH29Yq1S+bWs39tE8rXqXK8txyBO97STxf85/uPvmkHVPWNZ9rTntX1pfXTwWBzccYi0IPjpc7b77L4KQewoBSj4ZAAAAAElFTkSuQmCC",Research and Development,60.5
      13,Networked 6th generation forecast,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAGtSURBVDjLpZO/a5NhFIWfL1bNoFQdREMRRAo62CqIhOImWRz8A9xcNU4uFd1asEs3cXDxX+ggFkTQoZRsUrGDCDpoY4VSEoPRku+e4/B9+UUyFHqnM9zzcM77chPbHGQKHHAmumL51c9eFNkYiAAMlpAhlOkQLNw5lwwBAEonj2CMBQYsI4MHIBJ8/dUeTRA2dm4Q2MbO0+QgyUgmOmMqRGQRsZFyY1drGNIJjQIcyhYNkrDIDeoZu8A0HQNIBQqjfClb7mr1kxiUehSgVITc6+mBzs4rdZOk4wBpChHq9R+GQLP1luaf9/zda9Bq73HrUf3J66cbi31ABBET+avnRmdfudNYpThZo3LtOlOnpnm3uULt09ZCuVo6UegnMBFGKUQ4+5UQaZitnRWuXJwlCsHs2QqRdChfngO43weECZlUzrWIyJLstrY5nBzj9qUHADy8+YILp2cAigNvID5/b/c6S8JhBOz+brBZX2ejvsZ85SVLb+5SPHQU4F+yn2ssV0uLU+cnH8/N3GD6zFW+bH9g/eMaP741l5P9nnO5WloC7gHHgRbwvPasPv8fJZl0Xd9fi4EAAAAASUVORK5CYII=",Human Resources,20.3
      14,Fully-configurable 24/7 matrices,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJlSURBVDjLpZNrSJNRGMdlr7qat+zKaoYhjqYphRCWCtKFoCj60CeRpDB0djHUSMOZm0JhGEmlNhczXXunDgy7TNcVcsjGpk6dNsiJyyjWNg3ZnJfef69vMBBkFn34wXMu/995DocTBCDof1h1cvBJnM5RTsBVyYLzBgvfigjopbGDfyUwK+Nfu2RsTNcTDO5aAk4RC1/KQ2BqjetbU+AiOZip/xNyLndQSeCHmMBUIQFzTjDWFDiu0O0qzmJKU4OvPSmYuETAXhKM8WshsOYR0NZlRAUUtOXt+Dk99hYufSu+6x7D8fEAnLozmLEq0V3M8ww1F4QGFEhz+Aa3QQmHsQPeQZJGxdRuEwnp+SRjwCs0FpwIf3guwfayKBE+owxzI50M3oGn0JbuQW323vE7uac2rSpoFB6Pll/M0FjEofDZe2Go2ocu0VGG5dpjUWOEXpPlp72X5h/irhBIcrNYNunp5s+31gFTWmCsAfiQDWiOgXq2H1Q7H1TPSVCfmjBaHY4HFzJfNOQd5vgFZGHmo5n7bEBfQlPMBNGVCqgTQZGxWGjhwivbCKorHb/UybDf5UFekE76Bf3lu5ccz0uxpIgBOvgMlGoXPeZhvnkbHY7GbEMYnHVseKQb4OquQF+JYMEvMIsElFsroTfQL/TqCBYVOzHfsh0++RZ4mqIxJ98Kj2wzc7qtJhLTb6pguJ5A+QXDLZfLTGXxi45762G7TUs6BKtirWZjWByG/opkH52pWvEKEyphRK8oLan9aurkgCSGslRHYVTCwQjNkDgSpptcqrMwafZd2cGUyTZhRMDf+C/8Blefvm4GxFC9AAAAAElFTkSuQmCC",Business Development,45.9
      15,Cross-platform bottom-line circuit,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAMUSURBVDjLbZNLaFx1HIW/O5ln6jSZJE3SJE1L+pym1aSbirXoogah1KZUIYISRerCot34orjTBsQigt2I+EAEFwouRBMogdgniUmkIMZMpulMY2eaSdqYed659/5/PxelXWjO+vBtvnMsVWWtzP78TDciH6hoVEXeih8b/n2tnvVfQGL4aLOKvqEiJxu3Hqs3lWXupkaLKvqZGvl4z8BoZk3A3Eh/QFVfUpG3o+1921riz+ITQzE7SSBUQy45xj9/T6VV5KyKfNEzeKnyAJAY6e9D9L1QrOdgy67jhGPbQR28lTlujJ1h0+4D+Go3Uy0tsZicorA0M67GnNl3Yvwna3b46FeIDDZtG7DCDXuxC8usLs1gnCJuKUvIqtLauRPsFWoe6sQXjpLPJlhMTlFeSX/nVyMv7Dh0znILyxSzY4iTJ1ReopzPkl+4xb6BTwlE1kEphZaSWPkEjW0PU9cA07/MP+dXkZJi1QXDIaINnVSW/qQ2Vk99LEKEMtg3wQTBvgWVBcq3xymmrhDechw1UvKrCAhgBQnUbScQimLnJpFijkANWOXr4FPemfiBlWqV97e0QDCEuh4qgk+NcM+DAa2Cfx3h5l6CDXHC0Vrk9nlW0z9iey4dTXFOzaaQso04HmoMfjXmnlA1IC5IGbTKmxPfg7o44uJ4HhtjO4i37qdgl3h5fpxvmx5HjeBXkYgvEAAi4N0BqYLYeOLwVPcgRgUjBkHJrC6wt+MARafCkYtDfCTtYb8auTB/4ZNDbbueJhLrAM2AcxfbczAqpO/M4YqHJy6ucclXC/RsOkjRLXPixuWgT4w5XFi49OpfI6eT6YlvMAQhuhPbs/GMR8v6TlrXb2ZjXReBmggbou1ML1zm2vWri4elfsODKU9/vr9ZRU6pkdfaHumvf/2Pr7EdB0ccbM+hq3E3j3b1MXnzCr8mzs+UPe3NDGn1f2f67Vxvtxo5rSLPb33iFauSS5GZucbJ0sXqns4nQ2OJ0SlHeCwzpM6ab7yfq2e7+1TkXUSCKvLhi3bySyM1TRUxgdyQevd7/wI8lcwGoqfWawAAAABJRU5ErkJggg==",Accounting,46.6
      16,Seamless next generation firmware,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAADNSURBVCjPhZBNCsIwFIQnWvAGunHhSrBbQT2Op3EvCJ7JCxTcuhB0YytaW9N0fElbbIs/GZI8eF+GzFPE79X504dXXEq1GyytFYYYoPvh6RkH5raYJqE2GZtKuFljhI61mWlz55URY95FES88CXIsEQEs/xCl7rwx5FmAWKqtIEqAncEe2gWiyOCJRZVh7hVZ/erv0rYKkSNDv4qpELzjSTt3e1yfg1+fgAMMWAeCxghyB02+ORRf5W8HC/mfHdi61XJ162WoS7utXc30BXX/jFnkwiD5AAAAAElFTkSuQmCC",Training,71
      17,Re-contextualized multi-tasking policy,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAGqSURBVDjLlZM7S0JhGMfVox+gqYZuQkMETYZNQmi2+QGKligiCBoalFragoqGzDM41NRQQy4VKDhUSyC0NLR1EeKIt7wePV7/vc/BI97NF36cA+f9/97neQ6vCoCKrVGGgWHswyRDQxkFVU1gkCQpWSqVKuVyGZ1g3+Fyuc5aJYrASOFsNgtRFOukUikkEgmEw2FZEgqFwPN8k4SWmgS0IZ/Po1AoyE8ik8kgmUwiEonIglwuBzrE7XbLkjYBhRVIQIF0Oo1oNNrWUm0m6iYBa6O+gd6pb6WVWCwmVyIIQndBK40SqoTmEY/H/y9olFA7NBMSDSQgisWiPBeSEAMLqIrvWyde1mbgt+jwtDIBfl7D9xRQSCHoOceb3YT8wymq716I17sIbM9WfGbtTl8Blf+8OoUcC8NpAxxDwKEe0eMF+Ba5z75/gaCyq68eNK7EwQj8Zm21UVDtNoPH5XFkL9YBFpLsKvwyglscfFbuR7kLc2zKItvc8TJ93ZwgsDkNwaFHZE+Hjw01/DZtxWvl9hXBGEl6XeXLpWH+zsIJVPa9hQtfmbgjyv4BPlWugike25IAAAAASUVORK5CYII=",Sales,79.6
      18,Self-enabling even-keeled support,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAK/SURBVDjLjdJZSNMBHAfw1UMPhfTUQ5bgkfWQSodmYplroiAkXkvXcnOVipqsWhLKXEvnUEHUOecU72tec8vEVgQamUfeUzzThcc2QUqd+09b+u0pMxTz4fv04/d5+PIlASAdFG6wJWsk3351ofoMZstszKVs22I/V9tjf+4HPrN9z1I0lTZbizWnsTsFsXbZhwKKmadEi03O0KoiQHRnQit3x6LMCqP5dj8OBUiCT2bqhlRY/SyBeagchk4JFgZb0ZZyWXMoIND3buRY1bPtteFGbI03wTiqhK5dhGSGp3xfIJJsz8pj3V4VhZEhCaeYo0Mc+0QvYn/q5BzMv34FXXMSOqSP4RRxsdUl3uHEPwDT/Rwlj+W1lU0nY3dKstjILRAgQ8yFMtcf4y001CjC4ci7UHaJc/74DpAVcqWjMNofTfyHGKvhoppDhSiMAmmUF0qHuGh5Q8VyDxtmQw/mP9xHRhUNbtEukh1AHGLXMN0m21OYLJEMueoelj6GwbxSiZVRPpa7eJioCMBQmsf/C0tPCUanwg+b3+uwoeVhQ1+IlWEeiDk+pqSef4GjV3MSxAlxewpzoD5HRYkP1mfSQXyLgWmOA0LDBDFFRT/fzUQCQDriXvsokNNvaNcDwno5kkpkiBeVobZtAL3VUVDLQw1rkwwQ034wzdBhnKCin+9kqgi1ppFsfKVUKrvF2Dy+BcEYEPEFYLQDwvoWfCoLBzFXAOPXIBCT3ujLdl0fTHHRqwXX9DKGdRAAEkktcP7V15gLjkIHpgpgKrdBl22jqy4GG9pyrKmvgxjzwYD4Bgrodg9UQZYW7Qwri50haXJuaRtTn4LG60bke4D1FmAogS4FG5tLQhgn76A7xwO9wpvYb62kycoot9bkwERXapXS+UkvyDw1yLwRpKW+RHdRAN4Jvc1FcV4Ns6U0+n7Ab/dSu26WPRQHAAAAAElFTkSuQmCC",Services,68.8
      19,Ameliorated human-resource encoding,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAI8SURBVDjLpVNNiFJRFP70ac80w6FEJ2FqsDKmSRpmU6taBRGE4aaCYPatat1qtu3aRosJI4Ro0Q+EIP0QCTM4WhSBBqmkJJr2cvx53vfu69w3vXIapUUPPs69553zne+ee67NMAz8z+cY3aTTaZkIzxMucc6PkD1EoCV/T/YT2TuEdCwW060cm6WAkudofd/v90eDwSA8Hg/cbjfEf0VR0Ol0UKlU0Gg0XpPvYjwer5qJIkAglUo9L5fLopwx6WOMGblczkgmkytWnt2SQpujgUDgn2cOhUKgIme39YCcJmO9XofL5YIsy3A6naav1+uh1WqhWq0iHA6bsRMJHA4H2u02BoOBudc0DUzJw8PygHTG9I0lsM4kSZKpQBAJMHUDanMNe2ZOQS3lKXkeuv77Ev70wFJgVmTMhAjUGi8xte8Edk8vwNl9C32jtEXBNgIziUhMdGsYfn0B714f9B+PMH3sCvrlJ+A6m0xgVdc0BvXLM/gjF4DBOlbv3sMuXx+DWhZevSSPJRCwquvKR8i2IbxTPXD1MzWJk/w1zJ6+jiBb96zeOundQiCki6uiSYS8QwKvPIVv5jh47x3l9rEYj4APa9TgAg5Ez0maOrz2t4KlTCbTLRaLcH7PUuOicHubMLRvNPASsg8LIgp8UID/8H7oKrv6anl+zjb6GhOJxCwR3TiorCwtXL5tl+wlImiLSx6ZRTuknRHUP+RReLz8wDbuOb+5udg0dO6mY9sN0Vyu801Ls/LLYrPp2Z9W3anPTwD1kQAAAABJRU5ErkJggg==",Training,78.4
      20,Intuitive 24 hour data-warehouse,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJZSURBVDjLpVJda5JhGPYH9Ac66bSdFHTydtDhIAiCiA6CEbGiL1bUTgaO9pHk1+y11ymyNT/wYypMxzanqa8Km9PJxg5EJcWBJq7OzUHIRlfP/VQyKWLRCzcP78113dd1X8+jAKD4n/pngtfrhdPpxMLCAqxW6x1FLpcD1dbWFjY2NpBOpyHLMmKxGNbX17GysoJgMIhAIACPx8OxR0dHODg4gMlkKiuy2SyOj4/R7Xb/Wp1OBw6H41O73Ua1WoUkSQ2DwTCiyGQyvNFqtZDP59FsNkG9RqOBZDKJ/f19RCIRjgmFQiiXy9zRzMzMYC+DVCqF7e1tRKNRYXNzE8vLywKRFxcXBVrDZrMJRDabzYLP5+P7q9Xqgd6AeDyOYrHIM6jX6zwDUiZypVLpKbOBKBQKpI6pqakzfbewurqKw8NDJBIJsKSFcDhMSgLZZWEJRNbpdILdbicyfrtGBpzY3d1FrVYDkUl5aWkJpVKJBnJltgr29vagVCq//fEduN1uShrz8/OwWCyUNFjS0Gg0UBqe44VlCI/e3sDQ60FcU16cOPVDeiLdfKUK3kOkbEXhswwpOYLb0gVcfnpW5ACXy3We2Xs3NzdHScNoNEKv11PSmJ6exl3dVayVTFj7YKbdIaYeQko9pgFf+QAWFrczOzs7KoriR0YePeng+stLeF+24+QXLlppwA8Ae9MTLGl+XTs7O/D7/Tzp8fFxjI2N4cqzc3gj34dOHuZkXWK438Gv0mq1UKlUmJyc7HPAgOpb4gCM8gOuTCf99zI4TTGwntUXsv3z1FP/O6UL4ZoSeea0AAAAAElFTkSuQmCC",Research and Development,46.9
      21,Diverse multi-state strategy,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAANTSURBVDjLTZJtTFNXGMdvlpgl27Jvi5/2meyLWZbFGBdBBqJpi0njEtzEJUZa7LBGrARwTkvZFFpqodmKMC0CCrG1jSJqfCktl65YkUKtIFVKl6KzlVZa2vJShP/OOXHNbvK7ee5znv/v3HtyOQBc6hb3AUFJ8BIeET6k/f9Dehvfr7sJOf/1uXkrt4GgTo3se5mJ2pEYKY24+4qdxx9kHITYexwP+8T8wpgsujh5Mkbm3YTPmSDSy/2ccO9/tRK+hbnhA/OPTVuTDc4ofh+J4OL4awatz/EzGDd9lY776tLJccUbkhslbOBmL3G/LHhPxsJDB+Zdl7eu6odDuOr9Bz383zBYJ6A3T+CSbQY9Yy9hHLTjWd/OtcVZ87vw9S/8JJvDBdq4bVPtH/n/urAprbbPoNcdgtUexPRsAtFEEnOJFPyhBLrvTcM4FMTVG03w9mxZnmz/1EOyOewgjl+8qam2+NDuDMJEdqPX23gcz1+9xhKpKcl14Hz/NAyOFzhl4vFTh+s3dgb0tq9t1FF1zYfzd/yYJDunV9eRTKfxh7EDESJaWF6G5e4A+OdxnDU9AZ2lmazgu2Y+VtnjQeMVLyKLGbxdXsMKWahV1uGy9QaqT9fhnssNXzyDYwY36CzNZAW7z96JSS+4oewYQyiZIZI1zMYX8GuTloX5sSeYWwUeRzOQNw+DztJMVrDr1DXHXp0ddd2juP80DMvt+9CQsNFoREOjGqOBIJ6GE6hv0LCe6kwjflA0BnJzcz9mgvyqTqVAeR1H2oZwqFqLlpYWhMNhBAIBDA4OQkeeDe1/YnLKz3pOp5PNiEQiNRN8Izd8TZjYLtVAUVUDj8+HE6frUVxcDIlEAr1ej9raWlYLRSKI9x9KUolCoYhn//XNkqZy4V5JRqmqZ4KjzTbkF+yAzWaDx+MBz/OwWCzI/7YQWw6ekVOBSqVaygpcLle+TqfDYbmcCQTfy8hwAYqKiiAWixm0LiwsRGlp6SMqKC8vn2fh/v7+zwjJgYEBuvhOrWla6r7Su2q1WtHa2orKykrU1NSwmvbMZjO0Wm2CfOIzJujq6vqEMNXZ2bkik8n2CASCYFlZWaqiomKJsFJSUvIjoYDUKTl5Q6lUui4UCkN5eXlf/gvG8MXqEEqGrAAAAABJRU5ErkJggg==",Training,9.80
      22,User-centric empowering concept,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAKFSURBVDjLhVNNaxNRFD3vzUwSJ622YEwgYoVaNBUVilZwqStBtJBNxC4EEel/sDsXLhRcVxSUQo07QVy0jbpQqiANsS5ciNpowBhM2kk7nWS+vPdJqi0tXjhz39x595zz7syIMAxRKBSilM8TLgZBcIjyAIGWwQfKnyjfIxRGRkZ8bAoxOzs7SJumEonE0VQqhXg8DtM0wcTLy8toNpsol8uo1WqvqJbLZrOVDQzT09MvFhcXWS7cLlzXDYvFYpjP5x8w8b+QdDmcTCbxv0in0yCRs5vrOhUVU7VaRSwWQzQahWEYqmbbNur1OiqVCvr7+5kA2xLouo5GowHHcdS953mwLAutVks949qWBJ2zaJqmHPBmxs0ndXRHe2G3PfR2RfBo/geEHEy8v1sKg1CgYa3hebFyct0BK9KwVBZCYM12cHr4IC4MdeHpm+8Yv5TZoPzwZY0cibeyQ+D7vmpm8Npuuag3PbV55l11vdGhktUCakttEgr+zoDVGdzMx5FSQAsB1w9we2yI1OioRKDR1dShZmOttv8QMDrqHcKYIeGQixv5ryAueEQUEJiEn/PCNAJIVuRXRV+ieoWd8Eix5XvQpEFWdZAfyho1SiIQcEmsTQNmB5fn5uYeZzKZeF9fnyLhITbtKgxqHDvXTWRtopRKNaRzx/QIbk2V8ctahZ7L5Z5NTk4eWVhYuF4qlbJSyl38L/hBijQNBFjD/flr2G3uIxcSNfsbrp64Q6sYDZpmwHZHR0e/ULrCmJiY6F5ZWTmg6+n5/Skg2dXEmWPD6ImklYklJ409cQ9mhD4icirUQLaI42Mzrwf27jjVE+0hyzvpGC4EDViEPgJh42P5M35aLn4DnlayCCcx84IAAAAASUVORK5CYII=",Services,22.1
      23,Intuitive responsive matrix,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIMSURBVDjLpVNLaxNRFP6STmaKdFqrgYKWlGLSgoiKCwsKVnFRtBsVUSTNyj/gxv4Bl678AyKCoCulgmtd+W7romgzKT4QMW1G+5hMpnPnnuuZm6ZNawoVBw7n3pn5vvP4zkkopfA/j9F8cafO3FekCjGpIgKIvayftTXOkr71jkz2/UXA4HxXfz72gIx/lBsWSfiVtwiWHK8B3kRQeX/6lmnnkuDAwn0MJSKQEFChQCp9CcHixxgsGWw3B01uRKfx9t1HIP1POpoSdUulLyD0vqO26IAkDW7tgSZYeHPqcmpXxkTChKzOaAKSEdo6jnEWVY5ehFxdHs2cn55rScDR73H6DKyyRWs1R0haGdR+z8YZ3MyMTj9rpUKi/PLkUJuZfmX3nkNYmQBxzYprpyCA2XMRrvNAcdfDhgKkm6ttKTdW6jH4w4RpD/ALAaNzhH2kSwALoSJCd9+VhIqEVVeD4C1MclaOT0Ke0Cowq+X9eLHapLH23f1XreDzI27LfqT2HIfvzsRAyLB2N1coXV8vodUkfn16+HnnvrPDhrmXsxBY+fmOwcVlJh/IFebK207iuqSShg0rjer8B9TcWY7q38nmnRstm7g1gy9PDk2129mjinjy3OIvJjvI4PJ2u7CJgMEdUMmVuA9ShLez14rj/7RMDHzNAzTP/gCDvR2to968NSs9HBxqvu/E/gBCSoxk53STJQAAAABJRU5ErkJggg==",Business Development,45.3
      24,Persevering bi-directional monitoring,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAF8SURBVBgZBcFNiIwBAAbgN5etvQiJOPiuyk/YwqLk52v9NbTtarDGNpbhoCknHKgtOXxDIU60mVI4OOxVbtuchaTkoByUMpoc/NTjeSIi0irPd5q9U/2J/uHe7s7mUkQkImeLi1VrcM+cZ56oXLJusKZaVohEThcz3fve+Oaz1+bdctdNNUPdFBKZqu54658v2q54pKvlsmt2SCWpleODl75aMKvtu3MWNJ02oymDlCk7N7zwR9tHc9pm/TDtpHFNa6WT0d4d930y54E583inoe6YmhHpZX3/oVnP/fTKvF/+emzKpJo9tkk/Rf+2q9qe+uC39x5rqBt30E4bpJ+lvUuuaLmg5ZymhhMm1OwzarX0sqiz33UN06Y1TKmbcNSY7UYMSycpM5hxxnF1dZPG1YzZaZOVMkgZSbXOpGMOOeKIA/baaqNVhqSSSIp01xhV2mWrLTZZa7Eh6aaQiKRIlcESK6y23LAhGaRKIRIRkZTppJd++umlk1JE5D9AhzZjNC9N+QAAAABJRU5ErkJggg==",Business Development,13.8
      25,Integrated interactive artificial intelligence,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAI4SURBVDjLhVPNaxNREJ8k2yxuDMGEkGi0QltREC9+HQQPKl5EkBz8D7xI/QDxIh4KpeA5lII3IbeAF6UKHjU5SS2op1JKTFiN5GOD6WY/s/t8M5u3bkvBWWZneJn3m99vdhJrNBqrjLEH3MH3fRBRuOd55NN8qVwuL0PU6vX6N13X2f+s3++zWq1WxwZRlxAZbf37CBiP/IzcxwL4l1+bZcRkvxGAG2DAscxMAIAPRaBXS3NIguu6VNdefHoPDPP97Ku1X1KAynXzwuGuBdudMSiHkmHnoxmJxwRdnEwm0L7/5HkK3BV9bGzwo0uBhKmeTEqGCwvyHimYDwcBgxPq7yKMjTe2Y68cjnsXf1y/s0gMEjEAj1e2h+4e/X5kHv6Xr3C+rS7ounHbNa3HcpJVYGw+JADsfuuMHGok6VNWaMmkDNrnFEx2deAMXpz88DrWvHyzApZ1WkJdwhzHgW63C5qmEeVsNgv5fJ4D8JkguGEBGxtBsWECs20gAPEp8bKqquFC8f2gPJ1Og692QHIdYIb1rHn2yqO0IsHoj70VFwywcDAYUCyVSuQI0uv1KMZuXIVP2SM7YJrrM75XYY4NYNmr8agE0VloF/MRM9mcP95hln1XTjAY/RxuzPW21iQcnJCAmpF2q9UKgfBMAGCzuebm0k7uVAecyVvaxCgDHBh25XtPF3K5HBSLxRBAfKX5wfbLcJXxEH9UFIW8UCjAQYY1B/4XOIOP1Wr1HDLBgmgUecTf7Qf4C2kj+HVimC2aAAAAAElFTkSuQmCC",Accounting,21.3
      26,Seamless next generation workforce,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAJvSURBVDjLhZNNSFRRFIC/N++9eWMzhkl/ZJqFMQMRFvTvImkXSdKiVRAURBRRW1eZA9EqaNOiFlZEtQxKyrJwUS0K+qEQzaTE/AtLHR3HmffuvafFNINDWGdz7z2c7+Nyzr2WiFAIffaMBDW1+B0diAgYgxiDiCDG4DU1QfcLos+fWAXGYUGIUsXiAliUFER+sBAhVCIIVB7QGtEat1oTbcwVz2LMfwR+gPg+oY0bEa3x6sHdUoVdniMUj0M2i/j+PwVJa2QUu7YWp34D7mqNWdNApD6Ks24dpvcL4gfJRQXevbutjI4lGRzCS9iYukPo5dvxVqWQvn6k/2uyoudd60LGEhG43VBGyI4j2ADZ7vDJ8DZ9Img4hw4cvO/3UZ1vH3p7lrWRLwGVneD4y6G84NaOYSoTVYIFIiAGvXI3OWctJv0TW03jZb5gZSfzl9YBpMcIzUwdzQsuVR9EyR3TeCqm6w5jZiZQMz8xsxOYzDTi50AMVngJNgrnUweRbwMPiLpHrOJDOl9Vh6HD7GyO52qa0VPj6MwUJpNC5mYQS/DUJLH3zzRp1cqN8YulTUyODBBzt4X6Ou870z2I8ZHsHJLLYNQ8jusQ6+2exJf9BfivKdAymKZiaVdodhBRAagAjIbgzxp20lwb6Vp0jADYkQO6IpHfuoqInSJUVoE2HrpyRQ1tic2LC9p3lSHWPh2rJfL1MeVP2weWvHp8s3ziNZ49i1q6HrR1YHGBNnt1dG2Z++gC4TdvrqNkK1eHj7ljQ/ujHx6NyPw8BFIiKPmNpKar7P7xb/zyT9P+o7OYvzzYSUt8U+TzxytodixEfgN3CFlQMNAcMgAAAABJRU5ErkJggg==",Business Development,77.9
      27,Mandatory zero administration ability,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAALISURBVBgZfcFLbFRVHMDh37mPeXQ6M8VaGSvYilRgqmLSKErcSdSVaGIQoytkx0pDQjRx5Up3btSY+IjGFRhWJCQaNYZEQA1YMGWqlXYs6XPK3LnzuI9zzt8aazQG+T4lItzMK8/uHbuzMnhkqNz/mGDMStD+cnZh9YO3Pz8/xTolIvyfNw7tO7T9js2vj+24e3TzsICUWF3qUb9aW7g0t/Tmldnld5SI8F8vPzXhjG0f+WR8pHywujXj3rLN4A7WsEmOYP5FbMZn5soP5uTX3x/0uIFto8PvP/LAxAvjlSYqvkBad6Cvn05q+Tj+jLzOs3/Lk+79u5ZecriB4YHC8zsv/Y4+eQ1ty9jsKK35A9Rr47iOQNLDj0KGSvmqN33qwYu5UrWqlMPfstmCLwnYjEen+AS1qXOtUt+kL5Vd+RNzeyiYhOcGariKoqfE2bn10Y98pRQI64SL3x5m9fE99PuWsLnGYmO6P1hzVd9glR4lHGmDsoB4HloibJKNF9/FJC44JbxNBS78eBbfRty3e4J779nr+K5DLpzhWOMcI7dvIfTz/Lpy/ZRHqhyxCSbJIFawvToT1Tad5QZ6eZFoZgqfv0TA7gLQmuS7a3ed/+Ls9KseSnJW9+gsLBMvzWCTLm62zMjTH6JQzP/yEznTJe/n0CYldgq0vjrKiW9+PnD89OU5j9TBy9/G0MOvARZEEBuiW2ew0VXKuQ6NxSZtkyKqy6axo/zp+OnLc6zzSEXERNjuJGICxITYaBbEIjYi4/SoVBLEtBHTJT9QZpV/eMSIWI1NVxAdICZAbAyiQWLEdhHTweoQMSEoxb95JCIKg+g1RDcR3URMgOgAMQGiQ8S0ENNBbISN66yL2OBJYq/rbqMvbWeK2KIj4oMtgtyKmBhIECcGEpRjMFEkktiYDZ5E8Vu/vffMQwj7UBS5GQHUmQQrn7LhDzEafwIN5+bTAAAAAElFTkSuQmCC",Product Management,80.2
      28,Secured hybrid concept,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAGgSURBVDjLY/j//z8DJZgsTV+9fAu+uHo8+GzvXECWAV+c3R//mTn9/ydLu4eka3ZyY/ts63T3k4Xt+4/GlqS74JONY+9Hc5tdH4wsmAmGgWv9xQKX2nMPnapOF4A1WzsEfjSzefLB0FwUHoi/szPX/05P/f0rOWk9ugHONWefzNl44X/B/L3/o7LXnn1h4fitN6i22Tx7W5tpxqYHxmnrChh+p6X+/rd10/+fsbF/f0REmiE0n7F3rDz5wb7s6Bu3gt3Vz80db69zTd1mlr11tUnGxt89Cw/8N0ha9YDhZ2LC+p8xMb9/hEdc+h4Ucu+br//JFXFNi5zKjz20KztiDzIMGFgzP+iZboQZbpSypsAgaeUjvfilqIEI9C9bf8rk3Wd8kz59sHV+BQysa8DA+vNe1+Trew0DfrwJCehfCceqU8fsy48ttS05xAkMLANgYP39N23K/3fq+n9wpkTXugsFQP8+B/r3DdC/pciS77WN1r9T0/v9Vkl7PU4DnKrPPJi85uJ/oH9fkpUXHCqOF9iVHn5gU7S/gG6ZiaoGAADG9LhB7Kzu8AAAAABJRU5ErkJggg==",Research and Development,26.1
      29,Phased composite project,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAACWSURBVCjPY/jPgB8y0ElB+YHyA8UTcg+kLYjfEP4Bm4ILxQa5Dqn/4xv+M/hdcHXAUFAc8J8hzSH+fzhQgauCjQJWN8Q7RPz3AyqwmWC0QfO/wgKJBWgKwh0C/rsCFRgBTVP4/59BMABNgZ+Dx3+bBghb4j8WK1wdHP4bQRUIYlNgs8DogOYGBaAPBB24DrA40Duo8UEA+kT4W+XS/8wAAAAASUVORK5CYII=",Accounting,72.1
      30,Multi-lateral hybrid data-warehouse,"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAIESURBVDjLpZM9S9ZhFIev/+Pz+BKGUBAZJUQEOqRCi6hDYAYtfQdXySki+wYubeHQEoHQWoRLYBGIOFhkJTg0tCShgfq83W/nPqfhH9SgIXTGM1zn+p3DKcyM/6nqUc3553uWVYkCOStRlCDKs9lLxYkAISqTg6cQVdRAsvFyo35yA5eUmJW9QyFlo6+ng6bTkwNaToii+KRINkK1QsPJ0QB7eL/coiqWBEtC+/IDQjR8MpIo3bVM3ed/GEzdBFWKnClyprGpBDFcyKQMPTWjflwES0IhAh/egyQYHqXpIj4p7VhG8J0F4tIxgBBLQPCQBJJwGIyQFBeUlI3eLkVbytzKjKUoxJhIPhFCoqI+gAj4AN5DjDRbio+Gi6WFT8ZQ/xqdXzO23UC29xnQAXzLU1X3e3IIECOIIC6VBlGJ2QjtZW5MbHB9aIyLZ67ydusF619WONgVKtoup+JcaZAS2lJ8LAEuKu3GC0YHR8iVzEj/NLlIjF0bJzYOqVjb/RWhjKNOcekPYL/5g1rRy52hOQDuTT3hyrlhMKOqbQcpwfgE5AwimBOiGOf7aojC928HbO2ssbmzyvz0UxZez9Dd0VVe4VHXLXRpFwuCpYyljPZmlpd2ICqWhbMDt1n/9Ibx4UlefV6ks6iy+vEd9Z9DFCd957G7FxaAWeA00AAW1x/vzP8Cqr99v3YC63EAAAAASUVORK5CYII=",Marketing,62.6
    |||),

  testdataHomeSolarDay:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_content')
    + testdataQuery.withStringInput(|||
      house_draw, battery_charge, solar_output
      1.1, 2.2, 3.3
    |||),

  prometheusSmallGraphValues:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(prometheus_sd_discovered_targets{}) by (pod)
      ||| % config,
    )
    + prometheusQuery.withLegendFormat('{{pod}}'),

  prometheusSmallTableValues:
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum(prometheus_sd_discovered_targets{}) by (pod)
      ||| % config,
    )
    + g.query.prometheus.withInstant(true)
    + g.query.prometheus.withRange(true)
    + g.query.prometheus.withFormat('table')
    + prometheusQuery.withLegendFormat('{{pod}}'),


  testdataSetSmallTable:
    testdataQuery.withDatasource(variables.testDatasource.name)
    + testdataQuery.withScenarioId('csv_content')
    + testdataQuery.withCsvContent(|||
      "id","Catch phrase","Something","Sensor"
      1,Cross-group next generation middleware,Engineering,36.7
      2,Horizontal non-volatile system engine,Support,4.80
      3,Open-source analyzing hierarchy,Legal,79.3
      4,Universal 4th generation alliance,Support,20.8
      5,Multi-tiered mobile analyzer,Sales,36.7
      11,User-friendly explicit website,Training,90.5
      12,Customizable analyzing process improvement,Research and Development,60.5
      13,Networked 6th generation forecast,Human Resources,20.3
      14,Fully-configurable 24/7 matrices,Business Development,45.9
      15,Cross-platform bottom-line circuit,Accounting,46.6
      21,Diverse multi-state strategy,Training,9.80
      22,User-centric empowering concept,Services,22.1
      23,Intuitive responsive matrix,Business Development,45.3
      24,Persevering bi-directional monitoring,Business Development,13.8
      25,Integrated interactive artificial intelligence,Accounting,21.3
    |||),

}
