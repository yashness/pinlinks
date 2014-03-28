class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string  :name
      t.string  :tags
      t.timestamps
    end
  end
end
