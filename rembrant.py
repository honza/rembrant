import os
import json
import hashlib
from datetime import datetime
import baker
from bottle import route, run, debug, static_file, post, get, request
import Image


# Constants

DEBUG = True
LIBRARY_NAME = 'library.json'

# Utilities

def dt2str(d):
    return d.strftime('%Y-%m-%d %H:%M:%S')


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
        for i in self:
            if i.id == id:
                return i
        return None

    def filter(self, **kwds):
        """
        Only one key at a time for now
        """
        keys = kwds.keys()
        key = keys[0]
        results = Collection()
        for i in self:
            attr = getattr(i, key, None)
            if attr == int(kwds[key]):
                results.append(i)
        return results

    def _highest_id(self):
        """
        Return the highest id in the collection
        """
        a = 0
        for i in self:
            if i.id > a:
                a = i.id
        return a

    def serialize(self):
        return [i.serialize() for i in self]


class Model(object):

    def serialize(self):
        raise NotImplementedError("You must implement the `serialize` method")


class Library(object):

    def __init__(self):
        self.source = None
        self.cache = None
        self.albums = Collection()
        self.photos = Collection()

        self.load()

    def load(self):
        """
        Read the library file in the current working directory and parse it
        """
        path = os.path.join(os.getcwd(), LIBRARY_NAME)
        self.library_path = path
        if not os.path.exists(path):
            self.source = 'photos'
            self.cache = 'cache'
            self.albums.append(Album(1, 'Unsorted'))
            return

        library_file = open(path)
        library = library_file.read()
        library_file.close()
        library = json.loads(library)

        self.source = os.path.join(os.getcwd(), library['source'])
        self.cache = os.path.join(os.getcwd(), library['cache'])

        # Parse photos
        photos = library['photos']
        for photo in photos:
            self.add_photo(photo['id'], photo['filename'], photo['sha'],
                    photo['album_id'])

        # Parse albums
        albums = library['albums']
        for album in albums:
            a = Album(album['id'], album['name'])
            self.albums.append(a)

    def save(self):
        """
        Convert self to JSON and save to file.
        """
        library = {}
        library['last_modified'] = dt2str(datetime.now())

        if self.source != 'photos':
            library['source'] = os.path.basename(self.source)
        else:
            library['source'] = self.source
        if self.cache != 'cache':
            library['cache'] = os.path.basename(self.cache)
        else:
            library['cache'] = self.cache

        library['photos'] = self.photos.serialize()
        library['albums'] = self.albums.serialize()

        data = json.dumps(library, indent=4)

        library_file = open(self.library_path, 'w')
        library_file.write(data)
        library_file.close()

    def add_photo(self, id, filename, sha=None, album_id=None):
        """
        Create a new ``Photo`` instance and add it the ``photos`` collection.
        """
        photo = Photo(self.source, self.cache, id, filename, sha, album_id)
        self.photos.append(photo)

    def get_album(self, id):
        return self.albums.id(id)

    def create_album(self, name):
        id = self.albums._highest_id() + 1
        album = Album(id, name)
        self.albums.append(album)
        return id

    def get_photos_for_album(self, id):
        return self.photos.filter(album_id=id)


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

    def __init__(self, source_dir, cache_dir, id, filename, sha=None, album_id=None):

        self.id = id
        self.filename = filename
        self.full_path = os.path.join(source_dir, filename)
        self.sha = sha
        self.album_id = album_id
        self.source_dir = source_dir
        self.cache_dir = cache_dir

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
        small = '%s_%d.jpg' % (self.sha, 100)
        big = '%s_%d.jpg' % (self.sha, 800)

        full_small = os.path.join(self.cache_dir, small)
        full_big = os.path.join(self.cache_dir, big)

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
        im = Image.open(self.full_path)
        wpercent = (width/float(im.size[0]))
        hsize = int((float(im.size[1])*float(wpercent)))
        im.thumbnail((width, hsize))
        path = "%s_%d.jpg" % (self.sha, width)
        im.save(os.path.join(self.cache_dir, path), 'JPEG')


# Commands

@baker.command
def init():
    library = Library()
    library.save()


@baker.command
def load():
    library = Library()

    if len(library.photos) > 0:
        print 'Already loaded. Please use `scan` instead.'
        return

    paths = []

    # Collect all image filenames
    for p in os.walk(library.source, followlinks=False):
        for f in p[2]:
            if f.startswith('.'):
                continue
            paths.append(f)

    counter = 1

    for p in paths:
        library.add_photo(counter, p, album_id=1)
        counter += 1

    library.save()


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
    library = Library()
    return json.dumps(library.photos.serialize())


@get('/albums')
def albums():
    library = Library()
    return json.dumps(library.albums.serialize())


@post('/albums')
def new_album():
    library = Library()
    payload = json.loads(request.body.read())
    name = payload['name']
    id = library.create_album(name)
    library.save()
    return {
        'id': id,
        'name': name
    }


@route('/albums/:id/photos')
def photos_of_album(id):
    library = Library()
    photos = library.get_photos_for_album(id)
    return json.dumps(photos.serialize())


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
