# install fabric the right way
#


# on ubuntu, pycrypto installed from pip is known to be broken. Remove it and
# get the managed package, in case it was installed by pip.

## TODO - see https://github.com/saltstack/salt/issues/1881
## pycrypto: pip.removed

python-crypto:
    pkg.installed
    ## pkg.installed:
    ##     - require:
    ##         - pip: pycrypto

# fabric upstream recommends installing from pip
Fabric:
    pip.installed:
        - require:
            - pkg: python-crypto
    
