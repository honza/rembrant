from django.core.management.base import BaseCommand, CommandError
from rembrant.gui.filesystem import Thumbnailer


class Command(BaseCommand):
    help = 'Imports photos from SOURCE into database'

    def handle(self, *args, **options):
        Thumbnailer()
