require "active_record"
# Need to require this after requiring active_record because we only require the
# ActiveRecord functionality if the ActiveRecord constant is defined
require "anonymous/active_record"

RSpec.describe "ActiveRecord Anonymization" do
  before(:all) do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::Schema.define do
      create_table :users do |t|
        t.string :email
        t.string :name, null: false
        t.string :number

        t.index :email, unique: true
      end
    end

    class User < ActiveRecord::Base
      include Anonymous::ActiveRecord

      private

      def anonymization_definitions
        {
          email: -> (email) { "anonymous@example.com" },
          name: "John Smith",
          number: nil
        }
      end
    end
  end

  after do
    User.delete_all
  end

  describe "anonymize" do
    it "anonymizes the attributes" do
      user = User.create(name: "Old Name", email: "test@example.com")
      user.anonymize
      user.reload
      expect(user.name).to eq("John Smith")
    end

    it "retries when an ActiveRecord::RecordNotUnique error is raised before allowing the error to bubble up" do
      retries_count = 1

      Anonymous.configure do |config|
        config.max_anonymize_retries = retries_count
      end

      User.create(email: "anonymous@example.com", name: "test")
      user = User.create(email: "test@example.com", name: "test")

      expect(user).to receive(:update_attributes).exactly(retries_count + 1).times.and_call_original
      expect { user.anonymize }.to raise_error(::ActiveRecord::RecordNotUnique)
    end
  end

  describe "anonymize!" do
    it "anonymizes the attributes" do
      user = User.create(name: "Old Name", email: "test@example.com")
      user.anonymize!
      user.reload
      expect(user.name).to eq("John Smith")
    end

    it "retries when an ActiveRecord::RecordNotUnique error is raised before allowing the error to bubble up" do
      retries_count = 1

      Anonymous.configure do |config|
        config.max_anonymize_retries = retries_count
      end

      User.create(email: "anonymous@example.com", name: "test")
      user = User.create(email: "test@example.com", name: "test")

      expect(user).to receive(:update_attributes!).exactly(retries_count + 1).times.and_call_original
      expect { user.anonymize! }.to raise_error(::ActiveRecord::RecordNotUnique)
    end
  end
end
