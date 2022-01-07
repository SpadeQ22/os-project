
_myMemTest:     file format elf32-i386


Disassembly of section .text:

00000000 <getRandNum>:
#define arraySize 53248



static unsigned long int next = 1;
int getRandNum() {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
  next = next * 1103515245 + 12341;
   7:	a1 34 0f 00 00       	mov    0xf34,%eax
   c:	69 c0 6d 4e c6 41    	imul   $0x41c64e6d,%eax,%eax
  12:	05 35 30 00 00       	add    $0x3035,%eax
  17:	a3 34 0f 00 00       	mov    %eax,0xf34
  return (unsigned int)(next/65536) % (arraySize);
  1c:	a1 34 0f 00 00       	mov    0xf34,%eax
  21:	c1 e8 10             	shr    $0x10,%eax
  24:	89 c1                	mov    %eax,%ecx
  26:	ba 4f ec c4 4e       	mov    $0x4ec4ec4f,%edx
  2b:	89 c8                	mov    %ecx,%eax
  2d:	f7 e2                	mul    %edx
  2f:	89 d0                	mov    %edx,%eax
  31:	c1 e8 0e             	shr    $0xe,%eax
  34:	69 c0 00 d0 00 00    	imul   $0xd000,%eax,%eax
  3a:	29 c1                	sub    %eax,%ecx
  3c:	89 c8                	mov    %ecx,%eax
}
  3e:	5d                   	pop    %ebp
  3f:	c3                   	ret    

