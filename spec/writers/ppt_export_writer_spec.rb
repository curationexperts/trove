require 'rails_helper'

describe '#coordinates' do
  subject { PptExportWriter.new(double, $stdout, 'tmp/test.pptx') }
  let(:coords) { subject.send :coordinates, double }

  context 'when source image is the same size as the slide' do
    before { expect(subject).to receive(:get_image_dimensions).and_return([width, height]) }
    let(:width) { PptExportWriter::SLIDE_WIDTH }
    let(:height) { PptExportWriter::SLIDE_HEIGHT }

    it 'returns the max page width, height and zero offset' do
      expect(coords[:x]).to eq 0
      expect(coords[:y]).to eq 0
      expect(coords[:w]).to eq width
      expect(coords[:h]).to eq height
    end
  end

  context 'when the image is wider than it is tall' do
    before { expect(subject).to receive(:get_image_dimensions).and_return([width, height]) }

    let(:width) { PptExportWriter::SLIDE_WIDTH * 2 }
    let(:height) { width / 10 }
    let(:expected_width) { PptExportWriter::SLIDE_WIDTH }
    let(:expected_height) { expected_width / 10 }

    it 'returns max width, scales the height, and chooses y position to center the image' do
      expect(coords[:x]).to eq 0
      expect(coords[:y]).to eq PptExportWriter::SLIDE_HEIGHT/2 - expected_height/2
      expect(coords[:w]).to eq expected_width
      expect(coords[:h]).to eq expected_height
    end
  end

  context 'when the image is taller than it is wide' do
    before { expect(subject).to receive(:get_image_dimensions).and_return([width, height]) }
    let(:height) { PptExportWriter::SLIDE_HEIGHT / 5 }
    let(:width) { height / 2 }
    let(:expected_height) { PptExportWriter::SLIDE_HEIGHT }
    let(:expected_width) { expected_height / 2 }

    it 'returns max height, scales the width, and chooses x position to center the image' do
      expect(coords[:x]).to eq PptExportWriter::SLIDE_WIDTH/2 - expected_width/2
      expect(coords[:y]).to eq 0
      expect(coords[:w]).to eq expected_width
      expect(coords[:h]).to eq expected_height
    end
  end
end
