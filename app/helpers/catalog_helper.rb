module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def curated_collection_member_path(collection, position)
    case collection.relationships(:has_model).first
    when CourseCollection.to_class_uri
      course_collection_member_path(collection, position)
    when PersonalCollection.to_class_uri
      personal_collection_member_path(collection, position)
    else
      raise ArgumentError.new("Unknown has_model relationship")
    end
  end

  def featured_records
    pids = (FeatureDataSettings['featured_pids'] || []).select do |pid|
      TuftsBase.valid_pid?(pid) && ActiveFedora::Base.exists?(pid)
    end
    if pids.present?
      ActiveFedora::Base.find(pids)
    else
      TuftsImage.where(displays_ssim: 'trove').limit(3)
    end
  end

  def nested_collection_options(collections, indent=0)
     collections.map do |collection|
      "<option value=\"#{collection.id}\">#{"&nbsp;"*3*indent + collection.title}</option>" +
        nested_collection_options(collection.collection_members, indent + 1)
     end.join.html_safe
  end

  def grouped_collection_options(collections)
    collections.map do |collection|
      "<optgroup label=\"#{collection.title}\">" +
        nested_collection_options(collection.collection_members) +
      "</optgroup>"
    end.join.html_safe
  end
end
