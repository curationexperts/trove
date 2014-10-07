class CollectionExporter
  def initialize(collection)
    @collection = collection
  end

  def export_base_file_name
    Array(@collection.title).first.underscore.gsub(' ', '_').gsub("'", '_')
  end
end
