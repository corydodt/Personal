# how to get certs onto boxes


- The certs are kept in 1password
- A secret to access them is passed in via smbios.

    In `/etc/pve/local/qemu-server/105.conf`, add:

    ```
    args: -smbios type=11,value=io.systemd.credential:foo=bar
    ```

    Where foo is a credential name and bar is the value.  This can be accessed
    from the VM when it boots. To test:

    ```
    sudo systemd-creds --system cat foo
    ```

    This setting is kept (passed forward to the clone) when it appears in a template and the template is cloned.


    TODO: figure out how to back up qemu conf files.

- content of the credentials:

    - most obvious would be to pass in creds.txt for a cifs mount. 

        ```
        username=cdodt
        password=asdlkfjasdlkfjh
        ```

        # use this output as the value 
        echo 'args: -smbios type=11,value=io.systemd.credential.binary:cifs_creds='$(base64 < creds.txt)

- A startup service acquires the creds using LoadCredential

    ```
    sudo systemd-run -p LoadCredential=cifs_creds:cifs_creds -P --wait systemd-creds cat foo
    ```


## how to get certs into 1password at renew

...


## how to get opconnect the secrets it needs to connect upstream

First-time: manual setup. Uses:

    1. 1password username/password/secret
    2. cwcl1 token from 1password developer tools "carrotwithchickenlegs.com Access Token: cwcl1 (1password connect)"

    Reference: https://my.1password.com/developer-tools/infrastructure-secrets/connect/ > "Active" tab

This process creates  ./1password-credntials.json and ./1password-credentials.env.

Save these in 1password manually, then delete both.








NEXT STEP:

- FIXME: make install-service currently fails because `systemctl enable --now` fails because, when this credential is
  created, it isn't yet part of the systemd system credentials that we can use. Maybe just remove `--now`?

- pack 1password-credentials.env into the PVE .conf file for opconnect. pass that file via smbios into  --envfile for the 
  opconnect services.
