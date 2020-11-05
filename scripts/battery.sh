#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

emoji=$1

linux_acpi() {
    arg=$1
    BAT=$(ls -d /sys/class/power_supply/BAT* | head -1)
    if [ ! -x "$(which acpi 2> /dev/null)" ];then
        case "$arg" in
            status)
                cat $BAT/status
            ;;

            percent)
                cat $BAT/capacity
            ;;

            *)
            ;;
        esac
    else
        case "$arg" in
            status)
                acpi | cut -d: -f2- | cut -d, -f1 | tr -d ' '
            ;;
            percent)
                acpi | cut -d: -f2- | cut -d, -f2 | tr -d '% '
            ;;
            *)
            ;;
        esac
    fi
}

battery_percent()
{
    # Check OS
    case $(uname -s) in
        Linux)
            percent=$(linux_acpi percent)
            [ -n "$percent" ] && echo " $percent"
        ;;

        Darwin)
            echo $(pmset -g batt | grep -Eo '[0-9]?[0-9]?[0-9]%')
        ;;

        FreeBSD)
            echo $(apm | sed '8,11d' | grep life | awk '{print $4}')
        ;;

        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            # leaving empty - TODO - windows compatability
        ;;

        *)
        ;;
    esac
}

battery_status()
{
    p=$1

    # Check OS
    case $(uname -s) in
        Linux)
            status=$(linux_acpi status)
        ;;

        Darwin)
            status=$(pmset -g batt | sed -n 2p | cut -d ';' -f 2)
        ;;

        FreeBSD)
            status=$(apm | sed '8,11d' | grep Status | awk '{printf $3}')
        ;;

        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            # leaving empty - TODO - windows compatability
        ;;

        *)
        ;;
    esac

    if $emoji; then
        case $status in
            discharging|Discharging)
                if [ $p -lt 10 ]; then
                    echo '💔';
                elif [ $p -lt 20 ]; then
                    echo '❤️ ';
                elif [ $p -lt 40 ]; then
                    echo '💜';
                elif [ $p -lt 60 ]; then
                    echo '🧡';
                elif [ $p -lt 80 ]; then
                    echo '💛';
                elif [ $p -lt 90 ]; then
                    echo '💙';
                else
                    echo '💚';
                fi
            ;;
            high|High)
                echo '🌕'
            ;;
            charging|Charging)
                echo '⚡'
            ;;
            *)
                echo '⚰️ '
            ;;
        esac
    else
        case $status in
            discharging|Discharging)
                if [ $p -lt 10 ]; then
                    echo '✝'
                else
                    echo '♥'
                fi
            ;;
            high|High)
                echo ''
            ;;
            charging|Charging)
                echo 'AC'
            ;;
            *)
                echo 'AC'
            ;;
        esac
    fi
    ### Old if statements didn't work on BSD, they're probably not POSIX compliant, not sure
    # if [ $status = 'discharging' ] || [ $status = 'Discharging' ]; then
    #     echo ''
    # # elif [ $status = 'charging' ]; then # This is needed for FreeBSD AC checking support
    #     # echo 'AC'
    # else
    #      echo 'AC'
    # fi
}

main()
{
    p=$(battery_percent)
    bat_stat=$(battery_status $p)

    if [ $p -lt 20 ]; then
        bat_fg="#[fg=#ff5555]" # red
    elif [ $p -lt 40 ]; then
        bat_fg="#[fg=#ff79c6]" # pink
    elif [ $p -lt 60 ]; then
        bat_fg="#[fg=#ffb86c]" # orange
    elif [ $p -lt 80 ]; then
        bat_fg="#[fg=#f1fa8c]" # yellow
    else
        bat_fg="#[fg=#50fa7b]" # green
    fi

    if $emoji; then
        echo "${bat_stat}${bat_fg}${p}"
    else
        echo "${bat_fg}${bat_stat} ${p}"
    fi
}

#run main driver program
main

