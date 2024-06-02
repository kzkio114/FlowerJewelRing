class AddCompletedToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :completed, :boolean
  end
end
