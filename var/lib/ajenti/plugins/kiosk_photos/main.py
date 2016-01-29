# -*- coding: utf-8 -*-
from ajenti.api import *
from ajenti.plugins.main.api import SectionPlugin
from ajenti.ui import on
from ajenti.ui.binder import Binder

@plugin
class SanickioskScreensaverPrefs (SectionPlugin):
	default_classconfig = {
		'xscreensaver_enable': False,
		'xscreensaver_idle': '0:00:10',
		'glslideshow_duration': '',
		'glslideshow_pan': '',
		'glslideshow_fade': '3',
		'glslideshow_zoom': '100',
		'glslideshow_clip': False,
	}
	classconfig_root = True

	def init(self):
		self.title = 'Режим Снимки'
		self.icon = 'picture'
		self.category = 'Kiosk'

		self.append(self.ui.inflate('kiosk_photos:main'))
		self.binder = Binder(self, self)
		self.binder.populate()

	@on('save', 'click')
	def save(self):
		self.binder.update()
		self.save_classconfig()
		self.context.notify('info', _('Настройките са запаметени. Моля, рестартирайте киоска.'))
		self.binder.populate()

		all_vars = '\n'.join([k + '="' + str(v) + '"' for k,v in self.classconfig.iteritems()])
		open('/home/kiosk/.kiosk/screensaver.cfg', 'w').write(all_vars) #save

