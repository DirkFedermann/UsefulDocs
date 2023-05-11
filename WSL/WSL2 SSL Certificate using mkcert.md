To have get a (trusted) SSL Certificate into a local development environment is not easy.

Thankfully Filippo Valsorda made a simple tool named mkcert and it requires no little configuration.
And thanks to ledunguit for the explanation.


First we install mkcert:
```
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
```

and then we want to make a Root Certificate here with (`sudo` for later use with my lamp.sh):
```
sudo mkcert -install
```

and then we need to install the new CA certificate on the Windows machine.
For that we need to go to the `ca-certificates` folder on the WSL2 machine:
```
cd /usr/local/share/ca-certificates
```

and then open up a Windows Explorer in that folder:
```
explorer.exe .
```

double click to open up the certification, install the certificate to `Trusted Root Certification Authorities`

Now we can generate Certificates for our development environment with in the WSL2 console
```
mkcert "test.local.dev"
```
