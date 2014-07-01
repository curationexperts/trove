# This migration comes from tufts_models_engine (originally 20140416160011)
class AddBehaviorToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :behavior, :string
  end
end
