function toggleDatasetAgreementDisplay(val) {
  if (val == "") {
    // Display form fields to create new agreement
    $("#relatedAgreement").css('display', 'inline');
  } else {
    $("#relatedAgreement").css('display', 'none');
  }
}

function toggleDigitalFieldsDisplay(val) {
  if (val == "digital") {
    // Display form fields relating to digital data type
    $("#digitalFields").css('display', 'inline');
  } else {
    $("#digitalFields").css('display', 'none');
  }
}

function displayDatasetAgreement(id, val) {
  if (val != "") {
    $.ajax({
      url: "/datasets/" + id + "/agreement?a_id=" + val,
      type: "GET",
      success: function(data) {
        //append returned data to view
        $("#relatedAgreement").empty().html(data);
        $( "#relatedAgreement input.creatorName" ).each(function (i) {
          $(this).autocomplete(autocompletePerson).data("autocomplete")._renderItem = renderPerson;
        });
        //TODO: Add jquery onclick call to this html snippet
      }
    })
  }
}

function setStatus() {
 $("#workflows_entries_status").val("Submitted");
}

