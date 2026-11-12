require "rails_helper"

RSpec.describe User do
  describe "validations" do
    it "requires a name" do
      expect(described_class.new(name: " ")).not_to be_valid
    end

    it "rejects names with unsupported characters" do
      expect(described_class.new(name: "<script>")).not_to be_valid
    end

    it "treats names case-insensitively for uniqueness" do
      create(:user, name: "Ana")

      expect(described_class.new(name: "ana")).not_to be_valid
    end
  end

  describe ".sign_in" do
    it "creates a user the first time a name is used" do
      expect { described_class.sign_in("Ana") }.to change(described_class, :count).by(1)
    end

    it "finds the existing user regardless of case and surrounding spaces" do
      ana = create(:user, name: "Ana")

      expect(described_class.sign_in("  aNA ")).to eq(ana)
    end

    it "returns an unsaved user with errors for an invalid name" do
      user = described_class.sign_in("")

      expect(user).not_to be_persisted
      expect(user.errors).to be_present
    end
  end
end
