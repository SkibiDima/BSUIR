#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <linux/hdreg.h>
#include <sys/ioctl.h>

#include "my_mapper.h"
#include "argument_parser.h"
#include "rescue.h"

int main(int argc, char* argv[]) {

    args_t *args;

    args = parse_command_line(argc, argv);

    if((args->fd_in = open(args->path_in, O_RDONLY)) == -1 ){
        perror("Disk open error");
        exit(EXIT_FAILURE);
    }

    if((args->fd_out = open(args->path_out, O_CREAT | O_RDWR, 0666)) == -1 ){
        perror("File create error");
        exit(EXIT_FAILURE);
    }

    FILE *file_map = fopen(args->path_map, "r+");
    if (file_map == NULL)
        write_map_header(args, argc, argv);

    rescue(args);

    close(args->fd_in);
    close(args->fd_out);
    fclose(file_map);

    if(args->delete_mapfile)
        remove(args->path_map);

    return 0;
}