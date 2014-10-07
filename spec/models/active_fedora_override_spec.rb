require 'rails_helper'

describe "Overriding the find method" do
  let!(:course_collection) { create(:course_collection) }
  it "should raise an error when finding a course_collection" do
    expect { PersonalCollection.find(course_collection.pid) }.to raise_error Tufts::ModelNotAsserted
  end
end
