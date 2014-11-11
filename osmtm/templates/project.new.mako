# -*- coding: utf-8 -*-
<%inherit file="base.mako"/>
<%block name="header">
<h1>${_('Project New')}</h1>
</%block>
<%block name="content">
<div class="container">
    <div class="row">
      <div class="col-md-8">
        <div id="leaflet"></div>
      </div>
      <div class="col-md-4">
        ${step1()}
        ${step2()}
        ${step3_grid()}
        ${step3_arbitrary()}
      </div>
    </div>
</div>
<link rel="stylesheet" href="${request.static_url('osmtm:static/js/lib/Leaflet.draw/dist/leaflet.draw.css')}"/>
<script src="${request.static_url('osmtm:static/js/lib/leaflet.js')}"></script>
<script src="${request.static_url('osmtm:static/js/lib/Leaflet.draw/dist/leaflet.draw.js')}"></script>
<script src="${request.static_url('osmtm:static/js/lib/leaflet-omnivore.min.js')}"></script>
<script src="${request.static_url('osmtm:static/js/project.new.js')}"></script>

</%block>

<%block name="step1">
<div id="step1" class="">
  <h2>${_('Step 1')}</h2>
  <p>
  ${
    anchor='a id="draw" class="btn btn-default"'
    _('<%s>Draw<%s> the area of interest on the map.') % (anchor, '/a')
  }
  </p>
  <p>
  or
  </p>
  <p>
  <form id="uploadform" method="post" enctype="multipart/form-data">
    <input type="file" val="" name="import" class="hidden" />
    
    ${
        anchor='a id="import"
                data-role="button"
                class="btn btn-default"
                rel="tooltip"
                title="%s"' % _('Provide a .geojson or .kml file.')
        _('<%s>Import<%s> a <em>GeoJSON</em> or <em>KML</em> file.') % (anchor, '/a')
    }
    <span class="help-block">
      <small>
        ${_('Want to use an <em>.osm</em> file instead?')}<br>
        ${_('You can use <%s>GeoJSON.io<%s> to convert it to <em>GeoJSON</em>') % ('a href="http://geojson.io" target="_blank"', '/a')}.
      </small>
    </span>
  </form>
  </p>
</div>
</%block>

<%block name="step2">
<div id="step2" class="hidden">
  <h2>${_('Step 2 - Type of project')}</h2>
  <div class="row">
    <div class="col-md-6">
      <label class="radio">
        <input type="radio" name="type" value="grid" checked/>
        ${_('Square Grid')}
        <br>
        <img src="${request.static_url('osmtm:static/img/project_creation_grid.png')}" width="150">
        <p class="help-block">
        ${_('Area of interest is automatically split into grid cells. Each one is a task.')}<br>
        </p>
      </label>
    </div>
    <div class="col-md-6">
      <label id="arbitrary" class="radio mask"
             rel="tooltip"
             data-original-title="${_('You cannot select this option unless you import a file with polygons.')}"
             >
        <input type="radio" name="type" value="arbitrary" disabled />
        ${_('Arbitrary Geometries')}
        <br>
        <img src="${request.static_url('osmtm:static/img/project_creation_arbitrary.png')}" width="150">
        <p class="help-block">
        ${_('Each polygon represents a task.')}<br>
        </p>
      </label>
    </div>
  </div>
  <div class="row">
    <div class="pull-right">
      <a id="step2-back" class="btn btn-default">
        <span class="glyphicon glyphicon-chevron-left"></span>
        ${_('Back')}
      </a>
      <a id="step2-next" class="btn btn-default">Next
        <span class="glyphicon glyphicon-chevron-right"></span>
      </a>
    </div>
  </div>
</div>
</%block>

<%block name="step3_grid">
<div id="step3-grid" class="hidden">
  <form id="gridform" method="post" action="${request.route_url('project_new_grid')}">
    <h2>${_('Step 3')}</h2>
    <div class="form-group">
      ${_('Tile size')}
      <div id="tile_size" class="btn-group" >
        <button class="btn btn-default">XL</button>
        <button class="btn btn-default">L</button>
        <button class="btn btn-default active">M</button>
        <button class="btn btn-default">S</button>
        <button class="btn btn-default">XS</button>
      </div>
      <span id="computing" class="help-inline hidden">${_('Computing...')}</span>
    </div>
    <div>
      ${_('A new project will be created with %s tasks.') % '<strong id="grid_geometries_count"></strong>'}
    </div>
    <div class="form-actions pull-right">
      <a class="btn btn-default step3-back">
        <span class="glyphicon glyphicon-chevron-left"></span>
        ${_('Back')}
      </a>
      <input type="submit" value="${_('Create project')}"
             name="form.submitted" class="btn btn-success"/>
    </div>
    <div class="clearfix"></div>
    <div class="clearfix"></div>
    <div class="pull-right loading help hidden">
      ${_('Creating tiles, please wait...')}
    </div>
    <input type="hidden" name="tile_size"/>
    <input id="geometry" type="hidden" name="geometry"/>
  </form>
</div>
</%block>

<%block name="step3_arbitrary">
<div id="step3-arbitrary" class="hidden">
  <form id="gridform" method="post" action="${request.route_url('project_new_arbitrary')}">
    <h2>${_('Step 3')}</h2>
    ${_('A new project will be created with %s tasks.') % '<strong><span id="arbitrary_geometries_count"></span></strong>'}
    <div class="form-actions pull-right">
      <a class="btn btn-default step3-back">
        <span class="glyphicon glyphicon-chevron-left"></span>
        ${_('Back')}
      </a>
      <input type="submit" value="${_('Create project')}"
             name="form.submitted" class="btn btn-success"/>
    </div>
    <div class="clearfix"></div>
    <div class="loading pull-right help hidden">
      ${_('Creating project, please wait...')}
    </div>
    <input id="geometry_arbitrary" type="hidden" name="geometry"/>
  </form>
</div>
</%block>
