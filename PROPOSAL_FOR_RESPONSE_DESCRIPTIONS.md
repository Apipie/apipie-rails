# Proposal for supporting response descriptions in Apipie

## Rationale

Swagger allows API authors to describe the structure of objects returned by REST API calls.
Client authors and code generators can use such descriptions for various purposes, such as verification, 
autocompletion, and so forth.

The current Apipie DSL allows API authors to indicate returned error codes (using the `error` keyword), 
but does not support descriptions of returned data objects. As such, swagger files
generated from the DSL do not include those, and are somewhat limited in their value.

This document proposes a minimalistic approach to extending the Apipie DSL to allow description of response
objects, and including those descriptions in generated swagger files. 

## Design Objectives

* Full backward compatibility with the existing DSL
* Minimal implementation effort
* Enough expressiveness to support common use cases
* Optional integration of the DSL with advanced JSON generators (such as Grape-Entity)      

## Approach

#### Add a `returns` keyword to the DSL, based on the existing `error` keyword

Currently, returned error codes are indicated using the `error` keyword, for example:
```ruby
api :GET, "/users/:id", "Show user profile"
error :code => 401, :desc => "Unauthorized"
```

The proposed approach is to add a `returns` keyword, that has the following syntax:
```ruby
returns <type-identifier> [, :code => <number>] [, :desc => <response-description>]
```

For example:
```ruby
api :GET, "/users/:id", "Show user profile"
error :code => 401, :desc => "Unauthorized"
returns :SomeTypeIdentifier  # :code is not specified, so it is assumed to be 200
```


#### Leverage `param_group` for response object description

Apipie currently has a mechanism for describing complex objects using the `param_group` keyword.
It seems reasonable to leverage this mechanism as the basis of the response object description mechanism,
so that the `<type-identifier>` in the `returns` keyword will be the name of a param_group.

For example:
```ruby
  def_param_group :user do
    param :user, Hash, :desc => "User info", :required => true, :action_aware => true do
      param_group :credentials
      param :membership, ["standard","premium"], :desc => "User membership", :allow_nil => false
    end
  end

  api :GET, "/users/:id", "Get user record"
  returns :user, "the requested record"
  error :code => 404, :desc => "no user with the specified id"
```

Implementation of this DSL extension would involve - as part of the implementation of the `returns` keyword - 
the generation of a Apipie::ParamDescription object that has a Hash validator pointing to the param_group block.

#### Extend action-aware functionality to include 'response-only' parameters

In CRUD operations, it is common for `param_group` input definitions to be very similar to the 
output of the API, with the exception of a very small number of fields (such as the `:id` field
which usually appears in the response, but is not described in the `param_group` because it is passed as a 
path parameter).

To allow reuse of the `param_group`, it would be useful to its definition to describe parameters that are not passed 
in the request but are returned in the response.  This would be implementing by extending the DSL to 
support a `:only_in => :response` option on `param` definitions.   

For example:
```ruby
  # in the following group, the :id param is ignored in requests, but included in responses
  def_param_group :user do
    param :user, Hash, :desc => "User info", :required => true, :action_aware => true do
      param :id, Integer, :only_in => :response
      param_group :credentials
      param :membership, ["standard","premium"], :desc => "User membership", :allow_nil => false
    end
  end

  api :GET, "/users/:id", "Get user record"
  returns :user, :desc => "the requested record"  # includes the :id field, because this is a response
  error :code => 404, :desc => "no user with the specified id"
```

Note: if the need arises, it would be possible to extend this pattern to also support `:only_in => :request` params.


#### Support `:array_of => <param_group-name>` in the `returns` keyword 

Very often, a REST API call returns an array of some previously-defined object 
(the most common example an `index` operation that returns an array of the same entity returned by a `show` request), 
and it would be tedious to have to define a separate `param_group` for each one.

For added convenience, the `returns` keyword will also support an `:array_of =>` construct
to specify that an API call returns an array of some object type.

For example:
```ruby
  api :GET, "/users", "Get all user records"
  returns :array_of => :user, :desc => "the requested user records"

  api :GET, "/user/:id", "Get a single user record"
  returns :user, :desc => "the requested user record"
```

#### Integration with advanced JSON generators using an [adapter](https://en.wikipedia.org/wiki/Adapter_pattern) to `param_group`

While it makes sense for the sake of simplicity to leverage the `param_group` construct to describe 
returned objects, it is likely that many developers will prefer to unify the 
description of the response with the actual generation of the JSON.

Some JSON-generation libraries, such as [Grape-Entity](https://github.com/ruby-grape/grape-entity),
provide a declarative interface for describing an object model, allowing both runtime
generation of the response, as well as the ability to traverse the description to auto-generate
documentation.

Such libraries could be integrated with Apipie using adapters that wrap the library-specific
object description and expose an API that includes a `params_ordered` method that behaves in a 
similar manner to [`Apipie::HashValidator.params_ordered`](https://github.com/Apipie/apipie-rails/blob/cfb42198bc39b5b30d953ba5a8b523bafdb4f897/lib/apipie/validator.rb#L315).
Such an adapter would make it possible to pass an externally-defined entity to the `returns` keyword
as if it were a `param_group`.

For example:
```ruby
# entity defined using Grape::Entity
class UserView < Grape::Entity
    expose :id, documentation: {type: Integer, desc: "user id", required: true}
    expose :name
end

# API defined using Apipie
# where 'from_grape_entity' is an adapter that exposes the contents of the entity
# as if it were an Apipie::ParamDescription object 
api :GET, "/users", "Get all user records"
returns :array_of => from_grape_entity(UserView), :desc => "the requested user records"
```