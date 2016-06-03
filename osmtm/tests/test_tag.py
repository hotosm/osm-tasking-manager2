from . import BaseTestCase


class TestTagFunctional(BaseTestCase):

    def test_tagss_not_authenticated(self):
        self.testapp.get('/tags', status=403)

    def test_tags(self):
        headers = self.login_as_admin()
        self.testapp.get('/tags', headers=headers, status=200)

    def test_tag_new__forbidden(self):
        self.testapp.get('/tag/new', status=403)

        headers = self.login_as_user1()
        self.testapp.get('/tag/new', headers=headers, status=403)

    def test_tag_new(self):
        headers = self.login_as_admin()
        self.testapp.get('/tag/new', headers=headers, status=200)

    def test_tag_new__submitted(self):
        from osmtm.models import DBSession, Tag
        headers = self.login_as_admin()
        self.testapp.post('/tag/new', headers=headers,
                          params={
                              'form.submitted': True,
                              'name': 'Name',
                              'admin_description': 'description'
                          },
                          status=302)

        self.assertEqual(DBSession.query(Tag).count(), 2)

    def test_tag_edit__forbidden(self):
        self.testapp.get('/tag/1/edit', status=403)

        headers = self.login_as_user1()
        self.testapp.get('/tag/1/edit', headers=headers, status=403)

    def test_tag_edit(self):
        headers = self.login_as_admin()
        self.testapp.get('/tag/1/edit', headers=headers, status=200)

    def test_tag_edit__submitted(self):
        from osmtm.models import DBSession, Tag
        headers = self.login_as_admin()
        self.testapp.post('/tag/1/edit', headers=headers,
                          params={
                              'form.submitted': True,
                              'name': 'changed_name',
                              'admin_description': 'changed_description',
                              'spotlight_text_en': 'English_spotlight_text'
                          },
                          status=302)

        self.assertEqual(DBSession.query(Tag).get(1).name, u'changed_name')

    def test_tag_delete__forbidden(self):
        self.testapp.get('/tag/3/delete', status=403)

        headers = self.login_as_user1()
        self.testapp.get('/tag/3/delete', headers=headers, status=403)

    def test_tag_delete(self):
        import transaction
        from osmtm.models import DBSession, Tag
        tag = Tag()
        DBSession.add(tag)
        DBSession.flush()
        tag_id = tag.id
        transaction.commit()

        headers = self.login_as_admin()
        self.testapp.get('/tag/%d/delete' % tag_id,
                         headers=headers, status=302)

        self.assertEqual(DBSession.query(Tag).count(), 1)

    def test_tag_delete__doesnt_exist(self):
        headers = self.login_as_admin()
        self.testapp.get('/tag/999/delete', headers=headers, status=302)
