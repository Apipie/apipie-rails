Restapi.Views.ResourcesShow = Backbone.View.extend({
  
  template: JST['resources/show'],
  
  initialize: function() {
    this.collection.on('reset', this.render, this);
  },
  
  render: function() {
    $(this.el).html(this.template({ methods: this.collection }));
    return this;
  }

});