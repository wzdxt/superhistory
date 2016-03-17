class CreateVisit12Tables < ActiveRecord::Migration
  def up
    Visit.sub_classes[1..2].each do |clz|
      @connection = clz.connection
      create_table :visits do |t|
        t.references :user, index: true
        t.integer :page_id
        t.string :url, :limit => 1000
        t.datetime :open_time
        t.datetime :close_time

        t.timestamps null: false
      end
    end
    @connection = Visit.connection
  end

  def down
    Visit.sub_classes[1..2].each do |clz|
      @connection = clz.connection
      drop_table :visits
    end
    @connection = Visit.connection
  end
end
