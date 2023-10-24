# Used by the rails router for redirecting old benchmark urls to the new compare ones
class BenchmarkRedirector
  def call(_params, request)
    params = (request.params['benchmark'] || {}).slice('school_group_ids', 'school_types').transform_values { |a| a.reject(&:blank?) }
    params['school_types'].map! { |id| School.school_types.key(id.to_i) } if params['school_types']
    "/compare/#{request.params['benchmark_type']}?search=groups&#{params.to_query}"
  end
end
