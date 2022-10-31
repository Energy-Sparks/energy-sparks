class Issue < Note
  enum fuel_type: [:electricity, :gas, :solar]
  validates :status, presence: true
end
