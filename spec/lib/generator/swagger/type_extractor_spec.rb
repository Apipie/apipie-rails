require 'spec_helper'

describe Apipie::Generator::Swagger::TypeExtractor do
  let(:validator) {}
  let(:extractor) { described_class.new(validator) }

  describe '#extarct_with_warnings' do
    let(:warnings) { {} }

    before { Apipie.configuration.swagger_suppress_warnings = false }

    subject { extractor.extract_with_warnings(warnings) }

    it { is_expected.to eq(Apipie::Generator::Swagger::TypeExtractor::TYPES[:string]) }

    context "when enum validator is used" do
      let(:enum_values) { ["Name"] }

      context "of type Apipie::Validator::EnumValidator" do
        let(:validator) { Apipie::Validator::EnumValidator.new(nil, enum_values) }

        it { is_expected.to eq("enum") }
      end

      context "that responds to is_enum?" do
        let(:validator) do
          Apipie::ResponseDescriptionAdapter::PropDesc::Validator.new('some-type', enum_values)
        end

        it 'returns an enum type' do
          expect(subject).to eq(Apipie::Generator::Swagger::TypeExtractor::TYPES[:enum])
        end

        context 'and has `true`, `false` as values' do
          let(:param_description_name) { :visible }
          let(:enum_values) { [true, false] }

          it 'returns a boolean type' do
            expect(subject).to eq(Apipie::Generator::Swagger::TypeExtractor::TYPES[:boolean])
          end

          context 'and a boolean warning is passed' do
            let(:boolean_warning) do
              Apipie::Generator::Swagger::Warning.for_code(
                Apipie::Generator::Swagger::Warning::INFERRING_BOOLEAN_CODE,
                'SampleController#action',
                { parameter: 'some-param' }
              )
            end

            let(:warnings) { { boolean: boolean_warning } }

            it 'outputs the warning' do
              expect { subject }.to output(boolean_warning.warning_message).to_stderr
            end
          end
        end
      end
    end
  end
end
