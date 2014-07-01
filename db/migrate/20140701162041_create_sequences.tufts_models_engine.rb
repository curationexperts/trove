# This migration comes from tufts_models_engine (originally 20131108160030)
class CreateSequences < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.column :value, :integer, default: 0
    end
  end
end
