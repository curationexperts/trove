class CourseCollectionSolrProxy < CollectionSolrProxy
  class << self
    def root
      CourseCollectionSolrProxy.new(id: CourseCollection::ROOT_PID)
    end

    def model_name
      ActiveModel::Name.new(CourseCollection)
    end
  end
end
