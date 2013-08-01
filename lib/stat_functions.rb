module StatFunctions
  def self.map_and_fit(data, xmeth, ymeth)
    x = data.map { |d| xmeth.call(d) }
    y = data.map { |d| ymeth.call(d) }
    self.fit_line(x.zip(y).select { |d| d[0] && d[1] })
  end

  def self.fit_line(data)
    n = sx = sxx = sy = sxy = syy = 0
    xmin = xmax = nil

    data.each do |d|
      x = d[0].to_f
      y = d[1].to_f

      xmin = x if xmin.nil? || x < xmin
      xmax = x if xmax.nil? || x > xmax

      n += 1
      sx += x
      sxx += x * x
      sy += y
      sxy += x * y
      syy += y * y
    end

    t1 = (sx * sy - n * sxy) / (sx * sx - n * sxx)
    t0 = (sy - t1 * sx) / n

    sse = 0
    data.each do |d|
      x = d[0].to_f
      y = d[1].to_f

      e = y - (t0 + t1 * x)
      sse += e * e
    end
    mse = sse / (n - 2)
    rmse = Math.sqrt(sse)

    sse2 = t0 * t0 + 2 * t0 * t1 * sx + t1 * t1 * sxx - 2 * t0 * sy - 2 * t0 * t1 * sxy + syy
    debug = { sse: sse, sse2: sse2 }

    xfut = xmax + 2.weeks
    {:coeff => [t0, t1], :endpoints => [
      [xmin,t0 + t1 * xmin],
      [xmax, t0 + t1 * xmax ],
      [xfut, t0 + t1 * xfut ] ],
     :rmse => rmse, :debug => debug}
  end
end
