## works for ready or invalidated tasks
% if user and task.cur_lock and task.cur_lock.lock and task.cur_lock.user == user:
  <form action="${request.route_path('task_done', task=task.id, project=task.project_id)}" method="POST">
    <%include file="task.comment.mako" />
    <button type="submit" class="btn btn-success"><i class="glyphicon glyphicon-ok icon-white"></i> ${_('Mark task as done')}</button>
    <a id="unlock"
       class="btn btn-default"
       href="${request.route_path('task_unlock', task=task.id, project=task.project_id)}">
        ${_('Stop working and unlock')}
    </a>
  </form>
% endif
