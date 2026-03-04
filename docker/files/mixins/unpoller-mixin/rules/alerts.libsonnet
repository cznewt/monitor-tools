{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'unpoller',
        rules: [
          {
            alert: 'UnpollerDeviceDown',
            expr: 'absent_over_time(unpoller_device_info[15m])',
            'for': '5m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'UniFi device is not reporting metrics.',
              description: 'The UniFi device has stopped reporting metrics for over 15 minutes. It may be offline or unpoller has lost connectivity to the controller.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerDeviceDown.md',
              explore: 'unpoller_device_info',
            },
          },
          {
            alert: 'UnpollerDeviceHighCPU',
            expr: 'unpoller_device_cpu_utilization_ratio > 0.9',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'UniFi device {{ $labels.name }} CPU usage is above 90%.',
              description: 'Device {{ $labels.name }} ({{ $labels.site_name }}) has CPU utilization at {{ $value | humanizePercentage }} for over 15 minutes.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerDeviceHighCPU.md',
              explore: 'unpoller_device_cpu_utilization_ratio{name="{{ $labels.name }}"}',
            },
          },
          {
            alert: 'UnpollerDeviceHighMemory',
            expr: 'unpoller_device_memory_utilization_ratio > 0.9',
            'for': '15m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'UniFi device {{ $labels.name }} memory usage is above 90%.',
              description: 'Device {{ $labels.name }} ({{ $labels.site_name }}) has memory utilization at {{ $value | humanizePercentage }} for over 15 minutes.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerDeviceHighMemory.md',
              explore: 'unpoller_device_memory_utilization_ratio{name="{{ $labels.name }}"}',
            },
          },
          {
            alert: 'UnpollerDeviceRestarted',
            expr: 'unpoller_device_uptime_seconds < 300',
            labels: {
              severity: 'info',
            },
            annotations: {
              summary: 'UniFi device {{ $labels.name }} has recently restarted.',
              description: 'Device {{ $labels.name }} ({{ $labels.site_name }}) uptime is {{ $value | humanizeDuration }}, indicating a recent restart.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerDeviceRestarted.md',
              explore: 'unpoller_device_uptime_seconds{name="{{ $labels.name }}"}',
            },
          },
          {
            alert: 'UnpollerHighClientDropRate',
            expr: 'sum by (name, site_name) (rate(unpoller_device_vap_receive_dropped_total[5m]) + rate(unpoller_device_vap_transmit_dropped_total[5m])) > 50',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'UniFi AP {{ $labels.name }} is dropping packets at a high rate.',
              description: 'AP {{ $labels.name }} ({{ $labels.site_name }}) is dropping {{ $value | humanize }} packets/s (combined rx+tx) for over 10 minutes.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerHighClientDropRate.md',
              explore: 'sum by (name, site_name) (rate(unpoller_device_vap_receive_dropped_total{name="{{ $labels.name }}"}[5m]) + rate(unpoller_device_vap_transmit_dropped_total{name="{{ $labels.name }}"}[5m]))',
            },
          },
          {
            alert: 'UnpollerHighVAPErrorRate',
            expr: 'sum by (name, site_name) (rate(unpoller_device_vap_receive_errors_total[5m]) + rate(unpoller_device_vap_transmit_errors_total[5m])) > 10',
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'UniFi AP {{ $labels.name }} has a high VAP error rate.',
              description: 'AP {{ $labels.name }} ({{ $labels.site_name }}) is experiencing {{ $value | humanize }} errors/s (combined rx+tx) for over 10 minutes.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerHighVAPErrorRate.md',
              explore: 'sum by (name, site_name) (rate(unpoller_device_vap_receive_errors_total{name="{{ $labels.name }}"}[5m]) + rate(unpoller_device_vap_transmit_errors_total{name="{{ $labels.name }}"}[5m]))',
            },
          },
          {
            alert: 'UnpollerAccessPointNoClients',
            expr: 'sum by (name, site_name) (unpoller_device_stations) == 0',
            'for': '30m',
            labels: {
              severity: 'info',
            },
            annotations: {
              summary: 'UniFi AP {{ $labels.name }} has no connected clients.',
              description: 'AP {{ $labels.name }} ({{ $labels.site_name }}) has had zero connected clients for over 30 minutes.',
            },
            runbook:: {
              runbook: importstr '../runbooks/UnpollerAccessPointNoClients.md',
              explore: 'unpoller_device_stations{name="{{ $labels.name }}"}',
            },
          },
        ],
      },
    ],
  },
}
