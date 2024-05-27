module ApplicationHelper
  def show_header?
    !(controller_name == 'top' && action_name == 'index')
  end
  def border_class(total_gifts)
    case total_gifts
    when 0
      "border-danger"
    when 1..50
      "border-warning"
    when 51..100
      "border-info"
    else
      "border-success"
    end
  end
end