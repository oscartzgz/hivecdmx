# app/controllers/admin/users_controller.rb
module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :edit, :update, :destroy ]

    def index
      @users = User.order(:name)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_users_path, notice: "Usuario creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attrs = user_params
      attrs.delete(:password) if attrs[:password].blank?
      attrs.delete(:password_confirmation) if attrs[:password_confirmation].blank?
      if @user.update(attrs)
        redirect_to admin_users_path, notice: "Usuario actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "Usuario eliminado."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :password, :password_confirmation, :role)
    end
  end
end
