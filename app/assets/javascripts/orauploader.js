//= require fileupload/tmpl
//= require fileupload/jquery.iframe-transport
//= require fileupload/jquery.fileupload.js
//= require fileupload/jquery.fileupload-ui.js
//= require fileupload/locale.js
//
/*jslint nomen: true */
/*global $ */


//2 GB  max file size 
var max_file_size = 2000000000;
var max_file_size_str = "2 GB";
//5 GB max total upload size
var max_total_file_size = 5000000000;
var max_file_count = 100;
var max_total_file_size_str = "5 GB";
var first_file_after_max = ''; 
var filestoupload =0;
var sequentialUploads = true;

(function( $ ){
  'use strict';

  $.fn.oraUploader = function( options ) {  

    // Create some defaults, extending them with any options that were provided
    // option afterSubmit: function(form, event, data)
    var settings = $.extend( { }, options);
    var files_done =0;      
    var error_string =''; 

    function saveForm() {
      // do not validate
      $(".ora-validate-form").validate().settings.ignore = "*";
      // set workflow status to default
      $("#workflow_submit_entries_status").val($(this).attr("data-default-value"));
      $("#workflow_submit_entries_status").attr("value", $(this).attr("data-default-value"));
      // set format of data to none
      $("#dataset_format").val("");
      $("#dataset_format").attr("value", "");
      // set size of data to none
      $("#dataset_digitalSize").val("");
      $("#dataset_digitalSize").attr("value", "");
      // set location of data to none
      $("#data_locator_digital").val("");
      $("#data_locator_digital").attr("value", "");
      $("#data_locator_analog").val("");
      $("#data_locator_analog").attr("value", "");
      // get redirect field
      var focusid = $(document.activeElement).closest('[id]').attr('id');
      if (focusid && $("form#new_record_fields #"+focusid).length) {
        var inputid = "";
        if ($("#"+focusid).attr("tag") != "input") {
          inputid = $("#"+focusid).parent().closest('input').attr('id');
        }
        if (inputid) {
          $("#redirect_field").val(inputid);
          $("#redirect_field").attr("value", inputid);
        } else {
          $("#redirect_field").val(focusid);
          $("#redirect_field").attr("value", focusid);
        }
      }
      $("form#new_record_fields").submit();
      //var loc = $("#redirect-loc").html();
      //$(location).attr('href',loc);
    }

    function uploadStopped() {
      if (files_done == filestoupload && (files_done >0)){
        saveForm();
      } else if (error_string.length > 0){
        // an error occured
        if (files_done == 0) {
          $("#fail").fadeIn('slow')
        } else {
          $("#partial_fail").fadeIn('slow')
        }          
        $("#errmsg").html(error_string);
        $("#errmsg").fadeIn('slow');
      }
    } 

    function uploadAdd(e, data) {
      var total_sz = parseInt($('#total_upload_size').val()) + data.files[0].size;
      // is file of wrong type
      if (data.files[0].error == 'acceptFileTypes'){
        $("#errmsg").html(data.files[0].name + " is not of accepted type.");
        $($('#fileupload .files .cancel button')[data.context[0].rowIndex]).click(); 
      }
      // is file size too big
      else if (data.files[0].size > max_file_size) {
        $("#errmsg").html(data.files[0].name + " is too big. No files over " + max_file_size_str + " can be uploaded.");
        $("#errmsg").fadeIn('slow');
        $($('#fileupload .files .cancel button')[data.context[0].rowIndex]).click(); 
      }
      // cumulative upload file size is too big
      else if( total_sz > max_total_file_size) {
        if (first_file_after_max == '') first_file_after_max = data.files[0].name;
        $("#errmsg").html("All files selected from " + first_file_after_max + " and after will not be uploaded because your total upload is too big. You may not upload more than " + max_total_file_size_str + " in one upload.");
        $("#errmsg").fadeIn('slow');
        $($('#fileupload .files .cancel button')[data.context[0].rowIndex]).click(); 
      }
      else if( filestoupload > max_file_count) {
        if (first_file_after_max == '') first_file_after_max = data.files[0].name;
        $("#errmsg").html("All files selected from " + first_file_after_max + " and after will not be uploaded because your total number of files is too big. You may not upload more than " + max_file_count + " files in one upload.");
        $("#errmsg").fadeIn('slow');
        $($('#fileupload .files .cancel button')[data.context[0].rowIndex]).click(); 
      } 
      else {
        filestoupload++;
        $('#total_upload_size').val( parseInt($('#total_upload_size').val()) + data.files[0].size );
        if ( $('#terms_of_service').is(':checked') )
          $('#main_upload_start').attr('disabled', false);
      }
    }

    function uploadDone(e, data) {
      var file = ($.isArray(data.result) && data.result[0]) || {error: 'emptyResult'};
      if (!file.error) {
        files_done++;
        $('.bar').css('background-color', function(){
          var width = parseInt($(this).css('width'));
          if (width == 150) {
            return '#3a8d24';
          }    
        });
      } else {
        if (error_string.length > 0) {
          error_string += '<br/>';
        }
        error_string += file.error;
      }
    }

    // Takes the contextual values in the file you're uploading
    // and assign them to a value in the form that is being uploaded:
    // based off of https://github.com/blueimp/jQuery-File-Upload/wiki/How-to-submit-additional-Form-Data
    function uploadSubmit(e, data) {
      if (settings.afterSubmit) {
        settings.afterSubmit(this, e, data);
      }
      $("form#new_record_fields :submit").attr("title", "The form will be saved on completion of file upload");
      $("form#new_record_fields :submit").attr("disabled", true);
    }

    function uploadFail(e, data) {
      if (data.errorThrown == 'abort') {
         filestoupload--;
         $('#total_upload_size').val( parseInt($('#total_upload_size').val()) - data.files[0].size );
         if ((files_done == filestoupload)&&(files_done >0)){
           saveForm();
         } else {
           $("#errmsg").html(error_string);
         }
         if (filestoupload == 0 && files_done == 0) {
           $("form#new_record_fields :submit").attr("title", "");
           $("form#new_record_fields :submit").removeAttr("disabled");
         }
      } else {
       if (error_string.length > 0) {
          error_string += '<br/>';
       }
       error_string += data.errorThrown + ": " + data.textStatus;
       $("#errmsg").html(error_string);
       $("#errmsg").fadeIn('slow');
       $("form#new_record_fields :submit").attr("title", "");
       $("form#new_record_fields :submit").removeAttr("disabled");
      }
    }

    var $container = this;
    return this.each(function() {        
      // Initialize the jQuery File Upload widget:
      $(this).fileupload();

      // Enable iframe cross-domain access via redirect option:
      $('#fileupload').fileupload(
          'option',
          'redirect',
          window.location.href.replace(
              /\/[^\/]*$/,
              '/cors/result.html?%s'
          )
      );

      $('#fileupload').fileupload(
          'option',
          'acceptFileTypes',
          /^[^\.].*$/i
      );

      $('#fileupload').fileupload(
          'option',
          'sequentialUploads',
          true
      );

      $('#fileupload').bind("fileuploadstop", uploadStopped);

      // count the number of uploaded files to send to edit
      // check the validation on if the file type is not accepted just click cancel for the user as we do not want them to see all the hidden files
      $('#fileupload').bind("fileuploadadd", uploadAdd);
      
      // count the number of files completed and ready to send to edit                          
      $('#fileupload').bind("fileuploaddone", uploadDone);

      $('#fileupload').bind('fileuploadsubmit', uploadSubmit);

      // on fail if abort (aka cancel) decrease the number of uploaded files to send
      $('#fileupload').bind("fileuploadfail", uploadFail);

    });

  };
})( jQuery );  
