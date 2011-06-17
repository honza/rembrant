# encoding: utf-8
import datetime
from south.db import db
from south.v2 import SchemaMigration
from django.db import models

class Migration(SchemaMigration):

    def forwards(self, orm):
        
        # Adding model 'Tag'
        db.create_table('gui_tag', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=200)),
        ))
        db.send_create_signal('gui', ['Tag'])

        # Adding model 'Set'
        db.create_table('gui_set', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=200)),
        ))
        db.send_create_signal('gui', ['Set'])

        # Adding model 'Person'
        db.create_table('gui_person', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=200)),
        ))
        db.send_create_signal('gui', ['Person'])

        # Adding model 'Place'
        db.create_table('gui_place', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('name', self.gf('django.db.models.fields.CharField')(max_length=200)),
        ))
        db.send_create_signal('gui', ['Place'])

        # Adding model 'Photo'
        db.create_table('gui_photo', (
            ('id', self.gf('django.db.models.fields.AutoField')(primary_key=True)),
            ('title', self.gf('django.db.models.fields.CharField')(max_length=250, null=True, blank=True)),
            ('filename', self.gf('django.db.models.fields.CharField')(max_length=250)),
            ('caption', self.gf('django.db.models.fields.TextField')(blank=True)),
        ))
        db.send_create_signal('gui', ['Photo'])

        # Adding M2M table for field tags on 'Photo'
        db.create_table('gui_photo_tags', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('photo', models.ForeignKey(orm['gui.photo'], null=False)),
            ('tag', models.ForeignKey(orm['gui.tag'], null=False))
        ))
        db.create_unique('gui_photo_tags', ['photo_id', 'tag_id'])

        # Adding M2M table for field sets on 'Photo'
        db.create_table('gui_photo_sets', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('photo', models.ForeignKey(orm['gui.photo'], null=False)),
            ('set', models.ForeignKey(orm['gui.set'], null=False))
        ))
        db.create_unique('gui_photo_sets', ['photo_id', 'set_id'])

        # Adding M2M table for field people on 'Photo'
        db.create_table('gui_photo_people', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('photo', models.ForeignKey(orm['gui.photo'], null=False)),
            ('person', models.ForeignKey(orm['gui.person'], null=False))
        ))
        db.create_unique('gui_photo_people', ['photo_id', 'person_id'])

        # Adding M2M table for field places on 'Photo'
        db.create_table('gui_photo_places', (
            ('id', models.AutoField(verbose_name='ID', primary_key=True, auto_created=True)),
            ('photo', models.ForeignKey(orm['gui.photo'], null=False)),
            ('place', models.ForeignKey(orm['gui.place'], null=False))
        ))
        db.create_unique('gui_photo_places', ['photo_id', 'place_id'])


    def backwards(self, orm):
        
        # Deleting model 'Tag'
        db.delete_table('gui_tag')

        # Deleting model 'Set'
        db.delete_table('gui_set')

        # Deleting model 'Person'
        db.delete_table('gui_person')

        # Deleting model 'Place'
        db.delete_table('gui_place')

        # Deleting model 'Photo'
        db.delete_table('gui_photo')

        # Removing M2M table for field tags on 'Photo'
        db.delete_table('gui_photo_tags')

        # Removing M2M table for field sets on 'Photo'
        db.delete_table('gui_photo_sets')

        # Removing M2M table for field people on 'Photo'
        db.delete_table('gui_photo_people')

        # Removing M2M table for field places on 'Photo'
        db.delete_table('gui_photo_places')


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
