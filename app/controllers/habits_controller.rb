class HabitsController < ApplicationController
  before_action :authorize_request
  before_action :find_user

  def index
  end

  def create
  end

  def show
  end

  def update
  end

  def destroy
  end

  private

  def find_user
    @user = User.find_by id: params[:id]
  rescue ActiveRecord::RecordNotFound
    render json: { errors: 'User not found' }, status: :not_found
  end
end
