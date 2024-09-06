class AddDefaultToDisplayChoiceInConsultations < ActiveRecord::Migration[7.1]
  def change
    change_column :consultations, :display_choice, :string, default: 'name'
  end
end
