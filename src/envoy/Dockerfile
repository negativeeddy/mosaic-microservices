FROM envoyproxy/envoy-dev:4fd31f2a59cfd4e41a3e90d488b5067411327b60
WORKDIR /src
COPY ./envoy/envoy.yaml /etc/envoy.yaml
CMD /usr/local/bin/envoy -c /etc/envoy.yaml