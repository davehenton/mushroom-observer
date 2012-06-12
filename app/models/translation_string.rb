# encoding: utf-8
#
#  = TranslationString
#
#  Contains a single localization string.
#
#  == Attributes
#
#  language::   Language it belongs to.
#  tag::        Globalite "tag", e.g., :app_title.
#  text::       The actual text, e.g., "Mushroom Observer".
#  version::    ActsAsVersioned version number.
#  modified::   DateTime it was last modified.
#  user::       User who last modified it.
#
#  == Versions
#
#  ActsAsVersioned tracks changes in +text+, +modified+, and +user+.
#
################################################################################

class TranslationString < AbstractModel
  belongs_to :language
  belongs_to :user

  acts_as_versioned(
    :table_name => 'translation_strings_versions',
    :if => :update_version?
  )
  non_versioned_columns.push('language_id', 'tag')

  # Called to determine whether or not to create a new version.
  # Aggregate changes by the same user for up to a day.
  def update_version?
    result = false
    self.user = User.current || User.admin
    self.modified = Time.now unless modified_changed?
    if text_changed? and text_change[0].to_s != text_change[1].to_s
      latest = versions.latest
      if not latest or # (for testing)
         latest.user_id != user_id or
         latest.modified < modified - 1.day
        result = true
      elsif latest.text != text or latest.modified.to_s != modified.to_s
        latest.update_attributes(
          :text => text,
          :modified => modified
        )
      end
    end
    return result
  end

  # Update this string in the current set of translations Globalite is using.
  def update_localization
    data = Globalite.localization_data(language.locale)
    raise "Localization for #{language.locale.inspect} hasn't been loaded yet!" unless data
    data[tag.to_sym] = text
  end
end
