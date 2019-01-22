require 'active_support/ordered_hash'

class ReimbursementNoteService

  #create a new Reimbursement Note
  ##Post note to ledger
  #update a new Reimbursement Note
  ##Update note in ledger
  #Send Reimbursement Note to Customer/Vendor
  #Delete note

  def post_new_note(company, current_user, financial_year, remote_ip_request, rimb_note)
    rimb_note.company_id = company.id
    current_user.branch_id = nil ? rimb_note.branch_id = nil : rimb_note.branch_id = current_user.branch_id
    rimb_note.created_by = current_user.id
    rimb_note.reimbursement_note_line_items.each do |line_item|
      rimb_note.amount += line_item.amount
    end
    if rimb_note.valid?
      rimb_note.save_with_ledgers
      rimb_note.register_user_action(remote_ip_request, 'created')
      true
    else
      false
    end
  end

  def update_note(company, current_user, financial_year, remote_ip_request, rimb_note, params)
    rimb_note.update_attributes(params[:reimbursement_note])
    rimb_note.amount = 0
    rimb_note.reimbursement_note_line_items.each do |line_item|
      rimb_note.amount += line_item.amount
    end
    if rimb_note.valid?
      rimb_note.update_and_post_ledgers
      rimb_note.register_user_action(remote_ip_request, 'updated')
      true
    else
      false
    end
  end

  def delete_note(company, current_user, remote_ip_request, params)
    rimb_note = company.reimbursement_notes.find(params)
    if rimb_note.delete(current_user)
      rimb_note.register_user_action(remote_ip_request, 'deleted')
      true
    else
      false
    end
  end

  def email_reimbursement_note_to_party()

  end


  def return_previous_form
    return @messages
  end
end
