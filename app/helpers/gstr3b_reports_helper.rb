module Gstr3bReportsHelper

  def next_report_action(report, status_name)
    if status_name == "draft"
      link_to "populate report", edit_gstr3b_report_path(report), :class => "btn btn-xs btn-success"
    elsif status_name == "populated"
      link_to "populate report", edit_gstr3b_report_path(report)
    elsif status_name == "prepared"
      link_to "populate report", show_gstr3b_report_path(report)
    end      
  end

end
