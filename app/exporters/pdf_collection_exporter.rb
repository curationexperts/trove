require 'shellwords'

class PdfCollectionExporter < CollectionExporter

  def initialize(collection)
    @collection = collection
  end

  def export
    ppt_file = pptx_exporter.export
    directory = File.dirname(ppt_file)
    cmd = "#{path_to_libreoffice} --headless --invisible --convert-to pdf --outdir #{directory} #{Shellwords.escape(ppt_file)}"
    out = `#{cmd} 2>&1` # use backticks so that stdout is captured and not printed
    if $?.success?
      ppt_file.sub(/pptx\z/, 'pdf')
    else
      raise "There was an error generating the PDF file: #{out}"
    end
  end

  def path_to_libreoffice
    "soffice"
  end

  def pdf_file_name
    export_base_file_name + '.pdf'
  end

  def pptx_exporter
    @pptx_exporter ||= PowerPointCollectionExporter.new(@collection)
  end
end
