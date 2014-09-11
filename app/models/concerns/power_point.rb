require 'tempfile'
require 'open3'

module PowerPoint
  extend ActiveSupport::Concern

  PPTX_DIR = File.join(Rails.root, 'tmp', 'exports')

  SLIDE_WIDTH  = 720  # in pixels
  SLIDE_HEIGHT = 540  # in pixels
  SLIDE_ASPECT_RATIO = SLIDE_WIDTH.to_f / SLIDE_HEIGHT.to_f

  # Calculate offset, width, & height of the image on the slide
  def coordinates(image)
    source_img_width, source_img_height = get_image_dimensions(image)
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

  def pptx_base_file_name
    Array(title).first.underscore.gsub(' ', '_').gsub("'", '_')
  end

  def pptx_file_name
    pptx_base_file_name + '.pptx'
  end

  # TODO: Can/should this be moved to an initializer so that
  # we can parse the config file just once instead of every
  # time we want to generate a powerpoint file?
  def parse_java_config
    config_file = Rails.root.join('config', 'java.yml')
    config_erb = ERB.new(IO.read(config_file)).result(binding)
    Psych.load(config_erb)[Rails.env]
  end

  def classpath
    poi_files = ["poi-3.10.1-20140818.jar", "poi-examples-3.10.1-20140818.jar", "poi-excelant-3.10.1-20140818.jar", "poi-ooxml-3.10.1-20140818.jar", "poi-ooxml-schemas-3.10.1-20140818.jar", "poi-scratchpad-3.10.1-20140818.jar"]
    poi_ooxml_lib_files = ["dom4j-1.6.1.jar", "stax-api-1.0.1.jar", "xmlbeans-2.6.0.jar"]
    poi_lib_files = ["commons-codec-1.5.jar", "commons-logging-1.1.jar", "log4j-1.2.13.jar"]
    commons_io_files = ["commons-io-2.4.jar"]

    config = parse_java_config
    jars = poi_files.map {|jar| File.join(config['poi_dir'], jar) }
    jars = jars + poi_ooxml_lib_files.map {|jar| File.join(config['poi_ooxml_dir'], jar) }
    jars = jars + poi_lib_files.map {|jar| File.join(config['poi_lib_dir'], jar) }
    jars = jars + commons_io_files.map {|jar| File.join(config['commons_io_dir'], jar) }

    cp = jars.join(':')
    ".:#{config['class_files_dir']}:" + cp
  end


  # TODO: Handle the case where there is no data for a field
  def to_pptx
    export_file_name = Tempfile.new([pptx_base_file_name, '.pptx'], export_dir).path

    process = "java -cp #{classpath} Powerpoint"

    # Open a bi-directional connection to a Java process that
    # will generate the powerpoint file.  Send data to the Java
    # process and receive back either the name of the file that
    # was created or an error message.
    #
    Open3.popen2(process) do |stdin, stdout, wait_thr|
      # Send the name of the file we want to create
      stdin.puts export_file_name

      # Send the title and list of descriptions for the main title slide
      stdin.puts title
      desc = Array(description)
      stdin.puts desc.count
      desc.each { |d| stdin.puts d }

      # Tell the Java ppt generator how many image slides we want to make
      stdin.puts members.count.to_s

      # Send the data for each image slide
      members.each do |image|
        image_path = image.local_path_for(image.original_file_datastreams.first)
        stdin.puts image_path

        coords = coordinates(image)
        stdin.puts coords[:x]
        stdin.puts coords[:y]
        stdin.puts coords[:cx]
        stdin.puts coords[:cy]
      end

      # Read back the name of the output file from the Java ppt generator
      output_file = stdout.read

      # TODO:  Error handling
      # We expect output_file == export_file_name.
      # If it's not, something is wrong.
      # If the output_file contains the error_flag instead of
      # the output file name, something went wrong in the Java
      # code.
      # error_flag = /\AERROR:/
    end

    export_file_name
  end

end
