module HorizontalBalanceSheetHelper
	def user_branch_id
		params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
	end
end
