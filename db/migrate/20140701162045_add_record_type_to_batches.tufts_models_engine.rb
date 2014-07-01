# This migration comes from tufts_models_engine (originally 20140402184628)
class AddRecordTypeToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :record_type, :string
  end
end
