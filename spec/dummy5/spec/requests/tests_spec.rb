require 'rails_helper'

RSpec.describe "Tests", type: :request do
  describe "GET /tests" do
    it "works! (now write some real specs)" do
      get tests_path
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /tests" do
    subject { post tests_path }

    it "creates a record to shard1" do
      subject

      expect(Test.shard(:shard01).count).to eq(1)
      expect(Test.shard(:shard02).count).to eq(0)
      expect(Test.count).to eq(0)
    end
  end
end
