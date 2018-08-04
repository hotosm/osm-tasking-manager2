$(document).ready(function() {
    $('.nav-tabs a:first').tab('show');
    $('.nav.languages li:first-of-type a').tab('show');
    $('.input-group.date').datepicker({language: locale_name});

  var users = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    local: [],
    remote: {
      url: base_url + 'users.json?q=%QUERY',
      wildcard: '%QUERY'
    }
  });

  $('#adduser').typeahead({
    hint: true,
    highlight: true,
    minLength: 1
  },
  {
    name: 'states',
    limit: 40,
    source: users
  }).on({
    'typeahead:selected': function(e, suggestion, name) {
      window.setTimeout(function() {
        $('#do_add_user').removeClass('disabled');
      }, 200);
    },
    'typeahead:autocompleted': function(e, suggestion, name) {
      window.setTimeout(function() {
        $('#do_add_user').removeClass('disabled');
      }, 200);
    },
    'keyup': function(e) {
      $('#do_add_user').addClass('disabled');
    }
  });
});

// taken from the great GeoJSON.io
function readAsText(f, callback) {
  try {
    var reader = new FileReader();
    reader.readAsText(f);
    reader.onload = function(e) {
      if (e.target && e.target.result) callback(null, e.target.result);
      else callback({
        message: droppedFileCouldntBeLoadedI18n
      });
    };
    reader.onerror = function(e) {
      callback({
        message: droppedFileWasUnreadableI18n
      });
    };
  } catch (e) {
    callback({
      message: droppedFileWasUnreadableI18n
    });
  }
}

function allowedUsersCrtl($scope) {
  $scope.allowed_users = allowed_users;

  $(document).on('click', '#do_add_user', function() {
    $.ajax({
      url: base_url + 'project/' + project_id + '/user/' + $('#adduser').val(),
      type: 'PUT',
      success: function(data) {
        $scope.$apply(function() {
          allowed_users[data.user.id] = data.user;
          $scope.allowed_users = allowed_users;
        });
        $('#adduser').val('');
      }
    });
  });

  $(document).on('click', '.user-remove', function() {
    var el = $(this).parents('li:first');
    var user_id = el.attr('data-user');
    $.ajax({
      url: base_url + 'project/' + project_id + '/user/' + user_id,
      type: 'DELETE',
      success: function(data) {
        el.remove();
      }
    });
  });

  $('#user_import').click(function() {
    $('input[name=user_import]').click();
    return false;
  });


  $('input[name=user_import]').change(function() {
    function addUserToProject(userToAdd) {
      $.ajax({
        url: base_url + 'project/' + project_id + '/user/' + userToAdd,
        type: 'PUT',
        success: function(data) {
          $scope.$apply(function() {
          allowed_users[data.user.id] = data.user;
          $scope.allowed_users = allowed_users;
          });
        }
      });
    }

    var file = $(this).val();
    if ((file.substr(-3) == 'txt') || (file.substr(-3) == 'csv')) {
      readAsText($(this)[0].files[0], function(err, text) {
        var lines = text.split(/\r\n|\n/);
        var usersToAdd = [];

        for (var i=0; i<lines.length; i++) {
          var lineData = lines[i].split(',');
          for (var j=0; j<lineData.length; j++) {
            if (lineData[j] != "") {
              usersToAdd.push(lineData[j]);
            }
          }
        }
        for (var i=0; i<usersToAdd.length; i++) {
          addUserToProject(usersToAdd[i]);
        }
      });
    } else {
      alert(pleaseProvideTxtOrCSVFileI18n);
    }
    $(this).val('');
  });

}
angular.module('allowed_users', []);

