module PowerPoint
  extend ActiveSupport::Concern

  PPTX_DIR = File.join(Rails.root, 'tmp', 'exports')

  POINTS_PER_PIXEL = 12700
  SLIDE_WIDTH = 9144000   # in points
  SLIDE_HEIGHT = 6858000  # in points
  SLIDE_ASPECT_RATIO = SLIDE_WIDTH.to_f / SLIDE_HEIGHT.to_f

  # Calculate offset, width, & height of the image on the slide
  def coordinates(image)
    width_pixels, height_pixels = get_image_dimensions(image)
    source_img_width = width_pixels * POINTS_PER_PIXEL
    source_img_height = height_pixels * POINTS_PER_PIXEL

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
  def get_image_dimensions(image)
     path = image.local_path_for(image.original_file_datastreams.first)
    `identify -format %wx%h "#{path}"`.split('x').map(&:to_i)
  end

  def export_dir
    timestamp = Time.now.strftime("%Y_%m_%d_%H%M%S")
    dir = File.join(PPTX_DIR, timestamp)
    FileUtils.mkdir_p(dir)
    dir
  end

  def pptx_file_name
    name = Array(title).first.underscore.gsub(' ', '_').gsub("'", '_')
    name + '.pptx'
  end

  def to_pptx
    deck = Powerpoint::Presentation.new

    deck.add_textual_slide title, description

    members.each do |image|
      image_path = image.local_path_for(image.original_file_datastreams.first)
      blank_title = ''
      deck.add_pictorial_slide blank_title, image_path, coordinates(image)
    end

    export_file_name = File.join(export_dir, pptx_file_name)
    deck.save(export_file_name)
    export_file_name
  end

end
