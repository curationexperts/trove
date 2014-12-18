require 'rails_helper'

describe PdfCollectionExporter do
  let(:timestamp) { '2012_12_25_051545' }
  let(:export_dir) { File.join(PowerPointCollectionExporter::PPTX_DIR, timestamp) }

  let(:collection) { build(:course_collection) }
  before do
    xmas = Time.new(2012, 12, 25, 5, 15, 45, "+00:00")
    allow(Time).to receive(:now) { xmas }
  end

  subject { PdfCollectionExporter.new(collection) }

  it 'has a name for the export file', :exporter => 'true'  do
    collection.title = "Student Research in the 1960's"
    expect(subject.pdf_file_name).to eq 'student_research_in_the_1960_s.pdf'
  end

  context "when generating the file" do
    before { collection.update(title: "Student Research in the 1960's") }
    after { FileUtils.rm_rf(subject.pptx_exporter.export_dir, secure: true) }

    it 'generates the file and returns the file path', :exporter => 'true' do
      export_file_path = subject.export

      expect(export_file_path.match(/student_research_in_the_1960_s.*.pdf/)).to_not be_nil
      expect(File.exist?(export_file_path)).to eq true
    end
  end
end
