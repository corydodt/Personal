(function () {
        var title, link, username, ccTag, ccShort, ccName, ccVer;
        licenses = {
            'by': 'Attribution',
            'by-sa': 'Attribution Share-Alike',
            'by-nd': 'Attribution No-Derivative-Works',
            'by-nc': 'Attribution Non-Commercial',
            'by-nc-sa': 'Attribution Non-Commercial Share-Alike',
            'by-nc-nd': 'Attribution Non-Commercial No-Derivative-Works'
        };


        ccTag = $('a[rel=license cc:license]:eq(0)').attr('href');

        if (!ccTag) {
            alert('Does not appear to be CC-licensed.\n:(');
        };

        ccShort = new RegExp('.*creativecommons.org/licenses/(.*?)/(.*?)/.*').exec(ccTag);

        ccName = licenses[ccShort[1]];

        ccVer = ccShort[2];

        title = $('meta[name=title]:eq(0)').attr('content');
        link = $('link[rel=canonical]:eq(0)').attr('href');
        username = new RegExp('.*flickr.com/photos/(.*?)/.*').exec(link)[1];

        alert('(<i>Image: <a href="' + link + '">' + 
                title + '</a>, a Creative Commons <a href="' + ccURL + '">' + 
                ccName + ' (' + ccVer + ')</a> image from ' + username + '\'s photostream</i>)');
})
