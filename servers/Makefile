
OBJS = pillar/backup.sls pillar/duty.sls
SHELL = /bin/bash

all: $(OBJS)

$(OBJS):
	cp -ruvns ~/Dropbox/sysadmin-cory/salt-master/* .

samples = pillar/duty.sls pillar/backup.sls

sample:
	rm -f $(samples)
	for s in $(samples); do cp -nv $${s}.sample $$s; done

clean:
	rm -vf $(OBJS)

logrotate:
	@echo '"./fabric.log" { rotate 5|compress|copytruncate|}'|tr '|' $$'\n' > .fabric.log.conf
	logrotate -f -s .fabric.log.state .fabric.log.conf || true
	@rm -f .fabric.log.conf .fabric.log.state
