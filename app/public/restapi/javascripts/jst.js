Restapi.Templates.Index = _.template(
    "<ul class='breadcrumb'> \
       <li class='active'><a href='<%= docs.doc_url %>'><%= docs.name %></a></li> \
     </ul> \
     <div class=''><%= docs.info %></div> \
    <% _.each(docs.resources, function(api) { %> \
       <h2><a href='<%= api.doc_url %>'><%= api.name %></a><br><small><%= api.short_description %></small></h2> \
       <table class='table'> \
        <thead><tr><th>Resource</th><th>Description</th></tr></thead> \
        <tbody> \
          <% _.each(api.methods, function(m) { %> \
            <% _.each(m.apis, function(api) { %> \
              <tr> \
                <td><a href='<%= m.doc_url %>'><%= api.http_method %> <%= api.api_url %></a></td> \
                <td width='60%'><%= api.short_description %></td> \
              </tr> \
            <% }) %>\
          <% }) %> \
        </tbody> \
       </table> \
     <% }) %>");
     
Restapi.Templates.Resource = _.template(
      "<ul class='breadcrumb'> \
         <li><a href='<%= docs.doc_url %>'><%= docs.name %></a><span class='divider'>/</span></li> \
         <li class='active'><%= resource.name %></li> \
       </ul> \
      <div class='page-header'><h1><%= resource.name %><br>\
      <small><%= resource.short_description %></small></h1></div> \
      <% if(resource.full_description != '') { %> \
        <div><%= resource.full_description %></div> \
      <% } %> \
    <div class='accordion' id='accordion'> \
      <% _.each(resource.methods, function(m) { %> \
        <hr><div class=''> \
          <div class='pull-right small'><a href='<%= m.doc_url %>'> >>> </a></div> \
          <div> \
            <% _.each(m.apis, function(api) { %> \
              <h3> \
                <a href='#description-<%= m.name %>' \
                   class='accordion-toggle' \
                   data-toggle='collapse' \
                   data-parent='#accordion'> \
                  <%= api.http_method %> <%= api.api_url %> \
                </a> <br> \
                <small><%= api.short_description %></small> \
              </h3> \
            <% }) %> \
          </div> \
          <div id='description-<%= m.name %>' class='collapse accordion-body'> \
            <%= m.full_description %> \
            <% if(m.errors != '') { %> \
              <h2>Errors</h2> \
              <% _.each(m.errors, function(err) { %> \
                <%= err.code %> \
                <%= err.description %> \
                <br> \
              <% }) %> \
            <% } %> \
            <% if(m.params != ''){ %> \
              <h2>Params</h2> \
              <table class='table'> \
                <thead><tr><th>Param name</th><th>Description</th></tr></thead> \
                <tbody> \
                  <% _.each(m.params, function(val) { %> \
                    <tr><td><strong><%= val.name %></strong><br>\
                    <small><%= val.required ? 'required' : 'optional' %><%= val.allow_nil ? ', nil allowed' : '' %></small></td> \
                    <td><%= val.description %><br>\
                    <% if(val.validator != ''){ %> Value: <%= val.validator %><% } %> \
                    </td></tr> \
                  <% }) %> \
                </tbody> \
               </table> \
             <% } %> \
            </div> \
        </div> \
     <% }) %></div>");
     
Restapi.Templates.Method = _.template(
"<ul class='breadcrumb'> \
  <li> \
    <a href='<%= docs.doc_url %>'><%= docs.name %></a> \
    <span class='divider'>/</span> \
  </li> \
  <li> \
    <a href='<%= resource.doc_url %>'><%= resource.name %></a> \
    <span class='divider'>/</span> \
  </li> \
  <li class='active'><%= method.name %></li> \
</ul> \
<% _.each(method.apis, function(api) { %> \
  <div class='page-header'> \
    <h1><%= api.http_method %> <%= api.api_url %><br> \
    <small><%= api.short_description %></small></h1> \
    </div> \
<% }) %> \
<div> \
  <%= method.full_description %> \
  <% if(method.errors != '') { %> \
    <h2>Errors</h2> \
    <% _.each(method.errors, function(err) { %> \
      <%= err.code %> \
      <%= err.description %> \
      <br> \
    <% }) %> \
  <% } %> \
  <% if(method.params != ''){ %> \
    <h2>Params</h2> \
    <table class='table'> \
      <thead><tr><th>Param name</th><th>Description</th></tr></thead> \
      <tbody> \
        <% _.each(method.params, function(val) { %> \
          <tr> \
            <td> \
              <strong><%= val.name %></strong><br> \
              <small><%= val.required ? 'required' : 'optional' %><%= val.allow_nil ? ', nil allowed' : '' %></small> \
            </td> \
            <td> \
              <%= val.description %><br>\
              <% if(val.validator != ''){ %> Value: <%= val.validator %><% } %> \
            </td> \
          </tr> \
        <% }) %> \
      </tbody> \
    </table> \
  <% } %> \
</div>");
