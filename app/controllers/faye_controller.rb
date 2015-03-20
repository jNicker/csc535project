class FayeController < FayeRails::Controller
  channel '/signon' do
    monitor :publish do
      user = User.find(data["id"]).update_attributes(is_available: data["is_available"], is_online: true )
    end
  end

  channel '/signoff' do
    monitor :publish do
      user = User.find(data["id"]).update_attributes(is_available: false, is_online: false)
    end
  end

  channel '/startchat' do
    monitor :publish do
      User.find(data["ids"]).each do |user|
        user.update_attribute(:is_available, false)
      end
    end
  end

  channel '/endchat' do
    monitor :publish do
      User.find(data["ids"]).each do |user|
        user.update_attribute(:is_available, true)
      end
    end
  end

end
