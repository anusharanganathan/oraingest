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
