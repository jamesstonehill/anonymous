RSpec.describe Anonymous::Configuration do
  it "Allows you to set the configuration options" do
    subject.max_anonymize_retries = 99
    expect(subject.max_anonymize_retries).to eq(99)
  end

  it "Has default options for the configuration options" do
    expect(subject.max_anonymize_retries).to eq(1)
  end
end
