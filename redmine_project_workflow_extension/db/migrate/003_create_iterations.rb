class CreateIterations < ActiveRecord::Migration
  def self.up
    create_table :iterations do |t|
      t.column :project_id, :integer
      t.column :name, :string
      t.column :start_date, :date
      t.column :end_date, :date
      t.column :description, :text
    end

    add_index :iterations, :project_id
  end

  def self.down
    drop_table :iterations
  end
end
