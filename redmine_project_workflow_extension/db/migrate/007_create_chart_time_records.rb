class CreateChartTimeRecords < ActiveRecord::Migration
  def self.up
    # Create table for time records
    create_table :burndown_records do |t|
      t.integer :project_id
      t.datetime :day
      t.boolean :init_project, :default => false
      t.float :sub_time
      t.float :add_time
    end

    # Create index
    add_index :burndown_records, :project_id
  end

  def self.down
    drop_table :burndown_records
  end
end
