''' Should move to javascript showdown/markdown extension ??
'''
import re

from .models import (
    DBSession,
    User,
)


p = re.compile(ur'(@\d+)')


def convert_mentions(request):
    ''' Mako filter to convert any @id mention to link to user profile
    '''
    def d(text):

        def repl(val):
            user_id = val.group()[1:]
            user = DBSession.query(User).get(user_id)
            link = request.route_path('user', username=user.username)
            return '[@%s](%s)' % (user.username, link)

        return re.sub(p, repl, text)

    return d
