class AddDisplayChoiceToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :display_choice, :string
  end
end
