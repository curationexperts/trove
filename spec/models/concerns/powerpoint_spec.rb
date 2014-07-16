require 'rails_helper'

class TestImage
  include PowerPoint

  def initialize(width, height)
    @width = width
    @height = height
  end

  def get_image_dimensions(image)  # stub the method
    [@width, @height]
  end
end


describe '#coordinates' do
  subject { TestImage.new(width, height) }

  context 'when source image is the same size as the slide' do
    let(:width) { TestImage::SLIDE_WIDTH }
    let(:height) { TestImage::SLIDE_HEIGHT }

    it 'returns the max page width, height and zero offset' do
      coords = subject.coordinates(double)
      expect(coords[:x]).to eq 0
      expect(coords[:y]).to eq 0
      expect(coords[:cx]).to eq width
      expect(coords[:cy]).to eq height
    end
  end

  context 'when the image is wider than it is tall' do
    let(:width) { TestImage::SLIDE_WIDTH * 2 }
    let(:height) { width / 10 }
    let(:expected_width) { TestImage::SLIDE_WIDTH }
    let(:expected_height) { expected_width / 10 }

    it 'returns max width, scales the height, and chooses y position to center the image' do
      coords = subject.coordinates(double)
      expect(coords[:x]).to eq 0
      expect(coords[:y]).to eq TestImage::SLIDE_HEIGHT/2 - expected_height/2
      expect(coords[:cx]).to eq expected_width
      expect(coords[:cy]).to eq expected_height
    end
  end

  context 'when the image is taller than it is wide' do
    let(:height) { TestImage::SLIDE_HEIGHT / 5 } 
    let(:width) { height / 2 }
    let(:expected_height) { TestImage::SLIDE_HEIGHT }
    let(:expected_width) { expected_height / 2 }

    it 'returns max height, scales the width, and chooses x position to center the image' do
      coords = subject.coordinates(double)
      expect(coords[:x]).to eq TestImage::SLIDE_WIDTH/2 - expected_width/2
      expect(coords[:y]).to eq 0
      expect(coords[:cx]).to eq expected_width
      expect(coords[:cy]).to eq expected_height
    end
  end
end
