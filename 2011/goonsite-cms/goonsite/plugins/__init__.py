"""
The plugins directory
"""

# add goonsite.plugins directories to the plugin-searchable paths
from twisted.plugin import pluginPackagePaths
__path__.extend(pluginPackagePaths(__name__))
__all__ = []

