import serial
import time
import random

clear_console = "\033[2J\033[1;1H"

RED_COLOR = "\x1b[0;31m"
WHITE_COLOR = "\x1b[0m"
GREEN_COLOR = "\x1b[0;32m"


def encode_hamming(hamming_encoded, r):
    n = len(hamming_encoded)

    for i in range(r):
        count = 0

        for j in range(2 ** i - 1, n, (2 ** i) * 2):
            # Check all bits in
            for k in range(j, j + 2 ** i):
                if len(hamming_encoded) > k and hamming_encoded[k] == '1':
                    count += 1

            hamming_encoded = hamming_encoded[:2 ** i - 1] + str(count % 2) + hamming_encoded[2 ** i:]

    return hamming_encoded


def detect_errors(hamming_encoded):

    c = (len(hamming_encoded) - 1).bit_length()
    n = len(hamming_encoded)
    wrong_bits = []

    for i in range(c):
        count = 0

        for j in range(2 ** i - 1, n, (2 ** i) * 2):
            # Check all bits in
            for k in range(j, j + 2 ** i):
                if len(hamming_encoded) > k != 2 ** i - 1 and hamming_encoded[k] == '1':
                    count += 1

        if hamming_encoded[2 ** i - 1] != str(count % 2):
            wrong_bits.append(2 ** i)

    if len(wrong_bits) != 0:
        wrong_bit = sum(wrong_bits)
        hamming_encoded = hamming_encoded[:wrong_bit - 1] + str(
            int(not int(hamming_encoded[wrong_bit - 1]))) + hamming_encoded[wrong_bit:]

    return hamming_encoded


def control_bits_count(m):
    for i in range(m):
        if 2 ** i >= m + i + 1:
            return i

    return 0


def find_bits_position(data, r):
    if r == 0:
        return data
    j, k, m, res = (0, 0, len(data), '')

    for i in range(1, m + r + 1):
        if i == 2 ** j:
            res = res + 'X'
            j += 1
        else:
            res += data[k]
            k += 1

    return res


def decode_hamming(hamming_encoded):

    c = (len(hamming_encoded) - 1).bit_length()
    for i in range(c, -1, -1):
        if len(hamming_encoded) > 2 ** i:
            hamming_encoded = hamming_encoded[:2 ** i - 1] + hamming_encoded[2 ** i:]

    return hamming_encoded


def encode_message(data):
    c = control_bits_count(len(data))
    data_found_pos = find_bits_position(data, c)
    data_encoded = encode_hamming(data_found_pos, c)

    return data_encoded


def randomize_data(data_length):

    data = ""
    for i in range(data_length):
        data += str(random.randint(0, 1))

    return data


def writer():
    ser = serial.Serial('/dev/tnt0', timeout=None)

    data_length = 8
    jam_signal = "111111111111"
    print(clear_console, end="")

    while True:
        choice = input(WHITE_COLOR + "Enter the choice: \n1 - generate data \nq - quit \n>")

        if choice == "1":
            print(clear_console, end="")
            randomized_data = randomize_data(data_length)
            encoded_data = encode_message(randomized_data)
            print(f"Generated data: {randomized_data}")
            print(f"Encoded data:   {encoded_data}")

            attempts_amount = 0

            while attempts_amount < 10:
                if random.randint(0, 1) == 1:
                    final_data = randomize_data(data_length + control_bits_count(len(randomized_data)))
                    print(RED_COLOR + f"Wrong data:     {final_data}")
                else:
                    final_data = encoded_data
                    print(WHITE_COLOR + f"Final data:     {final_data}")

                ser.write(final_data.encode("windows-1251"))
                time.sleep(0.1)

                if final_data != encoded_data:
                    print(GREEN_COLOR + "Collision detected, sending jam-signal")
                    attempts_amount += 1
                    # jam-signal
                    ser.write(jam_signal.encode("windows-1251"))
                    wait = random.randint(1, 2**attempts_amount)
                    print(f"Wait for {wait} seconds")
                    time.sleep(wait)

                else:
                    break

        if choice == "q":
            ser.close()
            break


if __name__ == '__main__':
    writer()
