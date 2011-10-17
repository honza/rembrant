Installation
============

It's recommended that you install rembrant with `virtualenv`_.

First, clone the project from Github:

.. code-block:: bash

    $ git clone git://github.com/honza/rembrant.git
    $ cd rembrant

Create your environment and install the requirements:

.. code-block:: bash

    $ virtualenv env --no-site-packages
    $ source env/bin/activate
    (env) $ pip install -r requirements.txt

Initialize your library:

.. code-block:: bash

    $ python rembrant.py init

This will create a ``library.json`` file in the ``rembrant/`` directory. Next,
you will want to symlink your photo directory to ``rembrant/photos``. Then,
load your photos into the library:

.. code-block:: bash

    $ python rembrant.py load

This will add your photos to the ``library.json`` file. It will assign an *id*
to each photo and a *sha* digest to make sure it's unique. It will also create
2 thumbnails for each photo. One that's 100px wide and one that's 800px wide.
By default, it will place the thumbnails to the ``cache`` variable set in your
library file.

Next, we will export your gallery to HTML.

.. code-block:: bash

    $ python rembrant.py export

This will create a static site representation of your gallery. It will create a
detail page for each photo, and a blog-like feed of photos. The HTML generated
by this command will be placed in the ``build/`` directory.

Next, we will deploy this code to AWS S3.

.. code-block:: bash

    $ python rembrant.py deploy

This will copy all of the files in ``build/`` to your S3 bucket.

.. note:: Before you can deploy code to AWS S3, please make sure that the
    ``aws_key``, ``aws_secret`` and ``aws_bucket`` settings are populated.


.. _virtualenv: http://www.virtualenv.org/en/latest/
