require 'jido/conjugator'

module Jido
  # Convenience method for Jido::Conjugator.load
  def Jido.load lang, options = {}
    Jido::Conjugator.new lang, options
  end
end