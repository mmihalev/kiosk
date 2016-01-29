# -*- coding: utf-8 -*-
from ajenti.api import *
from ajenti.plugins import *


info = PluginInfo(
	title='Режим Видео',
	icon='facetime-video',
	dependencies=[
		PluginDependency('main'),
        BinaryDependency('mplayer'),
	],
)


def init():
	import main
