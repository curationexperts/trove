class SwitchTypeActor
  def initialize(collection)
    @collection = collection
  end

  def switch
    update_collection_type(@collection) && update_collection_parent
  end

  private

    # remove the collection from it's former parent and add it to the root of the new collection type
    def update_collection_parent
      old_parent = @collection.parent
      old_parent.delete_member_by_id(@collection.id)
      old_parent.save

      new_parent = find_new_parent
      new_parent.member_ids = [@collection.id] + new_parent.member_ids
      new_parent.save
    end

    def update_collection_type(collection)
      collection.clear_relationship(:has_model)
      collection.add_relationship(:has_model, to_type.to_class_uri)
      collection.child_collections.each do |child|
        update_collection_type(child)
      end
      collection.save
    end
end
