(function($) {
  $.expr[':'].oraValid = function(/*elem, index, match*/) {
    return Math.round(Math.random());
  };

  $(document).on("ora.formupdate", function(event, $form) {
    var inputs = $form.find("[data-progress]"),
      sections = $.unique($.map(inputs, function(input) {
          return $(input).data("progress");
        })),
      section_counts = {};
      
      $.each(sections, function(idx, section) {
          var section_inputs = inputs.filter('[data-progress="' + section + '"]');

          section_counts[section] = {
            count: section_inputs.length,
            percent: 100 * (section_inputs.filter(":oraValid").length) / section_inputs.length
          };
        });

      $("[data-progress-link]").each(function() {
        var $this = $(this),
          section = $(this).data("progress-link");

        if (typeof section_counts[section] !== "undefined") {
          //$(this).find(".percentage").css("width", section_counts[section].percent + "%");
          $this.find(".percentage").stop().animate({
            width: section_counts[section].percent + "%"
          }, {
            duration: 500
          });
        }
      });

  });
})(jQuery);
