Restapi.Collections.Resources = Backbone.Collection.extend({
  url: Restapi.baseurl(),
  model: Restapi.Models.Resource
});
