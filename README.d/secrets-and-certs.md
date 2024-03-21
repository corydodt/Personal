# how to get certs onto boxes


- The certs are kept in 1password
- A secret to access them is passed in via smbios.

    In `/etc/pve/local/qemu-server/105.conf`, add:

    ```
    args: -smbios type=11,value=io.systemd.credential:foo=bar
    ```

    TODO: figure out how to back up qemu conf files.

    Where foo is a credential name and bar is the value.

    This can be accessed from the VM when it boots. To test:

    ```
    sudo systemd-creds --system cat foo
    ```

    This setting is kept (passed forward to the clone) when it appears in a template and the template is cloned.

- A startup service acquires the creds using systemd conf syntax:



## how to get certs into 1password at renew

...


Here is an example systemd configuration file that references an SMBIOS Type 11 string credential:

[Unit]
Description=Example Service

[Service]
ExecStart=/usr/bin/example-service -credential ${io.systemd.credential:EXAMPLE_CREDENTIAL}1

The [Unit] and [Service] sections define a basic systemd unit file for a service. In the [Service] section, the ExecStart directive runs the example-service binary, passing the EXAMPLE_CREDENTIAL string retrieved from SMBIOS Type 11 as a command line argument.

Systemd supports retrieving credentials from SMBIOS Type 11 strings through the ${io.systemd.credential:CREDENTIAL} syntax. This allows configuration of services using credentials stored securely in the firmware rather than plain text files.
