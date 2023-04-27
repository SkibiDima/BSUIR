import matplotlib.pyplot as plt
import numpy as np


def coagulate(y, h):
    result = np.array(y).copy()
    for i in range(0, np.size(y)):#np.size(h), (np.size(y) // 2) + 1):
        result[i] = 0
        for j in range(np.size(h)):
            result[i] = result[i] + y[i - j] * h[j]
            #result[np.size(y) - i] = result[i]

    return result


def fft_dif(sequence, operation):
    if operation != 1 and operation != -1:
        raise Exception('Operation must be 1 (FFT) or -1 (reverse FFT)! Got {}'.format(operation))

    N = len(sequence)
    if N == 1 or (N & (N - 1)) != 0: return sequence

    count = (int)(np.log2(N))
    result = []
    for i in range(N):
        result.append(complex(sequence[i]))

    for i in range(count, 0, -1):
        n = 2 ** i // 2
        w = 1
        wN = np.exp(operation * -2j * np.pi / (2 ** i))
        for k in range(n):
            for j in range(0, N, 2 ** i):
                b = result[j + k]
                c = result[j + k + n]
                result[j + k] = b + c
                result[j + k + n] = (b - c) * w
            w *= wN

    result = binary_invert(result)

    if operation == 1:
        for i in range(N):
            result[i] /= N

    return result


def binary_invert(data):
    N = len(data)

    result = data
    for i in range(N):
        s = format(i, '0>6b')
        reversed_i = int(s[::-1], 2)
        if reversed_i > i:
            temp = result[reversed_i]
            result[reversed_i] = result[i]
            result[i] = temp

    return result


def unipolar_filter(noise_sequence, Fc):

    x = np.e ** (-2 * np.pi * Fc)
    result = np.array(noise_sequence).copy()

    a0 = (x+1)/2
    a1 = -(x+1)/2
    b1 = x

    for i in range(0, np.size(noise_sequence)):
    	result[i] = a0 * noise_sequence[i] + a1 * noise_sequence[i - 1] + b1 * result[i - 1]

    return result


def hamming_window(N, n):
    result = 0.54 + 0.46 * np.cos(2 * np.pi * n / N)
    #print(n, ' ', '%.3f' % result, ' ', end='')
    return result


def bandpass_hamming_window_filter(noise_sequence, M, N, Band, Fham):
    Fmin = Fham - Band/2
    Fmax = Fham + Band/2

    filter_arguments_min = []
    for i in range(M):
        window = hamming_window(M, i)
        temp = i - M / 2
        if temp == 0:
            filter_arguments_min.append(2 * np.pi * Fmin)
        else:
            filter_arguments_min.append(np.sin(2 * np.pi * Fmin * temp) / temp)
        filter_arguments_min[i] = filter_arguments_min[i] * window

    min_sum = np.sum(filter_arguments_min)
    filter_arguments_min = [element / min_sum for element in filter_arguments_min]

    filter_arguments_max = []
    for i in range(M):
        window = hamming_window(M, i)
        temp = i - M / 2
        if temp == 0:
            filter_arguments_max.append(2 * np.pi * Fmax)
        else:
            filter_arguments_max.append(np.sin(2 * np.pi * Fmax * temp) / temp)
        filter_arguments_max[i] = filter_arguments_max[i] * window

    max_sum = np.sum(filter_arguments_max)
    filter_arguments_max = [element / max_sum for element in filter_arguments_max]

    for i in range(M):
        filter_arguments_max[i] = -filter_arguments_max[i]
    filter_arguments_max[int(M/2)] += 1

    norm_filter_arguments = coagulate(filter_arguments_min, filter_arguments_max)

    gridsize = (22, 4)
    fig = plt.figure(figsize=(7, 6))
    arguments = np.linspace(0, M, M)
    ax0 = plt.subplot2grid(gridsize, (1, 0), colspan=2, rowspan=2)
    ax0.set_title('Filter', fontsize=20)
    ax0.grid()
    ax0.plot(arguments, norm_filter_arguments)

    ax2 = plt.subplot2grid(gridsize, (6, 0), colspan=2, rowspan=2)
    ax2.set_title('Min', fontsize=20)
    ax2.grid()
    ax2.plot(arguments, filter_arguments_min)

    ax3 = plt.subplot2grid(gridsize, (11, 0), colspan=2, rowspan=2)
    ax3.set_title('Max', fontsize=20)
    ax3.grid()
    ax3.plot(arguments, filter_arguments_max)

    result = coagulate(noise_sequence, norm_filter_arguments)

    return result


