require "spec_helper"

module Apipie::Validator
  describe ArrayOfValidator do
    let(:options) { { of: Integer } }
    let(:validator) do
      described_class.new(
        "param_description",
        options,
        proc {},
      )
    end

    class << self
      def it_returns_true
        it "returns true" do
          expect(validator.validate(value)).to be_truthy
        end
      end

      def it_returns_false
        it "returns false" do
          expect(validator.validate(value)).to be_falsey
        end
      end
    end

    describe "#validate" do
      context "nil" do
        let(:value) { nil }

        it_returns_true
      end

      context "empty array" do
        let(:value) { [] }

        it_returns_true
      end

      context "contains desired type" do
        let(:value) { [1] }

        it_returns_true
      end

      context "contains wrong type" do
        let(:value) { [1, "a"] }

        it_returns_false
      end
    end
  end
end
