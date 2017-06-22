// - JQuery is used throughout Canvas -- this hides a targeted element from non-admin users -

$(document).ready(function() {
  if (window.location.pathname == "/courses/" + ENV.COURSE_ID + "/settings") {
    if($.inArray("admin", ENV.current_user_roles) == -1) {
        $("#example_id").hide();
        //$(".example_class").hide();
  	}
  }
});
