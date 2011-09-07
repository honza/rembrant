# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding field 'Photo.sha'
        db.add_column('gui_photo', 'sha', self.gf('django.db.models.fields.CharField')(default='', max_length=40, blank=True), keep_default=False)


    def backwards(self, orm):
        
        # Deleting field 'Photo.sha'
        db.delete_column('gui_photo', 'sha')


    models = {
        'gui.person': {
            'Meta': {'object_name': 'Person'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        },
        'gui.photo': {
            'Meta': {'object_name': 'Photo'},
            'caption': ('django.db.models.fields.TextField', [], {'blank': 'True'}),
            'filename': ('django.db.models.fields.CharField', [], {'max_length': '250'}),
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'people': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['gui.Person']", 'symmetrical': 'False'}),
            'places': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['gui.Place']", 'symmetrical': 'False'}),
            'sets': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['gui.Set']", 'symmetrical': 'False'}),
            'sha': ('django.db.models.fields.CharField', [], {'max_length': '40', 'blank': 'True'}),
            'tags': ('django.db.models.fields.related.ManyToManyField', [], {'to': "orm['gui.Tag']", 'symmetrical': 'False'}),
            'title': ('django.db.models.fields.CharField', [], {'max_length': '250', 'null': 'True', 'blank': 'True'})
        },
        'gui.place': {
            'Meta': {'object_name': 'Place'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        },
        'gui.set': {
            'Meta': {'object_name': 'Set'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        },
        'gui.tag': {
            'Meta': {'object_name': 'Tag'},
            'id': ('django.db.models.fields.AutoField', [], {'primary_key': 'True'}),
            'name': ('django.db.models.fields.CharField', [], {'max_length': '200'})
        }
    }

    complete_apps = ['gui']
