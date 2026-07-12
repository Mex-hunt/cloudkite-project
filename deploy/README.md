# Cloudkite deployment structure

This folder is arranged for Argo CD with one reusable chart and environment
specific values.

```text
deploy/
  charts/
    cloudkite-app/
  production/
    applications/
      cloudkite-production.yaml
    Chart.yaml
    namespaces/
      cloudkite.yaml
    values.yaml
    values/
      cloudkite/
        frontend.yaml
        backend.yaml
```

Create one Argo CD root application from the UI:

| App | Project | Path | Destination namespace |
| --- | --- | --- | --- |
| `cloudkite-production` | `default` | `deploy/production/applications` | `argocd` |

The root app syncs one file, `cloudkite-production.yaml`. That file creates the
namespace app and an `ApplicationSet`. The `ApplicationSet` scans every file in
`deploy/production/values/cloudkite/` and creates one Argo CD application per
values file.

| App | Path | Values file | Destination namespace |
| --- | --- | --- | --- |
| `cloudkite-namespaces` | `deploy/production/namespaces` | n/a | `argocd` |
| `cloudkite-workloads` | `deploy/production` | all files in `values/cloudkite/*.yaml` | `cloudkite` |

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
