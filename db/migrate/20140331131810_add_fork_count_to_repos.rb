class AddForkCountToRepos < ActiveRecord::Migration
  def change
  	add_column :repos, :fork_counts, :integer , :default => 0
  end
end
