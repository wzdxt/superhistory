class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.references :user, index: true
      t.integer :page_id
      t.string :url, :limit => 1000
      t.datetime :open_time
      t.datetime :close_time

      t.timestamps null: false
    end
  end
end
