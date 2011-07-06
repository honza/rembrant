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

.. py:attribute:: tags

    A list of :py:class:`Tag` instances.

.. py:attribute:: sets

    A list of :py:class:`Set` instances.

.. py:attribute:: people

    A list of :py:class:`Person` instances.

.. py:attribute:: places

    A list of :py:class:`Place` instances.

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


Tag model
---------

.. py:class:: Tag

    The tag class

.. py:attribute:: name

Set model
---------

.. py:class:: Set

    The set class

.. py:attribute:: name

Person model
------------

.. py:class:: Person

    The person class

.. py:attribute:: name

Place model
-----------

.. py:class:: Place

    The place class

.. py:attribute:: name

