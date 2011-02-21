require 'jido/conjugator'

# Container for the conjugator. Maybe other stuff will go in here later..
module Jido
  # Convenience method for Jido::Conjugator.load
  def Jido.load lang, options = {}
    Jido::Conjugator.new lang, options
  end
end