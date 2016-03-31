from . import BaseTestCase


class TestUtils(BaseTestCase):

    def test_interpolate_text(self):
        from osmtm.utils import interpolate_text
        text = 'test {foo} bar'
        props = {
            'foo': 'replaced'
        }
        self.assertEqual(interpolate_text(text, props), 'test replaced bar')
        props = {
            'foo': 42
        }
        self.assertEqual(interpolate_text(text, props), 'test 42 bar')
        text = 'replace {var1} and {var2}'
        props = {
            'var1': 'test',
            'var2': 42
        }
        self.assertEqual(interpolate_text(text, props), 'replace test and 42')
