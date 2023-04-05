require 'spec_helper'

module Apipie::Validator
  describe ArrayValidator do

    let(:param_desc) { double(:param_desc) }

    context "with no constraint" do
      let(:validator) { ArrayValidator.new(param_desc, Array) }
      it "accepts any array" do
        expect(validator.validate([42, 'string', true])).to eq(true)
      end

      it "accepts empty array" do
        expect(validator.validate([])).to eq(true)
        expect(validator.validate(nil)).to eq(true)
      end

      it "does not accepts non array" do
        expect(validator.validate(42)).to eq(false)
        expect(validator.validate(true)).to eq(false)
        expect(validator.validate('string')).to eq(false)
      end
    end

    context "with a constraint on items type" do
      let(:validator) { ArrayValidator.new(param_desc, Array, :of => type) }

      context "String" do
        let(:type) { String }

        it "accepts array of specified type" do
          expect(validator.validate(%w[string1 string2])).to eq(true)
        end

        it "accepts empty array" do
          expect(validator.validate([])).to eq(true)
        end

        it "does not accepts array with other types" do
          expect(validator.validate(['string1', true])).to eq(false)
        end
      end

      context ":number" do
        let(:type) { :decimal }

        it "accepts array of specified type" do
          expect(validator.validate([12, '14'])).to eq(true)
        end

        it "accepts empty array" do
          expect(validator.validate([])).to eq(true)
        end

        it "does not accepts array with other types" do
          expect(validator.validate([12, 'potato'])).to eq(false)
        end
      end
    end

    context "with a constraint on items value" do
      let(:validator) { ArrayValidator.new(param_desc, Array, :in => [42, 'string', true]) }

      it "accepts array of valid values" do
        expect(validator.validate([42, 'string'])).to eq(true)
      end

      it "accepts empty array" do
        expect(validator.validate([])).to eq(true)
      end

      it "does not accepts array with invalid values" do
        expect(validator.validate([42, 'string', 'foo'])).to eq(false)
      end

      it "accepts a proc as list of valid values" do
        validator = ArrayValidator.new(param_desc, Array, :in => lambda { [42, 'string', true] })
        expect(validator.validate([42, 'string'])).to eq(true)
        expect(validator.validate([42, 'string', 'foo'])).to eq(false)
      end
    end

  end
end
