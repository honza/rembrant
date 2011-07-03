import os
from django.core.management.base import BaseCommand, CommandError
from rembrant.gui.models import Photo
from rembrant.settings import SOURCE


class Command(BaseCommand):
    help = 'Imports photos from SOURCE into database'

    def handle(self, *args, **options):
        # Check if SOURCE exists
        if not os.path.exists(SOURCE):
            raise CommandError("The path specified in SOURCE is not valid.")

        self.stdout.write("%s\n" % SOURCE)
        self.stdout.write("It worked\n")
