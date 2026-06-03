require 'minimization'
  # specialize Ruby built-in to reduce computational requirement
  # the original implementation is rubbish as the logging function
  # calls the proc 4 times adding +130% to the overall computational
  # requirement! Changed covergence evaluation to be more efficient
  # as payback function not 100% compliant with bisection functional
  # requirements, also only requires 2 rather than 3 payback calls
  # which are computationally intensive
  class Minimiser < Minimization::Bisection
    def initialize(lower, upper, proc, epsilon: 1.0, max_iterations: 10)
      super(lower, upper, proc)
      @max_iteration = max_iterations
      @epsilon = epsilon
    end

    def iterate
      ax = @lower
      cx = @upper
      k = 0
      while (ax - cx).abs > @epsilon and k < @max_iteration
        bx = (ax + cx) / 2.0
        fb1 = f(bx - @epsilon / 2.0)
        fb2 = f(bx + @epsilon / 2.0)
        if fb2 > fb1
          cx = bx
        else
          ax = bx
        end
        k += 1
      end
      @x_minimum = (ax + cx) / 2.0
      @f_minimum = f(@x_minimum)
    end
  end
