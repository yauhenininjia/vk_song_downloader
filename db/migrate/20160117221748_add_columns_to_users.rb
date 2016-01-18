class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string, default: 'local'
    add_column :users, :uid, :string
  end
end
