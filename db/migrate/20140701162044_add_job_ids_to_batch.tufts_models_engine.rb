# This migration comes from tufts_models_engine (originally 20140325210817)
class AddJobIdsToBatch < ActiveRecord::Migration
  def change
    change_table(:batches) do |t|
      t.column :job_ids, :text
    end
  end
end
