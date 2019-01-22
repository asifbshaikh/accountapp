class State < ActiveRecord::Base
  belongs_to :country
  has_many :companies

  class << self

    def find_state_code(state_name)
      State.find_by_name(state_name).state_code
    end
    
    def list
      states = State.all
      states_arr=[]
      states.each do |state|
        state_name=[]
        state_name<<state.id
        state_name<<state.state_code
        state_name<<state.name
        states_arr<<state_name
      end
      states_arr
    end
end
end
