import os
import json
import hashlib
from datetime import datetime
import baker
from bottle import route, run, debug
import Image


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
    return json.loads(library)


def save_lib(library):
    """
    Save ``library`` ``dict`` as JSON into a file
    """
    library['last_modified'] = dt2str(datetime.now())
    path = os.path.join(os.getcwd(), LIBRARY_NAME)
    library_file = open(path, 'w')
    library = library_file.write(json.dumps(library, indent=4))
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


def resize(library, filename, sha, width):
    """
    Resize an image with ``filename`` to ``width``. Rename the new image to
    ``sha_width.jpg``.
    """
    source = os.path.join(os.getcwd(), library['source'])
    cache = os.path.join(os.getcwd(), library['cache'])
    full_path = os.path.join(source, filename)

    im = Image.open(full_path)
    wpercent = (width/float(im.size[0]))
    hsize = int((float(im.size[1])*float(wpercent)))
    im.thumbnail((width, hsize))
    im.save(os.path.join(cache, "%s_%d.jpg" % (sha, width)), 'JPEG')


# Commands

@baker.command
def init():
    library = {
        'albums': [
            {
                'name': 'Unsorted',
                'photos': []
            }
        ],
        'source': 'photos',
        'cache': 'cache',
        'last_modified': dt2str(datetime.now())
    }
    save_lib(library)


@baker.command
def load():
    library = load_lib()
    paths = []
    full_source = os.path.join(os.getcwd(), library['source'])

    # Collect all image filenames
    for p in os.walk(full_source, followlinks=False):
        for f in p[2]:
            if f.startswith('.'):
                continue
            paths.append(f)

    # Create SHAs
    photos = []
    now = dt2str(datetime.now())

    for p in paths:
        full_path = os.path.join(full_source, p)
        sha = get_sha(full_path)
        photos.append({
            'filename': p,
            'added': now,
            'sha': sha
        })
        resize(library, p, sha, 800)
        resize(library, p, sha, 100)

    library['albums'][0]['photos'] = photos
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
    run(host='localhost', port=8000, reloader=True)


# Bottle views

@route('/')
def hello():
    return ''


if DEBUG:
    debug(True)


if __name__ == '__main__':
    baker.run()
