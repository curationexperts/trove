module CuratedCollectionsHelper
  def update_collection_type_button(collection)
    capture do
      form_for [:update_type, @curated_collection] do |f|
        if @curated_collection.type == 'personal'
          destination_type = 'course'
          button_text = 'Upgrade to course collection'
        else
          destination_type = 'personal'
          button_text = 'Downgrade to personal collection'
        end
        concat hidden_field_tag :collection_type, destination_type
        concat f.submit button_text, class: 'btn btn-default'
      end
    end
  end

  def weight_and_parent(collection_member, counter, parent_id)
    name_prefix = field_name_prefix(collection_member, counter)
    id_prefix = field_id_prefix(collection_member, counter)
    hidden_field_tag("#{name_prefix}[id]", collection_member.id, id: "#{id_prefix}_id") +
    hidden_field_tag("#{name_prefix}[weight]", counter.value, id: "#{id_prefix}_weight", data: { property: 'weight' }) +
    hidden_field_tag("#{name_prefix}[parent_page_id]", parent_id, id: "#{id_prefix}_parent_page_id", data: { property: 'parent_page' })

  end

  private
    def field_name_prefix(collection_member, counter)
      "#{ActiveModel::Naming.singular(collection_member)}[collection_attributes][#{counter.value}]"
    end

    def field_id_prefix(collection_member, counter)
      "#{ActiveModel::Naming.singular(collection_member)}[collection_attributes][#{counter.value}]"
    end
end
