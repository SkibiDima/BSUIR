#ifndef MY_RESCUE_RESCUE_H
#define MY_RESCUE_RESCUE_H

#include <fcntl.h>
#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <inttypes.h>
#include <stdio.h>
#include <pthread.h>

#include "my_mapper.h"
#include "my_logger.h"

ssize_t CURR_READ_POS;

long BAD_BLOCKS_AMOUNT, GOOD_BLOCKS_AMOUNT;
bool rescue_status;

ssize_t read_block();
ssize_t read_block_pos();
ssize_t write_block_pos();

void rescue(args_t *args){

    struct timespec current_start_time;
    struct timespec current_end_time;

    long long current_start_pos = args->rescue_start_pos;
    long long current_read_pos = current_start_pos;
    CURR_READ_POS = current_read_pos;

    lseek(args->fd_in, current_start_pos,0);
    lseek(args->fd_out, current_start_pos, 0);

    bool infinity_rescue = false;
    bool old_block_status = false;
    bool new_block_status = true;
    if(args->rescue_size == -1){
        infinity_rescue = true;
    }

    struct logger_info loggerInfo;

    BAD_BLOCKS_AMOUNT = 0, GOOD_BLOCKS_AMOUNT = 0;
    rescue_status = 0;

    loggerInfo.current_read_pos = &CURR_READ_POS;
    loggerInfo.bad_blocks_amount = &BAD_BLOCKS_AMOUNT;
    loggerInfo.good_blocks_amount = &GOOD_BLOCKS_AMOUNT;
    loggerInfo.status = &rescue_status;

    pthread_t logger_thread = pthread_create(&logger_thread, NULL, print_log, (void*)&loggerInfo);

    uint8_t * read_buffer = (uint8_t*) malloc(args->block_size);
    ssize_t success_read = 1;
    long long current_difference_time;
    int renew_map_counter = 0;

    ssize_t *bad_block_address_array = NULL;

    while((current_read_pos < args->rescue_size || infinity_rescue) && success_read){

        //-----------READ BLOCK-----------
        clock_gettime(CLOCK_REALTIME, &current_start_time);
        success_read = read_block(args->fd_in, read_buffer, args->block_size);
        clock_gettime(CLOCK_REALTIME, &current_end_time);

        //-----------BAD BLOCK CHECK-----------
        current_difference_time = current_end_time.tv_nsec - current_start_time.tv_nsec;

        if(current_difference_time  > 400000){
            new_block_status = false;
            BAD_BLOCKS_AMOUNT++;
            bad_block_address_array = (ssize_t *) realloc(bad_block_address_array ,BAD_BLOCKS_AMOUNT * sizeof(ssize_t));
            bad_block_address_array[BAD_BLOCKS_AMOUNT - 1] = current_read_pos;
        }
        else {
            new_block_status = true;
            GOOD_BLOCKS_AMOUNT++;
        }

        write_block_pos(args->fd_out, read_buffer, success_read, current_read_pos);

        current_read_pos += success_read;
        CURR_READ_POS = current_read_pos;
        renew_map_counter++;
        if(new_block_status != old_block_status) {
            renew_map_file(args->path_map, current_start_pos, current_read_pos, new_block_status, old_block_status);
            renew_map_counter = 0;
        }else
            if(!(renew_map_counter%500)){
                renew_map_file(args->path_map, current_start_pos, current_read_pos, new_block_status, old_block_status);
                renew_map_counter = 0;
            }

        old_block_status = new_block_status;
    }

    if(!args->just_copy) {
        rescue_status = 1;
        for (long i = 0; i < BAD_BLOCKS_AMOUNT; i++) {

            for (int j = 0; j < args->bad_block_repeat; j++) {

                success_read = read_block_pos(args->fd_in, read_buffer, args->block_size, bad_block_address_array[i]);
                write_block_pos(args->fd_out, read_buffer, success_read, bad_block_address_array[i]);
            }
        }
    }
    pthread_cancel(logger_thread);
    pthread_join(logger_thread, NULL);
}

ssize_t read_block(int fd, uint8_t * buffer, const int size_to_read){

    ssize_t succ_read = 0;
    while(succ_read < size_to_read){

        ssize_t i = read(fd, buffer + succ_read, size_to_read - succ_read);
        if(i > 0)
            succ_read += i;
        else if(i == 0)
            break;
    }
    return succ_read;
}

ssize_t read_block_pos(int fd, uint8_t * buffer, const int size_to_read, long long pos){

    ssize_t succ_read = 0;
    if(lseek(fd, pos, SEEK_SET) >= 0){
        succ_read = read_block(fd, buffer, size_to_read);
    }
    return succ_read;
}

ssize_t write_block_pos(int fd, uint8_t * buffer, const int size_to_read, long long pos){

    ssize_t succ_read = 0;
    if(lseek(fd, pos, SEEK_SET) >= 0) {
        while (succ_read < size_to_read) {

            ssize_t i = write(fd, buffer + succ_read, size_to_read - succ_read);
            if (i > 0)
                succ_read += i;
            else if (i == 0)
                break;
        }
    }
    return succ_read;
}

#endif //MY_RESCUE_RESCUE_H