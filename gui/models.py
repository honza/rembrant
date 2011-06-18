import json
from django.db import models


class Tag(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {'name': self.name}


class Set(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {'name': self.name}


class Person(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {'name': self.name}


class Place(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name

    def to_json(self):
        return {'name': self.name}


class Photo(models.Model):
    title = models.CharField(max_length=250, blank=True, null=True)
    filename = models.CharField(max_length=250)
    caption = models.TextField(blank=True)
    tags = models.ManyToManyField(Tag)
    sets = models.ManyToManyField(Set)
    people = models.ManyToManyField(Person)
    places = models.ManyToManyField(Place)

    def __unicode__(self):
        return self.filename

    def to_json(self):
        tags = self.tags.all()
        tags = [t.to_json() for t in tags]
        sets = self.sets.all()
        sets = [s.to_json() for s in sets]
        people = self.people.all()
        people = [p.to_json() for p in people]
        places = self.places.all()
        places = [p.to_json() for p in places]
        d = {
            'title': self.title,
            'filename': self.filename,
            'caption': self.caption,
            'tags': tags,
            'sets': sets,
            'people': people,
            'places': places
        }
        return json.dumps(d)

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
