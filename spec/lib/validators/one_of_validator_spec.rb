require 'spec_helper'

describe Apipie::Validator::OneOfValidator do
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
    expect(validator.params_ordered.size).to be 1
    expect(validator.validate('hello')).to be true
    expect(validator.validate(20)).to be false
  end

  it 'works with multiple primitive types' do
    validator = described_class.new(param_desc, lambda {
      param nil, String
      param nil, Integer
    })
    expect(validator.params_ordered.size).to be 2
    expect(validator.validate('hello')).to be true
    expect(validator.validate(20)).to be true
    expect(validator.validate(13.4)).to be false
  end

  it 'works with enum validators' do
    validator = described_class.new(param_desc, lambda {
      param nil, ['foo', 10]
      param nil, [20, 'bar']
    })
    expect(validator.validate('foo')).to be true
    expect(validator.validate(10)).to be true
    expect(validator.validate(20)).to be true
    expect(validator.validate('bar')).to be true
    expect(validator.validate('something else')).to be false
  end

  it 'accepts arguments for validators' do
    validator = described_class.new(param_desc, lambda {
      param :hash, Hash, desc: 'hash param' do
        param :foo, Integer
        param :bar, String
      end
      param :array_of_hash, Array, desc: 'array of hash param' do
        param :id, Integer, required: true
        param :name, String, required: true
      end
      param :array_of_int, Array, of: Integer, desc: 'array of int param'
    })

    expect(validator.validate({ foo: 5, bar: 'foo' })).to be true
    expect { validator.validate({ foo: 'bar', bar: 3 }) }.to raise_error Apipie::ParamError

    expect(validator.validate([{ id: 1, name: 'John Doe' }, { id: 2, name: 'Jane Doe' }])).to be true
    expect do
      validator.validate([{ id: 1, name: 'John Doe' }, { invalid: 'key' }])
    end.to raise_error Apipie::ParamError

    expect(validator.validate([10, 20, 30])).to be true
    expect(validator.validate([10, 20, 'foo'])).to be false
  end

  it 'ignores earlier validators that raise if a subsequent validator passes' do
    validator = described_class.new(param_desc, lambda {
      param :int_hash, Hash do
        param :foo, Integer
      end
      param :string_hash, Hash do
        param :foo, String
      end
    })

    expect(validator.validate({ foo: 'foo' })).to be true
    expect(validator.validate({ foo: 20 })).to be true
    expect { validator.validate({ foo: {} }) }.to raise_error Apipie::ParamError
  end


  it 'works with param group references' do
    validator = described_class.new(param_desc, lambda {
      param nil, Hash do
        param_group :param_group_b, UsersController
      end
      param nil, Hash do
        param_group :param_group_a, UsersController
      end
      param nil, [false]
    })

    expect(validator.validate({ str: 'string', int: 20 })).to be true
    expect(validator.validate({ id: 20, name: 'John Doe' })).to be true
    expect(validator.validate({ id: 20, name: 'John Doe', email: 'john.doe@example.com' })).to be true
    expect(validator.validate(false)).to be true

    expect { validator.validate({ str: 20, int: 20 }) }.to raise_error Apipie::ParamError
    expect { validator.validate({ id: 20 }) }.to raise_error Apipie::ParamError
    expect { validator.validate({ id: 20, name: 'John Doe', email: false }) }.to raise_error Apipie::ParamError
  end

  it 'marks values that match multiple validators as invalid' do
    validator = described_class.new(param_desc, lambda {
      param nil, Hash do
        param :foo, String, required: true
        param :baz, String
      end
      param nil, Hash do
        param :bar, Integer, required: true
      end
    })

    expect(validator.validate({ foo: 'bar' })).to be true
    expect(validator.validate({ foo: 'bar', baz: 'bar2' })).to be true
    expect(validator.validate({ bar: 12 })).to be true

    expect { validator.validate({ foo: 'bar', bar: 20 }) }.to raise_error Apipie::ParamError
  end
end
