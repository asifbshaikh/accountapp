class UserInformationsController < ApplicationController
def update
  # @user = User.find_by_id(params[:id])
    @user_information = UserInformation.find_by_id(params[:id])
    respond_to do |format|
       if @user_information.update_attributes(params[:user][:user_information_attributes])
        format.html { redirect_to(users_path, :notice => 'Salary structure was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @department.errors, :status => :unprocessable_entity }
        format.json{respond_with_bip(@duser_information) }
      end
    end
  end

end