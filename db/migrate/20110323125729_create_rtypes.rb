class CreateRtypes < ActiveRecord::Migration
  def self.up
    create_table :rtypes do |t|
      t.string :name
      t.text :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :rtypes
  end
end
