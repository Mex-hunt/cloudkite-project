# Cloudkite deployment structure

This folder is arranged for Argo CD with one reusable chart and environment
specific values.

```text
deploy/
  charts/
    cloudkite-app/
  production/
    Chart.yaml
    namespaces/
      cloudkite.yaml
    values.yaml
    values/
      cloudkite/
        frontend.yaml
        backend.yaml
```

Create one Argo CD application for namespaces first:

| App | Path | Destination namespace |
| --- | --- | --- |
| `cloudkite-namespaces` | `deploy/production/namespaces` | `argocd` |

Then create one Argo CD application per workload:

| App | Path | Values file | Destination namespace |
| --- | --- | --- | --- |
| `cloudkite-frontend` | `deploy/production` | `values.yaml`, `values/cloudkite/frontend.yaml` | `cloudkite` |
| `cloudkite-backend` | `deploy/production` | `values.yaml`, `values/cloudkite/backend.yaml` | `cloudkite` |

Do not enable `CreateNamespace=true` on the workload apps. Namespaces are
managed explicitly from `deploy/production/namespaces`.

Both workloads use the same chart dependency, `cloudkite-app`. The environment
`values.yaml` contains shared production defaults. Each app file only overrides
the values that are specific to that app.

The chart keeps the common app sections reusable:

- `image`
- `imagePullSecrets`
- `serviceAccount`
- `service`
- `containerPorts`
- `env`
- `livenessProbe`
- `readinessProbe`
- `resources`
- `autoscaling`
- `podDisruptionBudget`
- `ingress`
- `certificate`

Backend-specific behavior is optional and lives under:

```yaml
cloudkite-app:
  backend:
    enabled: true
    databaseCredentials:
      enabled: true
    cloudSqlProxy:
      enabled: true
```

When those flags are enabled, the same deployment template adds the database
credentials environment variable, CSI volume mount, `SecretProviderClass`, and
Cloud SQL proxy sidecar. Frontend apps leave `backend.enabled` as `false`.
