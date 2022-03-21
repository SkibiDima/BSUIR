#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <dos.h>

//piano octave https://nch-nch.ru/apps/frequency/
//0 -- first, 1 -- second octave
int du[] = {261, 523};
int re[]  = {294, 587};
int mi[]  = {330, 659};
int fa[]  = {349, 698};
int sol[] = {392, 784};
int la[]  = {440, 880};
int si[]  = {494, 988};
unsigned int bd = 1500; //base note length
unsigned int bs = 20; //base sleep between notes
unsigned int notes[][3] = { 
{ sol[0], bd/4, bs}, 
{ du[1],  bd/2, bs}, 
{ sol[0], bd/4, bs},
{ la[0], bd/8, bs},
{ si[0], bd/2, bs},
{ mi[0], bd/4, bs},
{ mi[0], bd/4, bs},
{ la[0], bd/2, bs},
{ sol[0], bd/4, bs},
{ fa[0], bd/8, bs},
{ sol[0], bd/2, bs},
{ du[0], bd/4, bs},
{ du[0], bd/8, bs},
{ re[0], bd/2, bs},
{ re[0], bd/4, bs},
{ mi[0], bd/8, bs},
{ fa[0], bd/2, bs},
{ fa[0], bd/4, bs},
{ sol[0], bd/8, bs},
{ la[0], bd/2, bs},
{ si[0], bd/4, bs},
{ du[1], bd/8, bs},
{ re[1], bd/2, bs},
};		         

void PlaySound();
void TurnSpeaker(int isActive);
void SetCount(int iDivider);
void Menu();

int main() {	
	PlaySound();
	
	return 0;
}

void SetCount(int iDivider) {	
	long base = 1193180; //максимальная частота
	long kd;
	outp(0x43, 0xB6); //10110110 - канал 2, операция 4, режим 3, формат 0
	kd = base / iDivider; 
	outp(0x42, kd % 256); // младший байт делителя
	kd /= 256;
	outp(0x42, kd); //старший байт делителя
	return;
}

//функция работы с громкоговорителем
void TurnSpeaker(int isActive) {
	if (isActive) {
		outp(0x61, inp(0x61) | 3); //устанавливаем 2 младших бита 11
		return;
	} else {
		outp(0x61, inp(0x61) & 0xFC); //устанавливаем 2 младших бита 00
		return;
	}
}

//функция воспроизведения песни
void PlaySound() {
	for (int i = 0; i < 23; i++) {
		SetCount(notes[i][0]);
		TurnSpeaker(1); //включаем громкоговоритель
		delay(notes[i][1]); //устанавливаем длительность мс
		TurnSpeaker(0); //выключаем громкоговоритель
		delay(notes[i][2]);
	}
}