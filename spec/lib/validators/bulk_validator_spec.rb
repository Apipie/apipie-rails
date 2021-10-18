require 'spec_helper'

describe Apipie::Validator::BulkValidator do
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

  it 'throws an error when no block is provided' do
    expect { described_class.new(param_desc, nil) }.to raise_error ArgumentError
  end

  it 'works with a single primitive type' do
    validator = described_class.new(param_desc, lambda {
      param :str, String
    })
    expect(validator.validate('hello')).to be true
    expect(validator.validate(20)).to be true
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
