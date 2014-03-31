class AddIndicesToTables < ActiveRecord::Migration
  def change
	add_index :links, :repo_id
	add_index :links, :id
	add_index :links, :tags
	add_index :repos, :id
	add_index :repos, :name
	add_index :repos, :tags
  end
end
