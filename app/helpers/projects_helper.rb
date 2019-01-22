module ProjectsHelper

  def display_project(object)
    raw("<i class='icon-suitcase'></i><strong> Project: </strong>#{object.project.name}") unless object.project.blank?
  end

  def back_link(project)
    link_to raw('<i class="icon-mail-reply"> </i>'), projects_path, :class => 'btn btn-default btn-lg', :title=>"Back"
  end

  def total_invoices_amt(project)
    format_currency(project.invoices_total)
  end

  def total_expenses_amt(project)
    format_currency(project.expenses_total)
  end

  def total_receipts_amt(project)
    format_currency(project.receipts_total)
  end

  def total_purchases_amt(project)
    format_currency(project.purchases_total)
  end

end