N = 64
PERIOD = 2 * np.pi
arguments = np.linspace(0, PERIOD, N)
initial_sequence = list(map(lambda x: np.sin(2*x) + np.cos(8*x), arguments))
noise = list(map(lambda x: 0.5*np.sin(26 * x), arguments))
noise_sequence = [i + j for (i, j) in zip(initial_sequence, noise)]

Band = 7/64
M = 24
Fham = 9/64
Fc = 16/64 

result_bandpass_hamming_window_filter = bandpass_hamming_window_filter(noise_sequence, int(M), N, Band, Fham)
result_unipolar_filter_noise = unipolar_filter(noise_sequence, Fc)

def main():
    gridsize = (22, 4)
    fig = plt.figure(figsize=(15, 10))

    ax1 = plt.subplot2grid(gridsize, (1, 0), colspan=2, rowspan=2)
    ax1.set_title('sin(2x) + cos(8x)', fontsize=20)
    ax1.grid()
    ax1.plot(arguments, initial_sequence)

    ax2 = plt.subplot2grid(gridsize, (1, 2), colspan=2, rowspan=2)
    ax2.set_title('Signal FFT', fontsize=20)
    ax2.grid()
    ax2.plot(arguments, np.absolute(fft_dif(initial_sequence, 1)))

    ax3 = plt.subplot2grid(gridsize, (5, 0), colspan=2, rowspan=2)
    ax3.set_title('Noise', fontsize=20)
    ax3.grid()
    ax3.plot(arguments, noise)

    ax4 = plt.subplot2grid(gridsize, (5, 2), colspan=2, rowspan=2)
    ax4.set_title('FFT noise', fontsize=20)
    ax4.grid()
    ax4.plot(arguments, np.absolute(fft_dif(noise, 1)))

    ax5 = plt.subplot2grid(gridsize, (9, 0), colspan=2, rowspan=2)
    ax5.set_title('Signal + noise', fontsize=20)
    ax5.grid()
    ax5.plot(arguments, noise_sequence)

    ax6 = plt.subplot2grid(gridsize, (9, 2), colspan=2, rowspan=2)
    ax6.set_title('Signal + noise FFT', fontsize=20)
    ax6.grid()
    ax6.plot(arguments, np.absolute(fft_dif(noise_sequence, 1)))

    ax7 = plt.subplot2grid(gridsize, (13, 0), colspan=2, rowspan=2)
    ax7.set_title('Signal FIR filter', fontsize=20)
    ax7.grid()
    ax7.plot(arguments, result_bandpass_hamming_window_filter)

    ax8 = plt.subplot2grid(gridsize, (13, 2), colspan=2, rowspan=2)
    ax8.set_title('Signal FIR filter FFT', fontsize=20)
    ax8.grid()
    ax8.plot(arguments, np.absolute(fft_dif(result_bandpass_hamming_window_filter, 1)))

    ax9 = plt.subplot2grid(gridsize, (17, 0), colspan=2, rowspan=2)
    ax9.set_title('Signal IIR filter', fontsize=20)
    ax9.grid()
    ax9.plot(arguments, result_unipolar_filter_noise)

    ax10 = plt.subplot2grid(gridsize, (17, 2), colspan=2, rowspan=2)
    ax10.set_title('Signal IIR filter FFT', fontsize=20)
    ax10.grid()
    ax10.plot(arguments, np.absolute(fft_dif(result_unipolar_filter_noise, 1)))

    plt.show()


if __name__ == '__main__':
    main()
