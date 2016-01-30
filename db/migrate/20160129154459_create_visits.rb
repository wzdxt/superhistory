class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.references :user, index: true
      t.references :page
      t.string :url
      t.datetime :open_time
      t.datetime :close_time

      t.timestamps null: false
    end
  end
end
