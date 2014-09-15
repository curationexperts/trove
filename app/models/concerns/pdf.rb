module Pdf
  extend ActiveSupport::Concern

  def to_pdf
    ppt_file = to_pptx
    directory = File.dirname(ppt_file)
    cmd = "#{path_to_libreoffice} --headless --invisible --convert-to pdf --outdir #{directory} #{ppt_file}"
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
end
