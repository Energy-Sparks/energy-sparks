class Issue < Note
  enum fuel_type: [:electricity, :gas, :solar]
end
