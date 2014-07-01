# This migration comes from tufts_models_engine (originally 20140403180704)
class AddMetadataFileToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :metadata_file, :string
  end
end
