(function( $ ){

  $.fn.multiForm = function( options ) {  

  // Create some defaults, extending them with any options that were provided
  var settings = $.extend( { }, options);

  function addField() {
    var parentId = this.id.replace("button", "clone");
    var groupId = this.id.split("_",1)
    var count = $("#" + groupId + " div").size();
    var lastId = $("#" + groupId + " div").last().attr("id");
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
  
    if (settings.afterAdd) {
      settings.afterAdd(this, cloneElem)
    }

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

