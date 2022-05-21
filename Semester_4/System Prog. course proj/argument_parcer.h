#ifndef MY_RESCUE_ARGUMENT_PARSER_H
#define MY_RESCUE_ARGUMENT_PARSER_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

#define MEGABYTE 1048576

typedef struct {

    int fd_in;
    int fd_out;

    char * path_in;
    char * path_out;
    char * path_map;

    long long rescue_start_pos; //-i
    long rescue_size;      //-s

    int bad_block_repeat; //-r

    int block_size;       //-b

    bool just_copy;
    bool delete_mapfile;  //-d

}args_t;

void show_help();

char * while_not_space(int pos, const char* str);

void default_args(args_t *args);

args_t * parse_command_line(int argc, char * argv[]){

    if(argc == 2 && strcmp(argv[1],"-h") == 0){
        show_help();
        exit(0);
    }

    if(argc < 3){
        printf("Too few arguments\n");
        exit(-1);
    }

    args_t *args = (args_t*) malloc(sizeof(args_t));
    default_args(args);

    char *cline = (char*) malloc(sizeof(&argv));

    args->path_in = (char*) malloc(strlen(argv[1]));
    args->path_out = (char*) malloc(strlen(argv[2]));

    strcat(args->path_in, argv[1]);
    strcat(args->path_out, argv[2]);

    if(argc == 3){
        return args;
    }

    for(int i = 3; i < argc; i++){
        strcat(cline, argv[i]);
        strcat(cline, " ");
    }

    char temp;
    int pos = 0;
    long long buffer;

    printf("%s\n", cline);
    while((temp = cline[pos]) != '\0'){
        pos++;
        if(temp == ' ')
            continue;

        if(temp == '-'){

            temp = cline[pos];
            pos++;
            switch(temp) {
                case 'i' :{
                    pos++;
                    buffer = atoll(while_not_space(pos, cline)) * MEGABYTE;
                    if (buffer < 0) {
                        printf("Invalid arguments\n");
                        exit(-1);
                    }
                    args->rescue_start_pos = buffer;
                    break;
                }
                case 's': {
                    pos++;
                    buffer = atoll(while_not_space(pos, cline)) * MEGABYTE;
                    if (buffer <= 0) {
                        printf("Invalid arguments\n");
                        exit(-1);
                    }
                    args->rescue_size = buffer;
                    break;
                }
                case 'r': {
                    pos++;
                    buffer = atoll(while_not_space(pos, cline));
                    if (buffer <= 0) {
                        printf("Invalid arguments\n");
                        exit(-1);
                    }
                    args->bad_block_repeat = (int)buffer;
                    break;
                }
                case 'd': {
                    args->delete_mapfile = true;
                    break;
                }
                default:{
                    printf("Invalid arguments\n");
                    exit(-1);
                }
            }
        }
    }


    return args;
}

void default_args(args_t *args){

    args->path_in = "";
    args->path_out = "./";
    args->rescue_size = -1;
    args->bad_block_repeat = 3;
    args->delete_mapfile = false;
    args->rescue_start_pos = 0;
    args->fd_in = 0;
    args->fd_out = 0;
    args->block_size = 512;
    args->path_map = "./my_mapfile";
    args->just_copy = 0;
}

char * while_not_space(int pos, const char* str){

    char *ret_str = (char *) malloc(sizeof(str));
    int i = 0;
    while(str[pos] != ' '){
        if(str[pos] == '\0')
            return ret_str;
        if(str[pos] < '0' || str[pos] > '9'){
            printf("Invalid arguments\n");
            exit(-1);
        }
        ret_str[i] = str[pos];
        pos++;
        i++;
    }
    ret_str[i] = '\0';
    printf("%s\n", ret_str);
    return ret_str;
}

void show_help(){
    printf("My_rescue help\n"
           "Use the following template:\n"
           "sudo ./my_rescue [save directory] [output directory] [options: -?]\n"
           "All args with data size should be in megabytes\n"
           "-d -- delete mapfile after work\n"
           "-b=<size> -- block size. Usual 512, 1024, 2048 bytes. Default 512\n"
           "-i=<pos> -- start pos of save file. If you want save all disk, use -i=0 or without this flag\n"
           "-s=<size> -- size of data to save. If you want save all disk, use -s=<your disk capacity> or without this flag\n"
           "-r=<times> -- amount of retrying read bad block. Default is 3\n"
           "-j -- save without trying bad blocks\n");
}

#endif //MY_RESCUE_ARGUMENT_PARSER_H