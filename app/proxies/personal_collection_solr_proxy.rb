class PersonalCollectionSolrProxy < CollectionSolrProxy
  class << self
    def model_name
      ActiveModel::Name.new(PersonalCollection)
    end
  end
end

