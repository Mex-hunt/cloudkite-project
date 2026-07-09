# Cloudkite frontend chart

The chart deploys the frontend with rolling updates, health probes, horizontal
autoscaling, a disruption budget, and an optional GKE ingress with Google-
managed TLS.

Use the Terraform outputs to configure ingress:

```bash
terraform -chdir=infra-modules output ingress_static_ip_name
terraform -chdir=infra-modules output application_hostname
```

Deploy with a configurable image version:

```bash
helm upgrade --install cloudkite deploy/charts/cloudkite-frontend \
  --namespace cloudkite \
  --create-namespace \
  --set image.repository=us-central1-docker.pkg.dev/PROJECT_ID/cloudkite/auth-frontend \
  --set image.tag=GIT_SHA \
  --set ingress.enabled=true \
  --set ingress.host=auth.example.com \
  --set ingress.staticIpName=cloudkite-ingress-ip \
  --set ingress.managedCertificateName=cloudkite-certificate
```

Google provisions the certificate after the DNS record points to the ingress
IP. The certificate can remain in `Provisioning` for several minutes.
