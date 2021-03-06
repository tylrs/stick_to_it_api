class CreateHabits < ActiveRecord::Migration[7.0]
  def change
    create_table :habits do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.datetime :start_datetime

      t.timestamps
    end
  end
end
