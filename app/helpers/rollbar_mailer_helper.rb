module RollbarMailerHelper
  #generate link to Rollbar
  def rollbar_item_url(environment, item_counter, occurence_id)
    return "https://rollbar.com/energysparks/#{environment}/items/#{item_counter}/occurrences/#{occurence_id}"
  end

  #strip the prefixes that Rollbar adds to custom columns
  def nice_column_title(col)
    col.gsub("body.trace.", "").gsub("extra.", "")
  end
end
