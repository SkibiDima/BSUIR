import serial


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
        print(f"Error in bits {str(wrong_bits)}. Must change {wrong_bit} bit")
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


def main():
    # Test case:

    data = "01101101"
    print(f"Unencoded data:    {data}")
    c = control_bits_count(len(data))
    arr_x = find_bits_position(data, c)
    print(f"Defined position:  {arr_x}")
    arr1 = encode_hamming(arr_x, c)
    print(f"Encoded data: \t   {arr1}")

    arr1 =     "000111010101"  # with error
    # decoded   XX0X110X1101
    # right     000111011101
    # error:    000111010101    error in bit 9 from

    print(f"Wrong transmitted: {arr1}")
    no_errors = detect_errors(arr1)
    print(f"Decoded: \t   {decode_hamming(no_errors)}")


if __name__ == '__main__':
    main()
