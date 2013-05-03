require 'dressipi_agent'
class NewUserAgent < DressipiAgent

  transition from: :initial, to: :landing_page
  transition from: :landing_page, to: :signup
  transition from: :signup, to: :browsing 
  transition from: :browsing, to: [:body_shape, :personality, :colours, [:browse_category,6], [:finished,2], :maybenots, :likes]
  transition from: :body_shape, to: :browsing
  transition from: :personality, to: :browsing
  transition from: :browse_category, to: :browsing
  transition from: :colours, to: :browsing
  transition from: :likes, to: :browsing
  transition from: :maybenots, to: :browsing
end