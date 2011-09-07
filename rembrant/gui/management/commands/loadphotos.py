import os
from django.core.management.base import BaseCommand, CommandError
from rembrant.gui.models import Photo
from django.conf import settings


class Command(BaseCommand):
    help = 'Imports photos from SOURCE into database'

    def handle(self, *args, **options):
        # Check if SOURCE exists
        SOURCE = getattr(settings, 'SOURCE')
        if not os.path.exists(SOURCE):
            raise CommandError("The path specified in SOURCE is not valid.")

        self.stdout.write("%s\n" % SOURCE)
        
        paths = []
        for p in os.walk(SOURCE, followlinks=False):
            for f in p[2]:
                if f.startswith('.'):
                    continue
                paths.append(f)
        for p in paths:
            self.stdout.write("%s\n" % p)
            Photo.from_path(p)

        self.stdout.write("It worked\n")
