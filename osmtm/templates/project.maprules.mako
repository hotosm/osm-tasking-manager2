<p class="text-center">
	<a class="btn btn-success btn-lg start">
	    <span class="glyphicon glyphicon-share-alt"></span>&nbsp;
	    ${_('Start contributing')}</a>
</p>
% if project.attribution_config_id:
<dl>
  <dd>
    <iframe id="viewMapRulesFrame" frameborder="0" seamless height="2000px" style="width:100%">
        MapRules could not be loaded.
    </iframe>
  </dd>
</dl>
% endif