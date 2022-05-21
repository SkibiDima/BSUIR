#ifndef MY_RESCUE_MY_LOGGER_H
#define MY_RESCUE_MY_LOGGER_H

#include <time.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>

struct logger_info{

    ssize_t *current_read_pos;

    long *bad_blocks_amount;
    long *good_blocks_amount;

    bool *status;
};

_Noreturn void* print_log(void* arg){
    struct logger_info* info = (struct logger_info*)arg;
    char loading_char[] = "-\\|/";
    int i = 0;
    long time_diff = 1;
    time_t start_time = time(NULL), current_time;
    ssize_t previous_pos = *(info->current_read_pos);
    while(1) {
        system("clear");
        printf("My_rescue logger %c\n", loading_char[i++]);
        if(*(info->status)){
            printf("Copying...\n");
        }
        else  printf("Rescuing...\n");
        printf("Rescue position: %ld Kb Rate: %ld Kb/sec\n", *(info->current_read_pos) / 1024, (*(info->current_read_pos) - previous_pos)/time_diff);
        printf("Bad blocks: %ld Good blocks %ld \n", *(info->bad_blocks_amount),  *(info->good_blocks_amount));
        printf("Working already: %ld:%02ld\n", time_diff/60, time_diff%60);
        sleep(1);
        previous_pos = *(info->current_read_pos);
        current_time = time(NULL);
        time_diff = current_time - start_time;
        fflush(stdin);
        if(i % 4 == 0)
            i = 0;
    }
}

#endif //MY_RESCUE_MY_LOGGER_H
