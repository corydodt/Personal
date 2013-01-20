"""
Simple grain to merge opts into grains
"""

def opts():
    """
    Return the minion configuration settings
    """
    return {'minion': __opts__}
