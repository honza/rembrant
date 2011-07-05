Configuration
=============

To configure your installation, edit the ``config.py`` file.

.. py:data:: SOURCE

    This is an absolute path to a directory where you original photos are
    stored. These are never modified.

.. py:data:: LIBRARY

    This is an absolute path to your main library file. This file contains
    information about your photographs, tags, sets, etc. It should be kept
    under version control.

.. py:data:: CACHE_DIR

    This is an absolute path to a directory where rembrant will save cached
    image files such as thumbnails.

.. py:data:: BUILD

    This is an absolute path to a directory where rembrant will place your
    generated online photo gallery.

.. py:data:: AWS_KEY
    
    Amazon Web Services key to your account.

.. py:data:: AWS_SECRET

    Amazon Web Services secret to your account.
