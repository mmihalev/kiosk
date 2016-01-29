# -*- coding: utf-8 -*-
from ajenti.api import *
from ajenti.plugins import *


info = PluginInfo(
	title='Режим Браузър',
	icon='globe',
	dependencies=[
		PluginDependency('main'),
        BinaryDependency('chromium-browser'),
	],
)


def init():
	import main
