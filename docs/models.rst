Model reference
===============

This is the public API for rembrant. 

.. warning:: This API may change at any time. When rembrant reaches 1.0.0, the
    API will become stable.

Photo model
-----------

.. py:class:: Photo

    This class contains all the information and metadata about a single photo.

.. py:attribute:: title

   The title for the photo.

.. py:attribute::  filename

    The photo's filename.

.. py:attribute:: caption

    The photo's caption.

.. py:attribute:: sha

    A hexdigest of a SHA hash of the original image file.

.. py:attribute:: small_thumb

    A filename of the small thumbnail. 100px wide by default.

.. py:attribute:: big_thumb

    A filename of the big thumbnail. 800px wide by default.

.. py:method:: to_json()

    Return a Python dictionary representing the :py:class:`Photo` instance
    suitable for serialization into JSON. Related objects are represented as
    lists of primary keys.
