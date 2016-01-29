# -*- coding: utf-8 -*-
from ajenti.api import *
from ajenti.plugins import *


info = PluginInfo(
	title='Режим Снимки',
	icon='picture',
	dependencies=[
		PluginDependency('main'),
        BinaryDependency('xscreensaver'),
	],
)


def init():
	import main
