#
class UsersController < ProtectedController
  skip_before_action :authenticate, only: [:login, :create]

  # POST '/signup'
  def create
    user = User.create(user_creds)
    if user.valid?
      render json: user, status: :created
    else
      head :bad_request
    end
  end

  # POST '/signin'
  def login
    creds = user_creds
    if (user = User.authenticate creds[:email],
                                 creds[:password])
      render json: user, serializer: UserLoginSerializer, root: 'user'
    else
      head :unauthorized
    end
  end

  # PATCH '/change-password/:id'
  def changepw
    if !current_user.authenticate(pw_creds[:old]) ||
       (current_user.password = pw_creds[:new]).blank? ||
       !current_user.save
      head :bad_request
    else
      head :no_content
    end
  end

  # DELETE '/signout/1'
  def logout
    if current_user == User.find(params[:id])
      current_user.logout
      head :no_content
    else
      head :unauthorized
    end
  end

  def index
    render json: User.all
  end

  def show
    user = User.find(params[:id])
    render json: user
  end

  def update
    head :bad_request
  end

  private

  def user_creds
    params.require(:credentials)
      .permit(:email, :password, :password_confirmation)
  end

  def pw_creds
    params.require(:password)
      .permit(:old, :new)
  end

  private :user_creds, :pw_creds
end
