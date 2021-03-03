# dns-over-tls-example
DNS over TLS (DoT) example

Build an image containing curl, knot-dnsutils and golang-cfssl
```
docker build . -t dot-example
```
Run a container
```
docker run -it --rm dot-example
```
You can query public DNS servers such as Cloudflare or Google DNS
```
kdig -d @1.1.1.1 +tls-ca +tls-hostname=one.one.one.one wikipedia.org
kdig -d @8.8.8.8 +tls-ca +tls-hostname=dns.google.com wikipedia.org
```