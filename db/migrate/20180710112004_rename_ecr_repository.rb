class RenameEcrRepository < ActiveRecord::Migration[5.1]
  def change
    rename_column :apps, :ecr_repository, :repository_name
  end
end
