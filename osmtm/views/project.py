from pyramid.view import view_config
from pyramid.httpexceptions import HTTPFound
from pyramid.url import route_path
from pyramid.response import Response
from ..models import (
    DBSession,
    Project,
    Area,
    PriorityArea,
    User,
    Task,
    TaskState,
    TaskLock,
    License,
)
from pyramid.security import authenticated_userid

from pyramid.i18n import (
    get_locale_name,
)
from sqlalchemy.orm import (
    joinedload,
)
from sqlalchemy.sql.expression import (
    and_,
    not_,
    or_,
    func,
)

from geoalchemy2 import (
    shape,
)

from shapely.geometry import (
    MultiPolygon
)

from geoalchemy2.functions import (
    ST_Area,
    ST_Transform,
)

from geojson import (
    FeatureCollection,
    Feature,
)

import datetime
import itertools

from .task import get_locked_task, add_comment

from ..utils import (
    parse_geojson,
    convert_to_multipolygon,
    get_tiles_in_geom,
)

import logging
log = logging.getLogger(__name__)


@view_config(route_name='project', renderer='project.mako', http_cache=0,
             permission='project_show')
def project(request):
    check_project_expiration()
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    if project is None:
        _ = request.translate
        request.session.flash(_("Sorry, this project doesn't  exist"))
        return HTTPFound(location=route_path('home', request))

    project.locale = get_locale_name(request)

    filter = and_(TaskState.project_id == id,
                  TaskState.state != TaskState.state_removed,
                  TaskState.state != TaskState.state_ready)
    history = DBSession.query(TaskState) \
                       .filter(filter) \
                       .order_by(TaskState.date.desc()) \
                       .limit(20).all()

    user_id = authenticated_userid(request)
    locked_task = None
    user = None
    if user_id:
        user = DBSession.query(User).get(user_id)
        locked_task = get_locked_task(project.id, user)

    features = []
    for area in project.priority_areas:
        features.append(Feature(geometry=shape.to_shape(area.geometry)))

    return dict(page_id='project', project=project,
                locked_task=locked_task,
                history=history,
                priority_areas=FeatureCollection(features),)


@view_config(route_name="project_json", renderer='json',
             permission="project_show",
             http_cache=0)
def project_json(request):
    id = request.matchdict['project']
    if not request.is_xhr:
        request.response.content_disposition = \
            'attachment; filename="osmtm_project_%s.json"' % id
    request.response.headerlist.append(('Access-Control-Allow-Origin', '*'))
    return get_project(id)


def get_project(id):
    project = DBSession.query(Project).get(id)

    if project is None:
        return {}

    return project.to_feature()


@view_config(route_name='project_new',
             renderer='project.new.mako',
             permission="project_edit")
def project_new(request):
    return dict(page_id='project_new')


@view_config(route_name='project_new_grid',
             renderer='project.new.mako',
             permission="project_edit")
def project_new_grid(request):
    _ = request.translate
    user_id = authenticated_userid(request)
    user = DBSession.query(User).get(user_id)

    try:
        project = Project(
            _(u'Untitled project'),
            user
        )

        DBSession.add(project)
        DBSession.flush()

        tile_size = int(request.params['tile_size'])

        geometry = request.params['geometry']

        geoms = parse_geojson(geometry)
        multipolygon = convert_to_multipolygon(geoms)

        geometry = shape.from_shape(multipolygon, 4326)

        geom_3857 = DBSession.execute(ST_Transform(geometry, 3857)).scalar()
        geom_3857 = shape.to_shape(geom_3857)
        zoom = get_zoom_for_tile_size(geom_3857, tile_size)

        project.area = Area(geometry)
        project.auto_fill(zoom)

        request.session.flash(_("Project #${project_id} created successfully",
                              mapping={'project_id': project.id}),
                              'success')
        return HTTPFound(location=route_path('project_edit', request,
                                             project=project.id))
    except Exception, e:
        msg = _("Sorry, could not create the project. <br />%s") % e.message
        request.session.flash(msg, 'alert')
        raise HTTPFound(location=route_path('project_new', request))


@view_config(route_name='project_new_arbitrary',
             permission="project_edit")
