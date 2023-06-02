require 'spec_helper'

describe Apipie::Generator::Swagger::OperationId do
  let(:path) { '/api' }
  let(:http_method) { :GET }
  let(:param) {}

  let(:operation_id) do
    described_class.new(path: path, http_method: http_method, param: param)
  end

  describe '#to_s' do
    subject { operation_id.to_s}

    it { is_expected.to eq('get_api') }

    context 'when path has variable' do
      let(:path) { '/api/users/:id' }

      it { is_expected.to eq("#{http_method.downcase}_api_users_id") }
    end

    context 'when param is given' do
      let(:param) { 'show' }

      it { is_expected.to eq("#{http_method.downcase}_api_param_show") }
    end
  end

  describe '.from' do
    subject { described_class.from(describable).to_s }

    context 'when an Apipie::MethodDescription::Api is given' do
      let(:describable) do
        Apipie::MethodDescription::Api.
          new(http_method, path, '', { from_routes: '' })
      end

      it { is_expected.to eq("#{http_method.downcase}_api") }
    end

    context 'when an Apipie::MethodDescription is given' do
      let(:dsl_data) do
        ActionController::Base.
          send(:_apipie_dsl_data_init).
          merge({
            api_args: [[http_method, path, "description", { :deprecated => true }]]
          })
      end

      let(:resource_desc) do
        Apipie::ResourceDescription.new(UsersController, "users")
      end

      let(:describable) do
        Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
      end

      it { is_expected.to eq("#{http_method.downcase}_api") }
    end
  end
end

