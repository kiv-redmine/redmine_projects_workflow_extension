class AddMilestonesAndIterationsToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :milestone_id, :integer, :default => nil
    add_column :issues, :iteration_id, :integer, :default => nil

    add_index :issues, :milestone_id
    add_index :issues, :iteration_id
  end

  def self.down
    remove_column :issues, :milestone_id
    remove_column :issues, :iteration_id
  end
end