def project_new_arbitrary(request):
    _ = request.translate

    user_id = authenticated_userid(request)
    user = DBSession.query(User).get(user_id)

    try:
        project = Project(
            _(u'Untitled project'),
            user
        )
        count = project.import_from_geojson(request.POST['geometry'])
        request.session.flash(_("Successfully imported ${n} geometries",
                              mapping={'n': count}),
                              'success')
        return HTTPFound(location=route_path('project_edit', request,
                         project=project.id))
    except Exception, e:
        msg = _("Sorry, could not create the project. <br />%s") % e.message
        request.session.flash(msg, 'alert')
        raise HTTPFound(location=route_path('project_new', request))


@view_config(route_name="project_grid_simulate",
             renderer="json",
             permission="project_edit")
def project_grid_simulate(request):
    ''' Returns collection of polygons representing the grid cells to be
        created. Helpful when creating a new project '''
    geometry = request.params['geometry']
    tile_size = int(request.params['tile_size'])

    geoms = parse_geojson(geometry)
    multipolygon = convert_to_multipolygon(geoms)

    geometry = shape.from_shape(multipolygon, 4326)

    geom_3857 = DBSession.execute(ST_Transform(geometry, 3857)).scalar()
    geom_3857 = shape.to_shape(geom_3857)
    zoom = get_zoom_for_tile_size(geom_3857, tile_size)

    found = get_tiles_in_geom(geom_3857, zoom)
    polygons = [i[2] for i in found]
    multi = MultiPolygon(polygons)

    geometry = DBSession.execute(
        ST_Transform(shape.from_shape(multi, 3857), 4326)).scalar()

    return FeatureCollection([Feature(geometry=shape.to_shape(geometry))])


@view_config(route_name='project_edit', renderer='project.edit.mako',
             permission="project_edit")
