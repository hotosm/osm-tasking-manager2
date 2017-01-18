from pyramid.view import view_config
from pyramid.url import route_path
from pyramid.httpexceptions import (
    HTTPFound,
)
from ..models import (
    DBSession,
    Tag
)


@view_config(route_name="tags", renderer="tags.mako",
             permission="license_edit")
def tags(request):
    tags = DBSession.query(Tag).all()

    return dict(page_id="tags", tags=tags)


@view_config(route_name="tag_delete", permission="license_edit")
def tag_delete(request):
    _ = request.translate
    id = request.matchdict['tag']
    tag = DBSession.query(Tag).get(id)

    if not tag:
        request.session.flash(_("Tag doesn't exist!"))
    else:
        DBSession.delete(tag)
        DBSession.flush()
        request.session.flash(_("Tag removed!"))

    return HTTPFound(location=route_path("tags", request))


@view_config(route_name='tag_new', renderer='tag.edit.mako',
             permission='license_edit')
@view_config(route_name='tag_edit', renderer='tag.edit.mako',
             permission='license_edit')
def tag_edit(request):
    _ = request.translate
    if 'tag' in request.matchdict:
        id = request.matchdict['tag']
        tag = DBSession.query(Tag).get(id)
        translations = tag.translations.items()
    else:
        tag = None
        translations = None

    if 'form.submitted' in request.params:
        if not tag:
            tag = Tag()
            DBSession.add(tag)
            DBSession.flush()
            request.session.flash(_('Project tag created!'), 'success')
        else:
            request.session.flash(_('Project tag updated!'), 'success')

        tag.name = request.params['name']
        tag.admin_description = request.params['admin_description']
        for locale, translation in tag.translations.iteritems():
            with tag.force_locale(locale):
                translated = '_'.join(['spotlight_text', locale])
                if translated in request.params:
                    setattr(tag, 'spotlight_text', request.params[translated])

        DBSession.add(tag)
        return HTTPFound(location=route_path('tags', request))

    return dict(page_id="tags", tag=tag, translations=translations)
