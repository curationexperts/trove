module CuratedCollectionHelper
  extend ActiveSupport::Concern

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
end
