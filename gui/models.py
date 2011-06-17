from django.db import models


class Tag(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name


class Set(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name


class Person(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name


class Place(models.Model):
    name = models.CharField(max_length=200)

    def __unicode__(self):
        return self.name


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
