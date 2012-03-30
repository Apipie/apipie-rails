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
    return this.left_menu();
  },
  
  show: function(resource) {
    this.left_menu();
    Restapi.Resource = this.resources.get(resource);
    this.methods.url = "/apidoc/"+resource;
    this.methods.fetch();
    this.resources.trigger('reset');
    
    var view = new Restapi.Views.ResourcesShow({ collection: this.methods });
    return $('#container').html(view.render().el);
  },

  left_menu: function() {
    var view = new Restapi.Views.ResourcesIndex({ collection: this.resources });
    return $('#left_menu_0').html(view.render().el);
  },

});