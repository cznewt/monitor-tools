{
  _config+:: {

    h: 8,

    datasourceEnabled: {
      doom: false,
    },

    y+: {
      timeSeriesStyle: 0 * $._config.h,
      timeSeriesLineInterpolation: 1 * $._config.h,
      timeSeriesFillOpacity: 2 * $._config.h,
      timeSeriesLineStyle: 3 * $._config.h,
      timeSeriesLineWidth: 4 * $._config.h,
      timeSeriesGradientMode: 5 * $._config.h,
      timeSeriesThreshold: 6 * $._config.h,
      timeSeriesMinMax: 7 * $._config.h,
      timeSeriesYAxis: 8 * $._config.h,

      tableCellOptions: 0 * $._config.h,
      tableCellGaugeBars: 1 * $._config.h,
      tableCellSparklines: 2 * $._config.h,

    },

    tags: ['reference'],

  },
}
