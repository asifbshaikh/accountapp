
namespace :gst_actions do 
  task :create_gst_action => :environment do 
    ActiveRecord::Base.transaction do  
      puts "in gst_action seed"
      CSV.foreach(File.join(Rails.root, 'resources', "GST-Action.csv"),:col_sep => ",", :skip_blanks => true, :headers => false, :encoding => 'utf-8') do |row|
        gst_action=GstAction.new(:gst_retrun_type =>row[0],:action =>row[1], 
          :version =>row[2],:url =>row[3],:description =>row[4])
        gst_action.save!
        puts "saved"
      end
    end
  end
end