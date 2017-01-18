# -*- coding: utf-8 -*-
<%inherit file="base.mako"/>
<%block name="header">
<h1>${_('Tags')}</h1>
</%block>
<%block name="content">
<div class="container group wrap">
    <div class="row">
        <div class="col-md-6">
            <ul>
            % for tag in tags:
            <li><h4>${tag.name}</h4>
                <div class="help-inline">
                  ${tag.admin_description}
                </div>
                <a href="${request.route_path('tag_edit', tag=tag.id)}" class="btn pull-right">${_('edit')}</a><br />
                </li>
            % endfor
            </ul>
            </ul>
        </div>
        <div class="col-md-6">
            <a href="${request.route_path('tag_new')}" class="btn btn-default">${_('Create new project tag')}</a>
        </div>
    </div>
</div>
</%block>
