import serial

clear_console = "\033[2J\033[1;1H"


def staff_decoder(my_string: str) -> str:
    start_byte = '/'
    decoded_string = ''
    for char in my_string[1:len(my_string)]:
        if char == start_byte:
            decoded_string = decoded_string[:-1]
        decoded_string += char
    return decoded_string


def reader():
    ser = serial.Serial('/dev/tnt1', timeout=None)

    while True:
        reader_choice = input("Enter the choice: \n 1 - read string \n 2 - change baud \n q - exit\n&")

        if reader_choice == "1":
            print(clear_console, end="")
            my_string = ""
            while ser.inWaiting():
                my_string = my_string + ser.read().decode("windows-1251")
            print("Encoded message:", my_string, end="")
            my_string = staff_decoder(my_string)

            if my_string[0] + my_string[1] + my_string[2] == "#BC":
                ser.baudrate = int(my_string[3:len(my_string)])
                print("Baud change to", my_string[3:len(my_string)])
            else:
                print("Message:", my_string, end="", flush=True)

        elif reader_choice == "2":
            print(clear_console, end="")

            while True:
                print("Available values:")
                for i, x in enumerate(serial.Serial.BAUDRATES):
                    print(i+1, '-', x, " \t", end="")
                    if (i+1) % 3 == 0:
                        print()

                print("Current baud rate:", ser.baudrate, "baud")
                baud_choice = int(input("Enter number of required baud rate: \n&"))
                if baud_choice in range(1, 30):
                    ser.baudrate = serial.Serial.BAUDRATES[baud_choice - 1]
                    print(clear_console, end="")
                    print("Baud rate changed to", serial.Serial.BAUDRATES[baud_choice - 1], "baud")
                    break
                else:
                    print(clear_console, end="")
                    print("Invalid baud choice!!!")

        elif reader_choice == "q":
            break

        else:
            print(clear_console, end="")
            print("Enter only 1, 2 or q, PLEASE!!!")


if __name__ == '__main__':
    reader()
