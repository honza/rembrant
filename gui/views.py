from django.shortcuts import render_to_response, get_object_or_404
from models import *


def index(request):
    photos = Photo.objects.all()
    return render_to_response('index.html', {
        'photos': photos
    })


def single(request, id):
    photo = get_object_or_404(Photo, pk=id)
    return render_to_response('single.html', {
        'photo': photo
    })


def photoset(request, id):
    pset = get_object_or_404(Set, pk=id)
    return render_to_response('set.html', {
        'set': pset
    })


def tag(request, id):
    t = get_object_or_404(Tag, pk=id)
    return render_to_response('tag.html', {
        'tag': t
    })


def person(request, id):
    p = get_object_or_404(Person, pk=id)
    return render_to_response('person.html', {
        'person': p
    })


def place(request, id):
    p = get_object_or_404(Place, pk=id)
    return render_to_response('place.html', {
        'place': p
    })
