class PptExportWriter

  attr_reader :out, :collection

  SLIDE_WIDTH  = 720  # in pixels
  SLIDE_HEIGHT = 540  # in pixels
  SLIDE_ASPECT_RATIO = SLIDE_WIDTH.to_f / SLIDE_HEIGHT.to_f


  def initialize(collection, out)
    @collection = collection
    @out = out
  end

  def write
    transmit_collection
    transmit_slides
  end

  private

    def transmit_collection
      # Send the title and list of descriptions for the main title slide
      out.puts collection.title
      desc = Array(collection.description)
      out.puts desc.count
      desc.each { |d| out.puts d }
    end

    def transmit_slides
      images_with_paths.tap { |images|
        # Tell the Java ppt generator how many image slides we want to make
        out.puts images.count.to_s
      }.each do |image, path|
        transmit_slide(image, path)
      end
    end

    def transmit_slide(image, path)
      out.puts image.title
      metadata = []
      metadata << "Creator: #{image.creator.join("\\r")}" if image.creator.present?
      metadata << "Description: #{image.description.join("\\r")}" if image.description.present?
      metadata << "Date: #{image.date_created.join("\\r")}" if image.date_created.present?
      # fill out any remaining metadata slots
      0.upto(2) do |n|
        out.puts metadata[n]
      end
      if path.nil?
        5.times { out.puts }
      else
        out.puts path
        coords = coordinates(path)
        out.puts coords[:x]
        out.puts coords[:y]
        out.puts coords[:cx]
        out.puts coords[:cy]
      end
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
        cx: width,
        cy: height
      }
    end

    # TODO: Move this into tufts_models gem on the TuftsImage
    # class.  It doesn't really belong here.
    # Something like:  image.dimensions
    def get_image_dimensions(image_path)
      `identify -format %wx%h "#{image_path}"`.split('x').map(&:to_i)
    end

end
