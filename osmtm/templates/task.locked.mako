<%
username = _('you') if task.cur_lock.user == user else task.cur_lock.user.username
username = '<strong>%s</strong>' % username
locked_text = _('This task is locked by ${username} while you are working on it', mapping={'username': username})
import datetime
from osmtm.models import EXPIRATION_DELTA
time_left = (task.cur_lock.date - (datetime.datetime.utcnow() - EXPIRATION_DELTA)).seconds
%>
<em>
  <span class="glyphicon glyphicon-lock"></span>
  ${locked_text|n}.&nbsp;
  % if user and task.cur_lock.user== user:
  <a id="unlock" href="${request.route_path('task_unlock', task=task.id, project=task.project_id)}">
    ${_('Stop working on this task and unlock it')}</a>
  <span id="task_countdown_text" rel="tooltip"
      data-original-title="${_('If you do not complete or release this task in time, it will be automatically unlocked')}"
      data-container="body"
      class="pull-right"><i class="glyphicon glyphicon-time" /> <span id="countdown">${time_left / 60}</span> ${_("min. left")}</span>
    <script>
      var task_time_left = ${time_left};
      var countdownInterval = setInterval(function(){
        $("#countdown").html(Math.floor(task_time_left / 60));
        if (task_time_left < 10 * 60) {
          $('#task_countdown_text').addClass('text-danger');
        }
        if (task_time_left < 0) {
          osmtm.project.loadTask(${task.id});
          clearInterval(countdownInterval);
        }
        task_time_left--;
      }, 1000);
    </script>
  % endif
</em>
<br>
