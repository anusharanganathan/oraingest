(function( $ ){

  $.fn.multiForm = function( options ) {  

  // Create some defaults, extending them with any options that were provided
  var settings = $.extend( { }, options);

  function addField() {
    var parentId = this.id.replace("button", "clone");
    var groupId = this.id.split("_",1);
    var count = $("#" + groupId + " div").size();
    var lastId = $("#" + groupId + " div").last().attr("id");
    var currentId = this.id.replace(groupId+"_button_", "");
    lastId = lastId.replace(groupId+"_clone_", "");
    if ($.isNumeric(lastId)) {
      count = parseInt(lastId) + 1;
    }
    var newId = groupId + "_clone_" + count;
    var cloneElem = $('#'+ parentId).clone();
    cloneElem.attr('id', newId);
    
    // change the add button to a remove button
    var plusbttn = cloneElem.find('#'+this.id);
    plusbttn.className = "remover btn";
    plusbttn.attr('id', groupId + "_button_" + count);
    plusbttn.attr('onclick', '');
    plusbttn.html('-<span class="accessible-hidden">remove this '+ this.name.replace("_", " ") +'</span>');
    plusbttn.on('click',removeField);
    
    // remove the help tag on subsequent added fields
    cloneElem.find('.formHelp').remove();
    cloneElem.find('i').remove();
    cloneElem.find('.modal-div').remove();
    
    //clear out the value for the element being appended
    //so the new element has a blank value
    inputFields = cloneElem.find('input')
    $.each(inputFields, function(n, tf) {
      if ($(tf).attr('type') != "hidden") {
        newId = $(tf).attr('id').replace(currentId, count);
        newName = $(tf).attr('name').replace("0", count);
        $(tf).val("");
        $(tf).attr('value', "");
        $(tf).attr('name', newName);
        $(tf).attr('id', newId).attr("required", false);
      }
    })
    selectFields = cloneElem.find('select')
    $.each(selectFields, function(n, tf) {
      newId = $(tf).attr('id').replace(currentId, count);
      newName = $(tf).attr('name').replace("0", count);
      $(tf).val("");
      $(tf).attr('value', "");
      $(tf).attr('name', newName);
      $(tf).attr('id', newId).attr("required", false);
    })
  
    if (settings.afterAdd) {
      settings.afterAdd(this, cloneElem)
    }

    // Add the cloned element to the page
    $("#"+groupId).append(cloneElem);
    
    //add autocomplete option
    if (groupId == "subject") {
      inputId = "subjectLabel"+count;
      $( "#"+inputId ).autocomplete(autocompleteSubject).data("autocomplete")._renderItem = renderSubject;
    } else if (groupId == "language") {
      inputId = "languageLabel"+count;
      $( "#"+inputId ).autocomplete(autocompleteLanguage).data("autocomplete")._renderItem = renderLanguage;
    } else if (groupId == "creator") {
      inputId = "creatorName"+count;
      $( "#"+inputId ).autocomplete(autocompletePerson).data("autocomplete")._renderItem = renderPerson;
    }
  
    // Focus on the cloned element 
    cloneElem.find('input[type=text]').first().focus();
    return false;
  }


    function removeField () {
      // get parent and remove it
      $(this).parent().remove();
      return false;
    }

    return this.each(function() {        

      // Tooltip plugin code here
      /*
       * adds additional metadata elements
       */
      $('.adder', this).click(addField);
      
      $('.remover', this).click(removeField);
      
    });

  };
})( jQuery );  

