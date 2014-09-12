class PptExportWriter

  attr_reader :out, :collection

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
      metadata << "Creator: #{image.creator.join("\r")}" if image.creator.present?
      metadata << "Description: #{image.description.join("\r")}" if image.description.present?
      metadata << "Date: #{image.date_created.join("\r")}" if image.date_created.present?
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
      collection.members.map { |member|
        next unless member.respond_to?(:local_path_for)
        path = member.local_path_for(TuftsImage.default_content_ds)
        File.exists?(path) ? [member, path] : [member, nil]
      }.compact
    end

end
