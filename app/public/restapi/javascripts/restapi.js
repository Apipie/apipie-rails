var Restapi = {
  Routers: {},
  Templates: {},
  Rendered: false,
  
  init: function() {
    new Restapi.Routers.Documentation();
    var base = window.location.pathname;
    Backbone.history.start({root: base});
  },
  
  highlight_syntax: function() {
    if (typeof prettyPrint == 'function') {
      $('pre.ruby').addClass('prettyprint lang-rb');
      prettyPrint();
    }
  }
};

$(document).ready(function() {
  Restapi.init();
});