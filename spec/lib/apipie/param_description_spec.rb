require "spec_helper"

describe Apipie::ParamDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, "users")
  end

  let(:method_desc) do
    Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
  end

  describe "metadata" do

    it "returns nil when no metadata is provided" do
      param = Apipie::ParamDescription.new(method_desc, :some_param, String)
      expect(param.to_json[:metadata]).to eq(nil)
    end

    it "returns the metadata" do
      meta = {
        :length => 32,
        :weight => '830g'
      }
      param = Apipie::ParamDescription.new(method_desc, :some_param, String, :meta => meta)
      expect(param.to_json[:metadata]).to eq(meta)
    end

  end

  describe "show option" do

    it "returns true when show option is not provided" do
      param = Apipie::ParamDescription.new(method_desc, :some_param, String)
      expect(param.to_json[:show]).to eq(true)
    end

    it "returns the show option" do
      param = Apipie::ParamDescription.new(method_desc, :some_param, String, :show => true)
      expect(param.to_json[:show]).to eq(true)

      param = Apipie::ParamDescription.new(method_desc, :some_param, String, :show => false)
      expect(param.to_json[:show]).to eq(false)
    end

  end

  describe "full_name" do
    context "with no nested parameters" do

      it "returns name" do
        param = Apipie::ParamDescription.new(method_desc, :some_param, String)
        expect(param.to_json[:full_name]).to eq('some_param')
      end

    end

    context "with nested parameters" do

      it "returns the parameter's name nested in the parents name" do
        parent_param = Apipie::ParamDescription.new(method_desc, :parent, String)
        nested_param = Apipie::ParamDescription.new(method_desc, :nested, String, :parent => parent_param)

        expect(nested_param.to_json[:full_name]).to eq('parent[nested]')
      end

      context "with the parent parameter set to not show" do

        it "returns just the parameter's name" do
          parent_param = Apipie::ParamDescription.new(method_desc, :parent, String, :show => false)
          nested_param = Apipie::ParamDescription.new(method_desc, :nested, String, :parent => parent_param)

          expect(nested_param.to_json[:full_name]).to eq('nested')
        end

      end
    end
  end

  describe "manual validation text" do
    it "allows manual text" do
      param = Apipie::ParamDescription.new(method_desc, :hidden_param, nil, :validations => "must be foo")

      expect(param.validations).to include("\n<p>must be foo</p>\n")
    end

    it "allows multiple items" do
      param = Apipie::ParamDescription.new(method_desc, :hidden_param, nil, :validations => ["> 0", "< 5"])

      expect(param.validations).to include("\n<p>&gt; 0</p>\n")
      expect(param.validations).to include("\n<p>&lt; 5</p>\n")
    end
  end

  describe "validator selection" do

    it "allows nil validator" do
      param = Apipie::ParamDescription.new(method_desc, :hidden_param, nil)
      expect(param.validator).to be_nil
    end

    it "throws exception on unknown validator" do
      expect { Apipie::ParamDescription.new(method_desc, :param, :unknown) }.to raise_error(RuntimeError, /Validator.*not found/)
    end

    it "picks type validator" do
      expect(Apipie::Validator::BaseValidator).to receive(:find).and_return(:validator_instance)
      param = Apipie::ParamDescription.new(method_desc, :param, String)
      expect(param.validator).to eq(:validator_instance)
    end

  end

  describe 'validate' do
    subject { param_description.validate(validation_value) }

    let(:allow_blank) { nil }

    let(:param_description) do
      Apipie::ParamDescription.new(
        method_desc,
        :param,
        validation_type,
        allow_blank: allow_blank
      )
    end

    context 'when allow_blank is ignored, as it was before 0.7.0' do
      before { Apipie.configuration.ignore_allow_blank_false = true }
      after { Apipie.configuration.ignore_allow_blank_false = false }

      context 'when validation type is :boolean' do
        let(:validation_type) { :boolean }

        context 'when validation value is false' do
          let(:validation_value) { false }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when validation value is an empty string' do
          let(:validation_value) { '' }

          it 'raises an error' do
            expect { subject }.to raise_error(Apipie::ParamInvalid)
          end
        end
      end

      context 'when validation type is a boolean array' do
        let(:validation_type) { [true, false] }

        context 'when validation value is false' do
          let(:validation_value) { false }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when validation value is true' do
          let(:validation_value) { true }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when validation value is an empty string' do
          let(:validation_value) { '' }

          it 'raises an error' do
            expect { subject }.to raise_error(Apipie::ParamInvalid)
          end
        end
      end

      context 'when validation type is String' do
        let(:validation_type) { String }

        context 'when validation value is empty string' do
          let(:validation_value) { '' }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end

          context 'when allow_blank is specified as true' do
            let(:allow_blank) { true }

            it 'does not raise an error' do
              expect { subject }.not_to raise_error
            end
          end
        end
      end
    end

    context 'when the validation type is :boolean' do
      let(:validation_type) { :boolean }

      context 'when validation value' do
        let(:validation_value) { false }

        it 'does not raise an error' do
          expect { subject }.not_to raise_error
        end

        context 'when allow_blank is false' do
          let(:allow_blank) { false }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when allow_blank is true' do
          let(:allow_blank) { true }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end
      end

      context 'when validation value is empty string' do
        let(:validation_value) { '' }

        it 'raises an error' do
          expect { subject }.to raise_error(Apipie::ParamInvalid)
        end
      end
    end

    context 'when validation type is a boolean array' do
      let(:validation_type) { [true, false] }

      context 'when validation value is false' do
        let(:validation_value) { false }

        it 'does not raise an error' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when validation value is true' do
        let(:validation_value) { true }

        it 'does not raise an error' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when validation value is an empty string' do
        let(:validation_value) { '' }

        it 'raises an error' do
          expect { subject }.to raise_error(Apipie::ParamInvalid)
        end
      end
    end

    context 'when the validation type is a custom one' do
      let(:validation_type) { :custom_bool }

      context 'when ignore_allow_blank? returning true' do
        before do
          allow(CustomBoolValidator).to receive(:ignore_allow_blank?).and_return(true)
        end

        context 'when a blank but valid value is passed' do
          let(:validation_value) { false }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end

          context 'when allow_blank is false' do
            let(:allow_blank) { false }

            it 'does not raise an error' do
              expect { subject }.not_to raise_error
            end
          end
        end

        context 'when a blank but invalid value is passed' do
          let(:validation_value) { '' }

          it 'raises an error' do
            expect { subject }.to raise_error(Apipie::ParamInvalid)
          end
        end
      end
    end

    context 'when validation type is String' do
      let(:validation_type) { String }

      context 'when a blank but invalid value is passed' do
        let(:validation_value) { '' }

        it 'raises an error' do
          expect { subject }.to raise_error(Apipie::ParamInvalid)
        end
      end

      context 'when allow_blank is specified as true' do
        let(:allow_blank) { true }

        context 'when and empty string is given' do
          let(:validation_value) { '' }

          it 'does not raise an error' do
            expect { subject }.not_to raise_error
          end
        end
      end
    end
  end

  describe "concern substitution" do

    let(:concern_dsl_data) { dsl_data.merge(:from_concern => true) }

    let(:concern_resource_desc) do
      Apipie::ResourceDescription.new(ConcernsController, "concerns")
    end

    let(:concern_method_desc) do
      Apipie::MethodDescription.new(:show, concern_resource_desc, concern_dsl_data)
    end

    it "replaces string parameter name with colon prefix" do
      param = Apipie::ParamDescription.new(concern_method_desc, ":string_subst", String)
      expect(param.name).to eq("string")
    end

    it "replaces symbol parameter name" do
      param = Apipie::ParamDescription.new(concern_method_desc, :concern, String)
      expect(param.name).to eq(:user)
    end

    it "keeps original value for strings without colon prefixes" do
      param = Apipie::ParamDescription.new(concern_method_desc, "string_subst", String)
      expect(param.name).to eq("string_subst")
    end

    it "keeps the original value when a string can't be replaced" do
      param = Apipie::ParamDescription.new(concern_method_desc, ":param", String)
      expect(param.name).to eq(":param")
    end

    it "keeps the original value when a symbol can't be replaced" do
      param = Apipie::ParamDescription.new(concern_method_desc, :param, String)
      expect(param.name).to eq(:param)
    end
  end

  describe "required_by_default config option" do
    context "parameters required by default" do

      before { Apipie.configuration.required_by_default = true }

      it "sets param as required by default" do
        param = Apipie::ParamDescription.new(method_desc, :required_by_default, String)
        expect(param.required).to be true
      end

      it "is possible to set param as optional" do
        param = Apipie::ParamDescription.new(method_desc, :optional, String, :required => false)
        expect(param.required).to be false
      end

    end

    context "parameters optional by default" do

      before { Apipie.configuration.required_by_default = false }

      it "sets param as optional by default" do
        param = Apipie::ParamDescription.new(method_desc, :optional_by_default, String)
        expect(param.required).to be false
      end

      it "is possible to set param as required" do
        param = Apipie::ParamDescription.new(method_desc, :required, String, 'description','required' => true)
        expect(param.required).to be true
      end

    end

  end

  describe "required params on given actions" do
    let(:method_desc) do
      Apipie::MethodDescription.new(:create, resource_desc, dsl_data)
    end

    context "when the param is required for current action" do
      it "sets param as required" do
        param = Apipie::ParamDescription.new(method_desc, :required, String, 'description','required' => :create)
        expect(param.required).to be true
      end
    end

    context "when the param is required for multiple actions" do
      it "sets param as required if it match current action" do
        param = Apipie::ParamDescription.new(method_desc, :required, String, 'description','required' => [:update, :create])
        expect(param.required).to be true
      end
    end

    context "when the param is not required for current action" do
      it "sets param as not required" do
        param = Apipie::ParamDescription.new(method_desc, :required, String, 'description','required' => :update)
        expect(param.required).to be false
      end
    end
  end

  describe "required params in action aware validator" do

    subject { method_description.params[:user].validator.params_ordered }

    let(:required) do
      subject.find_all(&:required).map(&:name)
    end

    let(:allowed_nil) do
      subject.find_all(&:allow_nil).map(&:name)
    end

    context "with resource creation" do

      let(:method_description) do
        Apipie.get_method_description(UsersController, :create)
      end

      it "makes the param required" do
        expect(required).to include :name
        expect(required).to include :pass
      end

      it "doesn't allow nil" do
        expect(allowed_nil).not_to include :name
        expect(allowed_nil).not_to include :pass
      end
    end

    context "with resource update" do

      let(:method_description) do
        Apipie.get_method_description(UsersController, :update)
      end

      it "doesn't make the param required" do
        expect(required).not_to include :name
        expect(required).not_to include :pass
      end

      it "doesn't allow nil" do
        expect(allowed_nil).not_to include :name
        expect(allowed_nil).not_to include :pass
      end

      it "doesn't touch params with explicitly set allow_nil" do
        expect(allowed_nil).not_to include :membership
      end
    end

    context "with explicitly setting action type in param group" do
      let(:method_description) do
        Apipie.get_method_description(UsersController, :admin_create)
      end

      it "makes the param required" do
        expect(required).to include :name
        expect(required).to include :pass
      end

      it "doesn't allow nil" do
        expect(allowed_nil).not_to include :name
        expect(allowed_nil).not_to include :pass
      end
    end
  end

  describe 'sub params' do

    context 'with HashValidator' do

      subject do
        Apipie::ParamDescription.new(method_desc, :param, Hash) do
          param :answer, Integer
        end
      end

      it "includes the nested params in the json" do
        sub_params = subject.to_json[:params]
        expect(sub_params.size).to eq(1)
        sub_param = sub_params.first
        expect(sub_param[:name]).to eq("answer")
        expect(sub_param[:full_name]).to eq("param[answer]")
      end

    end

    context 'with NestedValidator' do

      subject do
        Apipie::ParamDescription.new(method_desc, :param, Array) do
          param :answer, Integer
        end
      end

      it "includes the nested params in the json" do
        sub_params = subject.to_json[:params]
        expect(sub_params.size).to eq(1)
        sub_param = sub_params.first
        expect(sub_param[:name]).to eq("answer")
        expect(sub_param[:full_name]).to eq("param[answer]")
      end

    end

    context 'with flat validator' do

      subject do
        Apipie::ParamDescription.new(method_desc, :param, String)
      end

      it "includes the nested params in the json" do
        expect(subject.to_json[:params]).to be_nil
      end

    end

  end

  describe "Array with classes" do
    it "is valid for objects included in class array" do
      param = Apipie::ParamDescription.new(method_desc, :param, [Integer, String])
      expect { param.validate("1") }.not_to raise_error
      expect { param.validate(Integer) }.to raise_error(Apipie::ParamInvalid)
    end
  end

  describe '#deprecated?' do
    subject do
      Apipie::ParamDescription.new(method_desc, :param, Integer, options)
    end

    let(:options) { {} }

    it { is_expected.not_to be_deprecated }

    context 'when deprecated option is passed' do
      context 'and is true' do
        let(:options) { { deprecated: true } }

        it { is_expected.to be_deprecated }
      end

      context 'and is false' do
        let(:options) { { deprecated: false } }

        it { is_expected.not_to be_deprecated }
      end

      context 'and is a string' do
        let(:options) { { deprecated: 'Some description' } }

        it { is_expected.to be_deprecated }
      end

      context 'and deprecation options are given' do
        let(:options) do
          { deprecated: { in: '2.3', info: 'Something', sunset: '3.0' } }
        end

        it { is_expected.to be_deprecated }
      end
    end
  end

  describe '#deprecation' do
    subject { param_description.deprecation }

    let(:options) { {} }

    let(:param_description) do
      Apipie::ParamDescription.new(method_desc, :param, Integer, options)
    end

    it { is_expected.to be_blank }

    context 'when deprecated option is passed' do
      context 'and is true' do
        let(:options) { { deprecated: true } }

        it { is_expected.to be_blank }
      end

      context 'and is false' do
        let(:options) { { deprecated: false } }

        it { is_expected.to be_blank }
      end

      context 'and is a string' do
        let(:options) { { deprecated: 'Some description' } }

        it { is_expected.to be_an_instance_of(Apipie::ParamDescription::Deprecation) }
      end

      context 'and deprecation options are given' do
        let(:options) do
          { deprecated: { in: '2.3', info: 'Something', sunset: '3.0' } }
        end

        it { is_expected.to be_an_instance_of(Apipie::ParamDescription::Deprecation) }
      end
    end
  end

  describe '#required' do
    subject { param_description.required }

    let(:param_description) do
      Apipie::ParamDescription.new(method_desc, :param, validator, options)
    end

    context 'when is passed in options' do
      let(:validator) { String }

      context 'when is false' do
        let(:options) { { required: false } }

        it { is_expected.to eq(false) }
      end

      context 'when is true' do
        let(:options) { { required: true } }

        it { is_expected.to eq(true) }
      end
    end

    context 'when validator options are passed' do
      let(:options) { { only_in: :response } }
      let(:validator) { { array_of: String, required: required } }

      context 'when required is false' do
        let(:required) { false }

        it { is_expected.to eq(false) }
      end

      context 'when required is true' do
        let(:required) { true }

        it { is_expected.to eq(true) }
      end
    end
  end
end
