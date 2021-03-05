# dns-over-tls-example
DNS over TLS (DoT) example

# Build container image
Build an image containing curl, knot-dnsutils and golang-cfssl
```
docker build . -t dot-example
```
# Start a container
Run a container
```
docker run -it --rm -v $(pwd)/cfssl:/cfssl dot-example
```
The above container can be used for running `kdig` and `cfssl`.
Alternatively, install kdig and cfssl locally.

## Test with public DNS servers
You can query public DNS servers such as Cloudflare or Google DNS
```
kdig -d @1.1.1.1 +tls-ca +tls-hostname=one.one.one.one wikipedia.org
kdig -d @8.8.8.8 +tls-ca +tls-hostname=dns.google.com wikipedia.org
```

# Generate TLS certificates
For this example, I'll use self signed certificates.
Root CA
```
pushd /cfssl && \
  cfssl gencert -initca ca.json | cfssljson -bare ca && \
  cfssl gencert -initca intermediate-ca.json | cfssljson -bare intermediate_ca  && \
  cfssl sign -ca ca.pem -ca-key ca-key.pem -config cfssl.json -profile intermediate_ca intermediate_ca.csr | cfssljson -bare intermediate_ca  && \
  cfssl gencert -ca intermediate_ca.pem -ca-key intermediate_ca-key.pem -config cfssl.json -profile=server dns-host.json | cfssljson -bare dns-server && \
  popd
```
Inspect the certificate
```
openssl x509 -text -in cfssl/dns-server.pem | more
```

# Create a secret
```
pushd cfssl && \
  kubectl create secret generic coredns-tls \
  --from-file=dns-server.pem \
  --from-file=dns-server-key.pem \
  --from-file=intermediate_ca.pem && \
  popd
```

# Deploy CoreDNS with TLS
```
helm repo add coredns https://coredns.github.io/helm
helm upgrade -i example coredns/coredns --version 1.14.0 -f values.yaml
```

# Resolve DNS queries over TLS
```
kubectl run -it --rm --restart=Never --image=docker.io/alpine:3.12 sandbox -- ash -c "apk add knot-utils;cat"
```
From another tab
```
kubectl cp ./cfssl/intermediate_ca.pem sandbox:/
kubectl exec sandbox -- kdig -d @example-coredns.default.svc.cluster.local -p 5553 +tls-ca=/intermediate_ca.pem +tls-hostname=dns.example.com wikipedia.org
```