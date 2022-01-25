$(document).ready(function() {
  var btnFinish = $('<button id="#submit-wizard"></button>').text('Finish')
                                             .addClass('btn btn-info')
                                             .on('click', submitManifestWizard);

  $('#ingestManifestWizard').smartWizard({
    selected: 0,
    theme: 'arrows', // default, arrows, dots, progress
    transition: {
      animation: 'none', // Effect on navigation, none/fade/slide-horizontal/slide-vertical/slide-swing
    },
    autoAdjustHeight: false,
    toolbarSettings: {
      toolbarExtraButtons: [btnFinish]
    }
  });

  $('#browse-btn').browseEverything()
    .done(function(data) { $('#status').html(data.length.toString() + " items selected") })
    .cancel(function()   { window.alert('Cancelled!') });

  $("#ingestManifestWizard").on("leaveStep", function(e, anchorObject, currentStepIndex, nextStepIndex, stepDirection) {
    if (currentStepIndex == 0 && nextStepIndex == 1) {
      if ($('#ingestManifestWizard #collectionsSelectable').jstree('get_selected', true).length == 0) {
        alert('You must select a collection.');
        return e.preventDefault();
      }
    }
  });

    function submitManifestWizard() {
    if ($('#ingestManifestWizard #collectionsSelectable').jstree('get_selected', true).length == 0) {
        alert('You must select a collection.');
      $('#ingestManifestWizard').smartWizard("goToStep", 0);
    } else {
      $("#ingestManifestWizard #collection_id").val($('#ingestManifestWizard #collectionsSelectable').jstree('get_selected', true)[0].id);
      $('#manifest_form').submit();
    }
  }
});
