# -*- coding: utf-8 -*-
<%
from osmtm.models import (
    TaskState,
    TaskLock,
    TaskComment,
)
from osmtm.mako_filters import (
    convert_mentions,
    markdown_filter,
)
%>
<%page args="section='task'"/>
% for index, step in enumerate(history):
    <%
    first = "first" if index == 0 else ""
    last = "last" if index == len(history) - 1 else ""

    unknown = '<span class="text-danger">Unknown</span>'
    %>

    <div class="history ${first} ${last}">
    <%
    if section == 'project':
      tasklink = '<a href="#task/' + str(step.task_id) +'">#' + str(step.task_id) + '</a>'
    else:
      tasklink = ''
    endif
    %>
    % if isinstance(step, TaskState):
      % if step.state == step.state_done:
      <span><i class="glyphicon glyphicon-ok text-success"></i> ${step.user.username if step.user is not None else unknown | n} <b>${_('marked')} ${tasklink | n} ${_('as done')}</b>  </span>
      % elif step.state == step.state_invalidated:
      <span><i class="glyphicon glyphicon-thumbs-down text-danger"></i> ${step.user.username if step.user is not None else unknown | n} <b>${_('invalidated')}</b> ${tasklink | n}</span>
      % elif step.state == step.state_validated:
      <span><i class="glyphicon glyphicon-thumbs-up text-success"></i> ${step.user.username if step.user is not None else unknown | n} <b>${_('validated')}</b> ${tasklink | n}</span>
      % endif
    % endif
    % if isinstance(step, TaskLock):
      % if step.lock:
      <span><i class="glyphicon glyphicon-lock text-muted"></i> ${_('Locked')} ${_('by')} ${step.user.username}</span>
      % else:
      <span>${_('Unlocked')}</span>
      % endif
    % endif
    % if isinstance(step, TaskComment):
      <span><i class="glyphicon glyphicon-comment text-muted"></i> ${_('Comment left')} ${_('by')} ${step.author.username if step.author is not None else unknown | n}</span>
      <blockquote>
        ${step.comment | convert_mentions(request), markdown_filter, n}
      </blockquote>
    % endif
      <p class="text-muted">
        <em title="${step.date}Z" class="timeago"></em>
      </p>
    </div>
% endfor

% if len(history) == 0:
<div>${_('Nothing has happened yet.')}</div>
% endif

<script>$('.timeago').timeago()</script>
