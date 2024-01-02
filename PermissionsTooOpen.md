# Permissions for 'key.pem' are too open

If you get the following error message:

```bash
Permissions for 'key.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "key.pem": bad permissions
root@xx.xx.xx.xx: Permission denied (publickey).
```

then you have to change the permissions for your private key.

## Linux

If you are on a Linux machine it is as easy as using the command line to navigate to the key file, then use `chmod 400 key.pem` to change the permissions to only let the owner of the file have read access to the file.

If you need to change the owner of the file, use `chown -c [USER][:[GROUP]] key.pem` to change it.

## Windows

Under Windows, it is a bit more complicated.
Begin with browsing to the key.pem file, right-click on it and click on `properties`.
Then go to the `Security`-Tab and click on `Advanced`.
In the next window, we need to `Disable inheritance` and then `Remove all inherited permissions from this object.`
Now we can `Add` new permissions. We go to `Select a principal` and then type in a user that exists on that machine and click on `Check Names`.
After that click `OK`. The Basic permissions of `Read & execute` and `Read` need to be selected, with no other permissions. Click `OK` or `Apply` in the windows that pop up.

Now the correct permissions should be applied to your key file and you should be able to log in via SSH.

## Source

The source of this is a Youtube Video from `The_Sudo`: <https://www.youtube.com/watch?v=mrUqITjUhL8>