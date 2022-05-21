#ifndef MY_RESCUE_MY_MAPPER_H
#define MY_RESCUE_MY_MAPPER_H

#include <fcntl.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#include "argument_parser.h"

ssize_t previous_read_pos = 0;
__off_t previous_map_file_pos;

void renew_map_file(char *file_name, ssize_t current_start_pos, ssize_t current_read_pos, bool new_block_status, bool old_block_status){

    FILE* file_map_file = fopen(file_name, "r+");

    char char_to_find_new_line;
    int line = 0;

    while (line != 3){

        fread(&char_to_find_new_line, sizeof(char), 1, file_map_file);
        if(char_to_find_new_line == '\n')
            line++;
    }
    time_t current_time_time = time(NULL);
    fprintf(file_map_file, "# Last time:  %s", ctime(&current_time_time));

    fseek(file_map_file, 0, SEEK_END);
    char stat_char;
    if(new_block_status)
        stat_char = '+';
    else stat_char = '-';
    if(new_block_status != old_block_status) {
        fseek(file_map_file, 0, SEEK_CUR);
        previous_map_file_pos = ftell(file_map_file);
        fprintf(file_map_file, "  0x%010lx  0x%010lx   %c\n", previous_read_pos, current_read_pos, stat_char);
    }
    else{
        fseek(file_map_file, previous_map_file_pos, SEEK_SET);
        current_read_pos += previous_read_pos;
        fprintf(file_map_file, "  0x%010lx  0x%010lx   %c\n", current_start_pos, current_read_pos, stat_char);
    }

    previous_read_pos = current_read_pos;
    fclose(file_map_file);
}

void write_map_header(args_t *args, int argc, char *argv[]){

    FILE * file_map_file;
    char* map_file_path = args->path_map;
    file_map_file = fopen(map_file_path, "w");

    fprintf(file_map_file, "# My_rescue map file\n");
    fprintf(file_map_file, "# Provided command line:");

    for(int i = 0; i < argc; i++) {
        fprintf(file_map_file, "%s ", argv[i]);
    }
    fprintf(file_map_file, "\n");

    time_t current_time_time = time(NULL);
    fprintf(file_map_file, "# Start time: %s", ctime(&current_time_time));
    current_time_time = time(NULL);
    fprintf(file_map_file, "# Last time:  %s", ctime(&current_time_time));
    fprintf(file_map_file, "# --Position--  ----Size----   Status\n");

    fseek(file_map_file, 0, SEEK_CUR);
    previous_map_file_pos = ftell(file_map_file);

    fclose(file_map_file);
}

#endif //MY_RESCUE_MY_MAPPER_H
