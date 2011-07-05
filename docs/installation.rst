Installation
============

It's recommended that you install rembrant with `virtualenv`_.

.. code-block:: bash

    $ virtualenv env --no-site-packages
    $ source env/bin/activate
    (env)$

Rembrant comes with a list of requirements that are contained in the
``requirements.txt`` file. You can install all the packages by running:

.. code-block:: bash

    (env)$ pip install -r requirements.txt

Next, there are a couple of Ruby dependencies. Run the following to install
them.

.. code-block:: bash

    (env)$ gem install haml sass compass

.. note::

    If you want to avoid polluting your global scope with rembrant's Ruby gems,
    you can install them into your environment. Read `Install Ruby gems into
    virtualenv`_.

Next, you will sync the database and run migrations.

.. code-block:: bash

    (env)$ python manage.py syncdb
    (env)$ python manage.py migrate

And finally, you can run the server.

.. code-block:: bash

    (env)$ python manage.py runserver

You can now view rembrant in your browser by going to
``http://localhost:8000``.


.. _virtualenv: http://www.virtualenv.org/en/latest/
.. _Install Ruby gems into virtualenv: http://honza.ca/2011/06/install-ruby-gems-into-virtualenv/
