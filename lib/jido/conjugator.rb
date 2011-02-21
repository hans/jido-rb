require 'rubygems'
require 'nokogiri'

module Jido
  class Conjugator
    
    # The language used in this Conjugator instance.
    # Verbs given to this instance are expected to be in this language.
    # This instance will conjugate verbs according to rules of this language.
    attr_reader :lang
    
    # Create a Jido::Conjugator instance.
    # Load and parse the corresponding XML data file, and parse any provided options.
    # 
    # Accepted options (keys of the `options` hash should be symbols, not strings):
    # * <code>:forms</code>: Only return conjugations for the given verb forms / tenses.
    #     Jido::Conjugator.new 'fr', :forms => %w{prs futant}
    # * <code>:paradigms</code>: Only return conjugations for the given paradigms.
    #     Jido::Conjugator.new 'fr', :paradigms => [{:person => '1', :quant => 'sg'}]
    # * <code>:forms_except</code>: Return all conjugations except those for the given verb forms / tenses.
    #     Jido::Conjugator.new 'fr', :forms_except => 'prs'
    # * <code>:paradigms_except</code>: Return all conjugations except those for the given paradigms.
    #     Jido::Conjugator.new 'fr', :paradigms_except => [{:person => '3', :quant => 'pl'}]
    def initialize lang, options = {}
      @lang = lang
      
      data_file_path = File.join(File.dirname(__FILE__), 'data', lang + '.xml')
      data_file = nil
      
      begin
        data_file = open data_file_path, 'r'
      rescue IOError
        raise "There was an error loading the data file for the given language."
      end
      
      @data = Nokogiri.XML data_file, nil, 'UTF-8'
      data_file.close

      self.options = options
    end
    
    # Change the options for this Conjugator instance.
    # See Conjugator#new for possible options.
    def options= options
      @options = options
      @forms = check_for_list_option :forms
      @forms_except = check_for_list_option(:forms_except) || [ ]
      @paradigms = check_for_list_option :paradigms
      @paradigms_except = check_for_list_option(:paradigms_except) || [ ]
    end

    # Interpret the provided option when a list is expected.
    # Used to provide functionality like:
    #     jido.conjugate 'be', :form => 'prs'
    #     jido.conjugate 'be', :form => %w{prs pst prf}
    def check_for_list_option option_name
      return nil if @options[option_name].nil?

      return [@options[option_name]] if @options[option_name].is_a?(String)
      return @options[option_name] if @options[option_name].is_a?(Array)

      raise "Invalid data type provided for option #{option_name}: a list was expected. Please provide a single string element or an array of strings."
    end
    
    # Get the possible verb form IDs for any conjugated verb.
    #   Jido.load('fr').forms     # => ['PRS', 'PCOMP', 'IMP', ...]
    def forms
      if @forms.nil?
        @forms = []
        @data.xpath('/verbs/meta/forms/form').each do |form|
          @forms << form.text
        end
      end
      
      @forms
    end
    
    def forms= forms
      @forms = check_for_list_option :forms
    end
    
    def fallbacks
      if @fallbacks.nil?
        @fallbacks = []
        @data.xpath('/verbs/meta/fallbacks/fallback').each do |fallback|
          @fallbacks << {:regex => fallback['regex'], :ref => fallback['ref']}
        end
      end
      
      @fallbacks
    end
    
    def paradigms
      if @paradigms.nil?
        @paradigms = []
        @data.xpath('/verbs/meta/paradigms/paradigm').each do |paradigm|
          @paradigms << {:person => paradigm['person'], :quant => paradigm['quant']}
        end
      end
      
      @paradigms
    end
    
    def paradigms= paradigms
      @paradigms = check_for_list_option :paradigms
    end
    
    # Hmm.. what does this do.. ?
    def conjugate verb
      @current_el = @data.at_xpath "/verbs/verb[@word='#{verb}']"
      @current_el = get_fallback_for_verb(verb) if @current_el.nil?
      return false if @current_el.nil?
      
      ret = {}
      @current_el_parents = [] # array of parents of the element, sorted by priority - parents earlier in the array will be picked over later ones
      store_parents @current_el # populate the parents array = @current_el['inherit'].nil? ? nil : @data.at_xpath("/verbs/verbset[@id='#{@current_el['inherit']}']")
      
      group = nil; group_search = nil
      forms.each do |form|
        next if @forms_except.include?(form)
        ret[form] = {}
        
        group_search = "group[@id='#{form}']"
        group = search_current_el group_search
        
        # grab modifier elements and extract their values
        group_prepend_el = group.at_xpath('prepend'); group_append_el = group.at_xpath('append'); group_mod_el = group.at_xpath('mod'); group_endlength_el = group.at_xpath('endlength')
        group_prepend = group_prepend_el.nil? ? nil : group_prepend_el.text
        group_append = group_append_el.nil? ? nil : group_append_el.text
        group_mod = group_mod_el.nil? ? nil : {:match => group_mod_el['match'], :search => group_mod_el['search'], :replace => group_mod_el['replace']}
        group_endlength = group_endlength_el.nil? ? nil : group_endlength_el.text.to_i
        
        pdgmgroup = nil; pdgmgroup_search = nil
        paradigm = nil; paradigm_search = nil
        paradigms.each do |paradigm|
          next if @paradigms_except.include?(paradigm)

          pdgmgroup_search = "group[@id='#{form}']/pdgmgroup[@id='#{paradigm[:person]}']"
          pdgmgroup = search_current_el pdgmgroup_search
          
          # skip this paradigm group if the "ignore" attribute is set
          next unless pdgmgroup['ignore'].nil?
          
          # grab modifier elements and extract their values
          # if unset, try to inherit from parent group
          pdgmgroup_prepend_el = pdgmgroup.at_xpath('prepend'); pdgmgroup_append_el = pdgmgroup.at_xpath('append'); pdgmgroup_mod_el = pdgmgroup.at_xpath('mod'); pdgmgroup_endlength_el = pdgmgroup.at_xpath('endlength')
          pdgmgroup_prepend = pdgmgroup_prepend_el.nil? ? group_prepend : pdgmgroup_prepend_el.text
          pdgmgroup_append = pdgmgroup_append_el.nil? ? group_append : pdgmgroup_append_el.text
          pdgmgroup_mod = pdgmgroup_mod_el.nil? ? group_mod : {:match => pdgmgroup_mod_el['match'], :search => pdgmgroup_mod_el['search'], :replace => pdgmgroup_mod_el['replace']}
          pdgmgroup_endlength = pdgmgroup_endlength_el.nil? ? group_endlength : pdgmgroup_endlength_el.text.to_i
          
          paradigm_search = "group[@id='#{form}']/pdgmgroup[@id='#{paradigm[:person]}']/paradigm[@id='#{paradigm[:quant]}']"
          paradigm_el = search_current_el paradigm_search
          
          # skip this paradigm if the "ignore" attribute is set
          next unless paradigm_el['ignore'].nil?
          
          # grab modifier elements and extract their values
          # if unset, try to inherit from parent paradigm group
          paradigm_prepend_el = paradigm_el.at_xpath('prepend'); paradigm_append_el = paradigm_el.at_xpath('append'); paradigm_mod_el = paradigm_el.at_xpath('mod'); paradigm_endlength_el = paradigm_el.at_xpath('endlength')
          prepend = paradigm_prepend_el.nil? ? pdgmgroup_prepend : paradigm_prepend_el.text
          append = paradigm_append_el.nil? ? pdgmgroup_append : paradigm_append_el.text
          mod = paradigm_mod_el.nil? ? pdgmgroup_mod : {:match => paradigm_mod_el['match'], :search => paradigm_mod_el['search'], :replace => paradigm_mod_el['replace']}
          
          endlength = paradigm_endlength_el.nil? ? pdgmgroup_endlength : paradigm_endlength_el.text.to_i
          endlength = 0 if endlength.nil? or endlength < 0
          
          # make a copy of verb to run the modifiers on
          modded_verb = verb
          
          # chop n chars from the end of the string, based on the <endlength> modifier
          modded_verb = modded_verb[0 ... ( modded_verb.length - endlength )] unless endlength.nil?
          
          # <mod> modifier (regex replacement)
          unless mod.nil?
            case mod[:match]
            when 'first' then modded_verb.sub!(mod[:search], mod[:replace])
            when 'all' then modded_verb.gsub!(mod[:search], mod[:replace])
            end
          end
          
          # <append> and <prepend> modifiers
          modded_verb = ( prepend.nil? ? '' : prepend ) + modded_verb + ( append.nil? ? '' : append )
          ret[form][paradigm[:person] + paradigm[:quant]] = modded_verb
        end
      end
      
      @current_el = nil
      @current_el_inheritor = nil
      
      ret
    end
    
    # Find all parents of a given verb / verbset, and store them in @current_el_parents
    # (if a verb / verbset #1 inherits a verb / verbset #2, then #2 is the parent of #1)
    # 
    # Structure note: verbs are "final" objects. Verbs cannot be inherited; they are always at the bottom of a hierarchy.
    # Verbsets can inherit / be inherited by other verbsets, and verbs can inherit verbsets.
    # In other words.. verb = final class, verb set = abstract class
    # 
    # Yay recursion :)
    def store_parents el
      return if el['inherit'].nil?
      
      inherited_el = @data.at_xpath "/verbs/verbset[@id='#{el['inherit']}']"
      @current_el_parents << inherited_el
      store_parents inherited_el
    end
    
    # Search each parent of some verb for a given element.
    # Used for rule inheritance.
    def search_current_el xpath
      # try to find the rule in the current verb
      desired_el = @current_el.at_xpath xpath
      return desired_el unless desired_el.nil?
      
      # check all the verb's parents, walking up the hierarchy
      @current_el_parents.each do |parent|
        desired_el = parent.at_xpath xpath
        return desired_el unless desired_el.nil?
      end
      
      nil
    end
    
    # Find a fallback verbset whose regex matches the given verb.
    # Used when an exact verb element cannot be matched with an input verb (that is, in most cases).
    def get_fallback_for_verb verb
      fallbacks.each do |fallback|
        if verb.match fallback[:regex]
          ret = @data.at_xpath "/verbs/verbset[@id='#{fallback[:ref]}']"
          return ret
        end
      end
      
      false
    end
    
    # Return a string describing the instance.
    def inspect
      "#<Conjugator @lang=\"#{@lang}\">"
    end
  end
end
