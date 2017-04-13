define _GUN_SOURCE

#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <unistd.h>

define STACK_SIZE (1024*1024)

static char child_stack[STACK_SIZE];
char* const child_args[]={"/bin/bash",NULL};
int child_main(void* arg){
printf(" - World!\n");
execv(child_args[0],child_args);
}
