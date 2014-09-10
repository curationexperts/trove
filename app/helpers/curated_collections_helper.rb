module CuratedCollectionsHelper
  def update_collection_type_link(collection)
    button_text = case collection
                  when PersonalCollection
                    icon('hand-up') + ' upgrade to course collection'
                  when CourseCollection
                    icon('hand-down') + ' downgrade to personal collection'
                  end
    link_to button_text, [:update_type, collection], method: :patch
  end

  def weight_and_parent(collection_member, counter, parent_id)
    name_prefix = field_name_prefix(collection_member, counter)
    id_prefix = field_id_prefix(collection_member, counter)
    hidden_field_tag("#{name_prefix}[id]", collection_member.id, id: "#{id_prefix}_id") +
    hidden_field_tag("#{name_prefix}[weight]", counter.value, id: "#{id_prefix}_weight", data: { property: 'weight' }) +
    hidden_field_tag("#{name_prefix}[parent_page_id]", parent_id, id: "#{id_prefix}_parent_page_id", data: { property: 'parent_page' })
  end

  def icon(type)
    content_tag 'span', '', class: "glyphicon glyphicon-#{type}"
  end

  private
    def field_name_prefix(collection_member, counter)
      "#{ActiveModel::Naming.singular(collection_member)}[collection_attributes][#{counter.value}]"
    end

    def field_id_prefix(collection_member, counter)
      "#{ActiveModel::Naming.singular(collection_member)}[collection_attributes][#{counter.value}]"
    end
end
