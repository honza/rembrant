.. rembrant documentation master file, created by
   sphinx-quickstart on Tue Jul  5 10:47:05 2011.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to rembrant's documentation!
====================================

Rembrant is a piece of software that helps you organize your photos and create
online galleries. You run the software locally to create the gallery, add tags
and collections and then you sync it to your online account on `AWS S3`_.

Advantages
----------

* Organize your photos in the browser
* Structure saved in a single JSON file (unlike iPhoto's proprietary format)
* You own your photographs, not Flickr or Picasa
* The website is generated on your computer and not on the server, meaning that
  it's super fast. All the user has to do is download it.
* Cheap - about $1 for 3GB of images (including bandwidth)
* Flexible
* Familiar Django templates
* Your captions, tags, sets, etc are backed up
* Customizable user interface
* Your library can be version controlled (git, hg, etc)

Disadvantages
-------------

* You have to run a local server (you need to be handy with the terminal)
* The gallery can only be hosted on a subdomain (e.g.
  ``http://gallery.example.com``, but not ``http://example.com``)



Contents
--------

.. toctree::
   :maxdepth: 2

   installation
   configuration
   models

.. _AWS S3: http://aws.amazon.com/s3/
