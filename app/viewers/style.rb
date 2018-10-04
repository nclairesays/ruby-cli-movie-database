require 'rainbow'

# styles defined for project-wide usage

module Style

  FONT = TTY::Font.new(:starwars)
  PASTEL = Pastel.new
  LOAD = TTY::Spinner.new("[:spinner] Searching ...", format: :pulse_2)

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

  def spinner_animation(stop_message)
    LOAD.auto_spin
    sleep(2)
    LOAD.stop(stop_message)
    sleep(0.6)
  end

end
