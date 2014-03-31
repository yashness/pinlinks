class CreateUserForks < ActiveRecord::Migration
  def change
    create_table :user_forks do |t|
	  t.belongs_to :user
	  t.belongs_to :repo
      t.timestamps
    end
  end
end
