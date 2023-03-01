To have get a (trusted) SSL Certificate into a local development environment is not easy.

Thankfully Filippo Valsorda made a simple tool named mkcert and it requires no little configuration.
And thanks to Ian Huntington for the explanation

But since we use WSL2 and therefore have a Windows host machine, we need to also download the windows binary release for windows here (watch out, there is an arm and amd64 version, download the right one): https://github.com/FiloSottile/mkcert/releases

Open up a shell and cd your way to the folder where the just downloaded mkcert.exe is and type in:
```
.\mkcert.exe -install
```

(change the first part with the actual name of the exe)

Now you get prompted with a Security Warning, if you really want to install the Root Certificate mkcert just created. Press on Yes.

Now the Root Certificate is installed on the windows machine, but we still need to install it on the WSL2 Instance to let it create Certificates for the domains we want to create later.

We need to copy these Root Certificates to the WSL2 Instance.
For that we find the Certificates with
```
.\mkcert.exe -CAROOT
```

then cd to the directory (for me it is C:\Users\<USERNAME>\AppData\Local\mkcert) and type in
```
explorer.exe .
```

to open up the Windows Explorer in that directory. Leave that open, we need it later.

Now we want to do the same thing in the WSL2 Instance. First we install mkcert:
```
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
```

and then we want to make a Root Certificate here with:
```
mkcert -install
```

now we can look where the Certificates are with
```
mkcert -CAROOT
```

and then go to this directory (for me it is ~/.local/share/mkcert ) and delete the Certificates:
```
sudo rm rootCA.pem
sudo rm rootCA-key.pem
```

we install and then delete them again, to make the folder structure necessary and to make room for the Certificates from the Windows machine.

still in the mkcert folder type in
```
explorer.exe .
```

to open up the Windows Explorer in that directory.

Now we copy the rootCA.pem and rootCA-key.pem from Windows machine, to the mkcert folder on the WSL2 Instance machine.

But since the key now has changed, so we need to install the Certificate again in the WSL2 Instance with:
```
mkcert -install
```

Now we can generate Certificates for our development environment with
```
mkcert "test.local.dev"
```

and the directory where the certificates are created, can be seen with
```
mkcert -CAROOT
```

