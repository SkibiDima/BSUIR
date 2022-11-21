import serial

clear_console = "\033[2J\033[1;1H"

RED_COLOR = "\x1b[0;31m"
WHITE_COLOR = "\x1b[0m"
GREEN_COLOR = "\x1b[0;32m"


def reader():
    ser = serial.Serial('/dev/tnt1', timeout=None)

    correct_messages = 0

    while True:
        data = ""
        i = 0
        while ser.inWaiting():
            data = data + ser.read().decode("windows-1251")
            i += 1
        if i == 12:
            if data == "111111111111":
                print(RED_COLOR + f"Jam-signal received")
                correct_messages -= 1
            else:
                print(WHITE_COLOR + f"Message: {data}, correct = {correct_messages + 1}")
                correct_messages += 1


if __name__ == '__main__':
    reader()
