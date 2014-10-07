require 'rails_helper'

describe PowerPointCollectionExporter do
  let(:timestamp) { '2012_12_25_051545' }
  let(:export_dir) { File.join(PowerPointCollectionExporter::PPTX_DIR, timestamp) }

  let(:collection) { build(:course_collection) }
  before do
    xmas = Time.new(2012, 12, 25, 5, 15, 45, "+00:00")
    allow(Time).to receive(:now) { xmas }
  end

  subject { PowerPointCollectionExporter.new(collection) }


  it 'makes the export dir if it doesnt exist' do
    FileUtils.rm_rf(export_dir, secure: true)
    subject.export_dir
    expect(File).to exist(export_dir)
    FileUtils.rm_rf(export_dir, secure: true)
  end

  it 'has a name for the export file' do
    collection.title = "Student Research in the 1960's"
    expect(subject.pptx_file_name).to eq 'student_research_in_the_1960_s.pptx'
  end

  describe "#export" do
    before do
      collection.title = "Student Research in the 1960's"
      collection.save!
    end

    it 'generates the file and returns the file path' do
      export_file_path = subject.export

      expect(export_file_path.match(/student_research_in_the_1960_s.*.pptx/)).to_not be_nil
      expect(File).to exist(export_file_path)

      FileUtils.rm_rf(export_dir, secure: true)
    end
  end
end
