require 'spec_helper'

describe Apipie::Validator::NestedHashValidator do
  before do
    Apipie.configuration.validate = true
    Apipie.configuration.validate_presence = true
    Apipie.configuration.validate_value = true
  end

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }
  let(:resource_desc) { Apipie::ResourceDescription.new(UsersController, 'users') }
  let(:method_desc) { Apipie::MethodDescription.new(:show, resource_desc, dsl_data) }
  let(:param_desc) { Apipie::ParamDescription.new(method_desc, :param, nil) }
  let(:argument) { described_class::VALIDATOR_TYPE }

  before do
    Apipie.add_param_group UsersController, :param_group_a do
      param :str, String, required: true
      param :int, Integer, required: true
    end

    Apipie.add_param_group UsersController, :param_group_b do
      param :id, :number, required: true
      param :name, String, required: true
      param :email, String
    end
  end

  it 'works with a primitive type' do
    validator = described_class.new(param_desc, Integer)
    expect(validator.validate(20)).to be false
    expect(validator.validate({ key: 'foo' })).to be false
    expect(validator.validate({ key: 20 })).to be true
    expect(validator.validate({ key: 20, foo: 10, bar: 2 })).to be true
  end

  it 'works with a nested hash type' do
    validator = described_class.new(param_desc, Hash, {}, lambda {
      param :foo, String
    })
    expect(validator.validate({ key: 'foo' })).to be false
    expect(validator.validate({ key: 20 })).to be false
    expect(validator.validate({ key: { foo: 'bar' } })).to be true
  end

  it 'works with one_of validator' do
    validator = described_class.new(param_desc, :one_of, {}, lambda {
      param :str, String
      param :int, Integer
    })
    expect(validator.validate({ foo: 'bar', bar: 10 })).to be true
    expect(validator.validate({ foo: 'bar', bar: 2.1 })).to be false
    expect(validator.validate({ foo: {}, bar: 10 })).to be false
  end
end
