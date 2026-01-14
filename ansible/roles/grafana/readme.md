This currently fails settings up connection with prometheus so need to run this manually or setup up better
With ip we got from command you can connect to prometheus from grafana.

sudo podman inspect prometheus --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
10.89.0.7
