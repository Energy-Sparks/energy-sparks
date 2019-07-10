json.array! @annotations do |annotation|
  json.merge! annotation
  json.url school_intervention_path(@school, annotation[:id])
end
