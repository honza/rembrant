import os
import json
import hashlib
from datetime import datetime
import baker
from bottle import route, run, debug, static_file
import Image


# Globals

library = None


# Constants

DEBUG = True
LIBRARY_NAME = 'library.json'

# Utilities

def dt2str(d):
    return d.strftime('%Y-%m-%d %H:%M:%S')


def load_lib():
    """
    Read the library file in the current working directory, parse into a
    ``dict`` and return it.
    """
    path = os.path.join(os.getcwd(), LIBRARY_NAME)
    library_file = open(path)
    library = library_file.read()
    library_file.close()
    library = json.loads(library)
    library['source'] = os.path.join(os.getcwd(), library['source'])
    library['cache'] = os.path.join(os.getcwd(), library['cache'])
    return library


def save_lib(library):
    """
    Save ``library`` ``dict`` as JSON into a file
    """
    library['last_modified'] = dt2str(datetime.now())
    path = os.path.join(os.getcwd(), LIBRARY_NAME)
    library_file = open(path, 'w')

    if os.path.isabs(library['source']):
        library['source'] = os.path.dirname(library['source'])
    if os.path.isabs(library['cache']):
        library['cache'] = os.path.dirname(library['cache'])

    global photos
    library['photos'] = photos.serialize()

    data = json.dumps(library, indent=4)
    library = library_file.write(data)
    library_file.close()


def get_sha(filename):
    """
    Return a SHA hexdigest for ``filename``
    """
    sha = hashlib.sha1()
    f = open(filename)
    while True:
        try:
            data = f.read(2**20)
        except IOError:
            data = None
        if not data:
            break
        sha.update(data)
    return sha.hexdigest()


# Models

class Collection(list):
    """
    Each item in the collection has to inherit from ``Model``.
    """

    def id(self, id):
        pass

    def serialize(self):
        return [i.serialize() for i in self]


class Model(object):

    def serialize(self):
        raise NotImplementedError("You must implement the `serialize` method")


class Album(Model):

    def __init__(self, id, name):
        self.id = id
        self.name = name

    def serialize(self):
        return {
            'id': self.id,
            'name': self.name
        }


class Photo(Model):

    def __init__(self, id, filename, sha=None, album_id=None):
        global library

        self.id = id
        self.filename = filename
        self.full_path = os.path.join(library['source'], filename)
        self.sha = sha
        self.album_id = album_id

        if not self.sha:
            self._make_sha()

        if not self.album_id:
            self.album_id = 1

        if not self.has_thumbs():
            self._make_thumbnails()

    def serialize(self):
        return {
            'id': self.id,
            'filename': self.filename,
            'sha': self.sha,
            'album_id': self.album_id
        }

    def has_thumbs(self):
        global library
        small = '%s_%d.jpg' % (self.sha, 100)
        big = '%s_%d.jpg' % (self.sha, 800)

        full_small = os.path.join(library['cache'], small)
        full_big = os.path.join(library['cache'], big)

        if not os.path.exists(full_small):
            return False
        if not os.path.exists(full_big):
            return False

        return True

    def _make_sha(self):
        self.sha = get_sha(self.full_path)

    def _make_thumbnails(self):
        self.resize(800)
        self.resize(100)

    def resize(self, width):
        """
        Resize an image with ``filename`` to ``width``. Rename the new image to
        ``sha_width.jpg``.
        """
        global library
        im = Image.open(self.full_path)
        wpercent = (width/float(im.size[0]))
        hsize = int((float(im.size[1])*float(wpercent)))
        im.thumbnail((width, hsize))
        path = "%s_%d.jpg" % (self.sha, width)
        im.save(os.path.join(library['cache'], path), 'JPEG')


class Database(object):

    def __init__(self, library):
        self.library = library
        self.albums = []
        self.photos = []

    def parse(self):
        """
        Parse all the things
        """

        for p in self.library['photos']:
            photo = Photo(p['id'], p['filename'], p['sha'], p['album_id'])
            self.photos.append(photo)


photos = Collection()

# Commands

@baker.command
def init():
    library = {
        'albums': [
            {
                'name': 'Unsorted',
                'id': 1
            }
        ],
        'photos': [],
        'source': 'photos',
        'cache': 'cache',
        'last_modified': dt2str(datetime.now())
    }
    save_lib(library)


@baker.command
def load():
    global library
    library = load_lib()
    paths = []
    full_source = os.path.join(os.getcwd(), library['source'])

    # Collect all image filenames
    for p in os.walk(full_source, followlinks=False):
        for f in p[2]:
            if f.startswith('.'):
                continue
            paths.append(f)

    counter = 1

    for p in paths:

        photo = Photo(counter, p, album_id=1)
        photos.append(photo)

        counter += 1

    save_lib(library)


@baker.command
def scan():
    pass


@baker.command
def export():
    pass


@baker.command
def deploy():
    pass


@baker.command
def runserver():
    run(host='localhost', port=8000, server='tornado', reloader=True)


# Bottle views

@route('/photos')
def all_photos():
    global library
    if not library:
        library = load_lib()
    return {'photos': library['photos']}


@route('/:filename')
def server_static(filename):
    return static_file(filename, root='./static')


@route('/')
def root():
    return static_file('index.html', root='./static')


@route('/photo/:filename')
def serve_photo(filename):
    return static_file(filename, root='./cache')


if DEBUG:
    debug(True)


if __name__ == '__main__':
    baker.run()
