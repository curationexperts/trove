module ThumbnailHelper
  def thumbnail_tag(document, image_options)
    case document['active_fedora_model_ssi']
    when "TuftsImage"
      image_tag download_path(document.id, datastream_id: 'Thumbnail.png')
    else
      content_tag :span, '', class: 'canonical-image'
    end
    # if document.representative.present?
    #   image_tag download_path(document.representative, datastream_id: 'thumbnail'), alt: 'Thumbnail', class: "canonical-image"
    # else
    #   content_tag :span, '', class: 'canonical-image'
    # end
  end
end
