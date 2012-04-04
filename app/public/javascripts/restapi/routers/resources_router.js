Restapi.Routers.Resources = Backbone.Router.extend({

  routes: {
    "":                 "index",
    ":resource":        "show"
  },

  initialize: function() {
    this.resources = new Restapi.Collections.Resources();
    this.methods = new Restapi.Collections.Methods();
    return this.resources.fetch();
  },

  index: function(query) {
    var view = new Restapi.Views.ResourcesIndex({ collection: this.resources });
    return $('#container').html(view.render().el);
  },
  
  show: function(resource) {
    Restapi.Resource = this.resources.get(resource);
    this.methods.url = "/apidoc/"+resource;
    this.methods.fetch();
    
    var view = new Restapi.Views.ResourcesShow({ collection: this.methods });
    return $('#container').html(view.render().el);
  }

});