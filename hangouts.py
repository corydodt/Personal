import json
from cPickle import dump, load
import os.path
import sys

def run():
    if os.path.exists('Hangouts.json.p'):
        _cs = load(open('Hangouts.json.p'))['conversation_state']
    else:
        ho = json.load(open('Hangouts.json'))
        dump(ho, open('Hangouts.json.p', 'w'))
        _cs = ho['conversation_state']

    ## analyze(_cs, 0)
    for conv in formatConversations(_cs):
        print u'\n' + u'-' * 60 + u'\n'
        for line in conv:
            print line.encode('utf-8')

def formatConversations(cStates):
    out = []
    for cs in cStates:
        conv = []
        cs = cs['conversation_state']
        for evt in cs['event']:
            time = evt['timestamp']
            user = evt['sender_id']['chat_id']
            cm = evt.get('chat_message') or evt.get('hangout_event')
            if cm:
                mc = cm.get('message_content')
                if mc:
                    seg = mc.get('segment')
                    if seg:
                        text = u'\n'.join([o['text'] for o in
                                evt['chat_message']['message_content']['segment']])
                    else:
                        text = u'#'.join(mc.keys())
                else:
                    text = u'~'.join(cm.keys())
            else:
                text = u'|'.join(evt.keys())
            conv.append(u'{time}  {who}  {text}'.format(
                time=time, who=user, text=text))

        conv.sort()
        out.append(conv)

    return out

## def analyze(o, indent):
##     ind = ' '*indent
##     if type(o) in [int, unicode, bool]:
##         print ind + repr(o)
##     elif type(o) is list:
##         print ind + '[]'
##         analyze(o[0], indent + 2)
##     elif type(o) is dict:
##         _sorted = sorted(o.items())
##         if not _sorted:
##             print ind + '{}'
##         else:
##             for k, v in _sorted:
##                 print ind + '%s:' % k
##                 analyze(v, indent + 2)
##     else:
##         assert 0, 'o is ' + type(o)

sys.exit(run())

"""
[]
  conversation_id:
    id:
      u'UgwK1F1OxNl4dI284dJ4AaABAQ'
  conversation_state:
    conversation:
      conversation_history_supported:
        True
      current_participant:
        []
          chat_id:
            u'102947609875635305807'
          gaia_id:
            u'102947609875635305807'
      has_active_hangout:
        False
      id:
        id:
          u'UgwK1F1OxNl4dI284dJ4AaABAQ'
      otr_status:
        u'ON_THE_RECORD'
      otr_toggle:
        u'ENABLED'
      participant_data:
        []
          fallback_name:
            u'Cory D Dodt'
          id:
            chat_id:
              u'113502602137131383073'
            gaia_id:
              u'113502602137131383073'
      read_state:
        []
          latest_read_timestamp:
            u'1368827350047782'
          participant_id:
            chat_id:
              u'113502602137131383073'
            gaia_id:
              u'113502602137131383073'
      self_conversation_state:
        active_timestamp:
          u'1368815272855000'
        invite_timestamp:
          u'1368815272855000'
        inviter_id:
          chat_id:
            u'102947609875635305807'
          gaia_id:
            u'102947609875635305807'
        notification_level:
          u'RING'
        self_read_state:
          latest_read_timestamp:
            u'1368827350047782'
          participant_id:
            chat_id:
              u'113502602137131383073'
            gaia_id:
              u'113502602137131383073'
        sort_timestamp:
          u'1368827350047782'
        status:
          u'ACTIVE'
        view:
          []
            u'ARCHIVED_VIEW'
      type:
        u'STICKY_ONE_TO_ONE'
    conversation_id:
      id:
        u'UgwK1F1OxNl4dI284dJ4AaABAQ'
    event:
      []
        advances_sort_timestamp:
          True
        chat_message:
          message_content:
            segment:
              []
                text:
                  u"hey... so my mom has been trying to get a hold of you. She's at some mental hospital, and she says she keeps calling you at you're not answering."
                type:
                  u'TEXT'
        conversation_id:
          id:
            u'UgwK1F1OxNl4dI284dJ4AaABAQ'
        event_id:
          u'7-H0Z7-9ffC7-H0ZDh6Ywv'
        event_otr:
          u'ON_THE_RECORD'
        self_event_state:
          notification_level:
            u'RING'
          user_id:
            chat_id:
              u'113502602137131383073'
            gaia_id:
              u'113502602137131383073'
        sender_id:
          chat_id:
            u'102947609875635305807'
          gaia_id:
            u'102947609875635305807'
        timestamp:
          u'1368815273814245'
  response_header:
    current_server_time:
      u'1374301514550000'
    debug_url:
      u''
    request_trace_id:
      u'16458940411132596536'
    status:
      u'OK'
"""
