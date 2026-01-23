How the Caddy role currently works

1. Adds the official Caddy APT repository (Cloudsmith)

The role adds the Caddy repository manually using two shell tasks:

Downloads the Caddy GPG key and stores it in
/usr/share/keyrings/caddy-stable-archive-keyring.gpg

Downloads the repository definition into
/etc/apt/sources.list.d/caddy-stable.list

Both tasks use creates: so they:

Run only once per host

Are idempotent

Will not re-run on subsequent Ansible executions

This avoids re-downloading keys/repos every time.

2. Installs Caddy via APT
apt:
  name: caddy
  state: present
  update_cache: yes


This installs whatever version is currently available in the Caddy repo at install time.

Important behavior:

state: present → ensures Caddy is installed, but does not upgrade it

Caddy will only upgrade if:

You run a system-level apt upgrade, or

You change this to state: latest

This is intentional and keeps upgrades explicit and predictable.

3. Generates the Caddyfile and reloads Caddy
template:
  src: Caddyfile.j2
  dest: /etc/caddy/Caddyfile
notify: Reload Caddy


/etc/caddy/Caddyfile is fully managed by Ansible

Any change to the template or variables:

Rewrites the file

Triggers a Caddy reload (not a full restart)

Manual edits on the server will be overwritten on the next run.

What you are changing next (planned work)
1. Switch to the new load-balancing–capable template

You will replace the existing template with the new version that supports:

Multiple backends per site

Load-balancing policies

Health checks

Legacy single-site support has been removed — caddy_sites is now the only supported configuration.

2. Update group_vars to define caddy_sites

Each site will be defined declaratively in variables, for example:

caddy_sites:
  - domain: grafana.junttila.dev
    backends:
      - "{{ backend_ip }}:3222"
      - "{{ backend_ip2 }}:3222"
    lb_policy: round_robin        # or "first" for failover
    health_uri: /api/health
    health_interval: 10s
    health_timeout: 2s


This renders to a Caddyfile like:

Round-robin load balancing
reverse_proxy 100.64.0.10:8080 100.64.0.11:8080 {
  lb_policy round_robin
}

Failover (primary-first)
reverse_proxy 100.64.0.10:8080 100.64.0.11:8080 {
  lb_policy first
}

Health checks
reverse_proxy 100.64.0.10:8080 100.64.0.11:8080 {
  health_uri /health
  health_interval 10s
  health_timeout 2s
}


Notes:

Backend order matters when using lb_policy: first

Health checks must be reachable over Tailscale

If a service does not expose a health endpoint, / can be used, but it is less reliable

3. Final outcome

After the changes:

Caddy configuration is fully driven by caddy_sites

Load balancing and failover are configurable per domain

Health checks are explicit and visible in Ansible vars
