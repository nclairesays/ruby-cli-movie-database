require 'rainbow'

module Style
  def normal(string)
    Rainbow(string).white
  end

  def warning(string)
    Rainbow(string).red.bold
  end

  def message(string)
    Rainbow(string).magenta.bold
  end

  def menu(string)
    Rainbow(string).yellow.underline
  end
end
