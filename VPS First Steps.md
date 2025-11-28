# VPS First Steps
Since I seemingly install and configure VPS quite a lot lately and I don't want to search the commands that I have to do every single time, I'm gonna make a list of things I do first thing when I SSH into a new VPS.
This concentrates on Ubuntu as the Distro but can be applied to many other Distros - especially Debian based ones.

## Update everything
First update everything. Even though it is a fresh install, most often than not the packages installed are not updated to the latest version.
```bash
sudo apt update && sudo apt upgrade
```

if there is a kernel update, you have to reboot the server.
To see if you have to reboot the server (if you missed the message) you can do
```bash
ls /var/run/reboot-required
```

if that exist, that means you have to reboot the server with
```bash
sudo reboot
```
Do the `sudo apt upgrade` again to see if the new kernel version brings up new packages version.

## Root to User
### Adding a new user
You should never SSH as the root. In fact we gonna disable login via root later.
But first we need to generate a new user to login to
```bash
sudo adduser USERNAME
```
change `USERNAME` to what ever name you want. You will get asked to put in a password (you not gonna see anything typed in the shell, but the input will be registered).
For the additional data you can put the info in or not - I leave that out.

Now we have to give that user sudo rights
```bash
sudo usermod -aG sudo USERNAME
```
where obviously `USERNAME` is the username you have put in earlier. To see if that has been applied you can do
```bash
groups USERNAME
```
you should get an output like `USERNAME : USERNAME sudo` confirming that this user is in the sudo group.
Now exit the SSH session with `exit` and login again, but this time with the newly created user and password.

### SSH Keys FTW
To secure the SSH further we should make a SSH Key. Github has a really good article about that here for Linux, Windows and Mac:  [Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Now we have a public and a private key. We have to tell the server what key is authorized to connect to the server. For that we make a folder in the home directory
```bash
mkdir ~/.ssh
```
and make a new file called `authorized_keys`
```bash
nano ~/.ssh/authorized_keys
```
there we paste our **public** key into, **NOT** the private key!
Exit and save the file.

To try if that works we `exit` the SSH Session again and try login in again.
If everything worked you are not gonna get asked about your password, but instead logged in directly to the server. In the background there was a private->public key exchange and authorized you to login to the server.

### Disable Password Login
Now that the password is obsolete, we can disable it completely.
```bash
sudo nano /etc/ssh/sshd_config
```
go down the file and search for `PasswordAuthentication yes` and set that to `no`.
Save and exit the file.
There might be another config file you have to disable that.
```bash
sudo nano /etc/ssh/sshd_config.d/50-cloud-init.conf
```
and that the `PasswordAuthentication yes` also to `no`.

Now with the new configuration we need to restart the ssh service with
```bash
sudo service ssh restart
```
Now you can test it with trying to login with the root user. If you get a `Permission denied` message, then the password login has been disabled.

### Disable root login
The next step is to completely disable root login. We go back to the sshd_config file
```bash
sudo nano /etc/ssh/sshd_config
```
and search for the `PermitRootLogin` setting and set that to `no`. That will disable login in with the root user completely.
Of course after a config change we need to restart the ssh service again
```bash
sudo service ssh restart
```

## Change SSH Port
Changing the SSH Port is one way to filter out many of the automatic scripts that scrape the internet for insecure servers. There are still ways the server gonna report on what port the SSH is available, so it is not THE best way and it comes with a bit of hassle on your site.
Decide for yourself if that is worth it or not.
#### CAUTION! If you are running `ufw` or any other firewall, you might want to first open up the new port, before changing the ssh port!
```bash
sudo nano /etc/ssh/sshd_config
```
search for `Port 22` and change it to `Port 2222` or what ever port you want.
Restart the ssh service
```bash
sudo service ssh restart
```
and now you have to also change command of the login on your machine and add a `-p 2222` to it.


## Enable automatic updates
Because login into the server regularly is a hassle and at some point your not gonna do that, we gonna install and configure automatic updates.
For that we install unattended-upgrades
```bash
sudo apt install unattended-upgrades
```
then
```bash
sudo dpkg-reconfigure unattended-upgrades
```
by default this now automatically updates security patches. If you want to also allow normal packages to be updated you have to edit the config file
```bash
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```
and remove the slashes on the line with `-updates` in it.
You can go deeper into the config and enable automatic reboot, mailing, etc. For that I refer to the [github repo of unattended-upgrades](https://github.com/mvo5/unattended-upgrades?tab=readme-ov-file#unattended-upgrades).
