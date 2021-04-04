# ssh config

This directory has a public and private key configured 
for the vagrant machines.
These keys a there just for demo purposes and should not be used
on any system for realz like :-)

They are used in this docker-box by default for this docker-box, but you can
overrule them before you provision it as instructed below.

## Create ssh public/private keys

```bash
ssh-keygen -b 2048 -t rsa -f ./id_rsa
```

Follow instructions.

Note:

For testing it might be easier to use a private key without
passphrase (just press enter twice when asked for a passphrase)
as is done for these demo files.

## Passphrase  

If you do get a message like:

```text
vagrant@ubuntu-bionic:/project$ ansible -i ./hosts developer -m ping
Enter passphrase for key '/home/vagrant/.ssh/id_rsa':
```

That means u did use a passphrase and that is actually more production like.
To be able to use ansible in this case you need to start an ssh-agent to 
remember your password and give it when needed:

```bash
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
```

or use the /bin/set-ssh in this project:

```bash
source /project/bin/set-ssh
```

# Windows

the `id_rsa.ppk` file is the private key but as used by Putty.
