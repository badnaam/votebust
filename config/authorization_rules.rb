authorization do
    role :user do
        has_permission_on :users,  :to => [:edit, :update] do
            # user refers to the current_user when evaluating
            if_attribute :id => is {user.id}
        end
        has_permission_on :vote_topics, :to => [:confirm_vote] do
            if_attribute :user_id => is {user.id}
        end
        has_permission_on :vote_topics, :to => [:edit, :update] do
            if_attribute :user_id => is {user.id}
        end
        has_permission_on :vote_item do
            to :edit, :update
            if_permitted_to :update, :vote_topic
        end
    end

    role :admin do
        has_permission_on [:user, :vote_topic], :to => [:index, :show, :new, :create, :update, :destroy, :edit, :deactivate, :activate]
    end
end
