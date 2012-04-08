var Restapi = {
  Routers: {},
  Templates: {},
  
  init: function() {
    new Restapi.Routers.Documentation();
    var base = '/' + window.location.pathname.split('/')[1];
    Backbone.history.start({pushState: true, root: base});
  }
};

$(document).ready(function() {
  Restapi.init();
});