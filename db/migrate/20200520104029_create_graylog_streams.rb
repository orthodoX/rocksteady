class CreateGraylogStreams < ActiveRecord::Migration[5.1]
  def change
    create_table :graylog_streams, id: :string do |t|
      t.string :name, null: false
      t.string :rule_value, null: false
      t.string :index_set_id, null: false
      t.belongs_to :app, foreign_key: true

      t.timestamps
    end
  end
end
