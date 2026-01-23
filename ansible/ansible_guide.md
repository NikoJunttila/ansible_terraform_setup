## Check playbook syntax (NO execution)

ansible-playbook playbook.yml --syntax-check

## Dry-run a playbook (very important)

ansible-playbook playbook.yml --check --diff

This is “what would change if I ran this?”
No changes are applied
Shows tasks that would run
Some modules can’t fully simulate (Ansible will warn you)

## Lint your playbook (best practice)

If you install ansible-lint:

ansible-lint playbook.yml

## Test inventory connectivity (no playbooks)

Ping all hosts:

ansible all -i inventory.ini -m ping

## Run against a single host (safe testing)
ansible-playbook playbook.yml -l myhost

Or limit to a group:

ansible-playbook playbook.yml -l webservers

Great for: Learning, Testing changes, Not nuking everything

## List what hosts Ansible thinks exist

ansible-inventory -i inventory.ini --list

Readable version:

ansible-inventory -i inventory.ini --graph

## Run only one task (tags)

Tag a task:

- name: Install nginx
  apt:
    name: nginx
  tags: nginx


Run only that:

ansible-playbook playbook.yml --tags nginx

## Beginner “safe workflow” (recommended)

When learning, do this every time:

ansible-playbook playbook.yml --syntax-check
ansible-playbook playbook.yml --check --diff
ansible-playbook playbook.yml -l onehost
