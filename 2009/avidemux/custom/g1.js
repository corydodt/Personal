//AD  <- Needed to identify//
//--automatically built--

var app = new Avidemux();


//** Filters **
app.video.addFilter("mpresize","w=480","h=320","algo=0");

//** Video Codec conf **
app.video.codec("FFMpeg4","CBR=192","160 05 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 1f 00 00 00 03 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 fe ff ff ff 01 00 00 00 fb ff ff ff cd cc 4c 3d 01 00 00 00 0a d7 23 3c 01 00 00 00 00 00 00 3f 00 00 00 3f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 40 1f 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ");

//** Audio **
app.audio.reset();
app.audio.codec("aac",96,4,"80 00 00 00 ");

app.setContainer("MP4");

//End of script
