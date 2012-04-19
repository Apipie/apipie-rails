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
    var url = window.location.pathname + '.json';
    this.render('index', url);
  },
  
  resource: function(resource) {
    var url = [window.location.pathname, resource + '.json'].join('/');
    this.render('resource', url);
  },
  
  method: function(resource, method) {
    var url = [window.location.pathname, resource, method +'.json'].join('/');
    this.render('method', url);
  },
  
  render: function(type, url) {
    this.data = $.getJSON(url, function(data) {
      if(!Restapi.rendered) {
        $('footer').html(data.docs.copyright);
      }
      
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
      
      $("#container").html(html);
      Restapi.rendered = true;
    });
  }

});