# encoding: utf-8
#
#  = Language
#
#  This model groups all the translations for a single locale.
#
#  == Attributes
#
#  locale::     Official locale string, e.g., "en-US".
#  name::       Name of the language in that language, e.g., "English" or "Español".
#  order::      Latinized version of name of language, e.g., "Russkii" or "Ellenika".
#  official::   Set to true for English: this is the fall-back language for missing translations.
#  beta::       If true, this will not be shown in the list of available languages.
#
#  == Localization and export files
#
#  Translation strings are exported to two sets of files.  See LanguageExporter
#  module for more information.
#
#  == Tracking translations used on a page
#
#  Very simple global mechanism for keeping track of which localization strings
#  are used on each page.  See LanguageTracking module for more info.
#
################################################################################

class Language < AbstractModel
  include LanguageExporter
  class << self
    include LanguageTracking
  end

  has_many :translation_strings, :dependent => :destroy

  # Look up the official Language.
  def self.official
    find_by_official(true)
  end

  # Return Array of unofficial Language's.
  def self.unofficial
    find_all_by_official(false)
  end

  # Returns an Array of pairs containing language name and locale.
  # Useful for building pulldown menus using <tt>select_tag</tt> helper.
  def self.menu_options
    all.sort_by(&:order).map do |lang|
      [ lang.name, lang.locale ]
    end
  end

  # Get a list of the top N contributors to a language's translations.
  # This is used by the app layout, so must cause mimimal database load.
  def top_contributors(num=10)
    user_ids = self.class.connection.select_rows %(
      SELECT user_id
      FROM translation_strings
      WHERE language_id = #{id} AND user_id != 0
      GROUP BY user_id
      ORDER BY COUNT(id) DESC
      LIMIT #{num}
    )
    if user_ids.any?
      user_ids = self.class.connection.select_rows %(
        SELECT id, login
        FROM users
        WHERE id IN (#{user_ids.join(',')})
        ORDER BY FIND_IN_SET(id, '#{user_ids.join(',')}')
      )
    end
    return user_ids
  end
end
