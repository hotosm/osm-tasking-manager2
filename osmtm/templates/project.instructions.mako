<div id="fb-root"></div>
<script>
window.fbAsyncInit = function() {
FB.init({appId: '297735373763944', status: true, cookie: true,
xfbml: true});
};
(function() {
var e = document.createElement('script'); e.async = true;
e.src = document.location.protocol +
'//connect.facebook.net/en_US/all.js';
document.getElementById('fb-root').appendChild(e);
}());
</script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js" type="text/javascript"></script>
<script type="text/javascript">
$(document).ready(function(){
$('#share_button').click(function(e){
e.preventDefault();
FB.ui(
{
method: 'feed',
name: 'http://www.openstreetmap.org',
link: 'http://localhost:6543/',
picture: 'http://www.openstreetmap.org/assets/osm_logo-ffa5c1cdfc01a05e3c17bedbf39854bf.png',
caption: 'Local Knowledge,Community Driven,Open Data',
description: 'OpenStreetMap is built by a community of mappers that contribute and maintain data about roads, trails, cafés, railway stations, and much more, all over the world.',
message: '',
});
});
});
</script>
<%
import bleach
import markdown
%>
% if project.status in [project.status_draft, project.status_archived] :
<p class="alert alert-warning text-muted">
  <span class="glyphicon glyphicon-warning-sign"></span>
  % if project.status == project.status_draft:
    ${_('This project is not published yet.')}
    % if user and (user.is_project_manager or user.is_admin):
    <a href="${request.route_url('project_publish', project=project.id)}" class="pull-right">
      <span class="glyphicon glyphicon-share-alt"></span> ${_('Publish')}
    </a>
    % endif
  % elif project.status == project.status_archived:
    ${_('This project was archived.')}
  % endif
</p>
% endif
% if project.private:
<p class="text-muted">
  <span class="glyphicon glyphicon-lock"></span>
  ${_('Access to this project is limited')}
</p>
% endif
<p>${bleach.clean(markdown.markdown(project.description), strip=True) |n}</p>
<hr />
<dl>
  % if project.entities_to_map:
  <dt>
    ${_('Entities to Map')}
    <span class="glyphicon glyphicon-question-sign"
          data-toggle="tooltip"
          data-placement="right"
          data-container="body"
          title="The list of elements of elements we ask you to map">
    </span>
  </dt>
  <dd>${project.entities_to_map}</dd>
  % endif
  % if project.changeset_comment:
  <dt>
    ${_('Changeset Comment')}
    <span class="glyphicon glyphicon-question-sign"
          data-toggle="tooltip"
          data-placement="right"
          data-container="body"
          title="The comment to put when uploading data to the OSM database">
    </span>
  </dt>
  <dd>
    ${project.changeset_comment}
  </dd>
  % endif
  % if project.imagery:
  <dt>
    ${_('Imagery')}
  </dt>
  <dd>
      <%include file="imagery.mako" />
  </dd>
  % endif
</dl>
% if project.josm_preset:
<p >
  Using JOSM? Please use the dedicated
  <a href="${request.route_url('project_preset', project=project.id)}">preset</a>.
</p>
% endif
<hr />
<p>${bleach.clean(markdown.markdown(project.instructions), strip=True) |n}</p>
<p class="text-center">
  <a id="start"
     class="btn btn-success btn-lg">
    <span class="glyphicon glyphicon-share-alt"></span>&nbsp;
    ${_('Start contributing')}</a>
<img src = "/static/share_button.png" id = "share_button">
</p>
