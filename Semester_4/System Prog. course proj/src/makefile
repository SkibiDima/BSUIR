CC = gcc

all: main.c my_logger.h my_mapper.h argument_parser.h rescue.h
	$(CC) main.c my_logger.h my_mapper.h argument_parser.h rescue.h -lrt -pthread -o ../exe_my_rescue
clean:
	rm -rf *.o my_rescue
