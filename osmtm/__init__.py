import os

from pyramid.config import Configurator
from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from pyramid.session import UnencryptedCookieSessionFactoryConfig
from pyramid.paster import get_appsettings

from .utils import get_sql_engine

from .models import (
    DBSession,
    Base,
)

from .resources import (
    MapnikRendererFactory
)

from sqlalchemy_i18n.manager import translation_manager

from .security import (
    RootFactory,
    group_membership,
)


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    settings['mako.directories'] = 'osmtm:templates'
    local_settings_path = os.environ.get('LOCAL_SETTINGS_PATH', 'local.ini')
    if os.path.exists(local_settings_path):
        local_settings = get_appsettings('local.ini')
        settings.update(local_settings)

    engine = get_sql_engine(settings)
    DBSession.configure(bind=engine)
    Base.metadata.bind = engine

    authn_policy = AuthTktAuthenticationPolicy(
        secret='super_secret',
        callback=group_membership)
    authz_policy = ACLAuthorizationPolicy()
    config = Configurator(settings=settings,
                          root_factory=RootFactory,
                          authentication_policy=authn_policy,
                          authorization_policy=authz_policy)
    # fixes backwards incompatibilities when running Pyramid 1.5a
    # https://pypi.python.org/pypi/pyramid#features
    config.include('pyramid_mako')

    # pyramid_tm uses the transaction module to begin/commit/rollback
    # transaction when requests begin/end.
    config.include('pyramid_tm')

    session_factory = UnencryptedCookieSessionFactoryConfig('itsasecret')
    config.set_session_factory(session_factory)

    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('login', '/login')
    config.add_route('logout', '/logout')
    config.add_route('oauth_callback', '/oauth_callback')
    config.add_route('project_new', '/project/new')
    config.add_route('project_new_grid', '/project/new/grid')
    config.add_route('project_new_import', '/project/new/import')
    config.add_route('project', '/project/{project}')
    config.add_route('project_edit', '/project/{project}/edit')
    config.add_route('project_mapnik',
                     '/project/{project}/{z}/{x}/{y}.{format}')
    config.add_route('project_check_for_update',
                     '/project/{project}/check_for_updates')
    config.add_route('task_random', '/project/{project}/random', xhr=True)
    config.add_route('task_empty', '/project/{project}/task/empty', xhr=True)
    config.add_route('task_xhr', '/project/{project}/task/{task}', xhr=True)
    config.add_route('task_done',
                     '/project/{project}/task/{task}/done', xhr=True)
    config.add_route('task_lock',
                     '/project/{project}/task/{task}/lock', xhr=True)
    config.add_route('task_unlock',
                     '/project/{project}/task/{task}/unlock', xhr=True)
    config.add_route('task_split',
                     '/project/{project}/task/{task}/split', xhr=True)
    config.add_route('task_invalidate',
                     '/project/{project}/task/{task}/invalidate', xhr=True)
    config.add_route('task_gpx', '/project/{project}/task/{task}.gpx')
    config.add_route('users', '/users')
    config.add_route('user_messages', '/user/messages')
    config.add_route('user', '/user/{username}')
    config.add_route('user_admin', '/user/{id}/admin')
    config.add_route('user_prefered_editor',
                     '/user/prefered_editor/{editor}', xhr=True)
    config.add_route('user_prefered_language',
                     '/user/prefered_language/{language}', xhr=True)
    config.add_route('licenses', '/licenses')
    config.add_route('license_new', '/license/new')
    config.add_route('license', '/license/{license}')
    config.add_route('license_edit', '/license/{license}/edit')
    config.add_route('license_delete', '/license/{license}/delete')

    config.add_renderer('mapnik', MapnikRendererFactory)

    config.add_translation_dirs('osmtm:locale')
    config.set_locale_negotiator('osmtm.i18n.custom_locale_negotiator')

    translation_manager.options.update({
        'locales': settings['available_languages'].split(),
        'get_locale_fallback': True
    })

    config.scan(ignore=['osmtm.tests', 'osmtm.scripts'])
    return config.make_wsgi_app()
