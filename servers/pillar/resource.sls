resource:
    memory:
        '8GB':
            # 3GB
            vmLimit: 6000000
            apacheWarn: 80

        '4GB':
            # 2GB
            vmLimit: 4000000
            apacheWarn: 40

        '2GB':
            # 1GB
            vmLimit: 2000000
            apacheWarn: 20

        '1GB':
            # 750MB
            vmLimit: 1500000
            apacheWarn: 10

        '512MB':
            # 375MB
            vmLimit: 750000
            apacheWarn: 5

        'defaults':
            # These determine how we compute the limits, when memory is
            # reported to be something other than one of the above.

            # Multiply memory by vmLimitMultiplier to get the vmLimit 
            # - this works out to 750MB per GB
            vmLimitMultiplier: 1464
            
            # Divide memory (in MB) by apacheWarnFactor to get apacheWarn.
            # - 1 apache process for every 10MB of memory
            apacheWarnFactor: 10

    disk:
        '20GB':
            diskWarn: 6

        '40GB':
            diskWarn: 8

        '80GB':
            diskWarn: 10

        '160GB':
            diskWarn: 20

        'defaults':
            # These determine how we compute the limits, when disk is
            # reported to be something other than one of the above.

            # Divide disk by diskWarnFactor to determine where we issue a
            # warning.
            # - 12.5% of disk remaining
            diskWarnFactor: 8

