from django.conf.urls.defaults import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from django.contrib import admin

admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', 'gui.views.index', name='index'),
    url(r'^photo/(?P<id>[0-9]+)/$', 'gui.views.single', name='single'),
    url(r'^set/(?P<id>[0-9]+)/$', 'gui.views.photoset', name='photoset'),
    url(r'^tag/(?P<id>[0-9]+)/$', 'gui.views.tag', name='tag'),
    url(r'^person/(?P<id>[0-9]+)/$', 'gui.views.person', name='person'),
    url(r'^place/(?P<id>[0-9]+)/$', 'gui.views.place', name='place'),
)

urlpatterns += staticfiles_urlpatterns()
