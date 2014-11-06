class PptExportWriter

  attr_reader :out, :collection

  SLIDE_WIDTH  = 720  # in pixels
  SLIDE_HEIGHT = 540  # in pixels
  SLIDE_ASPECT_RATIO = SLIDE_WIDTH.to_f / SLIDE_HEIGHT.to_f


  def initialize(collection, out, tmpfile)
    @collection = collection
    @out = out
    @tmpfile = tmpfile
  end

  def write
    transmit_collection
    transmit_slides
  end

  private

    def transmit_collection
      # Send the title and metadata for the main title slide
      title_slide = {
        collectionTitle: collection.title,
        collectionType: collection.type,
        creator: collection.creator,
        uri: "#{Settings.repository_url}/#{collection.type}_collections/#{collection.pid}",
        description: collection.description,
        imageCount: images_with_paths.length, # TODO this is gross here since we're calling a somewhat expensive method again just a little later in the code
        pptExportFile: @tmpfile
      }
      out.puts title_slide.to_json
    end

    def transmit_slides
      images_with_paths.tap { |images|
        # Tell the Java ppt generator how many image slides we want to make
        # out.puts images.count.to_s
      }.each do |image, path|
        transmit_slide(image, path)
      end
    end

    def transmit_slide(image, path)
      # Send the metadata and file path for each individual image slide
      coords = coordinates(path)

      image_slide = {
          title: image.title,
          creator: image.creator,
          date: image.date_created,
          description: image.description,
          imagePath: path,
          x: coords[:x],
          y: coords[:y],
          width: coords[:w],
          height: coords[:h]
      }
      out.puts image_slide.to_json
    end

    def images_with_paths
      collection.flatten.map { |member|
        next unless member.respond_to?(:local_path_for)
        path = member.local_path_for(TuftsImage.default_content_ds)
        File.exists?(path) ? [member, path] : [member, nil]
      }.compact
    end

    # Calculate offset, width, & height of the image on the slide
    def coordinates(image_path)
      if image_path.nil? || image_path.empty?
        return {x:0, y:0, h:0, w:0}
      end

      source_img_width, source_img_height = get_image_dimensions(image_path)
      source_aspect_ratio = source_img_width.to_f / source_img_height.to_f

      if source_aspect_ratio > SLIDE_ASPECT_RATIO
        width = SLIDE_WIDTH
        height = (width / source_aspect_ratio).to_i
      else
        height = SLIDE_HEIGHT
        width = (height * source_aspect_ratio).to_i
      end

      { x: SLIDE_WIDTH / 2 - width / 2,
        y: SLIDE_HEIGHT / 2 - height / 2,
        w: width,
        h: height
      }
    end

    # TODO: Move this into tufts_models gem on the TuftsImage
    # class.  It doesn't really belong here.
    # Something like:  image.dimensions
    def get_image_dimensions(image_path)
      `identify -format %wx%h "#{image_path}"`.split('x').map(&:to_i)
    end

end
