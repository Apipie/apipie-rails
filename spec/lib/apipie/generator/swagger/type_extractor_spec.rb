require 'spec_helper'

describe Apipie::Generator::Swagger::TypeExtractor do
  let(:extractor) { described_class.new(validator) }

  shared_examples 'extractable method' do
    let(:warnings) { {} }
    let(:validator) {}

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
      end
    end
  end

  describe '#extract' do
    subject { extractor.extract }

    it_behaves_like 'extractable method'
  end
end
