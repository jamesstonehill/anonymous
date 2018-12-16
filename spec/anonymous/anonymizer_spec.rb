RSpec.describe Anonymous::Anonymizer do
  describe "#anonymized_attributes" do
    it "handles arguments with keys as either symbols or strings" do
      attributes = { attr_1: "abc", "attr_2" => "qwerty"}
      anonymization_definitions = { "attr_1" => "abc", attr_2: "abc" }

      subject = described_class.new(attributes, anonymization_definitions)

      expect(subject.anonymized_attributes).to eq(attr_1: "abc", attr_2: "abc")
    end

    it "does not return attributes that are nil" do
      attributes = { attr_1: "abc", attr_2: nil }
      anonymization_definitions = { attr_1: "abc", attr_2: "abc" }
      subject = described_class.new(attributes, anonymization_definitions)

      expect(subject.anonymized_attributes).to eq(attr_1: "abc")
    end

    it "does not return attributes not in the anonymization_definitions" do
      attributes = { attr_1: "abc", attr_2: "qwert" }
      anonymization_definitions = { attr_2: "abc" }

      subject = described_class.new(attributes, anonymization_definitions)

      expect(subject.anonymized_attributes).to eq(attr_2: "abc")
    end

    it "anonymizes with `call`able objects" do
      attributes = { attr: "abc" }
      anonymization_definitions = { attr: -> (origional) { origional + "123" } }

      subject = described_class.new(attributes, anonymization_definitions)

      expect(subject.anonymized_attributes).to eq(attr: "abc123")
    end

    it "anonymizes with fixed values" do
      attributes = { attr: "abc" }
      anonymization_definitions = { attr: "123" }

      subject = described_class.new(attributes, anonymization_definitions)

      expect(subject.anonymized_attributes).to eq(attr: "123")
    end
  end
end
