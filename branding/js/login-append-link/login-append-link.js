// - JQuery is used throughout Canvas -- this adds an additional link to the login screen - 

$(document).ready(function(){
  if (window.location.pathname == "/login/canvas"){
    var new_link = $('<a class="ic-Login__link" href="https://google.com" title="New_Link">New_Link</a>');
    $('#login_forgot_password').parent().parent().append(new_link);
  }
});