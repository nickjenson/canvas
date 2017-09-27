// - JQuery is used throughout Canvas -- this adds a global-nav link - 

function addMenuItem (linkText, url, icon, target) {    
  var iconHtml = '',    
  itemHtml,    
  linkId = linkText.split(' ').join('_'),  
  newtab = '';  
  if (typeof target !== 'undefined') {  
    newTab = 'target="' + target + '"';  
  }  else{
    window.open("url", "_self")
  }
  if (icon !== '') {
    iconHtml = '<i class="ic-icon-svg ' + icon.toLowerCase() + '"></i>';  
  }    
  itemHtml = '<li class="menu-item ic-app-header__menu-list-item"><a id="global_nav_' + linkId.toLowerCase() + '" href="' + url + '" class="ic-app-header__menu-list-link"><div class="menu-item-icon-container" aria-hidden="true">'+ iconHtml + '</div><div class="menu-item__text">' + linkText + '</div></a></li>';

  $('#menu li:eq(2)').after(itemHtml); // this adds the icon after the 3rd list-item, will need to be edited based on needs
}
$(document).ready(function(){    
  addMenuItem('Icons', 'http://instructure.github.io/instructure-icons/#Font', 'icon-image', '_self');
});