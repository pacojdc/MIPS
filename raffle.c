// Mario Alfredo Carrillo Arevalo
// mario.alfredo.c.arevalo@intel.com
// June 2017
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <getopt.h>
#include <time.h>

#define DEFAULT_WINNERS    1
#define BUFFER_SIZE     1024

struct list {
	char participant[BUFFER_SIZE];
	struct list *next;
};

struct list *init_list();
int destroy_list(struct list *l);
int select_winners(char *input_file, int number_winners);
int add_participant(struct list *l, char *name);
int *get_random_nums(int participants, int number_winners);

static const char help[] =
	"Usage: filter [-h] [--help] [-v] [--version]\n"
	"       filter <PARTICIPANTS FILE>\n"
	"Description:\n"
	"  -h, --help         help page\n"
	"  -f, --file         Input file with participants\n"
	"  -n, --num-winners  Number of winners\n"
	"  -v, --version      Show version\n";

static struct option long_cmd_opts[] = {
	{"help",	no_argument,       0, 'h'},
	{"file",	required_argument, 0, 'f'},
	{"winners",	required_argument, 0, 'n'},
	{"version",	no_argument,       0, 'v'},
	{0, 0, 0, 0}
};

int main(int argc, char **argv)
{
	int opt_index;
	int cmd;
	int number_winners;
	char *input_file = NULL;
	int *winners;

	number_winners = 0;
	while ((cmd = getopt_long(argc, argv, "hvf:n:",
		long_cmd_opts, &opt_index)) != -1) {

		switch(cmd) {
		case 'h':
			printf("%s", help);
			return EXIT_SUCCESS;
		case 'f':
			input_file = optarg;
			break;
		case 'n':
			number_winners = atoi(optarg);
			break;
		case 'v':
			printf("version 0.0.1");
			return EXIT_SUCCESS;
		default:
			printf("Unsupported options: -%c. "
				"See option -h for help.\n", optopt);
			return EXIT_FAILURE;
		}
	}

	if (input_file == NULL) {
		fprintf(stderr, "error: no input file\n");
		fprintf(stderr, "See option -h for help\n");
		return EXIT_FAILURE;
	}

	// Setting default number of winners
	if (number_winners == 0)
		number_winners = DEFAULT_WINNERS;

	select_winners(input_file, number_winners);

	return EXIT_SUCCESS;
}

int *get_random_nums(int participants, int number_winners)
{
	int i;
	int *nums;

	// The winners will chosen randomly
	nums = (int *)malloc(number_winners * sizeof(int));
	memset(nums, 0, sizeof(nums));
	srand(time(NULL));
	for (i=0; i < number_winners; i++)
		nums[i] = rand() % participants + 1;

	return nums;
}

int select_winners(char *input_file, int number_winners)
{
	FILE *fp;
	int i;
	int count;
	int pos;
	int *winners;
	char *line = NULL;
	ssize_t read;
	size_t length;
	struct list *l;
	struct list *head;

	length = 0;
	count = 0;
	fp = fopen(input_file, "r");
	if (fp == NULL) {
		fprintf(stderr, "error: open input file %p\n", fp);
		return EXIT_FAILURE;
	}

	l = init_list();
	head = l;
	// Reading input file in order to determine
	// the total of participants
	while ((read = getline(&line, &length, fp)) != -1) {
		add_participant(l, line);
		count++;
	}

	fclose(fp);
	if (number_winners > count) {
		fprintf(stderr, "error: number of winners exceeded %d\n",
			number_winners);
		exit(1);
	}

	// Getting the numbers of the winners
	winners = get_random_nums(count, number_winners);
	l = head;
	l = l->next;
	pos = 1;
	while (l != NULL) {
		for (i=0; i < number_winners; i++)
			if (pos == winners[i])
				printf("The winner is: %s", l->participant);
		l = l->next;
		pos++;
	}

	l = head;
	destroy_list(l);

	if (winners)
		free(winners);

	if (line) {
		free(line);
		return EXIT_SUCCESS;
	}
}

struct list *init_list()
{
	struct list *l;

	l = (struct list *)malloc(sizeof(struct list));
	memset(l, 0, sizeof(struct list));
	l->next = NULL;

	return l;
}

int destroy_list(struct list *l)
{
	struct list *tmp;

	if (l == NULL) {
		fprintf(stderr, "error: can't destroy: empty list %p\n", l);
		exit(1);
	}

	while (l != NULL) {
		tmp = l;
		l = l->next;
		free(tmp);
	}
	return 0;
}

int add_participant(struct list *l, char *name)
{
	struct list *new;

	if (l == NULL) {
		fprintf(stderr, "error: empty list %p\n", l);
		exit(1);
	}

	while (l->next != NULL) {
		l = l->next;
	}

	// Adding the new participant to the list
	new = (struct list *)malloc(sizeof(struct list));
	if (new == NULL) {
		fprintf(stderr, "error: new node %p\n", new);
		exit(1);
	}

	memset(new, 0, sizeof(struct list));
	snprintf(new->participant, BUFFER_SIZE , "%s", name);
	new->next = NULL;
	l->next = new;

	return 0;
}