def project_edit(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    licenses = DBSession.query(License).all()
    if 'form.submitted' in request.params:

        for locale, translation in project.translations.iteritems():
            with project.force_locale(locale):
                for field in ['name', 'short_description', 'description',
                              'instructions', 'per_task_instructions']:
                    translated = '_'.join([field, locale])
                    if translated in request.params:
                        setattr(project, field, request.params[translated])
                DBSession.add(project)

        for p in ['changeset_comment', 'entities_to_map', 'imagery']:
            if p in request.params:
                setattr(project, p, request.params[p])

        if 'license_id' in request.params and \
                request.params['license_id'] != "":
            license_id = int(request.params['license_id'])
            license = DBSession.query(License).get(license_id)
            project.license = license

        if 'private' in request.params and \
                request.params['private'] == 'on':
            project.private = True
        else:
            project.private = False

        project.status = request.params['status']
        project.priority = request.params['priority']

        if request.params.get('due_date', '') != '':
            due_date = request.params.get('due_date')
            due_date = datetime.datetime.strptime(due_date, "%m/%d/%Y")
            project.due_date = due_date
        else:
            project.due_date = None

        if 'josm_preset' in request.params:
            josm_preset = request.params.get('josm_preset')
            if hasattr(josm_preset, 'value'):
                project.josm_preset = josm_preset.value.decode('UTF-8')

        # Remove the previously set priority areas
        for area in project.priority_areas:
            DBSession.delete(area)
        project.priority_areas[:] = []
        DBSession.flush()

        priority_areas = request.params.get('priority_areas', '')

        if priority_areas != '':
            geoms = parse_geojson(priority_areas)

            for geom in geoms:
                geom = 'SRID=4326;%s' % geom.wkt
                project.priority_areas.append(PriorityArea(geom))

        DBSession.add(project)
        return HTTPFound(location=route_path('project', request,
                         project=project.id))

    translations = project.translations.items()

    features = []
    for area in project.priority_areas:
        features.append(Feature(geometry=shape.to_shape(area.geometry)))

    return dict(page_id='project_edit', project=project, licenses=licenses,
                translations=translations,
                priority_areas=FeatureCollection(features))


@view_config(route_name='project_publish',
             permission='project_edit')
def project_publish(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    project.status = project.status_published

    return HTTPFound(location=route_path('project', request,
                                         project=project.id))


@view_config(route_name='project_contributors', renderer='json')
def project_contributors(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    return get_contributors(project)


@view_config(route_name='project_stats', renderer='json')
def project_stats(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    return get_stats(project)


@view_config(route_name="project_check_for_update", renderer='json')
def check_for_updates(request):
    id = request.matchdict['project']
    interval = request.GET['interval']
    date = datetime.datetime.utcnow() \
        - datetime.timedelta(0, 0, 0, int(interval))
    updated = []

    tasks = DBSession.query(Task) \
                     .filter(Task.project_id == id, Task.date > date) \
                     .all()
    for task in tasks:
        updated.append(task.to_feature())

    tasks_lock = DBSession.query(TaskLock) \
        .filter(
            TaskLock.project_id == id,
            TaskLock.date > date,
            TaskLock.lock != None  # noqa
        ) \
        .all()
    for lock in tasks_lock:
        updated.append(lock.task.to_feature())

    states = DBSession.query(TaskState) \
        .filter(
            TaskState.project_id == id,
            TaskState.date > date,
            TaskState.state != TaskState.state_ready
        ) \
        .all()
    for state in states:
        updated.append(state.task.to_feature())

    if len(updated) > 0:
        return dict(update=True, updated=updated)
    return dict(update=False)


@view_config(route_name="project_tasks_json", renderer='json',
             permission="project_show",
             http_cache=0)
def project_tasks_json(request):
    id = request.matchdict['project']
    if not request.is_xhr:
        request.response.content_disposition = \
            'attachment; filename="osmtm_tasks_%s.json"' % id

    request.response.headerlist.append(('Access-Control-Allow-Origin', '*'))
    return get_tasks(id)


def get_tasks(id):
    project = DBSession.query(Project).get(id)

    tasks = DBSession.query(Task) \
                     .filter(Task.project_id == project.id) \
                     .options(joinedload(Task.cur_state)) \
                     .options(joinedload(Task.cur_lock)) \

    return FeatureCollection([task.to_feature() for task in tasks])


@view_config(route_name="project_user_add", renderer='json',
             permission="project_edit")
def project_user_add(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    username = request.matchdict['user']
    user = DBSession.query(User).filter(User.username == username).one()

    project.allowed_users.append(user)
    DBSession.add(project)

    return dict(user=user.as_dict())


@view_config(route_name="project_user_delete", renderer='json',
             permission="project_edit")
def project_user_delete(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    user_id = request.matchdict['user']
    user = DBSession.query(User).get(user_id)

    project.allowed_users.remove(user)
    DBSession.add(project)

    return dict()


@view_config(route_name='project_users', renderer='json',
             permission="project_show")
def project_users(request):
    ''' get the list of users for a given project.
        Returns list of allowed users if project is private.
        Return complete list of users if project is not private.
        Users with assigned tasks will appear first. '''

    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    query = request.params.get('q', '')
    query_filter = User.username.ilike(u"%" + query + "%")

    ''' list of users with assigned tasks '''
    t = DBSession.query(
            func.max(Task.assigned_date).label('date'),
            Task.assigned_to_id
        ) \
        .filter(
            Task.assigned_to_id != None,  # noqa
            Task.project_id == id
        ) \
        .group_by(Task.assigned_to_id) \
        .subquery('t')
    assigned = DBSession.query(User) \
        .join(t, and_(User.id == t.c.assigned_to_id)) \
        .filter(query_filter) \
        .order_by(t.c.date.desc()) \
        .all()

    r = []
    for user in assigned:
        r.append(user.username)

    if project.private:
        ''' complete list with allowed users '''
        users = DBSession.query(User) \
            .join(Project.allowed_users) \
            .filter(Project.id == id, query_filter)
        for user in users:
            if user.username not in r:
                r.append(user.username)
    else:
        ''' complete list with some users (up to 10 in total) '''
        users = DBSession.query(User).order_by(User.username) \
            .filter(query_filter)
        if len(r) > 0:
            users = users.filter(not_(User.username.in_(r)))
        users = users.limit(max(0, 10 - len(r)))  # we don't want all users
        r = r + [u.username for u in users]

    return r


@view_config(route_name='project_preset')
def project_preset(request):
    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)

    response = Response()
    response.text = project.josm_preset
    response.content_disposition = \
        'attachment; filename=hotosm_tasking_manager_project_%s.xml' \
        % project.id
    response.content_type = 'application/x-josm-preset'
    return response


@view_config(route_name='project_invalidate_all', renderer='json',
             permission='project_edit')
def project_invalidate_all(request):
    _ = request.translate

    # If user has not entered a comment, return error
    if not request.POST.get('comment', None):
        return {
            'error': True,
            'error_msg': _('A comment is required.')
        }

    challenge_id = request.POST.get('challenge_id', None)
    if not passes_project_id_challenge(challenge_id,
                                       request.matchdict['project']):
        return {
            'error': True,
            'error_msg': _('Please type the project id in the box to confirm')
        }

    id = request.matchdict['project']
    project = DBSession.query(Project).get(id)
    user_id = authenticated_userid(request)
    user = DBSession.query(User).get(user_id)
    tasks = project.tasks
    tasks_affected = 0
    for task in tasks:
        if task.cur_state.state == TaskState.state_done:
            tasks_affected += 1
            task.user = None
            task.states.append(TaskState(user=user,
                                         state=TaskState.state_invalidated))
            task.locks.append(TaskLock(user=None, lock=False))
            add_comment(request, task, user)
            DBSession.add(task)
    if tasks_affected == 0:
        msg = _('No done tasks to invalidate.')
    else:
        msg = _('%d tasks invalidated' % tasks_affected)
    DBSession.flush()
    return dict(success=True, msg=msg)


def passes_project_id_challenge(challenge_id, project_id):
    """
    Checks if challenge id is the same as project id.
    Returns True if yes, False if not
    """
    if not challenge_id:
        return False
    try:
        challenge_id_int = int(challenge_id)
        project_id_int = int(project_id)
    except:
        return False
    if not challenge_id_int == project_id_int:
        return False
    return True


def get_contributors(project):
    """ get the list of contributors and the tasks they worked on """

    # filter on tasks with state DONE
    filter = and_(
        TaskState.project_id == project.id,
        TaskState.state == TaskState.state_done
    )

    tasks = DBSession.query(TaskState.task_id, User.username) \
                     .join(TaskState.user) \
                     .filter(filter) \
                     .order_by(TaskState.user_id) \
                     .all()

    contributors = {}
    for user, tasks in itertools.groupby(tasks, key=lambda t: t.username):
        if user not in contributors:
            contributors[user] = {}
        contributors[user]['done'] = list(set([task[0] for task in tasks]))

    assigned = DBSession.query(Task.id, User.username) \
        .join(Task.assigned_to) \
        .filter(
            Task.project_id == project.id,
            Task.assigned_to_id != None  # noqa
        ) \
        .order_by(Task.assigned_to_id)
    for user, tasks in itertools.groupby(assigned,
                                         key=lambda t: t.username):
        if user not in contributors:
            contributors[user] = {}
        contributors[user]['assigned'] = list(set([task[0] for task in tasks]))

    return contributors


def get_stats(project):
    """
    the changes to create a chart with
    """

    total = DBSession.query(func.sum(ST_Area(Task.geometry))) \
        .filter(
            Task.cur_state.has(TaskState.state != TaskState.state_removed),
            Task.project_id == project.id
        ) \
        .scalar()

    subquery = DBSession.query(
        TaskState.state,
        TaskState.date,
        ST_Area(Task.geometry).label('area'),
        func.lag(TaskState.state).over(
            partition_by=(
                TaskState.task_id,
                TaskState.project_id
            ),
            order_by=TaskState.date
        ).label('prev_state')
    ).join(Task).filter(
        TaskState.project_id == project.id,
        TaskState.state != TaskState.state_ready) \
     .order_by(TaskState.date)

    tasks = subquery.all()
    log.debug('Number of tiles: %s', len(tasks))
    stats = [[project.created.isoformat(), 0, 0]]
    done = 0
    validated = 0

    # for every day count number of changes and aggregate changed tiles
    for task in tasks:
        if task.state == TaskState.state_done:
            done += task.area
        if task.state == TaskState.state_invalidated:
            if task.prev_state == TaskState.state_done:
                done -= task.area
            elif task.prev_state == TaskState.state_validated:
                validated -= task.area
        if task.state == TaskState.state_validated:
            validated += task.area
            done -= task.area

        # append a day to the stats and add total number of 'done' tiles and a
        # copy of a current tile_changes list
        stats.append([task.date.isoformat(), done, validated])

    return {"total": total, "stats": stats}


def check_project_expiration():
    ''' Verifies if a project has expired, ie. that its due date is over '''
    filter = or_(Project.status != Project.status_archived,
                 Project.status != Project.status_closed)
    expired = DBSession.query(Project) \
                       .filter(Project.due_date < datetime.datetime.now()) \
                       .filter(filter)

    for project in expired:
        project.status = Project.status_closed
        DBSession.add(project)


def get_zoom_for_tile_size(geom, tile_size):

    import math
    return int(28 - math.log(geom.area, 10) / 0.6 + tile_size)
