// - JQuery is used throughout Canvas -- this disable course start and end date fields for instructors -

$(document).ready(function() {
  if (window.location.pathname == "/courses/" + ENV.COURSE_ID + "/settings") {
    if($.inArray("admin", ENV.current_user_roles) == -1) {
      $("#course_start_at").prop("disabled", true);                                   // course_start field
      $("#course_conclude_at").prop("disabled", true);                                // course_end field
      $(".ui-datepicker-trigger").prop("disabled", true);                             // datepicker button
      $("input#course_restrict_enrollments_to_course_dates").prop("disabled", true);  // restrict student enrollments checkbox
  	}
  }
});