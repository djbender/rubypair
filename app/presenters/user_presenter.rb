require 'forwardable'

class UserPresenter
  extend Forwardable

  def_delegators :@user, :twitter, :github_login, :location, :email, :gravatar_id,
    :name, :remote_local_preference, :interests

  OFFSET_FOR_EARLIEST_AVAILABLE_TIME = 2 * 60 * 60

  def initialize(user, template)
    @user, @template = user, template
  end

  def render(&block)
    instance_eval &block
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

  def twitter_link
    "http://twitter.com/#{twitter}"
  end

  def github_link
    "http://github.com/#{github_login}"
  end

  def gravatar_image_url(size = 80)
    "http://www.gravatar.com/avatar.php?gravatar_id=#{gravatar_id}&size=#{size}"
  end

  def interest_links
    if interests && interests != ""
      interests.split(",")
               .map { |term| link_to_search_term(term) }
               .join(", ")
               .html_safe
    else
      "No interests. So sad..."
    end
  end

  def link_to_search_term(term)
    "<a href='/search?query=#{term.split(' ' ).map{|x| x.strip}.join('+')}'>#{term}</a>"
  end

  def pairing_preference
    case remote_local_preference
    when "Both"
      "Local or Remote"
    else
      remote_local_preference
    end
  end

  def delete_my_account_link
      link_to "Delete my account", user_path(current_user), :method => :delete, :confirm => "Are you sure that you want to delete your account?"
  end


  def pairing_preference_options
    User::REMOTE_LOCAL_PREFERENCES.map do |pref|
      case pref
      when "Both"
        ["Local or Remote", pref]
      else
        [pref, pref]
      end
    end
  end

  def available_now?
    earliest_available_time = Time.now - OFFSET_FOR_EARLIEST_AVAILABLE_TIME

    @user.last_available_time &&
      @user.last_available_time >= earliest_available_time
  end
end
