function fish_greeting
  set_color "cyan"

  set random_number (random 1 3)
  switch $random_number
    case 1
      printf "\n"
      printf " █   █   ██  █   █   ██  ████  █  ██  ███   █ \n"
      printf " █   █  █  █ █   █  █  █   █   ██  █ █      █ \n"
      printf "  ██ █ █   █  ██ █ █   █   █   █ █ █ █   ██ █ \n"
      printf "    █  █   █    █  █   █ █ █ █ █  ██  █   █   \n"
      printf " ███    ███  ███    ███   ████ ██  █   ███  █ \n"
    case 2
      printf "\n"
      printf " .--. --- --- .--. / .--. --- --- .--. \n"
      printf " .--. --- --- .--. / .--. --- --- .--. \n"
      printf " .--. --- --- .--. / .--. --- --- .--. \n"
      printf " .--. --- --- .--. / .--. --- --- .--. \n"
    case 3
      printf "\n"
      printf " ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣  \n"
      printf "  ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ \n"
      printf " ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣  \n"
      printf "  ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ ‣ \n"
  end
end
