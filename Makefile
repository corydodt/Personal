corydoctorow.min.js:
	@echo -n 'javascript:(function(e,a,g,h,f,c,b,d){if(!(f=e.jQuery)||g>f.fn.jquery||h(f)){c=a.createElement("script");c.type="text/javascript";c.src="http://ajax.googleapis.com/ajax/libs/jquery/"+g+"/jquery.min.js";c.onload=c.onreadystatechange=function(){if(!b&&(!(d=this.readyState)||d=="loaded"||d=="complete")){h((f=e.jQuery).noConflict(1),b=1);f(c).remove()}};a.documentElement.childNodes[0].appendChild(c)}})(window,document,"1.4.2",function($$,L){'
	@cat corydoctorow.js | perl -pnle 's/^\s+//'
	@echo '});'

shell:
	cp -av .screenrc .zsh* .vim .sqliterc .hgrc .inputrc ~
	mkdir -p ~/bin
	cp screenpick ~/bin
