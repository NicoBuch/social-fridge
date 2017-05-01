class DeviceTokenManager
  ALLOWED_DEVICES = %w(ios android).freeze

  DONATOR_APP_ARN = {
    ios: Rails.application.secrets.donator_sns_app_arn['ios']['arn'],
    android: Rails.application.secrets.donator_sns_app_arn['android']
  }.freeze

  VOLUNTEER_APP_ARN = {
    ios: Rails.application.secrets.volunteer_sns_app_arn['ios']['arn'],
    android: Rails.application.secrets.volunteer_sns_app_arn['android']
  }.freeze

  attr_reader :user, :device_token, :device_type

  def initialize(options = {})
    @user = options[:user]
    @device_token = options[:device_token].to_s.gsub(/\s+/, '')
    @device_type = options[:device_type]
  end

  def add_token
    return true if token_already_present?
    return false unless device_type_valid?
    user.device_tokens[device_token] = {
      'device_type' => device_type,
      'endpoint_arn' => service_endpoint[:endpoint_arn]
    }
    user.device_tokens_will_change!
    user.save
  end

  def delete_token
    return true unless token_already_present?
    push_service.delete_endpoint(endpoint_arn: user.device_tokens[device_token]['endpoint_arn'])
    user.device_tokens.delete(device_token)
    user.device_tokens_will_change!
    user.save
  end

  private

  def device_type_valid?
    ALLOWED_DEVICES.include? device_type
  end

  def token_already_present?
    user.device_tokens.key?(device_token)
  end

  def push_service
    @sns_client ||= Aws::SNS::Client.new
  end

  def service_endpoint
    app_arn = @user.volunteer? ? VOLUNTEER_APP_ARN : DONATOR_APP_ARN
    push_service.create_platform_endpoint(
      platform_application_arn: app_arn[device_type.to_sym],
      token: device_token
    )
  end
end
