require 'rails_helper'

describe SolrDocument do
  let(:doc) { SolrDocument.new('description_tesim' => ['My image']) }

  describe "#description" do
    subject { doc.description }
    it { should eq ['My image'] }
  end
end
