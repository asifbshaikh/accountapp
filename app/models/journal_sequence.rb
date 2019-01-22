class JournalSequence < ActiveRecord::Base
	belongs_to :company

	def journal_number
		#JournalSequence.increment_counter(:journal_sequence, self.id)
		self.reload
		(self.journal_sequence).to_s.rjust(3, '0')
	end
    
    def increment_counter
		JournalSequence.increment_counter(:journal_sequence, self.id)
    end
    
    # def decrement_counter
    # 	JournalSequence.decrement_counter(:journal_sequence,self.id)
    # end
 end


