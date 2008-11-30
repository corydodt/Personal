
=============================
Mercurial 'hg serve' template
=============================

Based on the default 'monoblue' template, only modified colors and background.

Installation
~~~~~~~~~~~~

1) Copy ./goonsite/ to:
    /usr/lib/python2.5/site-packages/mercurial/templates/

2) Copy static/style-goonsite.css to:
    /usr/lib/python2.5/site-packages/mercurial/templates/static/

3) Edit /etc/mercurial/hgrc and add:
    [web]
    style = goonsite
