# -*- coding: utf-8 -*-
<%inherit file="base.mako"/>
<%def name="title()">${_('Users')}</%def>
<%block name="header">
<h1>${_('Users')}</h1>
</%block>
<%block name="content">
<div class="container" ng-app="users">
  <div class="row" ng-controller="usersCrtl">
    <div class="col-md-8">
      <div class="form-group">
        <input type="text" id="user_search"
        placeholder="${_('Search')}" class="form-control">
      </div>
      ${paginate()}
      <ul>
        % if paginator.items:
          % for user in paginator.items:
            <li>
              <a href="user/${user.username}">${user.username}</a>
                % if user.is_admin:
                  <i class="glyphicon glyphicon-star user-admin"></i>
                % elif user.is_project_manager:
                  <i class="glyphicon glyphicon-star user-project-manager"></i>
                % endif
            </li>
          % endfor
        % endif
      </ul>
      ${paginate()}
    </div>
    <div class="col-md-4">
      <small>
        <p>${paginator.item_count} ${_('Users')}</p>
        ${_('Keys:')}
        <ul>
          <li><i class="glyphicon glyphicon-star user-admin"></i> ${_('Administrator')}</li>
          <li><i class="glyphicon glyphicon-star user-project-manager"></i> ${_('Project Manager')}</li>
        </ul>
      </small>
    </div>
  </div>
</div>
<script>
new autoComplete({
  'selector'  : document.getElementById('user_search'),
  'minChars'  : 1,
  'source'    : function(term, suggest) {
    term = term.toLowerCase();
    $.getJSON(
      base_url + 'users.json',
      {q: term},
      function(users) {
        suggest(users);
      }
    );
  },
  'onSelect' : function(e, term, item) {
    window.location.href = base_url + 'user/' + term;
    e.preventDefault();
  }
});
</script>
</%block>

<%def name="paginate()">
<div class="text-center">
  <div class="btn-group btn-group-xs">
    <% link_attr={"class": "btn btn-small btn-default"} %>
    <% curpage_attr={"class": "btn btn-default btn-primary"} %>
    <% dotdot_attr={"class": "btn btn-default btn-small disabled"} %>
    ${paginator.pager(format="$link_previous ~2~ $link_next",
                      link_attr=link_attr,
                      curpage_attr=curpage_attr,
                      dotdot_attr=dotdot_attr)}
  </div>
</div>
</%def>

<%block name="extrascripts">
<link rel="stylesheet" href="${request.static_url('osmtm:static/js/lib/JavaScript-AutoComplete/auto-complete.css')}">
<script src="${request.static_url('osmtm:static/js/lib/JavaScript-AutoComplete/auto-complete.js')}"></script>
</%block>
