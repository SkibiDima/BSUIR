import serial
import time
import sys
import random

clear_console = "\033[2J\033[1;1H"

WHITE_COLOR = "\x1b[0m"
RED_COLOR = "\x1b[0;31m"
GREEN_COLOR = "\x1b[0;32m"
YELLOW_COLOR = "\x1b[0;33m"
BLUE_COLOR = "\x1b[0;36m"


# 1: wr tnt0 rd tnt5
# 2: wr tnt2 rd tnt1
# 3: wr tnt4 rd tnt3
# PPP_T_RRR_DA_SA_D8
# priorbit_token_resbit_addrDst_addrSour_Data_


def main():
    if len(sys.argv) != 2:
        print(RED_COLOR + "Invalid amount of arguments!")
        return
    else:
        if sys.argv[1] == '1':
            write_file = "/dev/tnt0"
            read_file = "/dev/tnt5"
            have_token = True
            station_address = "00"
            print(GREEN_COLOR + "Created station 1")
        elif sys.argv[1] == '2':
            write_file = "/dev/tnt2"
            read_file = "/dev/tnt1"
            have_token = False
            station_address = "01"
            print(GREEN_COLOR + "Created station 2")
        elif sys.argv[1] == '3':
            write_file = "/dev/tnt4"
            read_file = "/dev/tnt3"
            have_token = False
            station_address = "10"
            print(GREEN_COLOR + "Created station 3")
        else:
            print(RED_COLOR + "Arguments must be 1-3!")
            return

    read_data = ""
    data_length = 8

    station_message_queue = list()

    ser_wr = serial.Serial(write_file, timeout=None)
    ser_rd = serial.Serial(read_file, timeout=None)
    while True:

        # GENERATE OWN MESSAGE
        if random.randint(0, 3) == 0:  # 25% to generate
            station_message = randomize_data(3) + "1" + randomize_data(3) + \
                              randomize_address(station_address) + station_address + randomize_data(data_length)
            print(GREEN_COLOR + "Generated message: "
                  + YELLOW_COLOR + f"{station_message[0:7]}"
                  + BLUE_COLOR + f"{station_message[7:11]}"
                  + WHITE_COLOR + f"{station_message[11:20]}")

            station_message_queue.append(station_message)
        if len(station_message_queue) != 0:
            current_priority = station_message_queue[0][0:3]
        else:
            current_priority = "000"

        # TOKEN CHECK
        if not read_data == "":
            if read_data[3] == "0":
                have_token = True

        # SEND MESSAGE
        if have_token:
            if len(station_message_queue) != 0:
                if read_data == "":
                    sending_message = station_message_queue[0][0:4] + "000" + station_message_queue[0][7:20]
                    station_message_queue.remove(station_message_queue[0])
                    ser_wr.write(sending_message.encode("windows-1251"))
                    print(WHITE_COLOR + f"Send own message:  {sending_message}")
                elif int(current_priority, 2) > int(read_data[0:3], 2):
                    sending_message = station_message_queue[0][0:4] + \
                                      format(max(int(current_priority, 2), int(read_data[4:7], 2)), "b") + \
                                      station_message_queue[0][7:20]
                    station_message_queue.remove(station_message_queue[0])
                    ser_wr.write(sending_message.encode("windows-1251"))
                    print(WHITE_COLOR + f"Send own message:  {sending_message}")
            else:
                print(RED_COLOR + "Must send token")
                if read_data == "":
                    sending_message = "000" + "0" + current_priority
                else:
                    sending_message = read_data[0:3] + "0" + read_data[4:7]
                ser_wr.write(sending_message.encode("windows-1251"))
                have_token = False
        elif read_data != "":
            sending_message = read_data[0:4] + format(max(int(current_priority, 2), int(read_data[4:7], 2)), "b") + \
                              read_data[7:20]
            ser_wr.write(sending_message.encode("windows-1251"))

        # READ MESSAGE
        read_data = ""
        while ser_rd.inWaiting():
            read_data = read_data + ser_rd.read().decode("windows-1251")
        if read_data != "":
            if read_data[3] == "0":
                print(GREEN_COLOR + "Got token")
            else:
                print(WHITE_COLOR + f"Got message: {read_data}")
        time.sleep(2)


def randomize_data(data_length):
    data = ""
    for i in range(data_length):
        data += str(random.randint(0, 1))

    return data


def randomize_address(station_address):
    address = station_address
    while address == station_address:
        address = randomize_data(2)
    return address


if __name__ == '__main__':
    main()
