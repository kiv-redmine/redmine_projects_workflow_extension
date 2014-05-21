class MigrateTotalTimeToProject < ActiveRecord::Migration
  def self.up
    remove_column :burndown_records, :init_project
    add_column :projects, :total_estimated_time, :float, :default => 0.0
  end
  def self.down
    add_column :burndown_records, :init_project, :boolean, :default => false
    remove_column :projects, :total_estimated_time
  end
end
