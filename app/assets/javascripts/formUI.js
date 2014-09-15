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
    //console.log("I am in the js function");
    $.ajax({
      url: "/datasets/" + id + "/agreement?a_id=" + val,
      type: "GET",
      success: function(data) {
        //append returned data to view
        $("#relatedAgreement").empty().html(data);
        // and then remove the form tag
        //var data2 = $("#relatedAgreement form").html();
        //$("#relatedAgreement").empty().append(data2);
        // and then remove the first div
        //$("#relatedAgreement").find("div").first().remove();
      }
    })
  }
}
