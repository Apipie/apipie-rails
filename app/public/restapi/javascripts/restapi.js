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
  },

  baseurl: function() { return document.location.toString().replace(/#.*/,""); }
};

$(document).ready(function() {
  return Restapi.init();
});
