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
<p class="text-center">
  <a id="InstructionsStartContributing"
     class="btn btn-success btn-lg">
    <span class="glyphicon glyphicon-share-alt"></span>&nbsp;
    ${_('Instructions and Start Contributing')}</a>
</p>
