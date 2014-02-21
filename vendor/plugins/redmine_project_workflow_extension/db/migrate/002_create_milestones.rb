class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.column :project_id, :integer
      t.column :name, :string
      t.column :start_date, :datetime
      t.column :end_date, :datetime
      t.column :description, :text
    end

    add_index :milestones, :project_id
  end

  def self.down
    drop_table :milestones
  end
end
