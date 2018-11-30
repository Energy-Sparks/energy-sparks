class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def notify(from:, to:)
    logs = AmrDataFeedImportLog.where('import_time BETWEEN ? AND ?', from, to).order(:import_time)
    ImportMailer.with(logs: logs, description: @description).import_summary.deliver_now
  end
end
