discord bot and analytics backend are encrypted with ansible-vault
find key in vaultwarden

pocketbase was added manually to rasperry due to it having already data. runs on port 8090

calendar-app has old sqlite database i am importing figure out how to make this again nicely backup and export back in

## TODO updates
Tags (huge quality-of-life upgrade)

Add tags to roles in playbooks:

roles:
  - { role: caddy, tags: caddy }
  - { role: docker, tags: docker } tags (huge quality-of-life upgrade)

Add tags to roles in playbooks:

roles:
  - { role: caddy, tags: caddy }
  - { role: docker, tags: docker }


ansible-playbook playbooks/vps.yml --tags caddy
