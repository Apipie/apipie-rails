var Restapi = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  Resource: null,
  ResourceAlias: "",

  init: function() {
    new Restapi.Routers.Resources();
    return Backbone.history.start();
  }
};

$(document).ready(function() {
  return Restapi.init();
});