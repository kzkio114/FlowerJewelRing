module ApplicationHelper
  def show_header?
    !(controller_name == 'top' && action_name == 'index')
  end
end