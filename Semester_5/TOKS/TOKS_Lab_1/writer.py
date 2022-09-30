import serial

clear_console = "\033[2J\033[1;1H"


def writer():
    ser = serial.Serial('/dev/tnt0', timeout=None)

    while True:
        writer_choice = input("Enter the choice: \n 1 - write string "
                              "\n 2 - change baud "
                              "\n 3 - send change baud signal "
                              "\n q - exit\n&")

        if writer_choice == "1":    # STRING SENDING
            print(clear_console, end="")
            my_string = input("Enter data to write into the COM-port(tnt0): \n&") + "\n"
            ser.write(my_string.encode("windows-1251"))
            print(clear_console, end="")
            print("String written")

        elif writer_choice == "2":  # BAUD CHANGING
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

        elif writer_choice == "3":
            ser.write(("#BC"+str(ser.baudrate)).encode())
            print(clear_console, end="")
            print("Change baud rate to", ser.baudrate, "message sent")

        elif writer_choice == "q":
            break

        else:
            print(clear_console, end="")
            print("Enter only 1, 2, 3 or q, PLEASE!!!")

    ser.close()


if __name__ == '__main__':
    writer()
