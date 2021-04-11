#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>

void yyerror(const char *msg);

using namespace std;

#define HASH_TABLE_SIZE 100
#define NUM_TABLES 10

int table_index = 0;
int current_scope = 0;

struct entry_t
{
	char *lexeme;
	int value;
	int data_type;
	int size;
	int array_dimension;
	int is_constant;

	struct entry_t *successor;
};

struct content_t
{
	vector<int> truelist;
	vector<int> falselist;
	vector<int> nextlist;
	vector<int> breaklist;
	vector<int> continuelist;
	string addr;
	string code;
	int array_dimension;
	entry_t *entry;
	int data_type;
};

struct table_t
{
	entry_t **symbol_table;
	int parent;
};

extern table_t symbol_table_list[NUM_TABLES];

void display_symbol_table(entry_t **hash_table_ptr);

entry_t **create_table()
{
	entry_t **hash_table_ptr = NULL;

	if ((hash_table_ptr = (entry_t **)malloc(sizeof(entry_t *) * HASH_TABLE_SIZE)) == NULL)
		return NULL;

	int i;

	for (i = 0; i < HASH_TABLE_SIZE; i++)
	{
		hash_table_ptr[i] = NULL;
	}

	return hash_table_ptr;
}

int create_new_scope()
{
	table_index++;
	// printf("Table index:%d\n",table_index);
	symbol_table_list[table_index].symbol_table = create_table();
	symbol_table_list[table_index].parent = current_scope;

	return table_index;
}

int exit_scope()
{
	return symbol_table_list[current_scope].parent;
}

int myhash(char *lexeme)
{
	size_t i;
	int hashvalue;

	for (hashvalue = i = 0; i < strlen(lexeme); ++i)
	{
		hashvalue += lexeme[i];
		hashvalue += (hashvalue << 10);
		hashvalue ^= (hashvalue >> 6);
	}
	hashvalue += (hashvalue << 3);
	hashvalue ^= (hashvalue >> 11);
	hashvalue += (hashvalue << 15);
	//cout<<(hashvalue% HASH_TABLE_SIZE + HASH_TABLE_SIZE) % HASH_TABLE_SIZE<<endl;
	return (hashvalue % HASH_TABLE_SIZE + HASH_TABLE_SIZE) % HASH_TABLE_SIZE; // return an index in [0, HASH_TABLE_SIZE)
}

entry_t *create_entry(char *lexeme, int value, int data_type, int size)
{
	entry_t *new_entry;

	if ((new_entry = (entry_t *)malloc(sizeof(entry_t))) == NULL)
	{
		return NULL;
	}

	if ((new_entry->lexeme = strdup(lexeme)) == NULL)
	{
		return NULL;
	}

	new_entry->value = value;
	new_entry->successor = NULL;
	new_entry->size = size;
	new_entry->array_dimension = -1;
	new_entry->is_constant = 0;

	new_entry->data_type = data_type;

	return new_entry;
}

entry_t *search(entry_t **hash_table_ptr, char *lexeme)
{
	int idx = 0;
	entry_t *myentry;

	idx = myhash(lexeme);

	myentry = hash_table_ptr[idx];

	while (myentry != NULL && strcmp(lexeme, myentry->lexeme) != 0)
	{
		myentry = myentry->successor;
	}

	if (myentry == NULL) // lexeme is not found
		return NULL;

	else // lexeme found
		return myentry;
}

entry_t *search_recursive(char *lexeme)
{

	int idx = current_scope;
	entry_t *finder = NULL;

	while (idx != -1)
	{
		//printf("%d\n", idx);
		char id = idx + '0';
		char* temp_lex;
		temp_lex = (char*)malloc(strlen(lexeme)*sizeof(char));
		strcpy(temp_lex, lexeme);
		strcat(temp_lex, &id);
		finder = search(symbol_table_list[idx].symbol_table, temp_lex);

		if (finder != NULL)
			return finder;

		idx = symbol_table_list[idx].parent;
	}

	return finder;
}

entry_t *insert(entry_t **hash_table_ptr, char *lexeme, int value, int data_type, int size)
{
	entry_t *finder = search(hash_table_ptr, lexeme);
	if (finder != NULL)
	{
		if (finder->is_constant)
			return finder;
		return NULL;
	}

	int idx;
	entry_t *new_entry = NULL;
	entry_t *head = NULL;

	idx = myhash(lexeme);									  // Get the index for this lexeme based on the myhash function
	new_entry = create_entry(lexeme, value, data_type, size); // Create an entry using the <lexeme, token> pair

	if (new_entry == NULL)
	{
		printf("Insert failed. New entry could not be created.");
		exit(1);
	}

	head = hash_table_ptr[idx];
	// printf("Index: %d\n",idx);// get the head entry at this index

	if (head == NULL)
	{
		hash_table_ptr[idx] = new_entry;
	}
	else
	{
		new_entry->successor = hash_table_ptr[idx];
		hash_table_ptr[idx] = new_entry;
	}

	// printf("in insert! Symbol table :%p, entry: %p, text: %s\n", hash_table_ptr, hash_table_ptr[idx], lexeme);
	// display_symbol_table(hash_table_ptr);
	return hash_table_ptr[idx];
}

void print_dashes(int n)
{
	printf("\n");

	int i;
	for (i = 0; i < n; i++)
		printf("=");
	printf("\n");
}

void display_symbol_table(entry_t **hash_table_ptr, std::ofstream& file)
{
	int i;
	entry_t *traverser;

	print_dashes(100);

	printf(" %-20s %-20s %-20s %-20s\n", "lexeme", "data-type", "size", "value");

	print_dashes(100);

	for (i = 0; i < HASH_TABLE_SIZE; i++)
	{
		// printf("In loop\n");
		traverser = hash_table_ptr[i];
		while (traverser != NULL)
		{
			printf(" %-20s %-20d %-20d %-20d", traverser->lexeme, traverser->data_type, traverser->size, traverser->value);
			file << traverser->lexeme << " " << traverser->data_type << " " << traverser->size << endl;
			printf("\n");

			traverser = traverser->successor;
		}
	}

	print_dashes(100);
}

void display_constant_table(entry_t **hash_table_ptr)
{
	int i;
	entry_t *traverser;

	print_dashes(25);

	printf(" %-10s %-10s %-10s \n", "lexeme", "data-type", "isConstant");

	print_dashes(25);

	for (i = 0; i < HASH_TABLE_SIZE; i++)
	{
		traverser = hash_table_ptr[i];
		while (traverser != NULL)
		{
			printf(" %-10s %-10d %-10d\n", traverser->lexeme, traverser->data_type, traverser->is_constant);
			traverser = traverser->successor;
		}
	}

	print_dashes(25);
}

void display_all()
{
	int i;
	ofstream outfile("ICG.vars");

	for (i = 0; i <= table_index; i++)
	{
		printf("Scope: %d\n", i);
		display_symbol_table(symbol_table_list[i].symbol_table, outfile);
		printf("\n\n");
	}

	// display_symbol_table(symbol_table_list[0].symbol_table);
	// display_symbol_table(symbol_table_list[1].symbol_table);
}

