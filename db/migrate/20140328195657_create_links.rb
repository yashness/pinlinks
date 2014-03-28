class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|      
      t.string  :actual_link
      t.string  :tags
      t.text  :description
      t.timestamps
    end
  end
end