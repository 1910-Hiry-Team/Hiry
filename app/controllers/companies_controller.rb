class CompaniesController < ApplicationController
  def show
    @company = Company.find(params[:id])
  end

  def article_params
    params.require(:company).permit(:name, :employee_number, :industry, :location, :description, photo: [])
  end
end
