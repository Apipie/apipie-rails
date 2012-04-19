var Restapi = {
  Routers: {},
  Templates: {},
  Rendered: false,
  
  init: function() {
    new Restapi.Routers.Documentation();
    var base = window.location.pathname;
    Backbone.history.start({root: base});
  }
};

$(document).ready(function() {
  Restapi.init();
});