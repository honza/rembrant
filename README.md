Rembrant
========

Rembrant is a piece of software that helps you create online galleries. You
run the software locally to create the gallery, add tags and collections and
then you sync it to your online account on [AWS S3][s3].

Advantages
----------

* You own your photographs, not Flickr or Picasa
* The website is generated on your computer and not on the server, meaning that
  it's super fast. All the user has to do is download it.
* Cheap - about $1 for 3GB of images (including bandwidth)
* Flexible
* Structure saved in a single JSON file
* Familiar Django templates
* GUI for adding captions, tags, sets, etc.

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

Dependencies
------------

* Boto - AWS Python library
* pyYAML
* Django - for templates
* Python Imaging Library (PIL)

Instalation
-----------

    $ virtualenv env --no-site-packages
    $ source env/bin/activate
    (env) $ pip install -r requirements.txt

[s3]: http://aws.amazon.com/s3/
