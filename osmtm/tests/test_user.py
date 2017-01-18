# -*- coding: utf-8 -*-
from . import BaseTestCase
import httpretty


class TestViewsFunctional(BaseTestCase):

    def test_users(self):
        self.testapp.get('/users', status=200)

    def test_users__logged_in(self):
        headers = self.login_as_user1()
        res = self.testapp.get('/users', headers=headers)
        # user should appear as authenticated
        self.assertFalse('login to OpenStreetMap' in res.body)

    def test_users_json(self):
        res = self.testapp.get('/users.json', status=200)
        self.assertEqual(len(res.json), 7)

    def test_users_json__query(self):
        res = self.testapp.get('/users.json',
                               params={
                                   'q': 'er1'
                               },
                               status=200)
        self.assertEqual(len(res.json), 1)

    def test_user_messages__not_authenticated(self):
        self.testapp.get('/user/messages', status=302)

    def test_user_messages(self):

        headers = self.login_as_user1()
        self.testapp.get('/user/messages', headers=headers, status=200)

    def test_user_admin__logged_in_as_admin(self):

        httpretty.enable()
        from osmtm.models import User, DBSession
        import transaction

        userid = 5463
        username = u'dude_user'
        user = User(userid, username)
        DBSession.add(user)
        DBSession.flush()
        transaction.commit()

        httpretty.register_uri(
            httpretty.GET,
            "http://www.openstreetmap.org/api/0.6/user/%s" % userid,
            body='<?xml version="1.0" encoding="UTF-8"?>' +
                 '<osm> <user display_name="%s"></user></osm>' % username,
            content_type='application/xml; charset=utf-8')

        headers = self.login_as_admin()
        res = self.testapp.get('/user/%d/admin' % userid, headers=headers,
                               status=302)

        res2 = res.follow(headers=headers, status=200)
        self.failUnless('dude_user' in res2.body)
        self.failUnless('This user is an administrator' in res2.body)

        DBSession.delete(user)
        transaction.commit()

    def test_user_admin__same_user(self):

        headers = self.login_as_admin()
        self.testapp.get('/user/%d/admin' % self.admin_user_id,
                         headers=headers, status=400)

    def test_user_project_manager__logged_in_as_admin(self):
        httpretty.enable()

        from osmtm.models import User, DBSession
        import transaction

        userid = 5463
        username = u'simon_user'
        user = User(userid, username)
        DBSession.add(user)
        DBSession.flush()
        transaction.commit()

        httpretty.register_uri(
            httpretty.GET,
            "http://www.openstreetmap.org/api/0.6/user/%s" % userid,
            body='<?xml version="1.0" encoding="UTF-8"?>' +
                 '<osm> <user display_name="%s"></user></osm>' % username,
            content_type='application/xml; charset=utf-8')

        headers = self.login_as_admin()
        res = self.testapp.get('/user/%d/project_manager' % userid,
                               headers=headers,
                               status=302)
        res2 = res.follow(headers=headers, status=200)
        self.failUnless('This user is a project manager' in res2.body)

        DBSession.delete(user)
        transaction.commit()

    def test_editor_validator_levels(self):
        from osmtm.models import User, DBSession
        import transaction

        edi_userid = 1111
        edi_username = u'editor_level_soon'

        val_userid = 2222
        val_username = u'validator_level_soon'

        edi_user = User(edi_userid, edi_username)
        val_user = User(val_userid, val_username)

        DBSession.add(edi_user)
        DBSession.add(val_user)
        DBSession.flush()
        transaction.commit()

        edi_user_before = DBSession.query(User).get(edi_userid)
        val_user_before = DBSession.query(User).get(val_userid)

        self.assertEqual(edi_user_before.editor_level, 0)
        self.assertEqual(val_user_before.validator_level, 0)

        headers = self.login_as_admin()
        self.testapp.get('/user/%s/editor_level/%s' % (edi_userid, 1),
                         headers=headers, status=302)
        self.testapp.get('/user/%s/validator_level/%s' % (val_userid, 1),
                         headers=headers, status=302)

        edi_user_after = DBSession.query(User).get(edi_userid)
        val_user_after = DBSession.query(User).get(val_userid)

        self.assertEqual(edi_user_after.editor_level, 1)
        self.assertEqual(val_user_after.validator_level, 1)

    def test_user(self):
        httpretty.enable()
        from . import USER1_ID

        username = 'user1'

        httpretty.register_uri(
            httpretty.GET,
            "http://www.openstreetmap.org/api/0.6/user/%s" % USER1_ID,
            body='<?xml version="1.0" encoding="UTF-8"?>' +
                 '<osm> <user display_name="%s"></user></osm>' % username,
            content_type='application/xml; charset=utf-8')

        res = self.testapp.get('/user/%s' % username, status=200)
        self.failUnless(username in res.body)

    def test_user__doesnt_exists(self):

        self.testapp.get('/user/unknown_user', status=302)

    def test_user__username_change(self):
        httpretty.enable()

        from osmtm.models import User, DBSession
        import transaction

        userid = 11
        username = u'new_user'
        user = User(userid, username)
        DBSession.add(user)
        DBSession.flush()
        transaction.commit()

        new_username = username + '_changed'
        httpretty.register_uri(
            httpretty.GET,
            "http://www.openstreetmap.org/api/0.6/user/%s" % userid,
            body='<?xml version="1.0" encoding="UTF-8"?>' +
                 '<osm> <user display_name="%s"></user></osm>' % new_username,
            content_type='application/xml; charset=utf-8')

        self.testapp.get('/user/%s' % username, status=302)

        user = DBSession.query(User).get(userid)
        self.assertEqual(user.username, new_username)

        DBSession.delete(user)
        transaction.commit()

    def test_user__OSM_API_failure(self):
        httpretty.enable()
        from . import USER1_ID

        username = 'user1'

        httpretty.register_uri(
            httpretty.GET,
            "http://www.openstreetmap.org/api/0.6/user/%s" % USER1_ID,
            status=500)

        self.testapp.get('/user/%s' % username, status=200)

    def test_user__username_with_accents(self):
        httpretty.enable()

        from osmtm.models import User, DBSession
        import transaction

        userid = 12
        username = u'new_user_éà'
        user = User(userid, username)
        DBSession.add(user)
        DBSession.flush()
        transaction.commit()

        httpretty.register_uri(
            httpretty.GET,
            "http://www.openstreetmap.org/api/0.6/user/%s" % userid,
            body='<?xml version="1.0" encoding="UTF-8"?>' +
                 '<osm> <user display_name="%s"></user></osm>' % username,
            content_type='application/xml; charset=utf-8')

        headers = self.login_as_user(userid)
        self.testapp.get('/project/1/task/4/lock', status=200,
                         headers=headers,
                         xhr=True)
        self.testapp.get('/project/1/task/4/done', status=200,
                         headers=headers,
                         params={
                             'comment': 'some_comment'
                         },
                         xhr=True)

        self.testapp.get((u'/user/%s' % username).encode('utf8'), status=200)

        self.testapp.get('/project/1/task/4', status=200,
                         headers=headers,
                         xhr=True)
