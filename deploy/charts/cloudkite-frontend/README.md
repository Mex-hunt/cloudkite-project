# Cloudkite frontend chart

The chart deploys the frontend with rolling updates, health probes, horizontal
autoscaling, a disruption budget, and an optional internal GKE ingress with a
cert-manager TLS secret. The intended TLS issuer is Google Certificate
Authority Service through a cert-manager issuer such as `google-cas-issuer`.

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
  --set image.repository=obachimex/cloudkite-frontend \
  --set image.tag=GIT_SHA \
  --set imagePullSecrets[0].name=dockerhub-registry \
  --set ingress.enabled=true \
  --set ingress.host=auth.kite.com \
  --set ingress.staticIpName=cloudkite-internal-ingress-ip \
  --set ingress.tls.enabled=true \
  --set ingress.tls.secretName=auth-kite-com-tls \
  --set certificate.enabled=true \
  --set certificate.name=auth-kite-com \
  --set certificate.secretName=auth-kite-com-tls \
  --set certificate.issuerRef.name=google-cas-issuer \
  --set certificate.issuerRef.kind=ClusterIssuer
```

The private Cloud DNS record points `auth.kite.com` to the internal ingress IP.
cert-manager writes the TLS certificate to `auth-kite-com-tls`, which the
Ingress uses for HTTPS.
