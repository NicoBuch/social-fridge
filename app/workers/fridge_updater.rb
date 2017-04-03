class FridgeUpdater
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  include HTTParty

  base_uri Rails.application.secrets.fridges_api_url

  DEFAULT_PASSWORD = 'fridge-password'.freeze

  recurrence { hourly }

  def perform
    response = self.class.get('/storage_units')
    response.parsed_response.each do |attributes|
      fridge = Fridge.find_or_initialize_by(attributes.slice('email'))
      fridge.new_record? ? create_fridge(fridge, attributes) : update_fridge(fridge, attributes)
    end
  end

  private

  def create_fridge(new_fridge, attributes)
    new_fridge.update(fridge_attributes(attributes).merge(password: DEFAULT_PASSWORD))
  end

  def update_fridge(existing_fridge, attributes)
    existing_fridge.reload.update(fridge_attributes(attributes))
  end

  def fridge_attributes(attributes)
    attributes.slice('name', 'address').merge(fridge_api_id: attributes['id'])
  end
end
