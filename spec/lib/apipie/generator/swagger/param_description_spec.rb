require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription do
  describe '.create_for_missing_param' do
    let(:name) { 'ok' }

    let(:method_description) do
      Apipie.get_method_description(UsersController, :update)
    end

    subject do
      described_class.create_for_missing_param(method_description, name)
    end

    it 'creates a required param description' do
      expect(subject.required).to eq(true)
    end

    it 'has the correct name' do
      expect(subject.name).to eq(name)
    end

    it 'has been created from path' do
      expect(subject.options[:added_from_path]).to eq(true)
    end
  end
end

