# Linux Server Health Check

A lightweight Linux server health monitoring tool written in Bash.

## Features

- Monitor CPU usage
- Monitor memory usage
- Monitor disk usage
- Generate warnings when usage exceeds 80%
- Return exit codes to indicate health status
- Support automated monitoring with cron
- Save monitoring results to logs files
- Validate CPU, memory, and disk usage data
- Handle command failures and invalid monitoring data
- Use reusable Bash functions for warning status management



## Usage
Run the health check script manually:

```bash
bash server_check.sh
```

The script checks CPU ,memory,and disk usage.

Exit codes:
- `0`: All monitored metrics are within thresholds.
- `1`: At least one monitored metric exceeds its threshold.
- `2`: Data collection failed or invalid data was detected.

## Cron Configuration

Edit the current user's crontab:

```bash
crontab -e
```

Add the following entry to run the script every 5 minutes:

```cron
*/5 * * * * /bin/bash /path/to/server-health-check/server_check.sh >> /path/to/server-health-check/health.log 2>&1
```

Replace `/path/to/server-health-check/` with the actual project directory.
