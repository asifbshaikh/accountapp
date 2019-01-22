Paperclip::Attachment.interpolations[:company_id] = proc do |attachment, style|
  attachment.instance.company_id
end
