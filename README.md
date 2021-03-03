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
From here, run the following commands inside the container.
Alternatively, install kdig and cfssl locally.

# Test with public DNS servers
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
  cfssl gencert -ca intermediate_ca.pem -ca-key intermediate_ca-key.pem -config cfssl.json -profile=server dns-host.json | cfssljson -bare dns-server
```
Inspect the certificate
```
openssl x509 -text -in dns-server.pem | more
```