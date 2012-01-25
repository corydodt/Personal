"""
Extract useful information from a .dja file
"""

from PIL import Image, ImageDraw
from StringIO import StringIO
from lxml import etree
import re

BLACK = 0
TRANS = 1

PARTFINDER = re.compile('[MLCX][^MLCX]+')

class Action(object):
    def __init__(self, text):
        parts = text.split(',')
        self.type = parts.pop(0)
        self.parts = [float(p)*50 for p in parts if p]

def parseSVGPath(pathstring):
    """
    @return a sequence of 2-tuples (x,y) from the given string, which is a
    path, as represented by SVG's <path> or <clippath> 'd' attribute.
    """
    actions = [Action(part) for part in PARTFINDER.findall(pathstring)]
    # assert (len(parts) % 2) == 0, "Path string does not contain even number of x's and y's"
    r = []
    for a in [a for a in actions if a.type in 'ML']:
        x, y = a.parts
        r.append((x,y))
    return r

def uniq(items):
    return sorted(set(items))


def newTransparentImage(w, h):
    """
    @return a string containing the PNG bytes of a transparent image with
    the specified dimensions.
    """
    i = Image.new('RGBA', (w, h), TRANS)
    return i


def saveFile(image):
    """
    Return a 1-bit PNG byte string from the PIL image
    """
    output = StringIO()
    output.name = '__obscurement.png'
    image.save(output, optimize=True, bits=32)
    output.seek(0)

    return output.read()


class MapItem(object):
    def __init__(self, object):
        self.type = object.tag
        self.image = object.find('MapItemImage').text
        area = object.find('MapItemArea')
        if area is not None:
            self.path = parseSVGPath(area.text)
            if len(self.path) == 1:
                self.path.append(self.path[0])
        else:
            self.path = None

        self.isUser = 'dotw' in self.image or 'User' in self.image

    def drawText(self, image):
        """
        Draw myself into a PIL drawing
        """
        if self.path is not None:
            di = ImageDraw.Draw(image)
            di.text(self.path[0], self.image)

    def drawOutline(self, image, color="#ffff00"):
        """
        Draw myself into a PIL drawing
        """
        if self.path is not None:
            di = ImageDraw.Draw(image)
            di.polygon(self.path, outline=BLACK, fill=color)

def main():
    f = open('/home/cdodt/wc/Dnd/campaigns/precarious-earth/used/council-room.dja')
    tree = etree.parse(f)

    ret = []

    for node in tree.iterfind('//MapItemImage'):
        ret.append(MapItem(node.getparent()))

    background = newTransparentImage(1600, 2000)
    for i in ret:
        if i.isUser:
            i.drawOutline(background, color="blue")
        else:
            if not i.type == 'Floor':
                i.drawOutline(background)
    for i in ret:
        if i.isUser:
            i.drawText(background)

    open('file.png', 'w').write(saveFile(background))

main()



# {{{
'''
/home/cdodt/wc/Dnd/campaigns/precarious-earth/evercrawling.dja
/home/cdodt/wc/Dnd/campaigns/precarious-earth/used/council-room.dja
/home/cdodt/wc/Dnd/campaigns/precarious-earth/used/gnoll-huddle.dja
/home/cdodt/wc/Dnd/campaigns/precarious-earth/used/grimcatch.dja
/home/cdodt/wc/Dnd/campaigns/precarious-earth/used/olemheiden.dja
/home/cdodt/wc/Dnd/campaigns/re-edits/orclords/orclords-1.dja
/home/cdodt/wc/Dnd/campaigns/re-edits/orclords/orclords-2.dja
/home/cdodt/wc/Dnd/campaigns/re-edits/orclords/orclords-3.dja
/home/cdodt/wc/Dnd/campaigns/re-edits/orclords/orclords-ww.dja
/home/cdodt/wc/Dnd/campaigns/re-edits/staff/staff1.dja
/home/cdodt/wc/Dnd/campaigns/vignettes/order-of-the-whispered-strike-1.dja
/home/cdodt/wc/Dnd/campaigns/vignettes/order-of-the-whispered-strike-2.dja
/home/cdodt/wc/Dnd/campaigns/vignettes/order-of-the-whispered-strike-3.dja
/home/cdodt/wc/Dnd/wip/banditsend.dja
/home/cdodt/wc/Personal/2007/vday/vd.dja
/home/cdodt/wc/Personal/2007/vday/vd_cropped.dja
'''
# }}}


# {{{
"""
.dja layout:

<Root>
  <Version>
    <Major>
    <Minor>
  <Story>
    <Name>
    <Author>
    <MinLevel>
    <MaxLevel>
    <Custom>
    <D20>
  <MapProp>
    <Type>
    <GridType>
    <Grid>
    <Bevel>
    <Shadow>
    <RoomKey>
    <Parchment>
    <PrintStyle>
    <ExportStyle>
  <Room>
    <Floor>*
        <MapItemLayer>
        <Scale>
        <MapItemImage>
        <MapItemArea>
    <Object>*
        <MapItemLayer>
        <Scale>
        <MapItemImage>
        <MapItemArea>
        <StampAnchor>
        <Flip>
        <Name>
    <Cover>*
        <MapItemLayer>
        <Scale>
        <MapItemImage>
        <MapItemArea>
        <StampAnchor>
        <Flip>
        <Name>
        <Element>
    <Wall>*
        <MapItemLayer>
        <Scale>
        <MapItemImage>
        <MapItemArea>
    <Door>*
        <MapItemLayer>
        <Scale>
        <MapItemImage>
        <MapItemArea>
        <StampAnchor>
        <Flip>
        <Name>
        <DoorType>
        <DoorThick>
        <DoorHard>
        <Hit>
        <DoorLockedDc>
        <DoorSecretDc>
        <DoorStuck>
        <DoorLocked>
        <DoorSecret>
        <DoorLockType>
        <DoorHinge>
"""
# }}}
