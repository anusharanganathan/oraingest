function toggleDatasetAgreementDisplay(val) {
  if (val == "") {
    // Display form fields to create new agreement
    $("#relatedAgreement").css('display', 'inline');
  } else {
    $("#relatedAgreement").css('display', 'none');
  }
}

function toggleLocatorFieldsDisplay(val) {
  if (val == "digital") {
    // Display form fields relating to digital data type
    $("#data_locator_digital").prop('disabled', false);
    $("#data_locator_analog").prop('disabled', true);
  } else {
    $("#data_locator_digital").prop('disabled', true);
    $("#data_locator_analog").prop('disabled', false);
    $("#dataset_digitalSize").val("");
    $("#dataset_digitalSize").attr("value", "");
    $("#dataset_format").val("");
    $("#dataset_format").attr("value", "");
  }
}

function toggleEmbargoFieldsDisplay(currentEle) {
  var val = currentEle.value;
  var eleId = currentEle.id;
  // show the fields for this embargo option
  var rowId = eleId.replace(val, val + "-row");
  var colClass = ".embargo-"+ val;
  $("#"+rowId).find(colClass).each(function(){
    // display the column
    $(this).css("display", "block");
    // Set input value of end date label to Stated
    if (val == "date") {
      $(this).find(".embargo-date-type").val("Stated");
      $(this).find(".embargo-date-type").attr("value", "Stated");
    }
  });
  // hide fields for other embargo option
  if (val == "date") {
    var otherCol = "duration";
  } else if (val == "duration") {
    var otherCol = "date";
  }
  var fieldsetId = eleId.replace(val, "fieldset");
  var colClass = ".embargo-"+ otherCol;
  $("#"+fieldsetId).find(colClass).each(function(){
    // display the column
    $(this).css("display", "none");
    // Set input value of end date label to blank
    if (otherCol == "date") {
      $(this).find(".embargo-date-type").val("");
      $(this).find(".embargo-date-type").attr("value", "");
    }
  });
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

function displayDoi() {
  var doiShoulder = $("#doiShoulder").val();
  var doi = $("#dataset_doi").val();
  if ($('#workflow_submit_involves').is(':checked')) {
    if (doi.startsWith(doiShoulder)) {
      $("#dataset_doi").val(doi);
      $("#dataset_doi").prop("value", doi);
      $("#dataset_doi").prop("readonly", true);
      $("#dataset_doi").show();
      $("#dataset_doi_fieldset").show();
    } else {
      $("#dataset_doi").val("");
      $("#dataset_doi").prop("value", "");
      $("#dataset_doi").prop("readonly", true);
      $("#dataset_doi").hide();
      $("#dataset_doi_fieldset").hide();
    }
    //$("#workflow_submit_involves").val("Register doi:"+doi);
    //$("#workflow_submit_involves").attr("value", "Register doi:"+doi);
  } else {
    $("#dataset_doi_fieldset").show();
    $("#dataset_doi").show();
    $("#dataset_doi").removeAttr("disabled");
    $("#dataset_doi").removeAttr("readonly");
  }
}

function setStatus(eleId, wstatus) {
  states = ["Draft", "Submitted", "Assigned", "Claimed", "Escalated", "Referred", "Rejected", "Approved"];
  if (states.indexOf(wstatus) > -1) {
   $("#"+eleId).val(wstatus);
   $("#"+eleId).attr("value", wstatus);
  } else if (wstatus == "default") {
    var defVal = $("#"+eleId).data("default-value");
    if (states.indexOf(defVal) > -1) {
      $("#"+eleId).val(defVal);
      $("#"+eleId).attr("value", defVal);
    }
  }
}

