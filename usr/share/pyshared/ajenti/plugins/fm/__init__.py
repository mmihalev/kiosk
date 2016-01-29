# -*- coding: utf-8 -*-
from ajenti.api import *
from ajenti.plugins import *


info = PluginInfo(
    title='Файлов мениджър',
    icon='folder-open',
    dependencies=[
        PluginDependency('main'),
        PluginDependency('tasks'),
    ],
)


def init():
    import fm
