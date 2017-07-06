// - JQuery is used throughout Canvas -- this hides a targeted element (in this case the todo list) from students -

function onElementRendered(selector, cb, _attempts) {
  var el = $(selector);
  _attempts = ++_attempts || 1;
  if (el.length) return cb(el);
  if (_attempts == 60) return;
  setTimeout(function() {
    onElementRendered(selector, cb, _attempts);
  }, 250);
};

$(document).ready(function() {
  onElementRendered('h2.todo-list-header', function(e) {
    if ($.inArray("student", ENV.current_user_roles) > -1) {
      $("h2.todo-list-header").remove();
      $("ul.right-side-list.to-do-list").remove();
    }
  });
});