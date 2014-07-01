# This migration comes from tufts_models_engine (originally 20140320192134)
class AddCreatedAtToBatches < ActiveRecord::Migration
  def change
    change_table(:batches) do |t|
      t.column :created_at, :datetime
    end
  end
end
