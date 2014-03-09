# -*- coding: utf-8 -*-
<!DOCTYPE html>
<html>
  <head>
    <title>OSM Tasking Manager</title>
    <link rel="stylesheet" href="${request.static_url('osmtm:static/css/main.css')}">
    <link rel="stylesheet" href="${request.static_url('osmtm:static/js/lib/leaflet.css')}">
    <script src="${request.static_url('osmtm:static/js/lib/jquery-1.7.2.min.js')}"></script>
    <script src="${request.static_url('osmtm:static/js/lib/showdown.js')}"></script>
    <script src="${request.static_url('osmtm:static/js/lib/jquery-timeago/jquery.timeago.js')}"></script>
    <script src="${request.static_url('osmtm:static/js/lib/jquery-timeago/locales/jquery.timeago.%s.js' % request.locale_name)}"></script>
    <script src="${request.static_url('osmtm:static/js/lib/sammy-latest.min.js')}"></script>
    <script src="${request.static_url('osmtm:static/js/shared.js')}"></script>
    <script src="${request.static_url('osmtm:static/bootstrap/js/bootstrap-dropdown.js')}"></script>
    <script src="${request.static_url('osmtm:static/bootstrap/js/bootstrap-tooltip.js')}"></script>
    <script src="${request.static_url('osmtm:static/bootstrap/js/bootstrap-transition.js')}"></script>
    <script src="${request.static_url('osmtm:static/bootstrap/js/bootstrap-tab.js')}"></script>
    <script src="${request.static_url('osmtm:static/bootstrap/js/bootstrap-modal.js')}"></script>
<%
from pyramid.security import authenticated_userid
from osmtm.models import DBSession, User, TaskComment
login_url= request.route_url('login', _query=[('came_from', request.url)])
username = authenticated_userid(request)
if username is not None:
   user = DBSession.query(User).get(username)
else:
   user = None
languages = request.registry.settings.available_languages.split()

comments = []
if user is not None:
    comments = DBSession.query(TaskComment).filter(TaskComment.task_history.has(prev_user_id=user.id)).all()
%>
    <script> 
        var base_url = "${request.route_url('home')}";
    </script>

  </head>
  <body id="${page_id}">
    <div id="wrap">
	<div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container"><%block name="header"></%block>
% if  user is not None:
          <%include file="user_menu.mako" args="user=user"/>
          <%
              badge = ""
              if len(comments) > 0:
                  badge = '<sup><span class="badge badge-important">%s</span></sup>' % len(comments)
          %>
          <a class="btn btn-link pull-right messages" href="${request.route_url('user_messages')}">
            <i class="icon-envelope" style="opacity: 0.5;"></i>${badge|n}
          </a>
% else:
<a href="${login_url}" class="btn btn-small btn-link pull-right">${_('login to OpenStreetMap')}</a>
% endif
          <%include file="languages_menu.mako" args="languages=languages"/>
        </div>
      </div>
    </div>
% if  request.session.peek_flash():

    <div class="container">
      <div class="row">
          <div id="flash" class="alert">
<% flash = request.session.pop_flash() %>
% for message in flash:
${message}
%endfor
        </div>
      </div>
    </div>
% endif

    <%block name="content"></%block>
    </div>
	<footer class="footer">
      <div class="container">
        <p class="span6">Designed and built for the<a>Humanitarian OpenStreetMap Team</a>
          <with>initial sponsorship from the Australia-Indonesia Facility for Disaster Reduction.</with>
        </p>
        <p class="pull-right">Fork the code on<a href="http://github.com/hotosm/osm-tasking-manager">github</a>.

        </p>
      </div>
    </footer>
  </body>
</html>
