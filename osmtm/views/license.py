from pyramid.view import view_config
from pyramid.url import route_path
from pyramid.httpexceptions import (
    HTTPFound,
    HTTPUnauthorized
)
from ..models import (
    DBSession,
    License,
    User,
)

from pyramid.security import authenticated_userid


@view_config(route_name='licenses', renderer='licenses.mako',
             permission="license_edit")
def licenses(request):
    licenses = DBSession.query(License).all()

    return dict(page_id="licenses", licenses=licenses)


@view_config(route_name='license', renderer='license.mako')
def license(request):
    _ = request.translate
    id = request.matchdict['license']
    license = DBSession.query(License).get(id)
    user_id = authenticated_userid(request)

    if not user_id:
        raise HTTPUnauthorized()

    user = DBSession.query(User).get(user_id)

    if not user:  # pragma: no cover
        raise HTTPUnauthorized()

    redirect = request.params.get("redirect", request.route_path("home"))
    if "accepted_terms" in request.params:
        if request.params["accepted_terms"] == _('I AGREE'):
            user.accepted_licenses.append(license)
        elif license in user.accepted_licenses:
            user.accepted_licenses.remove(license)
        return HTTPFound(location=redirect)

    return dict(page_id="license", user=user, license=license,
                redirect=redirect)


@view_config(route_name='license_delete', permission='license_edit')
def license_delete(request):
    _ = request.translate
    id = request.matchdict['license']
    license = DBSession.query(License).get(id)

    if not license:
        request.session.flash(_("License doesn't exist!"))
    else:
        DBSession.delete(license)
        DBSession.flush()
        request.session.flash(_('License removed!'))

    return HTTPFound(location=route_path('licenses', request))


@view_config(route_name='license_new', renderer='license.edit.mako',
             permission='license_edit')
@view_config(route_name='license_edit', renderer='license.edit.mako',
             permission='license_edit')
def license_edit(request):
    _ = request.translate
    if 'license' in request.matchdict:
        id = request.matchdict['license']
        license = DBSession.query(License).get(id)
    else:
        license = None

    if 'form.submitted' in request.params:
        if not license:
            license = License()
            DBSession.add(license)
            DBSession.flush()
            request.session.flash(_('License created!'), 'success')
        else:
            request.session.flash(_('License updated!'), 'success')

        license.name = request.params['name']
        license.description = request.params['description']
        license.plain_text = request.params['plain_text']

        DBSession.add(license)
        return HTTPFound(location=route_path('licenses', request))
    return dict(page_id="licenses", license=license)
