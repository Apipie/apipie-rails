Restapi.Views.ResourcesIndex = Backbone.View.extend({
  
  template: JST['resources/index'],
  
  initialize: function() {
    this.collection.on('reset', this.render, this);
  },
  
  render: function() {
    $(this.el).html(this.template({ resources: this.collection }));
    return this;
  }

});