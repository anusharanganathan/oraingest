$(setup_autocomplete);
  // don't navigate away from the field on tab when selecting an item
  //$( "#languageLabel" ).bind( "keydown", function( event ) {
  //    if ( event.keyCode === $.ui.keyCode.TAB &&
  //        $( this ).autocomplete( "instance" ).menu.active ) {
  //      event.preventDefault();
  //      }
  //  })
  //$( "#languageLabel" ).autocomplete(autocompleteLanguage).data("autocomplete")._renderItem = renderLanguage;

function setup_autocomplete() {
  $( "input.languageLabel" ).each(function (i) {
    if ($(this).data("aucomplete")) return;
    $(this).autocomplete(autocompleteLanguage).data("autocomplete")._renderItem = renderLanguage;
  });

  $("input.subjectLabel").each(function (i) {
    if ($(this).data("aucomplete")) return;
    $(this).autocomplete(autocompleteSubject).data("autocomplete")._renderItem = renderSubject;
  });

  $( "input.creatorName" ).each(function (i) {
    if ($(this).data("aucomplete")) return;
    $(this).autocomplete(autocompletePerson).data("autocomplete")._renderItem = renderPerson;
  });
}

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
    $(this).parents('.expand-content').find( ".languageCode" ).val( ui.item.id );
    $(this).parents('.expand-content').find( ".languageAuthority" ).val( ui.item.id.replace("info:lc", "http://id.loc.gov") );
    $(this).parents('.expand-content').find( ".languageScheme" ).val( "iso639-2" );
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
    $(this).parent().parent().find( ".subjectAuthority" ).val( "http://id.worldcat.org/fast/" + ui.item.id );
    $(this).parent().parent().find( ".subjectScheme" ).val( "FAST" );
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

var autocompletePerson = {
  minLength: 5,
  source: function( request, response ) {
    $.ajax({
      url: '/qa/search/cud/fullname',
      data: {q: request.term},
      dataType: 'json',
      success: response,
      timeout: 3000 //3 second timeout
    });
  },
  focus: function( event, ui ) {
    $(this).val( ui.item.auth );
    return false; 
  },
  select: function( event, ui ) {
    var pname = ui.item.firstname + " " + ui.item.lastname;
    $(this).val( pname );
    $(this).attr("value", pname);
    $(this).parent().parent().find( ".creatorEmail" ).val( ui.item.oxford_email );
    $(this).parent().parent().find( ".creatorAffiliation" ).val( ui.item.current_affiliation );
    return false;
  }
}

var renderPerson = function ( ul, item ) {
  var line = ""
  line = "<a><b>" + item.firstname + " " + item.lastname + "</b><br/>" + item.oxford_email + "</a>";
  return $("<li></li>")
      .data("item.autocomplete", item)
      .append( line )
      .appendTo(ul);
}

