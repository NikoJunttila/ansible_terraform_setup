discord bot needs .env file stuff at vars/vault.yml and then encrypt it using 

The 
vault.yml
 file is currently NOT ENCRYPTED. You must encrypt it before committing to Git:

Run the encryption command:
ansible-vault encrypt ansible/roles/discordbot/vars/vault.yml
When prompted, enter a strong password.
To run your playbook with the encrypted vault, add the --ask-vault-pass flag:
ansible-playbook -i inventory/pi.ini playbooks/site.yml --ask-vault-pass
