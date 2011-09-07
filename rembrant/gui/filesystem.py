# Provide functions to save/load data from json file
import os
import json
from datetime import datetime
from django.conf import settings
import Image
from models import Photo, Tag, Place, Set, Person


class ImportException(Exception):
    pass


class ExportException(Exception):
    pass


class CacheException(Exception):
    pass


class Importer(object):
    """
    Import data from a json file and return it as a Python dictionary of model
    instances
    """

    def __init__(self):
        library = getattr(settings, 'LIBRARY', None)
        if not library:
            raise ImportException


class Exporter(object):
    """
    Save data to a json file. This class is created each time a `post_save`
    signal is sent out.
    """

    def __init__(self):
        library = getattr(settings, 'LIBRARY', None)
        if not library:
            raise ImportException
        
        photos = Photo.objects.all()
        tags = Tag.objects.all()
        sets = Set.objects.all()
        persons = Person.objects.all()
        places = Place.objects.all()

        last_modified = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

        data = {
            'photos': [p.to_json() for p in photos],
            'tags': [t.to_json() for t in tags],
            'sets': [s.to_json() for s in sets],
            'persons': [p.to_json() for p in persons],
            'places': [p.to_json() for p in places],
            'last_modified': last_modified
        }

        f = open(library, 'w')
        f.write(json.dumps(data, indent=4))
        f.close()


class Thumbnailer(object):
    """
    Make sure all images have thumbnails present
    """

    def __init__(self):
        self.source = getattr(settings, 'SOURCE', None)
        self.cache = getattr(settings, 'CACHE_DIR', None)
        if not self.source:
            raise ImportException
        if not self.cache:
            raise CacheException

        photos = Photo.objects.all()
        # Widths: 800, 100
        # Format: sha_size.jpg
        for p in photos:
            # 800
            if not os.path.exists(os.path.join(self.cache, "%s_800.jpg" % p.sha)):
                # Create the image
                self._convert(p, 800)
            # 100
            if not os.path.exists(os.path.join(self.cache, "%s_100.jpg" % p.sha)):
                # Create the image
                self._convert(p, 100)

    def _convert(self, photo, width):
        im = Image.open(os.path.join(self.source, photo.filename))
        wpercent = (width/float(im.size[0]))
        hsize = int((float(im.size[1])*float(wpercent)))
        im.thumbnail((width, hsize))
        im.save(os.path.join(self.cache, "%s_%d.jpg" % (photo.sha, width)),
            'JPEG')

