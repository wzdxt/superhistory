class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url
      t.string :title
      t.text :brief_intro
      t.text :content

      t.timestamps null: false
    end
  end
end