osmtm = {};
osmtm.project = {};
osmtm.project.edit = {};
osmtm.project.edit.priority_areas = (function() {

  var lmap;
  var drawControl;
  var drawnItems;

  // creates the Leaflet map
  function createMap() {
    if (lmap) {
      return;
    }
    lmap = L.map('leaflet_priority_areas');
    // create the tile layer with correct attribution
    var osmUrl='//tile-{s}.openstreetmap.fr/hot/{z}/{x}/{y}.png';
    var osmAttrib='Map data © OpenStreetMap contributors';
    var osm = new L.TileLayer(osmUrl, {attribution: osmAttrib});
    lmap.addLayer(osm);

    var layer = new L.geoJson(geometry, {
      style: {
        fillOpacity: 0.1,
        weight: 1.5
      }
    });
    lmap.addLayer(layer);
    lmap.fitBounds(layer.getBounds());
    lmap.zoomOut();

    var style = {
      color: 'red',
      weight: 1
    };
    drawnItems = new L.GeoJSON(null, {
      style: style
    });
    lmap.addLayer(drawnItems);
    drawnItems.addData(priority_areas);

    onChange(true);

    drawControl = new L.Control.Draw({
      position: 'topleft',
      draw: {
        rectangle: {
          title: 'Draw the area of interest'
        },
        circle: false,
        marker: false,
        polyline: false,
        polygon: {
          title: 'Draw the area of interest'
        }
      },
      edit: {
        featureGroup: drawnItems
      }
    });
    lmap.addControl(drawControl);

    lmap.on('draw:created', function(e) {
      var layer = e.layer;
      drawnItems.addLayer(layer);
      layer.setStyle(style);
      onChange();
    });
    lmap.on('draw:edited', function(e) {
      onChange();
    });
    lmap.on('draw:deleted', function(e) {
      onChange();
    });
  }

  function onChange(silent) {
    var val = '';
    if (drawnItems.getLayers().length) {
      var gj = drawnItems.toGeoJSON();
      val = JSON.stringify(gj);
    }
    $('input[name=priority_areas]').val(val);

    silent = !!silent;
    if (!silent) {
      $('input[name=priority_areas]').trigger('change');
    }
  }

  return {
    init: function() {
      $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
        if (e.target.id == 'priority_areas_tab') {
          createMap();
        }
      });


      $('input[name=priority_areas]').on('change', function() {
        $('input[type=submit]').removeAttr('disabled');
      });
    }
  };
})();

/*
  Handles invalidate all feature
*/
function invalidateAll(e) {
  e.preventDefault();
  var data = {
    'comment': $('#project_invalidate_comment').val(),
    'challenge_id': $('#project_invalidate_challenge_id').val()
  };
  var url = base_url + "project/" + project_id + "/invalidate_all";
  var $modal = $('#invalidateAllModal');
  var $errors = $modal.find('.errors');
  $errors.text('');
  var $success = $('#invalidateAllSuccess');
  $success.text('');
  $.post(url, data, function(data) {
    if (data.success) {
      $modal.modal('hide');
      $success.text(data.msg);
      $success.prepend('<span class="glyphicon glyphicon-ok"></span> ');
      setTimeout(function() {
        $success.fadeOut();
      }, 5000);
    } else {
      var error = data.error_msg;
      $errors.text(error);
      $errors.prepend('<span class="glyphicon glyphicon-exclamation-sign"></span> ');
    }
  });
}

function messageAll(e) {
  e.preventDefault();
  var data = {
    'subject': $('#message_all_subject').val(),
    'message': $('#message_all_message').val()
  };
  var url = base_url + "project/" + project_id + "/message_all";
  var $modal = $('#messageAllModal');
  var $errors = $modal.find('.errors');
  $errors.text('');
  var $success = $('#messageAllSuccess');
  $success.text('');
  $.post(url, data, function(data) {
    if (data.success) {
      $modal.modal('hide');
      $success.text(data.msg);
      $success.prepend('<span class="glyphicon glyphicon-ok"></span> ');
      setTimeout(function() {
        $success.fadeOut();
      }, 5000);
    } else {
      var error = data.error_msg;
      $errors.text(error);
      $errors.prepend('<span class="glyphicon glyphicon-exclamation-sign"></span> ');
    }
  });
}

$(document).ready(function() {
  osmtm.project.edit.priority_areas.init();
  $(document).on('click', '.btn-invalidate-all', invalidateAll);
  $(document).on('click', '.btn-message-all', messageAll);
});
