#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"


#define pageSize 4096
#define arraySize 53248



static unsigned long int next = 1;
int getRandNum() {
  next = next * 1103515245 + 12341;
  return (unsigned int)(next/65536) % (arraySize);
}

#define PAGE_NUM(addr) ((uint)(addr) & ~0xFFF)
//#define TEST_POOL 500
/*
Global Test:
Allocates 17 pages (1 code, 1 space, 1 stack, 14 malloc)
Using pseudoRNG to access a single cell in the array and put a number in it.
Idea behind the algorithm:
	Space page will be swapped out sooner or later with scfifo or lap.
	Since no one calls the space page, an extra page is needed to play with swapping (hence the #17).
	We selected a single page and reduced its page calls to see if scfifo and lap will become more efficient.
Results (for TEST_POOL = 500):
LIFO: 42 Page faults
LAP: 18 Page faults
SCFIFO: 35 Page faults
*/
void globalTest(uint TEST_POOL){
	char * arr;
	int randNum;
	arr = malloc(arraySize); //allocates 14 pages (sums to 17 - to allow more then one swapping in scfifo)
	for (int i = 0; i < TEST_POOL; i++) {
		randNum = getRandNum();	//generates a pseudo random number between 0 and arraySize
		while (pageSize*10-8 < randNum && randNum < pageSize*10+pageSize/2-8){
			randNum = getRandNum(); //gives page #13 50% less chance of being selected
		}
		arr[randNum] = 'X';				//write to memory
		
	}
	printMem();
	free(arr);
}

void linearSweep(uint TEST_POOL){
	char * arr;
	//int randNum;
	arr = malloc(arraySize); //allocates 14 pages (sums to 17 - to allow more then one swapping in scfifo)
	for (int i = 0; i < TEST_POOL; i++) {
		for(int j = 0; j < arraySize; j+= pageSize)	//generates a pseudo random number between 0 and arraySize
		
		arr[j] = 'X';				//write to memory
		
	}
	printMem();
	free(arr);
} 

unsigned seed = 871753752;

unsigned int
irand(int l, int h)
{
	unsigned int a = 1588635695, m = 429496U, q = 2, r = 1117695901;
	unsigned int val;

	seed = a*(seed % q) - r*(seed / q);
	val = (seed / m) % (h - l) + l;

	return val;
}

void
test_badLocal()
{
	char *arr[14];
	int i;//j;


	for (i = 0; i < 21; i++){
		arr[i] = sbrk(pageSize);
	}

	int k;
	int rand1,rand2; 

	for (k = 0; k < 300; k++){			//in total 72 000 references
		for (i = 0; i < 19; i++){
				rand1 = irand(0, 17);	
				rand2 = irand(0, 16);	
				arr[i][rand1] ='x';	// choose element 1 and 35 to make sure they are on different pages, since every page is 128 contenting 32 integers
				arr[i+1][rand2] = 's';	
				arr[1][1] = 'x';	//frequently referenced element
				arr[19][20] = 'x';	//frequently referenced element
		}
		printMem();
	}
}

void test1() {
	char* array1[14];
	
	for (int i = 0; i < 12; ++i) {
		array1[i] = sbrk(pageSize);
		printf(1, "array1[%d] = 0x%x\n", i, array1[i]);
	}
	printMem();
}
void test2() {
	char* array1[14];

	for (int i = 0; i < 13; ++i) {
		array1[i] = sbrk(pageSize);
		printf(1, "array1[%d] = 0x%x\n", i, array1[i]);
	}
	printMem();
}

void test3() {
	char* array1[14];

	for (int i = 0; i < 14; ++i) {
		array1[i] = sbrk(pageSize);
		printf(1, "array1[%d] = 0x%x\n", i, array1[i]);
	}
	array1[0][3] = 'k';
	array1[1][3] = 'k';
	array1[2][3] = 'k';

	printMem();
}

void test4() {
	char* array1;
	int testSetOfPages = 1000;
	int randPage;
	array1 = malloc(arraySize);

	for (int j = 0; j < testSetOfPages; j++) {
		randPage = getRandNum();
		array1[randPage] = 'X';
	}
	printMem();
	free(array1);
}

int main(int argc, char *argv[]){
	
	//test_badLocal(500);			//for testing each policy efficiency
	test4();
	exit();
  //forkTest();			//for testing swapping machanism in fork.
  
}

//1023
//8002

//7767//ifdijf