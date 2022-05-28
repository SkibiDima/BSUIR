#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#pragma inline
using namespace std;

int main() {

	const int array_size = 5;
	float my_array[array_size] = {};
	float result_array[array_size] = {};

	for (size_t i = 0; i < array_size; i++) {
		cout << i << " > ";
		cin >> my_array[i];
	}

	cout << "\n";

	int max_position = 0;

	//FIND MAX ELEMENT
	_asm {
		finit
		mov ecx, array_size

		mov esi, 4			// start from 1 element
	find_max_loop:

		cmp cx, 0
		jbe end_find_max

		mov eax, max_position
		mov edx, esi

		fld my_array[eax]
		fld my_array[edx]
		fcompp				// current max < current element?

		fstsw ax

		or ah, 10111010b	// if st(0) > st(1) : c3(14), c2(10), c0(8) = 0
		cmp ah, 10111010b
		je renew_max
		
		dec cx
		add esi, 4			// i++
		jmp find_max_loop

	renew_max:

		mov max_position, edx
		dec cx
		add esi, 4
		jmp find_max_loop

	end_find_max:

		fwait
	}

	max_position /= 4;
	printf("Max element: %.2f, position %d\n", my_array[max_position], max_position);

	int i = 0, j = max_position * 4;
	_asm {
		
		finit

		mov ecx, max_position
		inc ecx
	adding_process:

		mov eax, j
		mov edx, i

		fld my_array[edx]
		fadd my_array[eax]		// add n-i
		fstp result_array[edx]
			 
		add i, 4
		sub j, 4
		loop adding_process

		fld array_size			// if n-i < 0 just copy past value 
		fsub max_position 
		fstp j

		mov ecx, j
	write_remaining:

		mov edx, i
		add i, 4

		fld my_array[edx]
		fstp result_array[edx]

		loop write_remaining
		fwait
	}

	for (size_t i = 0; i < array_size; i++) {
		printf("%.2f ", result_array[i]);
	}

	return 0;
}