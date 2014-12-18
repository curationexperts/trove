module CuratedCollectionHelper
  extend ActiveSupport::Concern

  included do
    include Blacklight::SolrHelper
  end

  def curated_collection_path(collection)
    case collection.relationships(:has_model).first
    when CourseCollection.to_class_uri
      course_collection_path(collection)
    when PersonalCollection.to_class_uri
      personal_collection_path(collection)
    else
      raise ArgumentError.new("Unknown has_model relationship")
    end
  end

  def visible_by_trove?(pid)
    doc = get_solr_response_for_doc_id(pid).second
    doc['displays_ssim'].include?('trove') && doc['object_state_ssi'] == 'A'
  end
end
