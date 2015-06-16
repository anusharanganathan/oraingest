/**!
 * easyPieChart
 * Lightweight plugin to render simple, animated and retina optimized pie charts
 *
 * @license
 * @author Robert Fleischmann <rendro87@gmail.com> (http://robert-fleischmann.de)
 * @version 2.1.5
 **/
!function(a,b){"object"==typeof exports?module.exports=b(require("jquery")):"function"==typeof define&&define.amd?define(["jquery"],b):b(a.jQuery)}(this,function(a){var b=function(a,b){var c,d=document.createElement("canvas");a.appendChild(d),"undefined"!=typeof G_vmlCanvasManager&&G_vmlCanvasManager.initElement(d);var e=d.getContext("2d");d.width=d.height=b.size;var f=1;window.devicePixelRatio>1&&(f=window.devicePixelRatio,d.style.width=d.style.height=[b.size,"px"].join(""),d.width=d.height=b.size*f,e.scale(f,f)),e.translate(b.size/2,b.size/2),e.rotate((-0.5+b.rotate/180)*Math.PI);var g=(b.size-b.lineWidth)/2;b.scaleColor&&b.scaleLength&&(g-=b.scaleLength+2),Date.now=Date.now||function(){return+new Date};var h=function(a,b,c){c=Math.min(Math.max(-1,c||0),1);var d=0>=c?!0:!1;e.beginPath(),e.arc(0,0,g,0,2*Math.PI*c,d),e.strokeStyle=a,e.lineWidth=b,e.stroke()},i=function(){var a,c;e.lineWidth=1,e.fillStyle=b.scaleColor,e.save();for(var d=24;d>0;--d)d%6===0?(c=b.scaleLength,a=0):(c=.6*b.scaleLength,a=b.scaleLength-c),e.fillRect(-b.size/2+a,0,c,1),e.rotate(Math.PI/12);e.restore()},j=function(){return window.requestAnimationFrame||window.webkitRequestAnimationFrame||window.mozRequestAnimationFrame||function(a){window.setTimeout(a,1e3/60)}}(),k=function(){b.scaleColor&&i(),b.trackColor&&h(b.trackColor,b.lineWidth,1)};this.getCanvas=function(){return d},this.getCtx=function(){return e},this.clear=function(){e.clearRect(b.size/-2,b.size/-2,b.size,b.size)},this.draw=function(a){b.scaleColor||b.trackColor?e.getImageData&&e.putImageData?c?e.putImageData(c,0,0):(k(),c=e.getImageData(0,0,b.size*f,b.size*f)):(this.clear(),k()):this.clear(),e.lineCap=b.lineCap;var d;d="function"==typeof b.barColor?b.barColor(a):b.barColor,h(d,b.lineWidth,a/100)}.bind(this),this.animate=function(a,c){var d=Date.now();b.onStart(a,c);var e=function(){var f=Math.min(Date.now()-d,b.animate.duration),g=b.easing(this,f,a,c-a,b.animate.duration);this.draw(g),b.onStep(a,c,g),f>=b.animate.duration?b.onStop(a,c):j(e)}.bind(this);j(e)}.bind(this)},c=function(a,c){var d={barColor:"#ef1e25",trackColor:"#f9f9f9",scaleColor:"#dfe0e0",scaleLength:5,lineCap:"round",lineWidth:3,size:110,rotate:0,animate:{duration:1e3,enabled:!0},easing:function(a,b,c,d,e){return b/=e/2,1>b?d/2*b*b+c:-d/2*(--b*(b-2)-1)+c},onStart:function(){},onStep:function(){},onStop:function(){}};if("undefined"!=typeof b)d.renderer=b;else{if("undefined"==typeof SVGRenderer)throw new Error("Please load either the SVG- or the CanvasRenderer");d.renderer=SVGRenderer}var e={},f=0,g=function(){this.el=a,this.options=e;for(var b in d)d.hasOwnProperty(b)&&(e[b]=c&&"undefined"!=typeof c[b]?c[b]:d[b],"function"==typeof e[b]&&(e[b]=e[b].bind(this)));e.easing="string"==typeof e.easing&&"undefined"!=typeof jQuery&&jQuery.isFunction(jQuery.easing[e.easing])?jQuery.easing[e.easing]:d.easing,"number"==typeof e.animate&&(e.animate={duration:e.animate,enabled:!0}),"boolean"!=typeof e.animate||e.animate||(e.animate={duration:1e3,enabled:e.animate}),this.renderer=new e.renderer(a,e),this.renderer.draw(f),a.dataset&&a.dataset.percent?this.update(parseFloat(a.dataset.percent)):a.getAttribute&&a.getAttribute("data-percent")&&this.update(parseFloat(a.getAttribute("data-percent")))}.bind(this);this.update=function(a){return a=parseFloat(a),e.animate.enabled?this.renderer.animate(f,a):this.renderer.draw(a),f=a,this}.bind(this),this.disableAnimation=function(){return e.animate.enabled=!1,this},this.enableAnimation=function(){return e.animate.enabled=!0,this},g()};a.fn.easyPieChart=function(b){return this.each(function(){var d;a.data(this,"easyPieChart")||(d=a.extend({},b,a(this).data()),a.data(this,"easyPieChart",new c(this,d)))})}});
$(function() {

	/* -------------------------------------------------------------
   * PIE CHART
   * -------------------------------------------------------------
   * Controls the pie chart which shows form submission progress
   * -----------------------------------------------------------*/

  // Initialize the pie chart on page load
	$('.chart').easyPieChart({
  	'trackColor' : '#C8C8C8',
  	'barColor' : '#719AAA',
  	'scaleColor' : false,
  	'lineWidth' : 20,
  	'size' : 180,
  	'lineCap' : 'square',
    'onStep': function (start, target, now) {
      $(this.el).find('.percentage').text(~~now);
    }
  });

  /* -------------------------------------------------------------
   * ACCORDIAN
   * -----------------------------------------------------------*/
  $(document).on("click",".accordian-header",function(){
    var accordian = $(this).parents(".accordian").first();
    accordian.toggleClass("open");
    accordian.find(".accordian-content").stop().slideToggle(400);
  });

  /* -------------------------------------------------------------
   * EXPANDABLE PANELS
   * -------------------------------------------------------------
   * Show and hide extra form elements if a certian selection
   * is made.
   * -----------------------------------------------------------*/
  $(document).on("click","input",function() {
    var fieldset = $(this).parents("fieldset").first(),
        panel_id = $(this).parents("label").first().attr("panel");
    
    // Close other panels
    fieldset.find("[panel!="+panel_id+"]").each(function(){
      var panel_id = $(this).attr("panel");
      $("#"+panel_id)
        .slideUp("slow")
        .animate(
          { opacity: 0 },
          { queue: false, duration: 'slow' }
        );
      // set required to false
      $("#"+panel_id).find("*[data-required]").each(function(){
        $(this).prop('required', false);
      });
      // remove data-progress attribute
      $("#"+panel_id).find("*[data-category]").each(function(){
        $(this).attr('data-progress', false);
      });
    });

    // Open expandable panel on click
    $("#"+panel_id)
      .slideDown("slow")
      .animate(
        { opacity: 1 },
        { queue: false, duration: 'slow' }
      );
    // set required to true
    $("#"+panel_id).find("*[data-required]").each(function(){
      $(this).prop('required', true);
    });
    // set data-progress attribute
    $("#"+panel_id).find("*[data-category]").each(function(){
      var cat = $(this).data("category");
      $(this).data('progress', cat);
    });
  });

  /* -------------------------------------------------------------
   * Hidden Form
   * -------------------------------------------------------------
   * Show and hide hidden form elements.
   * -----------------------------------------------------------*/
  $(document).on("click","[data-action]",function(){
    var action = $(this).attr("data-action"),
        hidden_form;

    // Show the hidden form
    if(action === "show_form"){
      hidden_form = $(this).parents(".file-content").first().find(".hidden-form");
      hidden_form
        .stop()
        .slideDown("slow")
        .animate(
          { opacity: 1 },
          { queue: false, duration: 'slow' }
        );
    }

    // Hide the form
    if(action === "hide_form"){
      hidden_form = $(this).parents(".hidden-form").first();
      hidden_form
        .stop()
        .slideUp("slow")
        .animate(
          { opacity: 0 },
          { queue: false, duration: 'slow' }
        );
    }

    return false;
  });

  // Show licence form thingy
  $("select#dataset_license_licenseLabel").on("change",function(){
    var val = $(this).val();
    if(val == "Bespoke licence") $("#license-statement").show();
    else $("#license-statement").hide();
  });

  /* -------------------------------------------------------------
   * Form Steps Navigation
   * -------------------------------------------------------------
   * Navigation for moving onto other steps of the form
   * -----------------------------------------------------------*/
  function goto_form_step(index, callback) {
    var new_form = $("section.form-step:eq("+index+")"),
        current_form = $("nav.form-steps li.current").index(),
        navigation = $("nav.form-steps ol");

    $("section.form-step:eq("+current_form+")").hide();
    new_form.show();

    navigation.find("li.current").removeClass("current");
    navigation.find("li:eq("+index+")").addClass("current");

    $('html,body').animate({
      scrollTop: $("section.main-content").offset().top-40
    },300, function() {
      if ($.isFunction(callback)) {
        callback();
      }
    });
  }

  $(document).on("click","nav.form-steps li:not(.current)",function(){
    var this_index = $(this).index();
    goto_form_step(this_index);
  });

  $(document).on("click","[data-action]",function(){
    var action = $(this).attr("data-action"),
        current_form = $("nav.form-steps li.current").index(),
        index = null;
    if(action === "next_step") index = current_form+1;
    if(action === "prev_step") index = current_form-1;
    if(index !== null) goto_form_step(index);
  });

  /* -------------------------------------------------------------
   * Expandable Content
   * -----------------------------------------------------------*/
  $(document).on("click",".expand-header",function(){
    var content = $(this).parent().find(".expand-content");
    content.stop().slideToggle("slow");
  });

  /* -------------------------------------------------------------
   * Filters
   * -------------------------------------------------------------
   * Actions for showing and hiding faceted filters
   * -----------------------------------------------------------*/
  $(document).on("click",".filters > ul > li > span",function(){
    $(this).parent().toggleClass("open");
  });

  /* -------------------------------------------------------------
   * Field Repeater
   * -------------------------------------------------------------
   * Gives the ability to add and remove clones of form elements
   * -----------------------------------------------------------*/

  // Collect the field to be cloned
  $('.field-repeater').each(function(){
    var clone = $(this).find("ol > li").first().clone(false);
    clone.find("input[type=text]").val("");
    clone.find("input[type=text]").attr("value", "");
    $(this).data("field",clone);
  });

  // Add a new field
  $(document).on("click",".field-repeater .add-field", function(){
    var container = $(this).parents(".field-repeater").first(),
        list = container.find("ol"),
        items = list.find("li").length,
        clone = container.data("field").clone(),
        max = parseInt(container.attr("data-max-fields")),
        next_id = items -1;
    $(this).closest(".field-repeater").find("[name]").each(function() {
      var name = $(this).attr("name"),
         id = 0;
      if (name) {
        var match = name.match(/\[[0-9]+\]/);
        if (match) {
          id = parseInt(match[0].replace(/\[|\]/g, ""), 10);
        }
      }
      if (id > next_id) next_id = id;
    });
    next_id += 1;
    if(!max) max = 100;
    if(items < max) clone.hide().appendTo(list).fadeIn("slow");
    if(items === (max-1)) container.find(".add-field").hide();
    setup_autocomplete();
    clone.find("[name]").attr("name", function() { return $(this).attr("name").replace(/\[[0-9]+\]/, '[' + next_id + ']'); });
    clone.find("[name]").attr("id", function() { return $(this).attr("id").replace(/[0-9]/, next_id); });
    clone.find('a').attr("data-method", function() { 
      if ($(this).attr("data-method") == "delete") {
        $(this).replaceWith('<a href="#" class="remove-field small">Remove<span class="icon icon-remove"></span></a>');
      }
    });
    return false;
  });

  // Remove a field
  $(document).on("click",".field-repeater .remove-field", function(){
      var container = $(this).parents(".field-repeater").first(),
          fieldrow = $(this).parents("li").first();
      fieldrow.remove();
      container.find(".add-field").show();
      return false;
  });

  $(document).on("click", "#file-table .cancel", function() { 
    $(this).parents("tr").first().fadeTo(50, 0, function() { 
      $(this).css("overflow", "hidden").slideUp(50, function() {
        $(this).remove();
      });
    });
  });

  $("input[type='date']").each(function() {
    var options = {};

    options.dateFormat = 'dd/mm/yy';
    options.firstDay = 1;
    if ($(this).attr("name").match(/dateAccepted/)) {
      options.maxDate = 0;
    }
    if ($(this).attr("name").match(/embargoDate/)) {
      options.minDate = 0;
    }
    $(this).datepicker(options).attr("type", "text");
  });

  $(document).on("focus", "input[type=text],input[type=date],textarea", function() {
    if ($(this).val() == $(this).attr("data-default-value")) {
      $(this).val("");
    }
  });

  $(document).on("blur", "input[type=text],input[type=date],textarea", function() {
    var default_value = $(this).attr("data-default-value");
    if (typeof default_value == "undefined") {
      return;
    }
    if ($(this).val() == "") {
      $(this).val(default_value);
    }
  });

  /* -------------------------------------------------------------
   * Highlight mandatory form field which hasn't been filled out
   * -----------------------------------------------------------*/
  $("section.form-step").each(function(index) {
    $(this).data("form-step-index", index);
  });
    
  function highlight_field($field) {
    var form_section = $field.closest("section.form-step");
    if (form_section.length) {
      goto_form_step(form_section.data("form-step-index"), function () { $field.focus(); });
    } else {
      $field.focus();
    }
  }

  $(".ora-validate-form").validate({
    invalidHandler: function(e, validator) {
      var errors = validator.numberOfInvalids();
      $(".invalid").removeClass("invalid");
      if (errors) {
        var element = validator.errorList[0].element;
        highlight_field($(element));
      }
    },
    ignore: ".ignore",
    focusInvalid: false,
    onsubmit: true,
    onfocusout: true,
    errorPlacement: function (error, element) {
      if (element.is("input:radio")) {
        error.insertBefore(element.parent()); 
      } else { 
        error.insertAfter(element); 
      } 
    }
  });

  // allow for form validation bypassing
  $(document).on("click", "[data-submit-without-validation='true']", function(e) {
    if (!e.isTrigger) {
      $(".ora-validate-form").validate().settings.ignore = "*";
      $("#workflows_entries_status").val($(this).attr("data-default-value"));
      $("#workflows_entries_status").attr("value", $(this).attr("data-default-value"));
      $(this).trigger("click");
    }
  });

  $(".creatorRole").change(function(event) {
    if ($(this).val().length > 5) {
     alert('You can only choose 5!');
     $("option:selected",this).each(function (index) {
       if (index > 4) {
         $(this).prop("selected", false);
       }
      });
    }
  });

  /* -------------------------------------------------------------
   * Tracker Follow
   * -------------------------------------------------------------
   * Fixes the tracker
   * -----------------------------------------------------------*/

  var tracker = $("div.tracker"),
      trackerY = tracker.offset().top;

  function fixTracker() {
    var scrollY = $(window).scrollTop();
    if((scrollY-10) >= trackerY){
      tracker.css({
        "position" : "fixed",
        "top" : "20px"
      });
    }else{
      tracker.css({
        "position" : "relative",
        "top" : "0px"
      });
    }
  }

  function expandPanel() {
    // On load set these values
    // Medium
    if ($(".medium-digital").first().is(':checked')) {
      $("#dataset-format-digital").css("display","block");
      $("#dataset-format-digital").css("opacity","1");
      $("#dataset-format-digital").find("*[data-category]").each(function(){
        var cat = $(this).data("category");
        $(this).data('progress', cat);
      });
      toggleLocatorFieldsDisplay('digital');
    } 
    if ($(".medium-analog").first().is(':checked')) {
      $("#dataset-format-analog").css("display","block");
      $("#dataset-format-analog").css("opacity","1");
      $("#dataset-format-analog").find("*[data-category]").each(function(){
        var cat = $(this).data("category");
        $(this).data('progress', cat);
      });
      toggleLocatorFieldsDisplay('analog');
    }
    // Funding
    $(".fundingAward").each(function(){
      if ($(this).is(':checked') && $(this).val() == "yes") {
        $("#dataset-funding").css("display","block");
        $("#dataset-funding").css("opacity","1");
        $("#dataset-funding").find("*[data-required]").each(function(){
          $(this).prop('required', true);
        });
        $("#dataset-funding").find("*[data-category]").each(function(){
          var cat = $(this).data("category");
          $(this).data('progress', cat);
        });
      }
    });
    // embargo status
    $(".embargoed").each(function(){
      if ($(this).is(':checked')) {
        var panelId = $(this).parents("label").first().attr('panel');
        $("#" + panelId).css("display","block");
        $("#" + panelId).css("opacity","1");
        $("#" + panelId).find("*[data-category]").each(function(){
          var cat = $(this).data("category");
          $(this).data('progress', cat);
        });
      }
    });
    // redirect to previous field
    var eleid = $("#redirect_field").val();
    if (eleid) {
      highlight_field($("#"+eleid));
    }
  }

  fixTracker();
  expandPanel();
  $(document).on("scroll",fixTracker);
});
