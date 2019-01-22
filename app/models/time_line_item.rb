class TimeLineItem < InvoiceLineItem
 belongs_to :invoice
  validates_presence_of :task_id, :amount 
  validate :task_account, :if => :task_id
  def task_account
    task_account = Task.find(task_id).sales_account_id
    if task_account.blank?
     errors[:task_account]<<"not found for #{Task.find(task_id).description}, please update your task link it with an account "
    end
  end
  def item_name
    task_id.blank? ? Account.find(account_id).name : Task.find(task_id).description
  end                            
end
