# Service Level Objectives (SLOs)

## Lambda Cost Notifier

### SLI: Daily Cost Email Delivery Success Rate
- **Definition:** Percentage of days the Lambda successfully sends a cost summary email to admin@company.com.
- **SLO:** 99% of daily cost emails are delivered successfully each month.
- **Rationale:** Ensures finance/admin is reliably informed of AWS costs.

### SLI: Lambda Execution Success Rate
- **Definition:** Percentage of scheduled Lambda invocations that complete without error.
- **SLO:** 99.9% of scheduled Lambda executions succeed each month.
- **Rationale:** High reliability for automation.

---

## Kubernetes Demo App

### SLI: HTTP 200 Success Rate
- **Definition:** Percentage of HTTP requests to the app that return 200 OK.
- **SLO:** 99.5% of requests return 200 OK over a rolling 30-day window.
- **Rationale:** Ensures the app is reliably serving users.

### SLI: App Availability
- **Definition:** Percentage of time the app responds to readiness probe.
- **SLO:** 99.9% monthly availability (readiness probe passes).
- **Rationale:** Tracks uptime from a user perspective. 