// simple scoped redirect of Canvas login page
pageRedirect = () => window.location.replace("https://duckduckgo.com/"); 

if (window.location.pathname.indexOf("/login/canvas") > -1){
  pageRedirect();
}