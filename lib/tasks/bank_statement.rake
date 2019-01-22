namespace :bank_statement do 
	task :create_header => :environment do 
		ActiveRecord::Base.transaction do 
			
			puts"Creating header..."

			     header_line_items=[]
			     # header_line_items << BankStatementHeaders.new(:bank_id => 3,:header_1=>'Date',:header_2 => 'Narration', :header_3 => 'Chq./Ref.No.', :header_4 => 'Value Dt', :header_5 => 'Withdrawal Amt.', :header_6 => 'Deposit Amt.', :header_7 => 'Closing Balance', :date_format => '%d/%m/%y' )
			     # header_line_items << BankStatementHeaders.new(:bank_id => 1,:header_1=>'Txn Date',:header_2 =>'Description', :header_3 => 'Ref No./Cheque No.', :header_4 => 'Value Date', :header_5 => 'Debit', :header_6 => 'Credit', :header_7 => 'Balance', :date_format => '%d-%b-%y' )
			     # header_line_items << BankStatementHeaders.new(:bank_id => 5,:header_1 =>'Txn Date', :header_2 => 'Description', :header_3 => 'ChequeNo.', :header_4 => 'Debit', :header_5 => 'Cr/Dr', :header_6 => 'Amount(INR)',:header_7 => 'Balance(INR)', :date_format => '%d/%m/%y' )
			     # header_line_items << BankStatementHeaders.new(:bank_id => 8,:header_1 =>'Tran Date', :header_2 => 'CHQNO', :header_3 => 'PARTICULARS',:header_4 => 'DR', :header_5 => 'CR',:header_6 => 'BAL',:header_7=> 'SOL',:date_format => '%d-%m-%Y')
			     # header_line_items << BankStatementHeaders.new(:bank_id => 2,:header_1 =>'DATE', :header_2 => 'MODE', :header_3 => 'PARTICULARS',:header_4 => 'DEPOSITS', :header_5 => 'WITHDRAWALS',:header_6 => 'BALANCE',:header_7=> 'EMPTY',:date_format => '%d-%m-%Y')
			     # header_line_items << BankStatementHeaders.new(:bank_id => 7,:header_1 =>'Txn Date', :header_2 => 'Description', :header_3 => 'Credit',:header_4 => 'Debit', :header_5 => 'Available Balance',:header_6 => 'EMPTY',:header_7=> 'EMPTY',:date_format => '%d/%m/%Y')
			     # header_line_items << BankStatementHeaders.new(:bank_id => 4,:header_1 =>'Txn. Date', :header_2 => 'Particulars', :header_3 => 'Chq No.',:header_4 => 'Txn. Type', :header_5 => 'Withdrawl',:header_6 => 'Deposit',:header_7=> 'Balance',:date_format => '%d/%m/%Y')
			     header_line_items << BankStatementHeaders.new(:bank_id => 9,:header_1 =>'Value Date', :header_2 => 'Txn Posted Date', :header_3 => 'ChequeNo.',:header_4 => 'Description', :header_5 =>'Cr/Dr' ,:header_6 => 'Transaction Amount(INR)' ,:header_7=> 'Available Balance(INR)' ,:date_format => '%d-%m-%Y')
			     header_line_items.each do |line_item|
			     	line_item.save!
			     end

		end
	end	
end