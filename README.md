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
* Familiar Django templates
* Your captions, tags, sets, etc are backed up
* Customizable user interface
* Your library can be version controlled (git, hg, etc)

Disadvantages
-------------

* You have to run a local server (you need to be handy with the terminal)
* The gallery can only be hosted on a subdomain (e.g.
  `http://gallery.example.com`, but not `http://example.com`)


Quick Instalation
-----------

    $ git clone git://github.com/honza/rembrant.git
    $ cd rembrant
    $ virtualenv env --no-site-packages
    $ source env/bin/activate
    (env) $ pip install -r requirements.txt
    (env) $ python rembrant.py init


Usage
-----

This is a typical initial setup:

1. Create a new directory for your gallery
2. Initialize a `rembrant` gallery in that directory
3. Specify where your pictures are in the `library.json` file
4. Import your photos
5. Run server to add albums, titles and captions


Open the terminal and type:

    $ mkdir gallery
    $ cd gallery
    $ python rembrant.py init
    $ vim library.json
    $ ... update settings
    $ python rembrant.py import
    $ python rembrant.py serve

Before you can deploy your gallery, you need to fill out the `aws_key`,
`aws_secret` and `aws_bucket` fields in your `library.json` file.

Commands
--------

`init`

Create a default `library.json` file. 

`load`

Look at the `source` in the configuration file and load all the images
contained in it. Populate the library file with the new images. Put all images
into an `Unsorted` album. Produce 100- and 800- thumbs. Create cache directory.

`scan`

Look in the `source` directory to see if there are any images that aren't
already in the library. If there are, load them and put them in the `Unsorted`
album.

`export`

Produce a static version of your gallery which is suitable for deployment.

`deploy`

Deploy your gallery to AWS.

`runserver`

Run a local development server on port `8000` to make changes to your gallery's
properties (add photos to albums, change captions, etc).

Documentation
-------------

Documentation can be found in the `docs` directory. It's written in
reStructuredText using [Sphinx][2]. To build the documentation, run:

    (env) $ pip install sphinx
    (env) $ cd docs
    (env) $ make html
    (env) $ open _build/html/index.html

You can find the latest documentation [here][4].


State
-----

Please note that this is pretty much pre-alpha software and mostly doesn't
work. The project is under [Semantic Versioning][3], so it will be stable when
it reaches `1.0.0`.


License
-------

BSD. Short and sweet. Check the `LICENSE` file.

Changelog
---------

* `0.2.0`
    * All commands except for scan work
    * You can actually deploy stuff
    * May require some path adjustments to get to work
    * Still unsure about installation

[1]: http://aws.amazon.com/s3/
[2]: http://sphinx.pocoo.org/index.html
[3]: http://semver.org/
[4]: http://rembrant.readthedocs.org/en/latest/index.html
