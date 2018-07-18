class AddAppImageSourceField < ActiveRecord::Migration[5.1]
  def change
    add_column :apps, :image_source, :text, null: false, default: :ecr
  end
end
