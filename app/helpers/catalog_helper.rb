module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def featured_records
    pids = FeatureDataSettings['featured_pids']
    if pids.present?
      ActiveFedora::Base.find(pids)
    else
      TuftsImage.where(displays_ssim: 'tdil').limit(3)
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
