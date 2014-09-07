# vim:set ft=conf et sw=4 ts=4:

    listen 80;
    return 301 https://$host$request_uri;
