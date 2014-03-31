class AddPrivateColumnInRepo < ActiveRecord::Migration
  def up
  	add_column :repos, :is_private, :boolean , :default => false
  end

  def down
  	remove_column :repos, :is_private
  end
end
