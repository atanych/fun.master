## Generate private/public keys for access on servers
```ssh-keygen -t rsa -f servers.key -C "master@example.com"```

#### Add servers.key.pub to all nodes in ~/.ssh/authorized_keys

#### Copy host config for provision master and change "set_ip" to real ip
```cp devops/servers/provision/host.sample devops/servers/provision/host```

#### Ping server
```ansible -i devops/servers/provision/host -m ping master```

#### For setup all dependencies
```ansible-playbook devops/servers/provision/playbook.yml -i devops/servers/provision/host```

#### Deploy all new version to all masters
```mix deploy staging master-v0.0.0```
