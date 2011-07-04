# Provide functions to save/load data from json file
from datetime import datetime
from django.conf import settings
from models import *


class ImportException(Exception):
    pass


class ExportException(Exception):
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
