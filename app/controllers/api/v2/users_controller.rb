class Api::V2::UsersController < ApplicationController
  skip_before_action :authorize_request, only: [:create]
  before_action :find_user, except: %i[create index]

  # GET /users
  def index
    users = User.all
    render json: users, status: :ok
  end

  # GET /users/{username}
  def show
    render json: @user, status: :ok
  end

  # POST /users
  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # PUT /users/{username}
  def update
    unless @user.update(user_params)
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /users/{username}
  def destroy
    @user.destroy
  end

  private

  def find_user
    @user = User.find params[:id]
  rescue ActiveRecord::RecordNotFound
    render json: { errors: "User not found" }, status: :not_found
  end

  def user_params
    params.permit(
      :avatar, :name, :username, :email, :password, :password_confirmation
    )
  end
end
