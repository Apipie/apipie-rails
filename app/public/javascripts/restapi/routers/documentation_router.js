Restapi.Routers.Documentation = Backbone.Router.extend({

  routes: {
    "":                  "index",
    ":resource":         "resource",
    ":resource/:method": "method"
  },

  initialize: function() {
    // this.navigate(window.location.pathname);
  },

  index: function() {
    this.render('index');
  },
  
  resource: function(resource) {
    this.render('resource');
  },
  
  method: function(resource, method) {
    this.render('method');
  },
  
  render: function(type) {
    this.data = $.getJSON(window.location.pathname + '.json', function(data) {
      $('#api-title').html(data.docs.name).attr('href', data.docs.doc_url);
      $('footer').html(data.docs.copyright);
      
      var html = '';
      if (type == 'index') {
        html = Restapi.Templates.Index({ docs: data.docs });
      } else if (type == 'resource') {
        html = Restapi.Templates.Resource({ docs: data.docs, resource: data.docs.resources[0] });
      } else if (type == 'method') {
        html = Restapi.Templates.Method({ 
          docs: data.docs, 
          resource: data.docs.resources[0],
          method: data.docs.resources[0].methods[0]
        });
      }
      
      $("#container").append(html);
    });
  }

});