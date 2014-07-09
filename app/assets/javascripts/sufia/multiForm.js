function addField(item) {
  var parentId = item.id.replace("button", "clone");
  var groupId = item.id.split("_",1)
  var count = $("#" + groupId + " div").size();
  var newId = groupId + "_clone_" + count;
  var cloneElem = $('#'+ parentId).clone();
  cloneElem.attr('id', newId);

  // change the add button to a remove button
  var plusbttn = cloneElem.find('#'+item.id);
  plusbttn.className = "remover btn";
  plusbttn.attr('id', groupId + "_button_" + count);   
  plusbttn.attr('onclick', '');
  plusbttn.html('-<span class="accessible-hidden">remove this '+ item.name.replace("_", " ") +'</span>');
  plusbttn.on('click',removeFieldthis);

  // remove the help tag on subsequent added fields
  cloneElem.find('.formHelp').remove();
  cloneElem.find('i').remove();
  cloneElem.find('.modal-div').remove();

  //clear out the value for the element being appended
  //so the new element has a blank value
  inputFields = cloneElem.find('input')
  $.each(inputFields, function(n, tf) {
    newName = $(tf).attr('id').replace('0', count);
    $(tf).val("");
    $(tf).attr('id', newName).attr("required", false);
  })
  selectFields = cloneElem.find('select')
  $.each(selectFields, function(n, tf) {
    newName = $(tf).attr('id').replace('0', count);
    $(tf).val("");
    $(tf).attr('id', newName).attr("required", false);
  })

  // Add the cloned element to the page
  $("#"+groupId).append(cloneElem);

  //add autocomplete option
  if (groupId == "subject") {
    inputId = "subjectLabel"+count;
    console.log(inputId);
    $( "#"+inputId ).autocomplete(autocompleteSubject).data("autocomplete")._renderItem = renderSubject;
  } else if (groupId == "language") {
    inputId = "languageLabel"+count;
    console.log(inputId);
    $( "#"+inputId ).autocomplete(autocompleteLanguage).data("autocomplete")._renderItem = renderLanguage;
  }

  // Focus on the cloned element 
  cloneElem.find('input[type=text]').focus();
  return false;

}

function removeField(item) {
  console.log("I am in remove field");
  // get parent and remove it
  $(item).parent().remove();
  return false;
}

function removeFieldthis() {
  console.log("I am in remove field");
  // get parent and remove it
  $(this).parent().remove();
  return false;
}

