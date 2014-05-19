class AddProjectEndDatetime < ActiveRecord::Migration
  def self.up
    add_column :projects, :end_date, :date, :default => nil
  end

  def self.down
    remove_column :projects, :end_date
  end
end
