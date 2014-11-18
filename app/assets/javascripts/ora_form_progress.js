(function($) {
  /**
   * Counts the totla number of complete inputs (complete counts as checked,
   * selected, or non-empty
   */
  function countComplete($inputs) {
    var valid_count = 0;
    $inputs.each(function() {
      if ($(this).attr("type") == "radio" || $(this).attr("type") == "checkbox") {
        if (this.checked) {
          valid_count += 1;
        }
      } else if (!!$(this).val()) {
        valid_count += 1;
      }
    });
    return valid_count;
  }

  /**
   * Counts the total number of unique inputs. Unique will discount things like
   * radios where there are a few inputs all with the same name, but should be
   * thought of as one item.
   */
  function countUnique($inputs) {
    return $.unique($.map($inputs, function(input) {
        return input.name;
      })).length
  }


  function updateProgress() {
    var inputs = $("[data-progress]"),
      sections = $.unique($.map(inputs, function(input) {
          return $(input).data("progress");
        })),
      section_counts = {};

    $.each(sections, function(idx, section) {
        var section_inputs = inputs.filter('[data-progress="' + section + '"]'),
          input_count = countUnique(section_inputs);

        section_counts[section] = {
          count: input_count,
          percent: 100 * (countComplete(section_inputs)) / input_count
        };
      });

    $(".chart").each(function() {
      $(this).data('easyPieChart').update(100 * countComplete(inputs) / countUnique(inputs));
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
  }

  function toggleUploadForm() {
    var terms_accepted = $("#terms_of_service").is(":checked");

    if (terms_accepted) {
      $("#file-table").show();
      $("#file-upload-tos-warning").hide();
    } else {
      $("#file-table").hide();
      $("#file-upload-tos-warning").show();
    }
  }


  /**
   * Let's do this
   */
  $(document).on("change", "[data-progress]", updateProgress);
  $(updateProgress);
  $(document).on("change", "#terms_of_service", toggleUploadForm);
  $(toggleUploadForm);
})(jQuery);
