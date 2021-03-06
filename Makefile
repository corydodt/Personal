corydoctorow.min.js:
	@echo -n 'javascript:(function(e,a,g,h,f,c,b,d){if(!(f=e.jQuery)||g>f.fn.jquery||h(f)){c=a.createElement("script");c.type="text/javascript";c.src="http://ajax.googleapis.com/ajax/libs/jquery/"+g+"/jquery.min.js";c.onload=c.onreadystatechange=function(){if(!b&&(!(d=this.readyState)||d=="loaded"||d=="complete")){h((f=e.jQuery).noConflict(1),b=1);f(c).remove()}};a.documentElement.childNodes[0].appendChild(c)}})(window,document,"1.4.2",function($$,L){'
	@cat corydoctorow.js | perl -pnle 's/^\s+//'
	@echo '});'

PACKAGES =      screen vim-gtk exuberant-ctags python-pip zsh mercurial git fabric awscli

shell:
	cp -av .screenrc .zsh* .vim .sqliterc .hgrc .gitconfig .inputrc ~
	mkdir -p ~/bin
	cp xvim screenpick ~/bin
	@echo
	@echo Installing packages: $(PACKAGES)
	@echo
	@for pkg in $(PACKAGES); do \
		dpkg -l $$pkg | grep ^ii || \
	 	sudo apt-get install -y $${pkg} || echo '** Installation failed: ' $${pkg}; \
	done
	test -f ~/vimrc || ln -s ~/.vim/plugin/cory_vimrc.vim ~/vimrc
	getent passwd $$USER | grep /usr/bin/zsh || sudo chsh -s /usr/bin/zsh $$USER

server:
	~/Personal/setup-hostname
	~/Personal/install-nginx
	sudo apt-get install postfix postfix-pcre

mezzanine:
	mkdir ~/Mezzanine.env; cd ~/Mezzanine.env; virtualenv .
	cd ~/Mezzanine.env; . bin/activate; pip install mezzanine
	sudo cp ~/Personal/init/mezzanine.conf /etc/init

supperfeed:
	sudo apt-get install mongodb-server
	mkdir ~/SupperFeed.env; cd ~/SupperFeed.env; virtualenv .
	cd ~/SupperFeed.env; . bin/activate; pip install git+ssh://git@github.com/corydodt/SupperFeed.git
	sudo cp ~/Personal/init/supperfeed.conf /etc/init
