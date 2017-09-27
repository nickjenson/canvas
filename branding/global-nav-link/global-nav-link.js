// - JQuery is used throughout Canvas -- this adds a global-nav link - 

function addMenuItem (link-text, url, icon, target) {    
  var icon-html = '',    
  item-html,    
  link-id = link-text.split(' ').join('_'),  
  newtab = '';  
  if (typeof target !== 'undefined') {  
    newtab = 'target="' + target + '"';  
  }  else{
    window.open("url","_self")
  }
  if (icon !== '') {
    icon-html = '<i class="' + icon + '" style="display: block; width: 100%; height: 25px;"></i> ';  
  }    
  item-html = '<li class="ic-app-header__menu-list-item "><a id="global_nav_' + link-id + '" href="' + url + '" class="ic-app-header__menu-list-link" target="_new"><div class="menu-item__text">' + icon-html + link-text + '</div></a></li>';

  $('#menu li:eq(2)').after(item-html); // this adds the icon after the 3rd list-item, will need to be edited based on needs
}
$(document).ready(function(){    
  addMenuItem('Library', 'https://google.com/', 'icon-collection','_self');  
});