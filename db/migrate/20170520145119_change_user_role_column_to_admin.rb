class ChangeUserRoleColumnToAdmin < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.remove(:role)
    end
    add_column :users, :admin, :boolean, default: false
  end
end
