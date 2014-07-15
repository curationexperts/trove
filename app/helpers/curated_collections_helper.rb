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
end
