<div class="text-center">
  <div class="btn-group">
    <%
      cookies = request.cookies
      prefered_editor = cookies['prefered_editor'] if 'prefered_editor' in cookies else ''
    %>
    <button id="edit" class="btn btn-default">
      <i class="glyphicon glyphicon-share-alt"></i> ${_('Edit with')}
      <span id="prefered_editor"></span>
    </button>
    <button data-toggle="dropdown" class="btn btn-default dropdown-toggle"><span class="caret"></span>
    </button>
    <ul id="editDropdown" class="dropdown-menu text-left">
      <li id="josm"><a role="menuitem">JOSM</a></li>
      <li id="iDeditor"><a role="menuitem">iD editor</a></li>
      <li id="potlatch2"><a role="menuitem">Potlatch 2</a></li>
      <li id="wp"><a role="menuitem">Walking Papers</a></li>
      <li id="fp"><a role="menuitem">Field Papers</a></li>
    </ul>
  </div>
</div>
<script>
  osmtm.prefered_editor = "${prefered_editor}";
</script>
<p></p>
