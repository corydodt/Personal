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

    TODO: figure out how to back up /etc/pve/qemu-server/*.conf


- content of the credentials:

    - We'll pass 1 of two things:
        1. for the opconnect vm, pass OP_SESSION to allow us to start the opconnect service without putting the credentials onto the vm disk
            ```
            echo 'args: -smbios type=11,value=io.systemd.credential.binary:1password-credentials=$(base64 -w0 1password-credentials.env)
            ```

        2. For other VMs that need secrets, pass OP_CONNECT_TOKEN to allow us to use the 1password cli with our op connect service

- A startup service acquires the creds using LoadCredential

    ```
    ...
    [Service]
    LoadCredential=1password-credentials:1password-credentials
    Environment=OP_ENVIRONMENT_FILE=%d/1password-credentials
    ...
    ExecStart=... --env-file=${OP_ENVIRONMENT_FILE}
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
