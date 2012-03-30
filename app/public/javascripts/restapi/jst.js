window.JST = {};

window.JST['resources/index'] = _.template(
    "<ul class='nav nav-list'> \
     <li class='nav-header'>Resources</li> \
     <% _.each(resources.models, function(api) { %> \
       <li class='<%= api==Restapi.Resource ? 'active' : '' %>'><a href='#<%= api.get('id') %>'><%= api.get('alias') %></a></li> \
     <% }) %> \
     </ul>");
     
window.JST['resources/show'] = _.template(
    "<% if(Restapi.Resource) { %> \
      <div class='page-header'><h1><%= Restapi.Resource.get('alias') %></h1></div> \
    <% } %> \
    <div class='accordion' id='accordion'> \
      <% _.each(methods.models, function(api) { %> \
        <div class='well accordion-group'> \
          <div class='accordion-heading'> \
            <a href='#description-<%= api.get('method') %>' class='accordion-toggle' data-toggle='collapse' data-parent='#accordion'> \
              <h2><%= api.get('http') %> <%= api.get('path') %> <small><%= api.get('method') %>: <%= api.get('short_description') %></small></h2>\
            </a> \
          </div> \
          <div id='description-<%= api.get('method') %>' class='collapse accordion-body'> \
            <%= api.get('full_description') %> \
            <h1>Errors</h1> \
            <% _.each(api.get('errors'), function(err) { %> \
              <%= err['code'] %> \
              <%= err['description'] %> \
              <br> \
            <% }) %> \
            <h1>Params</h1> \
            <% _.each(api.get('params'), function(val) { %> \
              <h3><%= val['name'] %></h3> \
              <ul>\
                <li>Description: <%= val['description'] %></li> \
                <li>Required: <%= val['required'] %></li> \
                <% if(val['validator']!=''){ %> \
                  <li>Validator: <%= val['validator'] %></li> \
                <% } %> \
              </ul> \
            <% }) %> \
            </div> \
        </div> \
     <% }) %></div>");


    // "<% _.each(mapis.models, function(api) { %> \
       // <strong><%= api.get('resource') %>#<%= api.get('method') %></strong><br> \
     // <% }) %>");