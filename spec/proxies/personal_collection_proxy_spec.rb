require 'rails_helper'

describe PersonalCollectionSolrProxy do

  describe "model_name" do
    it "should be PersonalCollection" do
      expect(PersonalCollectionSolrProxy.model_name).to eq "PersonalCollection"
    end
  end
end


