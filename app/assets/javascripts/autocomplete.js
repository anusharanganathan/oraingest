$(function() {
  
  // don't navigate away from the field on tab when selecting an item
  //$( "#languageLabel" ).bind( "keydown", function( event ) {
  //    if ( event.keyCode === $.ui.keyCode.TAB &&
  //        $( this ).autocomplete( "instance" ).menu.active ) {
  //      event.preventDefault();
  //      }
  //  })
  //$( "#languageLabel" ).autocomplete(autocompleteLanguage).data("autocomplete")._renderItem = renderLanguage;
    
  $( "input.languageLabel" ).each(function (i) {
    $(this).autocomplete(autocompleteLanguage).data("autocomplete")._renderItem = renderLanguage;
  });


  // don't navigate away from the field on tab when selecting an item
  //$( "#subjectLabel0" ).bind( "keydown", function( event ) {
  //    if ( event.keyCode === $.ui.keyCode.TAB &&
  //        $( this ).autocomplete( "instance" ).menu.active ) {
  //      event.preventDefault();
  //      }
  //  });
  //$( "#subjectLabel0" ).autocomplete(autocompleteSubject).data("autocomplete")._renderItem = renderSubject;

  $("input.subjectLabel").each(function (i) {
    $(this).autocomplete(autocompleteSubject).data("autocomplete")._renderItem = renderSubject;
  });

});

var autocompleteLanguage = {
  minLength: 2,
  source: function( request, response ) {
    $.getJSON( "/qa/search/loc/iso639-2", {
      q: request.term + '*'
    }, response );
  },
  focus: function( event, ui ) {
    $( this ).val( ui.item.label );
    return false;
  },
  select: function( event, ui ) {
    $(this).val( ui.item.label );
    $(this).attr("value", ui.item.label);
    $(this).parent().find( ".languageCode" ).val( ui.item.id );
    $(this).parent().find( ".languageAuthority" ).val( ui.item.id.replace("info:lc", "http://id.loc.gov") );
    $(this).parent().find( ".languageScheme" ).val( "iso639-2" );
    return false;
  }
}

var renderLanguage = function ( ul, item ) {
  return $("<li></li>")
      .data("item.autocomplete", item)
      .append( "<a>" + item.label + "</a>" )
      .appendTo(ul);
}

var autocompleteSubject = {
  minLength: 2,
  source: function( request, response ) {
    $.getJSON( "/qa/search/fast/topical", {
      q: request.term
    }, response);
   //console.log("I have a response");
  },
  focus: function( event, ui ) {
    $(this).val( ui.item.auth );
    return false; 
  },
  select: function( event, ui ) {
    $(this).val( ui.item.auth );
    $(this).attr("value", ui.item.auth);
    $(this).parent().find( ".subjectAuthority" ).val( "http://id.worldcat.org/fast/" + ui.item.id );
    $(this).parent().find( ".subjectScheme" ).val( "FAST" );
    return false;
  }
}

var renderSubject = function ( ul, item ) {
  var line = ""
  if ( item.label == item.auth ) {
    line = "<a><b>" + item.label + "</b></a>";
  } else {
    line = "<a>" + item.label + " <i>Use</i> <b>" + item.auth + "</b></a>";
  }
  return $("<li></li>")
      .data("item.autocomplete", item)
      .append( line )
      .appendTo(ul);
}
