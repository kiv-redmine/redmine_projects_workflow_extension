class AddProjectStartDatetime < ActiveRecord::Migration
  def self.up
    add_column :projects, :start_date, :datetime, :default => nil
  end

  def self.down
    remove_column :projects, :start_date
  end
end
