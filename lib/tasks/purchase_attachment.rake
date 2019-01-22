
# namespace :purchase_attachment do
  
#   #This task should only be run once
#   task :update => :environment do
#     count_success=0
#     count_fail=0
#      @purchases= Purchase.where('uploaded_file_file_name !=?','')
#      count=Purchase.where('uploaded_file_file_name !=?','').count
#      @purchases.each do |purchases|

#       purchase_attachment= PurchaseAttachment.new(:company_id=>purchases.company_id,:user_id=>purchases.created_by,:voucher_id=>purchases.id,:uploaded_file_file_name=>purchases.uploaded_file_file_name,:uploaded_file_content_type=>purchases.uploaded_file_content_type,
#         :uploaded_file_file_size=>purchases.uploaded_file_file_size,
#         :uploaded_file_updated_at=>purchases.uploaded_file_updated_at)
#       if purchase_attachment.save
#         count_success+=1
#         puts "updated file for #{purchases.id}"
#       else
#         count_fail+=1
#          puts "updated file failed for #{purchases.id}"
#       end

#      end
#      puts "updated: #{count_success}, failed : #{count_fail} out of #{count}"
#   end
  
# end


