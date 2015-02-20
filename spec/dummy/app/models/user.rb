class User < ActiveRecord::Base
  structure do
    # Devise attributes
    encrypted_password      :string
    reset_password_token    :string
    reset_password_sent_at  :datetime
    remember_created_at     :datetime
    confirmation_sent_at    :datetime
    confirmed_at            :datetime
    confirmation_token      :string
    unconfirmed_email       :string
    sign_in_count           :integer, :default => 0
    current_sign_in_at      :datetime
    last_sign_in_at         :datetime
    current_sign_in_ip      :string
    last_sign_in_ip         :string

    email                   :string
    first_name              :string
    last_name               :string

    timestamps
  end
end
