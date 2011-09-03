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
* Your captions, titles and albums are backed up
* Customizable user interface
* Your library can be version controlled (git, hg)

Disadvantages
-------------

* You have to run a local server (you need to be handy with the terminal)
* The gallery can only be hosted on a subdomain (e.g.
  `http://gallery.example.com`, but not `http://example.com`)

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
    $ rembrant --init
    $ vim library.json
    $ rembrant --import
    $ rembrant --serve

Commands
--------

`--init`

Create a default `library.json` file. Create cache directory.

`--import`

Look at the `source` in the configuration file and load all the images
contained in it. Populate the library file with the new images. Put all images
into an `Unsorted` album. Produce 100- and 800- thumbs.

`--scan`

Look in the `source` directory to see if there are any images that aren't
already in the library. If there are, load them and put them in the `Unsorted`
album.

`--export`

Produce a static version of your gallery which is suitable for deployment.

`--deploy`

Deploy your gallery to AWS.

License
-------

BSD. Short and sweet. Check the `LICENSE` file.

[1]: http://aws.amazon.com/s3/
