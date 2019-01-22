class Gstr2Summary < ActiveRecord::Base
  belongs_to :company
  belongs_to :gstr_two

  STATUS = {processing: 0, updated: 1, final: 2, failed: 3}

  def processing?
    self.status == STATUS[:processing]
  end

  def processing
    update_attributes(:status => STATUS[:processing])
  end

  def failed
    update_attributes(:status => STATUS[:failed])
  end

  def update_summary(response)
    #Rails.logger.debug "Gstr2Summary::update_summary:: The response object received is #{response.inspect}"
    update_attributes(status: STATUS[:updated])
  end

end
