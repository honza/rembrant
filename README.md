Rembrant
========

Rembrant is a piece of software that helps you organize your photos and create
online galleries. You run the software locally to create the gallery, add tags
and collections and then you sync it to your online account on [AWS S3][1].

Advantages
----------

* Organize your photos in the browser
* Structure saved in a single JSON file (unlike iPhoto's proprietary format)
* You own your photographs, not Flickr or Picasa
* The website is generated on your computer and not on the server, meaning that
  it's super fast. All the user has to do is download it.
* Cheap - about $1 for 3GB of images (including bandwidth)
* Flexible
* Your captions, tags, sets, etc are backed up
* Customizable user interface
* Your library can be version controlled (git, hg, etc)

Disadvantages
-------------

* You have to run a local server (you need to be handy with the terminal)
* The gallery can only be hosted on a subdomain (e.g.
  `http://gallery.example.com`, but not `http://example.com`)

URLs
----

A welcome page with a few of the latest images, list of tags and sets

    /

List of pictures from the given year or year/month

    /2011/
    /2011/05/

List of pictures with the given tag or in the given set

    /tag/dogs/
    /set/wedding/

Places

    /places/paris/
    /places/florida/

People

    /people/john/
    /people/mom/

Individual images

    /image/20110622_paris_0123.html

Thumbnails

    /thumbs/20110622_paris_0123.jpg
    /full/20110622_paris_0123.jpg



Filtering page. Allow for any kind of combination: sets, places, tags, caption
text, people, date taken, camera used, etc.

    /filter/


Documentation
-------------

Documentation can be found in the `docs` directory. It's written in
reStructuredText using [Sphinx][2]. To build the documentation, run:

    $ pip install sphinx
    $ cd docs
    $ make html
    $ open _build/html/index.html

[1]: http://aws.amazon.com/s3/
[2]: http://sphinx.pocoo.org/index.html
