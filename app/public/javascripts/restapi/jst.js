window.JST = {};

window.JST['resources/index'] = _.template(
    "<% _.each(resources.models, function(api) { %> \
       <h3><a href='#<%= api.get('id') %>'><%= api.get('name') %></a><br><small><%= api.get('short_description') %></small></h3> \
       <table class='table'> \
        <thead><tr><th>Resource</th><th>Description</th></tr></thead> \
        <tbody> \
          <% _.each(api.get('methods'), function(m) { %> \
            <tr><td><%= m['http'] %> <%= m['path'] %></td><td><%= m['short_description'] %></td></tr> \
            <% }) %> \
        </tbody> \
       </table> \
     <% }) %>");
     
window.JST['resources/show'] = _.template(
    "<% if(Restapi.Resource) { %> \
      <div class='page-header'><h1><%= Restapi.Resource.get('name') %><br>\
      <small><%= Restapi.Resource.get('short_description') %></small></h1></div> \
      <% if(Restapi.Resource.get('full_description') != '') { %> \
        <div class='hero-unit'> \
          <p><%= Restapi.Resource.get('full_description') %></p> \
        </div> \
      <% } %> \
    <% } %> \
    <div class='accordion' id='accordion'> \
      <% _.each(methods.models, function(api) { %> \
        <div class='well accordion-group'> \
          <div class='accordion-heading'> \
            <a href='#description-<%= api.get('method') %>' class='accordion-toggle' data-toggle='collapse' data-parent='#accordion'> \
              <h3><%= api.get('http') %> <%= api.get('path') %></a> \
            <small><%= api.get('short_description') %></small></h3>\
          </div> \
          <div id='description-<%= api.get('method') %>' class='collapse accordion-body'> \
            <%= api.get('full_description') %> \
            <% if(api.get('errors')!='') { %> \
              <h2>Errors</h2> \
              <% _.each(api.get('errors'), function(err) { %> \
                <%= err['code'] %> \
                <%= err['description'] %> \
                <br> \
              <% }) %> \
            <% } %> \
            <% if(api.get('params') != ''){ %> \
              <h2>Params</h2> \
              <table class='table'> \
                <thead><tr><th>Param name</th><th>Description</th></tr></thead> \
                <tbody> \
                  <% _.each(api.get('params'), function(val) { %> \
                    <tr><td><strong><%= val['name'] %></strong><br>\
                    <small><%= val['required'] ? 'required' : 'optional' %></small></td> \
                    <td><%= val['description'] %><br>\
                    <% if(val['validator']!=''){ %> Value: <%= val['validator'] %><% } %> \
                    </td></tr> \
                  <% }) %> \
                </tbody> \
               </table> \
             <% } %> \
            </div> \
        </div> \
     <% }) %></div>");