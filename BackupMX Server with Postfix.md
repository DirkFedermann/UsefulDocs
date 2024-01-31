# BackupMX Server with Postfix

We've all been there: Server down or not reachable, an email comes in and gets sent back to the recipient because of it and never reaches you.
Best case the email gets delivered again when the server is back up, often the email will not be sent out again and in the worst case, you end up on the blacklist of the sending email server, because they have it set that way, to protect their deliverability score.

## This little Postfix trick does need at least 2 independent Server and access to the DNS settings of your domain

I have my server currently at Strato.de and they are both running Plesk. So Postfix is automatically installed and set up and I will use Plesk to set up the domains.
This is not a tutorial on how to set up Postfix - there are plenty of them out there.

## Setting up the primary Server

On the primary Server, set the domain up as usual, with mails enabled, creating an email address, SSL Certification, etc.

Add or Edit the DNS Setting to `@ 60 IN MX 10 mail1.<domain>.`, which means Name is `@` (root - so for the main domain), TTL `60` to have the change fast (please change that to something appropriate like 86400 after testing), Priority `10` (lower the number, the higher the priority) because it is the primary Server and Value to `mail1.<domain>.` (don't forget the `.` at the end!).

Also Add or Edit the DNS Setting to `mail1 60 IN A 12.34.56.78`, which means Name is `mail1`, TTL `60` to have the change fast (please change that to something appropriate like 86400 after testing), `A`-Record to the IP `12.34.56.78`.

If your Server also has an IPv6, also Add a `AAAA`-Record to the same Name and TTL as the `A`-Record.

Now you can test if your emails are being sent and received by for example Gmail.

## Setting up the Backup Server

The Backup Server only needs to run Postfix. A small, cheap but 24/7 running server is enough.

Setup Postfix - as I said above, there are plenty of tutorials out there that cover this. I have Plesk running on it, so it is installed automatically.

### Changing /etc/postfix/main.cf

We SSH to the Backup Server and `sudo nano /etc/postfix/main.cf` (or use vim if you hate yourself 🙃).

Add or edit the parameter `relay_domains = <domain>` and `maximal_queue_lifetime = 10d`.

Now you need to restart the postfix service, to apply the changes to the config: `sudo systemctl restart postfix`

## Adding a Backup Server to the DNS

Now add the `A`-Record of the Backup Server to the DNS: 
`mail2 60 in A 23.45.67.89`. If your backup server has an IPv6, also add the `AAAA`-Record to the same Name.

Add the `MX`-Record: `@ 60 IN MX 20 mail2.<domain>.`, with a priority of `20` and to `mail2` obviously.

## Test if the backup work

If you don't have Plesk installed on the Backup Server, you can `tail -f /var/log/maillog` to see live changes in the mail log. If you have Plesk installed on the Backup Server, you can go to "Tools & Settings" -> "Mail" -> "Mail Queue" to see if any emails are held back.

Shut down the primary Server and send an email to the email address that you set up there.
Look at the `maillog` and you should see a `connect to mail1.<domain>: Network is unreachable` or similar message from the sender server. After a few moments, the backup Server should try it but also get a `Connection timed out`.

In Plesk you should see an email now in the Mail Queue.

Now you can start the primary Server again and as soon as it is online and reachable you should see in the `maillog` that the email was sent and in Plesk that the email is gone from the Mail Queue.

### If everything works you can change the DNS TTL Settings to something more appropriate like 86400 seconds
