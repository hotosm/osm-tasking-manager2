# -*- coding: utf-8 -*-
<%namespace file="project.edit.mako" import="locale_chooser"/>
<%inherit file="base.mako"/>
<%block name="header">
<h1>${_('Edit Tag')}</h1>
</%block>
<%block name="content">
<div class="container">
    <form method="post" action="" class="form-horizontal">
        <div class="form-group">
          <label class="control-label" for="id_name">${_('Name')}</label>
          <input type="text" class="form-control" id="id_name" name="name" value="${tag.name if tag else ''}"
                 placeholder="${_('The tag name, such as red-cross or ebola. Do not use spaces in the tag name.')}" />
        </div>
        <div class="form-group">
          <label class="control-label" for="id_admin_description">${_('Administrator Description')}</label>
          <textarea class="form-control" id="id_admin_description" name="admin_description" rows="2"
              placeholder="${_('Add a description for admins to discern between tags.')}">${tag.admin_description if tag else ''}</textarea>
        </div>
        % if tag:
        <!-- spotlight text translations for tag pages -->
        <div class="row">
          <div class="col-md-8">
            <div class="form-group">
              <label for="id_spotlight_text" class="control-label">
                 ${_('Spotlight text')}
              </label>
              ${locale_chooser(inputname='spotlight_text')}
              <div class="tab-content">
                % for locale, translation in translations:
                  <div id="spotlight_text_${locale}"
                       data-locale="${locale}"
                       class="tab-pane ${'active' if locale == 'en' else ''}">
                    <textarea id="id_spotlight_text_${locale}"
                              name="spotlight_text_${locale}"
                              class="form-control"
                              placeholder="${tag.translations.en.spotlight_text}"
                              rows="3">${translation.spotlight_text}</textarea>
                  </div>
                % endfor
              </div>
            <div class="help-block">
              ${_('This text will be displayed whenever a user navigates to the tag-specific page, e.g. http://site.com/tag/tag-name.')}
            </div>
            </div>
          </div>
        </div>
        % else:
        <div class="row">
          <div class="help-block">
            <em>${_('Once you create the tag, you will be able to edit the spotlight text.')}</em>
          </div>
        </div>
        % endif
        <div class="form-group">
            % if tag:
            <input type="submit" class="btn btn-success" value="${_('Save the modifications')}" id="id_submit" name="form.submitted"/>
            <a class="btn btn-danger" id="delete" href="${request.route_path('tag_delete', tag=tag.id)}">${_('Delete')}</a>
            % else:
            <input type="submit" class="btn btn-success" value="${_('Create the new tag')}" id="id_submit" name="form.submitted"/>
            % endif
            <a class="btn btn-default pull-right" href="${request.route_path('tags')}">${_('Cancel')}</a>
        </div>
    </form>
</div>
<script>
    $('#delete').click(function() {
        if (confirm("${_('Are you sure you want to delete this tag? You will lose any translations of spotlight texts.')}")) {
            window.location = this.href;
        }
        return false;
    });
</script>
</%block>
