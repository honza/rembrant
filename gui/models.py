import os
import json
import hashlib
from django.conf import settings
from django.db import models
from django.db.models.signals import post_save


SOURCE = getattr(settings, 'SOURCE')


class Tag(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {
            'id': self.id,
            'name': self.name
        }


class Set(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {
            'id': self.id,
            'name': self.name
        }


class Person(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {
            'id': self.id,
            'name': self.name
        }


class Place(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {
            'id': self.id,
            'name': self.name
        }


class Photo(models.Model):
    title = models.CharField(max_length=250, blank=True, null=True)
    filename = models.CharField(max_length=250)
    caption = models.TextField(blank=True)
    tags = models.ManyToManyField(Tag)
    sets = models.ManyToManyField(Set)
    people = models.ManyToManyField(Person)
    places = models.ManyToManyField(Place)
    sha = models.CharField(max_length=40, blank=True)

    def __unicode__(self):
        return self.filename

    def to_json(self):
        tags = self.tags.all()
        tags = [t.id for t in tags]
        sets = self.sets.all()
        sets = [s.id for s in sets]
        people = self.people.all()
        people = [p.id for p in people]
        places = self.places.all()
        places = [p.id for p in places]
        d = {
            'title': self.title,
            'filename': self.filename,
            'caption': self.caption,
            'tags': tags,
            'sets': sets,
            'people': people,
            'places': places
        }
        return d

    @classmethod
    def from_json(self, string):
        d = json.loads(string)
        ph = self.objects.create(
            filename=d['filename'],
            title=d['title'],
            caption=d['caption']
        )
        for t in d['tags']:
            o = Tag.objects.get_or_create(name=t['name'])[0]
            ph.tags.add(o)
        for s in d['sets']:
            o = Set.objects.get_or_create(name=s['name'])[0]
            ph.sets.add(o)
        for p in d['people']:
            o = Person.objects.get_or_create(name=p['name'])[0]
            ph.people.add(o)
        for p in d['places']:
            o = Place.objects.get_or_create(name=p['name'])[0]
            ph.places.add(o)

        ph.save()

    @classmethod
    def from_path(self, path):
        sha = hashlib.sha1()
        f = open(os.path.join(SOURCE, path))
        while True:
            try:
                data = f.read(2**20)
            except IOError:
                data = None
            if not data:
                break
            sha.update(data)
        sha = sha.hexdigest()
        # Don't import duplicates
        if not self.objects.filter(sha=sha).exists():
            self.objects.create(sha=sha, filename=path)


def save_json(sender, **kwargs):
    from filesystem import Exporter
    Exporter()


post_save.connect(save_json)
