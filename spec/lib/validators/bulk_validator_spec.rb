require 'spec_helper'

describe Apipie::Validator::BulkfValidator do
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

  it 'throws an error when no block is provided' do
    expect { described_class.new(param_desc, nil) }.to raise_error ArgumentError
  end

  it 'works with a single primitive type' do
    validator = described_class.new(param_desc, lambda {
      param :str, String
    })
    expect(validator.validate('hello')).to be true
    expect(validator.validate(nil)).to be true
  end

  it 'always return true after pass the block check' do
    validator = described_class.new(param_desc, lambda {
      param nil, Hash do
        param :foo, String, required: true
        param :baz, String
      end
    })

    expect(validator.validate({ foo: 'bar' })).to be true
    expect(validator.validate({ foo: 'bar', baz: 'bar2' })).to be true
  end
end
