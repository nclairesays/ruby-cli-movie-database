require 'rainbow'

# styles defined for project-wide usage

module Style
  PROMPT = TTY::Prompt.new
  FONT = TTY::Font.new(:starwars)
  PASTEL = Pastel.new

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

  def title_header
    puts PASTEL.magenta.bold(FONT.write('MOVIE'.center(50)))
    puts PASTEL.magenta.bold(FONT.write('DATABASE'))
    puts
  end

end
