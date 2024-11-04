module ApplicationHelper
  def show_header?
    !(controller_name == 'tops' && action_name == 'index')
  end
end