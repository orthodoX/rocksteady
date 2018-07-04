class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps do |t|
      t.text :name, null: false, index: { unique: true }
      t.text :description
      t.text :ecr_repository, null: false
      t.text :env_template
      t.boolean :auto_deploy, default: false
      t.text :auto_deploy_branch, default: 'master'
      t.text :job_spec, null: false
      t.timestamps
    end
  end
end
