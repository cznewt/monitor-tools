{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'base',
        rules: [
          {
            alert: 'Watchdog',
            expr: 'vector(1)',
            labels: {
              severity: 'info',
            },
            annotations: {
              summary: 'This is an alert meant to ensure that the entire alerting pipeline is functional.',
              description: 'This alert is always firing, therefore it should always be firing in Alertmanager and always fire against a receiver.',
            },
            runbook:: {
              runbook: importstr '../runbooks/Watchdog.md',
              explore: 'vector(1)',
            },
          },
        ],
      },
    ],
  },
}
