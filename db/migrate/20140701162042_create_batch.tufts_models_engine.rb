# This migration comes from tufts_models_engine (originally 20140317145954)
class CreateBatch < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.references :creator
      t.string :template_id
      t.string :type
      t.text :pids
    end
  end
end
