# vim:set ft=conf et sw=4 ts=4:
        # Helps with ajaxy progress bars and web sockets and stuff:
        proxy_buffering off;

        # Necessary to tell the twisted server who it's supposed to be, for
        # link generation:
        proxy_set_header Host $host;

        # Twisted doesn't honor X-Forwarded-For yet, but maybe someday:
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # proxy_read_timeout 300s;
        # send_timeout 100m;