00000040 <globalTest>:
Results (for TEST_POOL = 500):
LIFO: 42 Page faults
LAP: 18 Page faults
SCFIFO: 35 Page faults
*/
void globalTest(uint TEST_POOL){
  40:	f3 0f 1e fb          	endbr32 
  44:	55                   	push   %ebp
  45:	89 e5                	mov    %esp,%ebp
  47:	83 ec 18             	sub    $0x18,%esp
	char * arr;
	int randNum;
	arr = malloc(arraySize); //allocates 14 pages (sums to 17 - to allow more then one swapping in scfifo)
  4a:	83 ec 0c             	sub    $0xc,%esp
  4d:	68 00 d0 00 00       	push   $0xd000
  52:	e8 7d 0a 00 00       	call   ad4 <malloc>
  57:	83 c4 10             	add    $0x10,%esp
  5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (int i = 0; i < TEST_POOL; i++) {
  5d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  64:	eb 33                	jmp    99 <globalTest+0x59>
		randNum = getRandNum();	//generates a pseudo random number between 0 and arraySize
  66:	e8 95 ff ff ff       	call   0 <getRandNum>
  6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		while (pageSize*10-8 < randNum && randNum < pageSize*10+pageSize/2-8){
  6e:	eb 08                	jmp    78 <globalTest+0x38>
			randNum = getRandNum(); //gives page #13 50% less chance of being selected
  70:	e8 8b ff ff ff       	call   0 <getRandNum>
  75:	89 45 f4             	mov    %eax,-0xc(%ebp)
		while (pageSize*10-8 < randNum && randNum < pageSize*10+pageSize/2-8){
  78:	81 7d f4 f8 9f 00 00 	cmpl   $0x9ff8,-0xc(%ebp)
  7f:	7e 09                	jle    8a <globalTest+0x4a>
  81:	81 7d f4 f7 a7 00 00 	cmpl   $0xa7f7,-0xc(%ebp)
  88:	7e e6                	jle    70 <globalTest+0x30>
		}
		arr[randNum] = 'X';				//write to memory
  8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  90:	01 d0                	add    %edx,%eax
  92:	c6 00 58             	movb   $0x58,(%eax)
	for (int i = 0; i < TEST_POOL; i++) {
  95:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  99:	8b 45 f0             	mov    -0x10(%ebp),%eax
  9c:	39 45 08             	cmp    %eax,0x8(%ebp)
  9f:	77 c5                	ja     66 <globalTest+0x26>
		
	}
	printMem();
  a1:	e8 6a 06 00 00       	call   710 <printMem>
	free(arr);
  a6:	83 ec 0c             	sub    $0xc,%esp
  a9:	ff 75 ec             	pushl  -0x14(%ebp)
  ac:	e8 d9 08 00 00       	call   98a <free>
  b1:	83 c4 10             	add    $0x10,%esp
}
  b4:	90                   	nop
  b5:	c9                   	leave  
  b6:	c3                   	ret    

000000b7 <linearSweep>:

void linearSweep(uint TEST_POOL){
  b7:	f3 0f 1e fb          	endbr32 
  bb:	55                   	push   %ebp
  bc:	89 e5                	mov    %esp,%ebp
  be:	83 ec 18             	sub    $0x18,%esp
	char * arr;
	//int randNum;
	arr = malloc(arraySize); //allocates 14 pages (sums to 17 - to allow more then one swapping in scfifo)
  c1:	83 ec 0c             	sub    $0xc,%esp
  c4:	68 00 d0 00 00       	push   $0xd000
  c9:	e8 06 0a 00 00       	call   ad4 <malloc>
  ce:	83 c4 10             	add    $0x10,%esp
  d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	for (int i = 0; i < TEST_POOL; i++) {
  d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  db:	eb 28                	jmp    105 <linearSweep+0x4e>
		for(int j = 0; j < arraySize; j+= pageSize)	//generates a pseudo random number between 0 and arraySize
  dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  e4:	eb 12                	jmp    f8 <linearSweep+0x41>
		
		arr[j] = 'X';				//write to memory
  e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  ec:	01 d0                	add    %edx,%eax
  ee:	c6 00 58             	movb   $0x58,(%eax)
		for(int j = 0; j < arraySize; j+= pageSize)	//generates a pseudo random number between 0 and arraySize
  f1:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
  f8:	81 7d f0 ff cf 00 00 	cmpl   $0xcfff,-0x10(%ebp)
  ff:	7e e5                	jle    e6 <linearSweep+0x2f>
	for (int i = 0; i < TEST_POOL; i++) {
 101:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 105:	8b 45 f4             	mov    -0xc(%ebp),%eax
 108:	39 45 08             	cmp    %eax,0x8(%ebp)
 10b:	77 d0                	ja     dd <linearSweep+0x26>
		
	}
	printMem();
 10d:	e8 fe 05 00 00       	call   710 <printMem>
	free(arr);
 112:	83 ec 0c             	sub    $0xc,%esp
 115:	ff 75 ec             	pushl  -0x14(%ebp)
 118:	e8 6d 08 00 00       	call   98a <free>
 11d:	83 c4 10             	add    $0x10,%esp
} 
 120:	90                   	nop
 121:	c9                   	leave  
 122:	c3                   	ret    

00000123 <irand>:

unsigned seed = 871753752;

unsigned int
irand(int l, int h)
{
 123:	f3 0f 1e fb          	endbr32 
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	83 ec 20             	sub    $0x20,%esp
	unsigned int a = 1588635695, m = 429496U, q = 2, r = 1117695901;
 12d:	c7 45 fc 2f a8 b0 5e 	movl   $0x5eb0a82f,-0x4(%ebp)
 134:	c7 45 f8 b8 8d 06 00 	movl   $0x68db8,-0x8(%ebp)
 13b:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
 142:	c7 45 f0 9d af 9e 42 	movl   $0x429eaf9d,-0x10(%ebp)
	unsigned int val;

	seed = a*(seed % q) - r*(seed / q);
 149:	a1 38 0f 00 00       	mov    0xf38,%eax
 14e:	ba 00 00 00 00       	mov    $0x0,%edx
 153:	f7 75 f4             	divl   -0xc(%ebp)
 156:	89 d0                	mov    %edx,%eax
 158:	0f af 45 fc          	imul   -0x4(%ebp),%eax
 15c:	89 c1                	mov    %eax,%ecx
 15e:	a1 38 0f 00 00       	mov    0xf38,%eax
 163:	ba 00 00 00 00       	mov    $0x0,%edx
 168:	f7 75 f4             	divl   -0xc(%ebp)
 16b:	0f af 45 f0          	imul   -0x10(%ebp),%eax
 16f:	29 c1                	sub    %eax,%ecx
 171:	89 c8                	mov    %ecx,%eax
 173:	a3 38 0f 00 00       	mov    %eax,0xf38
	val = (seed / m) % (h - l) + l;
 178:	a1 38 0f 00 00       	mov    0xf38,%eax
 17d:	ba 00 00 00 00       	mov    $0x0,%edx
 182:	f7 75 f8             	divl   -0x8(%ebp)
 185:	89 c2                	mov    %eax,%edx
 187:	8b 45 0c             	mov    0xc(%ebp),%eax
 18a:	2b 45 08             	sub    0x8(%ebp),%eax
 18d:	89 c1                	mov    %eax,%ecx
 18f:	89 d0                	mov    %edx,%eax
 191:	ba 00 00 00 00       	mov    $0x0,%edx
 196:	f7 f1                	div    %ecx
 198:	8b 45 08             	mov    0x8(%ebp),%eax
 19b:	01 d0                	add    %edx,%eax
 19d:	89 45 ec             	mov    %eax,-0x14(%ebp)

	return val;
 1a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
 1a3:	c9                   	leave  
 1a4:	c3                   	ret    

000001a5 <test_badLocal>:

void
test_badLocal()
{
 1a5:	f3 0f 1e fb          	endbr32 
 1a9:	55                   	push   %ebp
 1aa:	89 e5                	mov    %esp,%ebp
 1ac:	83 ec 58             	sub    $0x58,%esp
	char *arr[14];
	int i;//j;


	for (i = 0; i < 21; i++){
 1af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b6:	eb 1b                	jmp    1d3 <test_badLocal+0x2e>
		arr[i] = sbrk(pageSize);
 1b8:	83 ec 0c             	sub    $0xc,%esp
 1bb:	68 00 10 00 00       	push   $0x1000
 1c0:	e8 33 05 00 00       	call   6f8 <sbrk>
 1c5:	83 c4 10             	add    $0x10,%esp
 1c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1cb:	89 44 95 b0          	mov    %eax,-0x50(%ebp,%edx,4)
	for (i = 0; i < 21; i++){
 1cf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1d3:	83 7d f4 14          	cmpl   $0x14,-0xc(%ebp)
 1d7:	7e df                	jle    1b8 <test_badLocal+0x13>
	}

	int k;
	int rand1,rand2; 

	for (k = 0; k < 300; k++){			//in total 72 000 references
 1d9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 1e0:	eb 73                	jmp    255 <test_badLocal+0xb0>
		for (i = 0; i < 19; i++){
 1e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1e9:	eb 5b                	jmp    246 <test_badLocal+0xa1>
				rand1 = irand(0, 17);	
 1eb:	83 ec 08             	sub    $0x8,%esp
 1ee:	6a 11                	push   $0x11
 1f0:	6a 00                	push   $0x0
 1f2:	e8 2c ff ff ff       	call   123 <irand>
 1f7:	83 c4 10             	add    $0x10,%esp
 1fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
				rand2 = irand(0, 16);	
 1fd:	83 ec 08             	sub    $0x8,%esp
 200:	6a 10                	push   $0x10
 202:	6a 00                	push   $0x0
 204:	e8 1a ff ff ff       	call   123 <irand>
 209:	83 c4 10             	add    $0x10,%esp
 20c:	89 45 e8             	mov    %eax,-0x18(%ebp)
				arr[i][rand1] ='x';	// choose element 1 and 35 to make sure they are on different pages, since every page is 128 contenting 32 integers
 20f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 212:	8b 54 85 b0          	mov    -0x50(%ebp,%eax,4),%edx
 216:	8b 45 ec             	mov    -0x14(%ebp),%eax
 219:	01 d0                	add    %edx,%eax
 21b:	c6 00 78             	movb   $0x78,(%eax)
				arr[i+1][rand2] = 's';	
 21e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 221:	83 c0 01             	add    $0x1,%eax
 224:	8b 54 85 b0          	mov    -0x50(%ebp,%eax,4),%edx
 228:	8b 45 e8             	mov    -0x18(%ebp),%eax
 22b:	01 d0                	add    %edx,%eax
 22d:	c6 00 73             	movb   $0x73,(%eax)
				arr[1][1] = 'x';	//frequently referenced element
 230:	8b 45 b4             	mov    -0x4c(%ebp),%eax
 233:	83 c0 01             	add    $0x1,%eax
 236:	c6 00 78             	movb   $0x78,(%eax)
				arr[19][20] = 'x';	//frequently referenced element
 239:	8b 45 fc             	mov    -0x4(%ebp),%eax
 23c:	83 c0 14             	add    $0x14,%eax
 23f:	c6 00 78             	movb   $0x78,(%eax)
		for (i = 0; i < 19; i++){
 242:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 246:	83 7d f4 12          	cmpl   $0x12,-0xc(%ebp)
 24a:	7e 9f                	jle    1eb <test_badLocal+0x46>
		}
		printMem();
 24c:	e8 bf 04 00 00       	call   710 <printMem>
	for (k = 0; k < 300; k++){			//in total 72 000 references
 251:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 255:	81 7d f0 2b 01 00 00 	cmpl   $0x12b,-0x10(%ebp)
 25c:	7e 84                	jle    1e2 <test_badLocal+0x3d>
	}
}
 25e:	90                   	nop
 25f:	90                   	nop
 260:	c9                   	leave  
 261:	c3                   	ret    

00000262 <test1>:

void test1() {
 262:	f3 0f 1e fb          	endbr32 
 266:	55                   	push   %ebp
 267:	89 e5                	mov    %esp,%ebp
 269:	83 ec 48             	sub    $0x48,%esp
	char* array1[14];
	
	for (int i = 0; i < 12; ++i) {
 26c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 273:	eb 35                	jmp    2aa <test1+0x48>
		array1[i] = sbrk(pageSize);
 275:	83 ec 0c             	sub    $0xc,%esp
 278:	68 00 10 00 00       	push   $0x1000
 27d:	e8 76 04 00 00       	call   6f8 <sbrk>
 282:	83 c4 10             	add    $0x10,%esp
 285:	8b 55 f4             	mov    -0xc(%ebp),%edx
 288:	89 44 95 bc          	mov    %eax,-0x44(%ebp,%edx,4)
		printf(1, "array1[%d] = 0x%x\n", i, array1[i]);
 28c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 28f:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
 293:	50                   	push   %eax
 294:	ff 75 f4             	pushl  -0xc(%ebp)
 297:	68 bb 0b 00 00       	push   $0xbbb
 29c:	6a 01                	push   $0x1
 29e:	e8 51 05 00 00       	call   7f4 <printf>
 2a3:	83 c4 10             	add    $0x10,%esp
	for (int i = 0; i < 12; ++i) {
 2a6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 2aa:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
 2ae:	7e c5                	jle    275 <test1+0x13>
	}
	printMem();
 2b0:	e8 5b 04 00 00       	call   710 <printMem>
}
 2b5:	90                   	nop
 2b6:	c9                   	leave  
 2b7:	c3                   	ret    

000002b8 <test2>:
void test2() {
 2b8:	f3 0f 1e fb          	endbr32 
 2bc:	55                   	push   %ebp
 2bd:	89 e5                	mov    %esp,%ebp
 2bf:	83 ec 48             	sub    $0x48,%esp
	char* array1[14];

	for (int i = 0; i < 13; ++i) {
 2c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2c9:	eb 35                	jmp    300 <test2+0x48>
		array1[i] = sbrk(pageSize);
 2cb:	83 ec 0c             	sub    $0xc,%esp
 2ce:	68 00 10 00 00       	push   $0x1000
 2d3:	e8 20 04 00 00       	call   6f8 <sbrk>
 2d8:	83 c4 10             	add    $0x10,%esp
 2db:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2de:	89 44 95 bc          	mov    %eax,-0x44(%ebp,%edx,4)
		printf(1, "array1[%d] = 0x%x\n", i, array1[i]);
 2e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e5:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
 2e9:	50                   	push   %eax
 2ea:	ff 75 f4             	pushl  -0xc(%ebp)
 2ed:	68 bb 0b 00 00       	push   $0xbbb
 2f2:	6a 01                	push   $0x1
 2f4:	e8 fb 04 00 00       	call   7f4 <printf>
 2f9:	83 c4 10             	add    $0x10,%esp
	for (int i = 0; i < 13; ++i) {
 2fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 300:	83 7d f4 0c          	cmpl   $0xc,-0xc(%ebp)
 304:	7e c5                	jle    2cb <test2+0x13>
	}
	printMem();
 306:	e8 05 04 00 00       	call   710 <printMem>
}
 30b:	90                   	nop
 30c:	c9                   	leave  
 30d:	c3                   	ret    

0000030e <test3>:

void test3() {
 30e:	f3 0f 1e fb          	endbr32 
 312:	55                   	push   %ebp
 313:	89 e5                	mov    %esp,%ebp
 315:	83 ec 48             	sub    $0x48,%esp
	char* array1[14];

	for (int i = 0; i < 14; ++i) {
 318:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 31f:	eb 35                	jmp    356 <test3+0x48>
		array1[i] = sbrk(pageSize);
 321:	83 ec 0c             	sub    $0xc,%esp
 324:	68 00 10 00 00       	push   $0x1000
 329:	e8 ca 03 00 00       	call   6f8 <sbrk>
 32e:	83 c4 10             	add    $0x10,%esp
 331:	8b 55 f4             	mov    -0xc(%ebp),%edx
 334:	89 44 95 bc          	mov    %eax,-0x44(%ebp,%edx,4)
		printf(1, "array1[%d] = 0x%x\n", i, array1[i]);
 338:	8b 45 f4             	mov    -0xc(%ebp),%eax
 33b:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
 33f:	50                   	push   %eax
 340:	ff 75 f4             	pushl  -0xc(%ebp)
 343:	68 bb 0b 00 00       	push   $0xbbb
 348:	6a 01                	push   $0x1
 34a:	e8 a5 04 00 00       	call   7f4 <printf>
 34f:	83 c4 10             	add    $0x10,%esp
	for (int i = 0; i < 14; ++i) {
 352:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 356:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
 35a:	7e c5                	jle    321 <test3+0x13>
	}
	array1[0][3] = 'k';
 35c:	8b 45 bc             	mov    -0x44(%ebp),%eax
 35f:	83 c0 03             	add    $0x3,%eax
 362:	c6 00 6b             	movb   $0x6b,(%eax)
	array1[1][3] = 'k';
 365:	8b 45 c0             	mov    -0x40(%ebp),%eax
 368:	83 c0 03             	add    $0x3,%eax
 36b:	c6 00 6b             	movb   $0x6b,(%eax)
	array1[2][3] = 'k';
 36e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
 371:	83 c0 03             	add    $0x3,%eax
 374:	c6 00 6b             	movb   $0x6b,(%eax)

	printMem();
 377:	e8 94 03 00 00       	call   710 <printMem>
}
 37c:	90                   	nop
 37d:	c9                   	leave  
 37e:	c3                   	ret    

0000037f <test4>:

void test4() {
 37f:	f3 0f 1e fb          	endbr32 
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	83 ec 18             	sub    $0x18,%esp
	char* array1;
	int testSetOfPages = 1000;
 389:	c7 45 f0 e8 03 00 00 	movl   $0x3e8,-0x10(%ebp)
	int randPage;
	array1 = malloc(arraySize);
 390:	83 ec 0c             	sub    $0xc,%esp
 393:	68 00 d0 00 00       	push   $0xd000
 398:	e8 37 07 00 00       	call   ad4 <malloc>
 39d:	83 c4 10             	add    $0x10,%esp
 3a0:	89 45 ec             	mov    %eax,-0x14(%ebp)

	for (int j = 0; j < testSetOfPages; j++) {
 3a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3aa:	eb 17                	jmp    3c3 <test4+0x44>
		randPage = getRandNum();
 3ac:	e8 4f fc ff ff       	call   0 <getRandNum>
 3b1:	89 45 e8             	mov    %eax,-0x18(%ebp)
		array1[randPage] = 'X';
 3b4:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ba:	01 d0                	add    %edx,%eax
 3bc:	c6 00 58             	movb   $0x58,(%eax)
	for (int j = 0; j < testSetOfPages; j++) {
 3bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 3c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 3c9:	7c e1                	jl     3ac <test4+0x2d>
	}
	printMem();
 3cb:	e8 40 03 00 00       	call   710 <printMem>
	free(array1);
 3d0:	83 ec 0c             	sub    $0xc,%esp
 3d3:	ff 75 ec             	pushl  -0x14(%ebp)
 3d6:	e8 af 05 00 00       	call   98a <free>
 3db:	83 c4 10             	add    $0x10,%esp
}
 3de:	90                   	nop
 3df:	c9                   	leave  
 3e0:	c3                   	ret    

000003e1 <main>:

int main(int argc, char *argv[]){
 3e1:	f3 0f 1e fb          	endbr32 
 3e5:	55                   	push   %ebp
 3e6:	89 e5                	mov    %esp,%ebp
 3e8:	83 e4 f0             	and    $0xfffffff0,%esp
	
	//test_badLocal(500);			//for testing each policy efficiency
	test4();
 3eb:	e8 8f ff ff ff       	call   37f <test4>
	exit();
 3f0:	e8 7b 02 00 00       	call   670 <exit>

000003f5 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 3f5:	55                   	push   %ebp
 3f6:	89 e5                	mov    %esp,%ebp
 3f8:	57                   	push   %edi
 3f9:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 3fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
 3fd:	8b 55 10             	mov    0x10(%ebp),%edx
 400:	8b 45 0c             	mov    0xc(%ebp),%eax
 403:	89 cb                	mov    %ecx,%ebx
 405:	89 df                	mov    %ebx,%edi
 407:	89 d1                	mov    %edx,%ecx
 409:	fc                   	cld    
 40a:	f3 aa                	rep stos %al,%es:(%edi)
 40c:	89 ca                	mov    %ecx,%edx
 40e:	89 fb                	mov    %edi,%ebx
 410:	89 5d 08             	mov    %ebx,0x8(%ebp)
 413:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 416:	90                   	nop
 417:	5b                   	pop    %ebx
 418:	5f                   	pop    %edi
 419:	5d                   	pop    %ebp
 41a:	c3                   	ret    

0000041b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 41b:	f3 0f 1e fb          	endbr32 
 41f:	55                   	push   %ebp
 420:	89 e5                	mov    %esp,%ebp
 422:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 42b:	90                   	nop
 42c:	8b 55 0c             	mov    0xc(%ebp),%edx
 42f:	8d 42 01             	lea    0x1(%edx),%eax
 432:	89 45 0c             	mov    %eax,0xc(%ebp)
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	8d 48 01             	lea    0x1(%eax),%ecx
 43b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 43e:	0f b6 12             	movzbl (%edx),%edx
 441:	88 10                	mov    %dl,(%eax)
 443:	0f b6 00             	movzbl (%eax),%eax
 446:	84 c0                	test   %al,%al
 448:	75 e2                	jne    42c <strcpy+0x11>
    ;
  return os;
 44a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 44d:	c9                   	leave  
 44e:	c3                   	ret    

0000044f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 44f:	f3 0f 1e fb          	endbr32 
 453:	55                   	push   %ebp
 454:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 456:	eb 08                	jmp    460 <strcmp+0x11>
    p++, q++;
 458:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 45c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 460:	8b 45 08             	mov    0x8(%ebp),%eax
 463:	0f b6 00             	movzbl (%eax),%eax
 466:	84 c0                	test   %al,%al
 468:	74 10                	je     47a <strcmp+0x2b>
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	0f b6 10             	movzbl (%eax),%edx
 470:	8b 45 0c             	mov    0xc(%ebp),%eax
 473:	0f b6 00             	movzbl (%eax),%eax
 476:	38 c2                	cmp    %al,%dl
 478:	74 de                	je     458 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 47a:	8b 45 08             	mov    0x8(%ebp),%eax
 47d:	0f b6 00             	movzbl (%eax),%eax
 480:	0f b6 d0             	movzbl %al,%edx
 483:	8b 45 0c             	mov    0xc(%ebp),%eax
 486:	0f b6 00             	movzbl (%eax),%eax
 489:	0f b6 c0             	movzbl %al,%eax
 48c:	29 c2                	sub    %eax,%edx
 48e:	89 d0                	mov    %edx,%eax
}
 490:	5d                   	pop    %ebp
 491:	c3                   	ret    

00000492 <strlen>:

uint
strlen(char *s)
{
 492:	f3 0f 1e fb          	endbr32 
 496:	55                   	push   %ebp
 497:	89 e5                	mov    %esp,%ebp
 499:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 49c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4a3:	eb 04                	jmp    4a9 <strlen+0x17>
 4a5:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 4a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ac:	8b 45 08             	mov    0x8(%ebp),%eax
 4af:	01 d0                	add    %edx,%eax
 4b1:	0f b6 00             	movzbl (%eax),%eax
 4b4:	84 c0                	test   %al,%al
 4b6:	75 ed                	jne    4a5 <strlen+0x13>
    ;
  return n;
 4b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4bb:	c9                   	leave  
 4bc:	c3                   	ret    

000004bd <memset>:

void*
memset(void *dst, int c, uint n)
{
 4bd:	f3 0f 1e fb          	endbr32 
 4c1:	55                   	push   %ebp
 4c2:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 4c4:	8b 45 10             	mov    0x10(%ebp),%eax
 4c7:	50                   	push   %eax
 4c8:	ff 75 0c             	pushl  0xc(%ebp)
 4cb:	ff 75 08             	pushl  0x8(%ebp)
 4ce:	e8 22 ff ff ff       	call   3f5 <stosb>
 4d3:	83 c4 0c             	add    $0xc,%esp
  return dst;
 4d6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4d9:	c9                   	leave  
 4da:	c3                   	ret    

000004db <strchr>:

char*
strchr(const char *s, char c)
{
 4db:	f3 0f 1e fb          	endbr32 
 4df:	55                   	push   %ebp
 4e0:	89 e5                	mov    %esp,%ebp
 4e2:	83 ec 04             	sub    $0x4,%esp
 4e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4eb:	eb 14                	jmp    501 <strchr+0x26>
    if(*s == c)
 4ed:	8b 45 08             	mov    0x8(%ebp),%eax
 4f0:	0f b6 00             	movzbl (%eax),%eax
 4f3:	38 45 fc             	cmp    %al,-0x4(%ebp)
 4f6:	75 05                	jne    4fd <strchr+0x22>
      return (char*)s;
 4f8:	8b 45 08             	mov    0x8(%ebp),%eax
 4fb:	eb 13                	jmp    510 <strchr+0x35>
  for(; *s; s++)
 4fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 501:	8b 45 08             	mov    0x8(%ebp),%eax
 504:	0f b6 00             	movzbl (%eax),%eax
 507:	84 c0                	test   %al,%al
 509:	75 e2                	jne    4ed <strchr+0x12>
  return 0;
 50b:	b8 00 00 00 00       	mov    $0x0,%eax
}
 510:	c9                   	leave  
 511:	c3                   	ret    

00000512 <gets>:

char*
gets(char *buf, int max)
{
 512:	f3 0f 1e fb          	endbr32 
 516:	55                   	push   %ebp
 517:	89 e5                	mov    %esp,%ebp
 519:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 51c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 523:	eb 42                	jmp    567 <gets+0x55>
    cc = read(0, &c, 1);
 525:	83 ec 04             	sub    $0x4,%esp
 528:	6a 01                	push   $0x1
 52a:	8d 45 ef             	lea    -0x11(%ebp),%eax
 52d:	50                   	push   %eax
 52e:	6a 00                	push   $0x0
 530:	e8 53 01 00 00       	call   688 <read>
 535:	83 c4 10             	add    $0x10,%esp
 538:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 53b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 53f:	7e 33                	jle    574 <gets+0x62>
      break;
    buf[i++] = c;
 541:	8b 45 f4             	mov    -0xc(%ebp),%eax
 544:	8d 50 01             	lea    0x1(%eax),%edx
 547:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54a:	89 c2                	mov    %eax,%edx
 54c:	8b 45 08             	mov    0x8(%ebp),%eax
 54f:	01 c2                	add    %eax,%edx
 551:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 555:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 557:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 55b:	3c 0a                	cmp    $0xa,%al
 55d:	74 16                	je     575 <gets+0x63>
 55f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 563:	3c 0d                	cmp    $0xd,%al
 565:	74 0e                	je     575 <gets+0x63>
  for(i=0; i+1 < max; ){
 567:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56a:	83 c0 01             	add    $0x1,%eax
 56d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 570:	7f b3                	jg     525 <gets+0x13>
 572:	eb 01                	jmp    575 <gets+0x63>
      break;
 574:	90                   	nop
      break;
  }
  buf[i] = '\0';
 575:	8b 55 f4             	mov    -0xc(%ebp),%edx
 578:	8b 45 08             	mov    0x8(%ebp),%eax
 57b:	01 d0                	add    %edx,%eax
 57d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 580:	8b 45 08             	mov    0x8(%ebp),%eax
}
 583:	c9                   	leave  
 584:	c3                   	ret    

00000585 <stat>:

int
stat(char *n, struct stat *st)
{
 585:	f3 0f 1e fb          	endbr32 
 589:	55                   	push   %ebp
 58a:	89 e5                	mov    %esp,%ebp
 58c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 58f:	83 ec 08             	sub    $0x8,%esp
 592:	6a 00                	push   $0x0
 594:	ff 75 08             	pushl  0x8(%ebp)
 597:	e8 14 01 00 00       	call   6b0 <open>
 59c:	83 c4 10             	add    $0x10,%esp
 59f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 5a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a6:	79 07                	jns    5af <stat+0x2a>
    return -1;
 5a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5ad:	eb 25                	jmp    5d4 <stat+0x4f>
  r = fstat(fd, st);
 5af:	83 ec 08             	sub    $0x8,%esp
 5b2:	ff 75 0c             	pushl  0xc(%ebp)
 5b5:	ff 75 f4             	pushl  -0xc(%ebp)
 5b8:	e8 0b 01 00 00       	call   6c8 <fstat>
 5bd:	83 c4 10             	add    $0x10,%esp
 5c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5c3:	83 ec 0c             	sub    $0xc,%esp
 5c6:	ff 75 f4             	pushl  -0xc(%ebp)
 5c9:	e8 ca 00 00 00       	call   698 <close>
 5ce:	83 c4 10             	add    $0x10,%esp
  return r;
 5d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5d4:	c9                   	leave  
 5d5:	c3                   	ret    

000005d6 <atoi>:

int
atoi(const char *s)
{
 5d6:	f3 0f 1e fb          	endbr32 
 5da:	55                   	push   %ebp
 5db:	89 e5                	mov    %esp,%ebp
 5dd:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5e7:	eb 25                	jmp    60e <atoi+0x38>
    n = n*10 + *s++ - '0';
 5e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5ec:	89 d0                	mov    %edx,%eax
 5ee:	c1 e0 02             	shl    $0x2,%eax
 5f1:	01 d0                	add    %edx,%eax
 5f3:	01 c0                	add    %eax,%eax
 5f5:	89 c1                	mov    %eax,%ecx
 5f7:	8b 45 08             	mov    0x8(%ebp),%eax
 5fa:	8d 50 01             	lea    0x1(%eax),%edx
 5fd:	89 55 08             	mov    %edx,0x8(%ebp)
 600:	0f b6 00             	movzbl (%eax),%eax
 603:	0f be c0             	movsbl %al,%eax
 606:	01 c8                	add    %ecx,%eax
 608:	83 e8 30             	sub    $0x30,%eax
 60b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	0f b6 00             	movzbl (%eax),%eax
 614:	3c 2f                	cmp    $0x2f,%al
 616:	7e 0a                	jle    622 <atoi+0x4c>
 618:	8b 45 08             	mov    0x8(%ebp),%eax
 61b:	0f b6 00             	movzbl (%eax),%eax
 61e:	3c 39                	cmp    $0x39,%al
 620:	7e c7                	jle    5e9 <atoi+0x13>
  return n;
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 625:	c9                   	leave  
 626:	c3                   	ret    

00000627 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 627:	f3 0f 1e fb          	endbr32 
 62b:	55                   	push   %ebp
 62c:	89 e5                	mov    %esp,%ebp
 62e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 631:	8b 45 08             	mov    0x8(%ebp),%eax
 634:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 637:	8b 45 0c             	mov    0xc(%ebp),%eax
 63a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 63d:	eb 17                	jmp    656 <memmove+0x2f>
    *dst++ = *src++;
 63f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 642:	8d 42 01             	lea    0x1(%edx),%eax
 645:	89 45 f8             	mov    %eax,-0x8(%ebp)
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8d 48 01             	lea    0x1(%eax),%ecx
 64e:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 651:	0f b6 12             	movzbl (%edx),%edx
 654:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 656:	8b 45 10             	mov    0x10(%ebp),%eax
 659:	8d 50 ff             	lea    -0x1(%eax),%edx
 65c:	89 55 10             	mov    %edx,0x10(%ebp)
 65f:	85 c0                	test   %eax,%eax
 661:	7f dc                	jg     63f <memmove+0x18>
  return vdst;
 663:	8b 45 08             	mov    0x8(%ebp),%eax
}
 666:	c9                   	leave  
 667:	c3                   	ret    

00000668 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 668:	b8 01 00 00 00       	mov    $0x1,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <exit>:
SYSCALL(exit)
 670:	b8 02 00 00 00       	mov    $0x2,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <wait>:
SYSCALL(wait)
 678:	b8 03 00 00 00       	mov    $0x3,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <pipe>:
SYSCALL(pipe)
 680:	b8 04 00 00 00       	mov    $0x4,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <read>:
SYSCALL(read)
 688:	b8 05 00 00 00       	mov    $0x5,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <write>:
SYSCALL(write)
 690:	b8 10 00 00 00       	mov    $0x10,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <close>:
SYSCALL(close)
 698:	b8 15 00 00 00       	mov    $0x15,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <kill>:
SYSCALL(kill)
 6a0:	b8 06 00 00 00       	mov    $0x6,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <exec>:
SYSCALL(exec)
 6a8:	b8 07 00 00 00       	mov    $0x7,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <open>:
SYSCALL(open)
 6b0:	b8 0f 00 00 00       	mov    $0xf,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <mknod>:
SYSCALL(mknod)
 6b8:	b8 11 00 00 00       	mov    $0x11,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <unlink>:
SYSCALL(unlink)
 6c0:	b8 12 00 00 00       	mov    $0x12,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <fstat>:
SYSCALL(fstat)
 6c8:	b8 08 00 00 00       	mov    $0x8,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <link>:
SYSCALL(link)
 6d0:	b8 13 00 00 00       	mov    $0x13,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <mkdir>:
SYSCALL(mkdir)
 6d8:	b8 14 00 00 00       	mov    $0x14,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <chdir>:
SYSCALL(chdir)
 6e0:	b8 09 00 00 00       	mov    $0x9,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <dup>:
SYSCALL(dup)
 6e8:	b8 0a 00 00 00       	mov    $0xa,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <getpid>:
SYSCALL(getpid)
 6f0:	b8 0b 00 00 00       	mov    $0xb,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <sbrk>:
SYSCALL(sbrk)
 6f8:	b8 0c 00 00 00       	mov    $0xc,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <sleep>:
SYSCALL(sleep)
 700:	b8 0d 00 00 00       	mov    $0xd,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <uptime>:
SYSCALL(uptime)
 708:	b8 0e 00 00 00       	mov    $0xe,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <printMem>:
 710:	b8 16 00 00 00       	mov    $0x16,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 718:	f3 0f 1e fb          	endbr32 
 71c:	55                   	push   %ebp
 71d:	89 e5                	mov    %esp,%ebp
 71f:	83 ec 18             	sub    $0x18,%esp
 722:	8b 45 0c             	mov    0xc(%ebp),%eax
 725:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 728:	83 ec 04             	sub    $0x4,%esp
 72b:	6a 01                	push   $0x1
 72d:	8d 45 f4             	lea    -0xc(%ebp),%eax
 730:	50                   	push   %eax
 731:	ff 75 08             	pushl  0x8(%ebp)
 734:	e8 57 ff ff ff       	call   690 <write>
 739:	83 c4 10             	add    $0x10,%esp
}
 73c:	90                   	nop
 73d:	c9                   	leave  
 73e:	c3                   	ret    

0000073f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 73f:	f3 0f 1e fb          	endbr32 
 743:	55                   	push   %ebp
 744:	89 e5                	mov    %esp,%ebp
 746:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 749:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 750:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 754:	74 17                	je     76d <printint+0x2e>
 756:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 75a:	79 11                	jns    76d <printint+0x2e>
    neg = 1;
 75c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 763:	8b 45 0c             	mov    0xc(%ebp),%eax
 766:	f7 d8                	neg    %eax
 768:	89 45 ec             	mov    %eax,-0x14(%ebp)
 76b:	eb 06                	jmp    773 <printint+0x34>
  } else {
    x = xx;
 76d:	8b 45 0c             	mov    0xc(%ebp),%eax
 770:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 77a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 77d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 780:	ba 00 00 00 00       	mov    $0x0,%edx
 785:	f7 f1                	div    %ecx
 787:	89 d1                	mov    %edx,%ecx
 789:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78c:	8d 50 01             	lea    0x1(%eax),%edx
 78f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 792:	0f b6 91 3c 0f 00 00 	movzbl 0xf3c(%ecx),%edx
 799:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 79d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 7a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7a3:	ba 00 00 00 00       	mov    $0x0,%edx
 7a8:	f7 f1                	div    %ecx
 7aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7ad:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7b1:	75 c7                	jne    77a <printint+0x3b>
  if(neg)
 7b3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7b7:	74 2d                	je     7e6 <printint+0xa7>
    buf[i++] = '-';
 7b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bc:	8d 50 01             	lea    0x1(%eax),%edx
 7bf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7c2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7c7:	eb 1d                	jmp    7e6 <printint+0xa7>
    putc(fd, buf[i]);
 7c9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cf:	01 d0                	add    %edx,%eax
 7d1:	0f b6 00             	movzbl (%eax),%eax
 7d4:	0f be c0             	movsbl %al,%eax
 7d7:	83 ec 08             	sub    $0x8,%esp
 7da:	50                   	push   %eax
 7db:	ff 75 08             	pushl  0x8(%ebp)
 7de:	e8 35 ff ff ff       	call   718 <putc>
 7e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 7e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 7ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7ee:	79 d9                	jns    7c9 <printint+0x8a>
}
 7f0:	90                   	nop
 7f1:	90                   	nop
 7f2:	c9                   	leave  
 7f3:	c3                   	ret    

000007f4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 7f4:	f3 0f 1e fb          	endbr32 
 7f8:	55                   	push   %ebp
 7f9:	89 e5                	mov    %esp,%ebp
 7fb:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 7fe:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 805:	8d 45 0c             	lea    0xc(%ebp),%eax
 808:	83 c0 04             	add    $0x4,%eax
 80b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 80e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 815:	e9 59 01 00 00       	jmp    973 <printf+0x17f>
    c = fmt[i] & 0xff;
 81a:	8b 55 0c             	mov    0xc(%ebp),%edx
 81d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 820:	01 d0                	add    %edx,%eax
 822:	0f b6 00             	movzbl (%eax),%eax
 825:	0f be c0             	movsbl %al,%eax
 828:	25 ff 00 00 00       	and    $0xff,%eax
 82d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 830:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 834:	75 2c                	jne    862 <printf+0x6e>
      if(c == '%'){
 836:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 83a:	75 0c                	jne    848 <printf+0x54>
        state = '%';
 83c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 843:	e9 27 01 00 00       	jmp    96f <printf+0x17b>
      } else {
        putc(fd, c);
 848:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 84b:	0f be c0             	movsbl %al,%eax
 84e:	83 ec 08             	sub    $0x8,%esp
 851:	50                   	push   %eax
 852:	ff 75 08             	pushl  0x8(%ebp)
 855:	e8 be fe ff ff       	call   718 <putc>
 85a:	83 c4 10             	add    $0x10,%esp
 85d:	e9 0d 01 00 00       	jmp    96f <printf+0x17b>
      }
    } else if(state == '%'){
 862:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 866:	0f 85 03 01 00 00    	jne    96f <printf+0x17b>
      if(c == 'd'){
 86c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 870:	75 1e                	jne    890 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 872:	8b 45 e8             	mov    -0x18(%ebp),%eax
 875:	8b 00                	mov    (%eax),%eax
 877:	6a 01                	push   $0x1
 879:	6a 0a                	push   $0xa
 87b:	50                   	push   %eax
 87c:	ff 75 08             	pushl  0x8(%ebp)
 87f:	e8 bb fe ff ff       	call   73f <printint>
 884:	83 c4 10             	add    $0x10,%esp
        ap++;
 887:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 88b:	e9 d8 00 00 00       	jmp    968 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 890:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 894:	74 06                	je     89c <printf+0xa8>
 896:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 89a:	75 1e                	jne    8ba <printf+0xc6>
        printint(fd, *ap, 16, 0);
 89c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 89f:	8b 00                	mov    (%eax),%eax
 8a1:	6a 00                	push   $0x0
 8a3:	6a 10                	push   $0x10
 8a5:	50                   	push   %eax
 8a6:	ff 75 08             	pushl  0x8(%ebp)
 8a9:	e8 91 fe ff ff       	call   73f <printint>
 8ae:	83 c4 10             	add    $0x10,%esp
        ap++;
 8b1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8b5:	e9 ae 00 00 00       	jmp    968 <printf+0x174>
      } else if(c == 's'){
 8ba:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8be:	75 43                	jne    903 <printf+0x10f>
        s = (char*)*ap;
 8c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8c3:	8b 00                	mov    (%eax),%eax
 8c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8c8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8cc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8d0:	75 25                	jne    8f7 <printf+0x103>
          s = "(null)";
 8d2:	c7 45 f4 ce 0b 00 00 	movl   $0xbce,-0xc(%ebp)
        while(*s != 0){
 8d9:	eb 1c                	jmp    8f7 <printf+0x103>
          putc(fd, *s);
 8db:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8de:	0f b6 00             	movzbl (%eax),%eax
 8e1:	0f be c0             	movsbl %al,%eax
 8e4:	83 ec 08             	sub    $0x8,%esp
 8e7:	50                   	push   %eax
 8e8:	ff 75 08             	pushl  0x8(%ebp)
 8eb:	e8 28 fe ff ff       	call   718 <putc>
 8f0:	83 c4 10             	add    $0x10,%esp
          s++;
 8f3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 8f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fa:	0f b6 00             	movzbl (%eax),%eax
 8fd:	84 c0                	test   %al,%al
 8ff:	75 da                	jne    8db <printf+0xe7>
 901:	eb 65                	jmp    968 <printf+0x174>
        }
      } else if(c == 'c'){
 903:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 907:	75 1d                	jne    926 <printf+0x132>
        putc(fd, *ap);
 909:	8b 45 e8             	mov    -0x18(%ebp),%eax
 90c:	8b 00                	mov    (%eax),%eax
 90e:	0f be c0             	movsbl %al,%eax
 911:	83 ec 08             	sub    $0x8,%esp
 914:	50                   	push   %eax
 915:	ff 75 08             	pushl  0x8(%ebp)
 918:	e8 fb fd ff ff       	call   718 <putc>
 91d:	83 c4 10             	add    $0x10,%esp
        ap++;
 920:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 924:	eb 42                	jmp    968 <printf+0x174>
      } else if(c == '%'){
 926:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 92a:	75 17                	jne    943 <printf+0x14f>
        putc(fd, c);
 92c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 92f:	0f be c0             	movsbl %al,%eax
 932:	83 ec 08             	sub    $0x8,%esp
 935:	50                   	push   %eax
 936:	ff 75 08             	pushl  0x8(%ebp)
 939:	e8 da fd ff ff       	call   718 <putc>
 93e:	83 c4 10             	add    $0x10,%esp
 941:	eb 25                	jmp    968 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 943:	83 ec 08             	sub    $0x8,%esp
 946:	6a 25                	push   $0x25
 948:	ff 75 08             	pushl  0x8(%ebp)
 94b:	e8 c8 fd ff ff       	call   718 <putc>
 950:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 953:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 956:	0f be c0             	movsbl %al,%eax
 959:	83 ec 08             	sub    $0x8,%esp
 95c:	50                   	push   %eax
 95d:	ff 75 08             	pushl  0x8(%ebp)
 960:	e8 b3 fd ff ff       	call   718 <putc>
 965:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 968:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 96f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 973:	8b 55 0c             	mov    0xc(%ebp),%edx
 976:	8b 45 f0             	mov    -0x10(%ebp),%eax
 979:	01 d0                	add    %edx,%eax
 97b:	0f b6 00             	movzbl (%eax),%eax
 97e:	84 c0                	test   %al,%al
 980:	0f 85 94 fe ff ff    	jne    81a <printf+0x26>
    }
  }
}
 986:	90                   	nop
 987:	90                   	nop
 988:	c9                   	leave  
 989:	c3                   	ret    

0000098a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 98a:	f3 0f 1e fb          	endbr32 
 98e:	55                   	push   %ebp
 98f:	89 e5                	mov    %esp,%ebp
 991:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 994:	8b 45 08             	mov    0x8(%ebp),%eax
 997:	83 e8 08             	sub    $0x8,%eax
 99a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 99d:	a1 58 0f 00 00       	mov    0xf58,%eax
 9a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9a5:	eb 24                	jmp    9cb <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9aa:	8b 00                	mov    (%eax),%eax
 9ac:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 9af:	72 12                	jb     9c3 <free+0x39>
 9b1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9b4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9b7:	77 24                	ja     9dd <free+0x53>
 9b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9bc:	8b 00                	mov    (%eax),%eax
 9be:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9c1:	72 1a                	jb     9dd <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c6:	8b 00                	mov    (%eax),%eax
 9c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ce:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9d1:	76 d4                	jbe    9a7 <free+0x1d>
 9d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d6:	8b 00                	mov    (%eax),%eax
 9d8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 9db:	73 ca                	jae    9a7 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 9dd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e0:	8b 40 04             	mov    0x4(%eax),%eax
 9e3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9ea:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ed:	01 c2                	add    %eax,%edx
 9ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f2:	8b 00                	mov    (%eax),%eax
 9f4:	39 c2                	cmp    %eax,%edx
 9f6:	75 24                	jne    a1c <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 9f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fb:	8b 50 04             	mov    0x4(%eax),%edx
 9fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a01:	8b 00                	mov    (%eax),%eax
 a03:	8b 40 04             	mov    0x4(%eax),%eax
 a06:	01 c2                	add    %eax,%edx
 a08:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0b:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a11:	8b 00                	mov    (%eax),%eax
 a13:	8b 10                	mov    (%eax),%edx
 a15:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a18:	89 10                	mov    %edx,(%eax)
 a1a:	eb 0a                	jmp    a26 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a1f:	8b 10                	mov    (%eax),%edx
 a21:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a24:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a26:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a29:	8b 40 04             	mov    0x4(%eax),%eax
 a2c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a33:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a36:	01 d0                	add    %edx,%eax
 a38:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 a3b:	75 20                	jne    a5d <free+0xd3>
    p->s.size += bp->s.size;
 a3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a40:	8b 50 04             	mov    0x4(%eax),%edx
 a43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a46:	8b 40 04             	mov    0x4(%eax),%eax
 a49:	01 c2                	add    %eax,%edx
 a4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a51:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a54:	8b 10                	mov    (%eax),%edx
 a56:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a59:	89 10                	mov    %edx,(%eax)
 a5b:	eb 08                	jmp    a65 <free+0xdb>
  } else
    p->s.ptr = bp;
 a5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a60:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a63:	89 10                	mov    %edx,(%eax)
  freep = p;
 a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a68:	a3 58 0f 00 00       	mov    %eax,0xf58
}
 a6d:	90                   	nop
 a6e:	c9                   	leave  
 a6f:	c3                   	ret    

00000a70 <morecore>:

static Header*
morecore(uint nu)
{
 a70:	f3 0f 1e fb          	endbr32 
 a74:	55                   	push   %ebp
 a75:	89 e5                	mov    %esp,%ebp
 a77:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 a7a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 a81:	77 07                	ja     a8a <morecore+0x1a>
    nu = 4096;
 a83:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 a8a:	8b 45 08             	mov    0x8(%ebp),%eax
 a8d:	c1 e0 03             	shl    $0x3,%eax
 a90:	83 ec 0c             	sub    $0xc,%esp
 a93:	50                   	push   %eax
 a94:	e8 5f fc ff ff       	call   6f8 <sbrk>
 a99:	83 c4 10             	add    $0x10,%esp
 a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a9f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 aa3:	75 07                	jne    aac <morecore+0x3c>
    return 0;
 aa5:	b8 00 00 00 00       	mov    $0x0,%eax
 aaa:	eb 26                	jmp    ad2 <morecore+0x62>
  hp = (Header*)p;
 aac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aaf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ab2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ab5:	8b 55 08             	mov    0x8(%ebp),%edx
 ab8:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 abe:	83 c0 08             	add    $0x8,%eax
 ac1:	83 ec 0c             	sub    $0xc,%esp
 ac4:	50                   	push   %eax
 ac5:	e8 c0 fe ff ff       	call   98a <free>
 aca:	83 c4 10             	add    $0x10,%esp
  return freep;
 acd:	a1 58 0f 00 00       	mov    0xf58,%eax
}
 ad2:	c9                   	leave  
 ad3:	c3                   	ret    

00000ad4 <malloc>:

void*
malloc(uint nbytes)
{
 ad4:	f3 0f 1e fb          	endbr32 
 ad8:	55                   	push   %ebp
 ad9:	89 e5                	mov    %esp,%ebp
 adb:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ade:	8b 45 08             	mov    0x8(%ebp),%eax
 ae1:	83 c0 07             	add    $0x7,%eax
 ae4:	c1 e8 03             	shr    $0x3,%eax
 ae7:	83 c0 01             	add    $0x1,%eax
 aea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 aed:	a1 58 0f 00 00       	mov    0xf58,%eax
 af2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 af5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 af9:	75 23                	jne    b1e <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 afb:	c7 45 f0 50 0f 00 00 	movl   $0xf50,-0x10(%ebp)
 b02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b05:	a3 58 0f 00 00       	mov    %eax,0xf58
 b0a:	a1 58 0f 00 00       	mov    0xf58,%eax
 b0f:	a3 50 0f 00 00       	mov    %eax,0xf50
    base.s.size = 0;
 b14:	c7 05 54 0f 00 00 00 	movl   $0x0,0xf54
 b1b:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b21:	8b 00                	mov    (%eax),%eax
 b23:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b29:	8b 40 04             	mov    0x4(%eax),%eax
 b2c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b2f:	77 4d                	ja     b7e <malloc+0xaa>
      if(p->s.size == nunits)
 b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b34:	8b 40 04             	mov    0x4(%eax),%eax
 b37:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 b3a:	75 0c                	jne    b48 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b3f:	8b 10                	mov    (%eax),%edx
 b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b44:	89 10                	mov    %edx,(%eax)
 b46:	eb 26                	jmp    b6e <malloc+0x9a>
      else {
        p->s.size -= nunits;
 b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4b:	8b 40 04             	mov    0x4(%eax),%eax
 b4e:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b51:	89 c2                	mov    %eax,%edx
 b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b56:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5c:	8b 40 04             	mov    0x4(%eax),%eax
 b5f:	c1 e0 03             	shl    $0x3,%eax
 b62:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b68:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b6b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b71:	a3 58 0f 00 00       	mov    %eax,0xf58
      return (void*)(p + 1);
 b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b79:	83 c0 08             	add    $0x8,%eax
 b7c:	eb 3b                	jmp    bb9 <malloc+0xe5>
    }
    if(p == freep)
 b7e:	a1 58 0f 00 00       	mov    0xf58,%eax
 b83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 b86:	75 1e                	jne    ba6 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 b88:	83 ec 0c             	sub    $0xc,%esp
 b8b:	ff 75 ec             	pushl  -0x14(%ebp)
 b8e:	e8 dd fe ff ff       	call   a70 <morecore>
 b93:	83 c4 10             	add    $0x10,%esp
 b96:	89 45 f4             	mov    %eax,-0xc(%ebp)
 b99:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b9d:	75 07                	jne    ba6 <malloc+0xd2>
        return 0;
 b9f:	b8 00 00 00 00       	mov    $0x0,%eax
 ba4:	eb 13                	jmp    bb9 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
 baf:	8b 00                	mov    (%eax),%eax
 bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 bb4:	e9 6d ff ff ff       	jmp    b26 <malloc+0x52>
  }
}
 bb9:	c9                   	leave  
 bba:	c3                   	ret    
