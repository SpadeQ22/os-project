
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 60 f6 10 80       	mov    $0x8010f660,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8d 41 10 80       	mov    $0x8010418d,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	f3 0f 1e fb          	endbr32 
80100038:	55                   	push   %ebp
80100039:	89 e5                	mov    %esp,%ebp
8010003b:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003e:	83 ec 08             	sub    $0x8,%esp
80100041:	68 e0 9f 10 80       	push   $0x80109fe0
80100046:	68 60 f6 10 80       	push   $0x8010f660
8010004b:	e8 ae 5d 00 00       	call   80105dfe <initlock>
80100050:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100053:	c7 05 70 35 11 80 64 	movl   $0x80113564,0x80113570
8010005a:	35 11 80 
  bcache.head.next = &bcache.head;
8010005d:	c7 05 74 35 11 80 64 	movl   $0x80113564,0x80113574
80100064:	35 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100067:	c7 45 f4 94 f6 10 80 	movl   $0x8010f694,-0xc(%ebp)
8010006e:	eb 3a                	jmp    801000aa <binit+0x76>
    b->next = bcache.head.next;
80100070:	8b 15 74 35 11 80    	mov    0x80113574,%edx
80100076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100079:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
8010007c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007f:	c7 40 0c 64 35 11 80 	movl   $0x80113564,0xc(%eax)
    b->dev = -1;
80100086:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100089:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
80100090:	a1 74 35 11 80       	mov    0x80113574,%eax
80100095:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100098:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
8010009b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009e:	a3 74 35 11 80       	mov    %eax,0x80113574
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a3:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000aa:	b8 64 35 11 80       	mov    $0x80113564,%eax
801000af:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000b2:	72 bc                	jb     80100070 <binit+0x3c>
  }
}
801000b4:	90                   	nop
801000b5:	90                   	nop
801000b6:	c9                   	leave  
801000b7:	c3                   	ret    

801000b8 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b8:	f3 0f 1e fb          	endbr32 
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 60 f6 10 80       	push   $0x8010f660
801000ca:	e8 55 5d 00 00       	call   80105e24 <acquire>
801000cf:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000d2:	a1 74 35 11 80       	mov    0x80113574,%eax
801000d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000da:	eb 67                	jmp    80100143 <bget+0x8b>
    if(b->dev == dev && b->blockno == blockno){
801000dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000df:	8b 40 04             	mov    0x4(%eax),%eax
801000e2:	39 45 08             	cmp    %eax,0x8(%ebp)
801000e5:	75 53                	jne    8010013a <bget+0x82>
801000e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ea:	8b 40 08             	mov    0x8(%eax),%eax
801000ed:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000f0:	75 48                	jne    8010013a <bget+0x82>
      if(!(b->flags & B_BUSY)){
801000f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f5:	8b 00                	mov    (%eax),%eax
801000f7:	83 e0 01             	and    $0x1,%eax
801000fa:	85 c0                	test   %eax,%eax
801000fc:	75 27                	jne    80100125 <bget+0x6d>
        b->flags |= B_BUSY;
801000fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100101:	8b 00                	mov    (%eax),%eax
80100103:	83 c8 01             	or     $0x1,%eax
80100106:	89 c2                	mov    %eax,%edx
80100108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010b:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
8010010d:	83 ec 0c             	sub    $0xc,%esp
80100110:	68 60 f6 10 80       	push   $0x8010f660
80100115:	e8 75 5d 00 00       	call   80105e8f <release>
8010011a:	83 c4 10             	add    $0x10,%esp
        return b;
8010011d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100120:	e9 98 00 00 00       	jmp    801001bd <bget+0x105>
      }
      sleep(b, &bcache.lock);
80100125:	83 ec 08             	sub    $0x8,%esp
80100128:	68 60 f6 10 80       	push   $0x8010f660
8010012d:	ff 75 f4             	pushl  -0xc(%ebp)
80100130:	e8 c0 57 00 00       	call   801058f5 <sleep>
80100135:	83 c4 10             	add    $0x10,%esp
      goto loop;
80100138:	eb 98                	jmp    801000d2 <bget+0x1a>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010013a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013d:	8b 40 10             	mov    0x10(%eax),%eax
80100140:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100143:	81 7d f4 64 35 11 80 	cmpl   $0x80113564,-0xc(%ebp)
8010014a:	75 90                	jne    801000dc <bget+0x24>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010014c:	a1 70 35 11 80       	mov    0x80113570,%eax
80100151:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100154:	eb 51                	jmp    801001a7 <bget+0xef>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
80100156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100159:	8b 00                	mov    (%eax),%eax
8010015b:	83 e0 01             	and    $0x1,%eax
8010015e:	85 c0                	test   %eax,%eax
80100160:	75 3c                	jne    8010019e <bget+0xe6>
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 00                	mov    (%eax),%eax
80100167:	83 e0 04             	and    $0x4,%eax
8010016a:	85 c0                	test   %eax,%eax
8010016c:	75 30                	jne    8010019e <bget+0xe6>
      b->dev = dev;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 08             	mov    0x8(%ebp),%edx
80100174:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010017d:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100183:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100189:	83 ec 0c             	sub    $0xc,%esp
8010018c:	68 60 f6 10 80       	push   $0x8010f660
80100191:	e8 f9 5c 00 00       	call   80105e8f <release>
80100196:	83 c4 10             	add    $0x10,%esp
      return b;
80100199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010019c:	eb 1f                	jmp    801001bd <bget+0x105>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
8010019e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a1:	8b 40 0c             	mov    0xc(%eax),%eax
801001a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001a7:	81 7d f4 64 35 11 80 	cmpl   $0x80113564,-0xc(%ebp)
801001ae:	75 a6                	jne    80100156 <bget+0x9e>
    }
  }
  panic("bget: no buffers");
801001b0:	83 ec 0c             	sub    $0xc,%esp
801001b3:	68 e7 9f 10 80       	push   $0x80109fe7
801001b8:	e8 da 03 00 00       	call   80100597 <panic>
}
801001bd:	c9                   	leave  
801001be:	c3                   	ret    

801001bf <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001bf:	f3 0f 1e fb          	endbr32 
801001c3:	55                   	push   %ebp
801001c4:	89 e5                	mov    %esp,%ebp
801001c6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001c9:	83 ec 08             	sub    $0x8,%esp
801001cc:	ff 75 0c             	pushl  0xc(%ebp)
801001cf:	ff 75 08             	pushl  0x8(%ebp)
801001d2:	e8 e1 fe ff ff       	call   801000b8 <bget>
801001d7:	83 c4 10             	add    $0x10,%esp
801001da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e0:	8b 00                	mov    (%eax),%eax
801001e2:	83 e0 02             	and    $0x2,%eax
801001e5:	85 c0                	test   %eax,%eax
801001e7:	75 0e                	jne    801001f7 <bread+0x38>
    iderw(b);
801001e9:	83 ec 0c             	sub    $0xc,%esp
801001ec:	ff 75 f4             	pushl  -0xc(%ebp)
801001ef:	e8 54 2f 00 00       	call   80103148 <iderw>
801001f4:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001fa:	c9                   	leave  
801001fb:	c3                   	ret    

801001fc <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001fc:	f3 0f 1e fb          	endbr32 
80100200:	55                   	push   %ebp
80100201:	89 e5                	mov    %esp,%ebp
80100203:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100206:	8b 45 08             	mov    0x8(%ebp),%eax
80100209:	8b 00                	mov    (%eax),%eax
8010020b:	83 e0 01             	and    $0x1,%eax
8010020e:	85 c0                	test   %eax,%eax
80100210:	75 0d                	jne    8010021f <bwrite+0x23>
    panic("bwrite");
80100212:	83 ec 0c             	sub    $0xc,%esp
80100215:	68 f8 9f 10 80       	push   $0x80109ff8
8010021a:	e8 78 03 00 00       	call   80100597 <panic>
  b->flags |= B_DIRTY;
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	8b 00                	mov    (%eax),%eax
80100224:	83 c8 04             	or     $0x4,%eax
80100227:	89 c2                	mov    %eax,%edx
80100229:	8b 45 08             	mov    0x8(%ebp),%eax
8010022c:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010022e:	83 ec 0c             	sub    $0xc,%esp
80100231:	ff 75 08             	pushl  0x8(%ebp)
80100234:	e8 0f 2f 00 00       	call   80103148 <iderw>
80100239:	83 c4 10             	add    $0x10,%esp
}
8010023c:	90                   	nop
8010023d:	c9                   	leave  
8010023e:	c3                   	ret    

8010023f <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010023f:	f3 0f 1e fb          	endbr32 
80100243:	55                   	push   %ebp
80100244:	89 e5                	mov    %esp,%ebp
80100246:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100249:	8b 45 08             	mov    0x8(%ebp),%eax
8010024c:	8b 00                	mov    (%eax),%eax
8010024e:	83 e0 01             	and    $0x1,%eax
80100251:	85 c0                	test   %eax,%eax
80100253:	75 0d                	jne    80100262 <brelse+0x23>
    panic("brelse");
80100255:	83 ec 0c             	sub    $0xc,%esp
80100258:	68 ff 9f 10 80       	push   $0x80109fff
8010025d:	e8 35 03 00 00       	call   80100597 <panic>

  acquire(&bcache.lock);
80100262:	83 ec 0c             	sub    $0xc,%esp
80100265:	68 60 f6 10 80       	push   $0x8010f660
8010026a:	e8 b5 5b 00 00       	call   80105e24 <acquire>
8010026f:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
80100272:	8b 45 08             	mov    0x8(%ebp),%eax
80100275:	8b 40 10             	mov    0x10(%eax),%eax
80100278:	8b 55 08             	mov    0x8(%ebp),%edx
8010027b:	8b 52 0c             	mov    0xc(%edx),%edx
8010027e:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	8b 40 0c             	mov    0xc(%eax),%eax
80100287:	8b 55 08             	mov    0x8(%ebp),%edx
8010028a:	8b 52 10             	mov    0x10(%edx),%edx
8010028d:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
80100290:	8b 15 74 35 11 80    	mov    0x80113574,%edx
80100296:	8b 45 08             	mov    0x8(%ebp),%eax
80100299:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	c7 40 0c 64 35 11 80 	movl   $0x80113564,0xc(%eax)
  bcache.head.next->prev = b;
801002a6:	a1 74 35 11 80       	mov    0x80113574,%eax
801002ab:	8b 55 08             	mov    0x8(%ebp),%edx
801002ae:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
801002b1:	8b 45 08             	mov    0x8(%ebp),%eax
801002b4:	a3 74 35 11 80       	mov    %eax,0x80113574

  b->flags &= ~B_BUSY;
801002b9:	8b 45 08             	mov    0x8(%ebp),%eax
801002bc:	8b 00                	mov    (%eax),%eax
801002be:	83 e0 fe             	and    $0xfffffffe,%eax
801002c1:	89 c2                	mov    %eax,%edx
801002c3:	8b 45 08             	mov    0x8(%ebp),%eax
801002c6:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002c8:	83 ec 0c             	sub    $0xc,%esp
801002cb:	ff 75 08             	pushl  0x8(%ebp)
801002ce:	e8 19 57 00 00       	call   801059ec <wakeup>
801002d3:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002d6:	83 ec 0c             	sub    $0xc,%esp
801002d9:	68 60 f6 10 80       	push   $0x8010f660
801002de:	e8 ac 5b 00 00       	call   80105e8f <release>
801002e3:	83 c4 10             	add    $0x10,%esp
}
801002e6:	90                   	nop
801002e7:	c9                   	leave  
801002e8:	c3                   	ret    

801002e9 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002e9:	55                   	push   %ebp
801002ea:	89 e5                	mov    %esp,%ebp
801002ec:	83 ec 14             	sub    $0x14,%esp
801002ef:	8b 45 08             	mov    0x8(%ebp),%eax
801002f2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002f6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002fa:	89 c2                	mov    %eax,%edx
801002fc:	ec                   	in     (%dx),%al
801002fd:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80100300:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80100304:	c9                   	leave  
80100305:	c3                   	ret    

80100306 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80100306:	55                   	push   %ebp
80100307:	89 e5                	mov    %esp,%ebp
80100309:	83 ec 08             	sub    $0x8,%esp
8010030c:	8b 45 08             	mov    0x8(%ebp),%eax
8010030f:	8b 55 0c             	mov    0xc(%ebp),%edx
80100312:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100316:	89 d0                	mov    %edx,%eax
80100318:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010031b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010031f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80100323:	ee                   	out    %al,(%dx)
}
80100324:	90                   	nop
80100325:	c9                   	leave  
80100326:	c3                   	ret    

80100327 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100327:	55                   	push   %ebp
80100328:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010032a:	fa                   	cli    
}
8010032b:	90                   	nop
8010032c:	5d                   	pop    %ebp
8010032d:	c3                   	ret    

8010032e <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010032e:	f3 0f 1e fb          	endbr32 
80100332:	55                   	push   %ebp
80100333:	89 e5                	mov    %esp,%ebp
80100335:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100338:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010033c:	74 1c                	je     8010035a <printint+0x2c>
8010033e:	8b 45 08             	mov    0x8(%ebp),%eax
80100341:	c1 e8 1f             	shr    $0x1f,%eax
80100344:	0f b6 c0             	movzbl %al,%eax
80100347:	89 45 10             	mov    %eax,0x10(%ebp)
8010034a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010034e:	74 0a                	je     8010035a <printint+0x2c>
    x = -xx;
80100350:	8b 45 08             	mov    0x8(%ebp),%eax
80100353:	f7 d8                	neg    %eax
80100355:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100358:	eb 06                	jmp    80100360 <printint+0x32>
  else
    x = xx;
8010035a:	8b 45 08             	mov    0x8(%ebp),%eax
8010035d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100360:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
80100367:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010036a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010036d:	ba 00 00 00 00       	mov    $0x0,%edx
80100372:	f7 f1                	div    %ecx
80100374:	89 d1                	mov    %edx,%ecx
80100376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100379:	8d 50 01             	lea    0x1(%eax),%edx
8010037c:	89 55 f4             	mov    %edx,-0xc(%ebp)
8010037f:	0f b6 91 04 b0 10 80 	movzbl -0x7fef4ffc(%ecx),%edx
80100386:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
8010038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010038d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100390:	ba 00 00 00 00       	mov    $0x0,%edx
80100395:	f7 f1                	div    %ecx
80100397:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010039a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010039e:	75 c7                	jne    80100367 <printint+0x39>

  if(sign)
801003a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003a4:	74 2a                	je     801003d0 <printint+0xa2>
    buf[i++] = '-';
801003a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a9:	8d 50 01             	lea    0x1(%eax),%edx
801003ac:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003af:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003b4:	eb 1a                	jmp    801003d0 <printint+0xa2>
    consputc(buf[i]);
801003b6:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bc:	01 d0                	add    %edx,%eax
801003be:	0f b6 00             	movzbl (%eax),%eax
801003c1:	0f be c0             	movsbl %al,%eax
801003c4:	83 ec 0c             	sub    $0xc,%esp
801003c7:	50                   	push   %eax
801003c8:	e8 06 04 00 00       	call   801007d3 <consputc>
801003cd:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003d0:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003d8:	79 dc                	jns    801003b6 <printint+0x88>
}
801003da:	90                   	nop
801003db:	90                   	nop
801003dc:	c9                   	leave  
801003dd:	c3                   	ret    

801003de <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003de:	f3 0f 1e fb          	endbr32 
801003e2:	55                   	push   %ebp
801003e3:	89 e5                	mov    %esp,%ebp
801003e5:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003e8:	a1 f4 d5 10 80       	mov    0x8010d5f4,%eax
801003ed:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003f0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003f4:	74 10                	je     80100406 <cprintf+0x28>
    acquire(&cons.lock);
801003f6:	83 ec 0c             	sub    $0xc,%esp
801003f9:	68 c0 d5 10 80       	push   $0x8010d5c0
801003fe:	e8 21 5a 00 00       	call   80105e24 <acquire>
80100403:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100406:	8b 45 08             	mov    0x8(%ebp),%eax
80100409:	85 c0                	test   %eax,%eax
8010040b:	75 0d                	jne    8010041a <cprintf+0x3c>
    panic("null fmt");
8010040d:	83 ec 0c             	sub    $0xc,%esp
80100410:	68 06 a0 10 80       	push   $0x8010a006
80100415:	e8 7d 01 00 00       	call   80100597 <panic>

  argp = (uint*)(void*)(&fmt + 1);
8010041a:	8d 45 0c             	lea    0xc(%ebp),%eax
8010041d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100420:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100427:	e9 2f 01 00 00       	jmp    8010055b <cprintf+0x17d>
    if(c != '%'){
8010042c:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100430:	74 13                	je     80100445 <cprintf+0x67>
      consputc(c);
80100432:	83 ec 0c             	sub    $0xc,%esp
80100435:	ff 75 e4             	pushl  -0x1c(%ebp)
80100438:	e8 96 03 00 00       	call   801007d3 <consputc>
8010043d:	83 c4 10             	add    $0x10,%esp
      continue;
80100440:	e9 12 01 00 00       	jmp    80100557 <cprintf+0x179>
    }
    c = fmt[++i] & 0xff;
80100445:	8b 55 08             	mov    0x8(%ebp),%edx
80100448:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010044c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010044f:	01 d0                	add    %edx,%eax
80100451:	0f b6 00             	movzbl (%eax),%eax
80100454:	0f be c0             	movsbl %al,%eax
80100457:	25 ff 00 00 00       	and    $0xff,%eax
8010045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
8010045f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100463:	0f 84 14 01 00 00    	je     8010057d <cprintf+0x19f>
      break;
    switch(c){
80100469:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010046d:	74 5e                	je     801004cd <cprintf+0xef>
8010046f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100473:	0f 8f c2 00 00 00    	jg     8010053b <cprintf+0x15d>
80100479:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010047d:	74 6b                	je     801004ea <cprintf+0x10c>
8010047f:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100483:	0f 8f b2 00 00 00    	jg     8010053b <cprintf+0x15d>
80100489:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010048d:	74 3e                	je     801004cd <cprintf+0xef>
8010048f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100493:	0f 8f a2 00 00 00    	jg     8010053b <cprintf+0x15d>
80100499:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010049d:	0f 84 89 00 00 00    	je     8010052c <cprintf+0x14e>
801004a3:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004a7:	0f 85 8e 00 00 00    	jne    8010053b <cprintf+0x15d>
    case 'd':
      printint(*argp++, 10, 1);
801004ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b0:	8d 50 04             	lea    0x4(%eax),%edx
801004b3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004b6:	8b 00                	mov    (%eax),%eax
801004b8:	83 ec 04             	sub    $0x4,%esp
801004bb:	6a 01                	push   $0x1
801004bd:	6a 0a                	push   $0xa
801004bf:	50                   	push   %eax
801004c0:	e8 69 fe ff ff       	call   8010032e <printint>
801004c5:	83 c4 10             	add    $0x10,%esp
      break;
801004c8:	e9 8a 00 00 00       	jmp    80100557 <cprintf+0x179>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004d0:	8d 50 04             	lea    0x4(%eax),%edx
801004d3:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d6:	8b 00                	mov    (%eax),%eax
801004d8:	83 ec 04             	sub    $0x4,%esp
801004db:	6a 00                	push   $0x0
801004dd:	6a 10                	push   $0x10
801004df:	50                   	push   %eax
801004e0:	e8 49 fe ff ff       	call   8010032e <printint>
801004e5:	83 c4 10             	add    $0x10,%esp
      break;
801004e8:	eb 6d                	jmp    80100557 <cprintf+0x179>
    case 's':
      if((s = (char*)*argp++) == 0)
801004ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ed:	8d 50 04             	lea    0x4(%eax),%edx
801004f0:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004f3:	8b 00                	mov    (%eax),%eax
801004f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004f8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004fc:	75 22                	jne    80100520 <cprintf+0x142>
        s = "(null)";
801004fe:	c7 45 ec 0f a0 10 80 	movl   $0x8010a00f,-0x14(%ebp)
      for(; *s; s++)
80100505:	eb 19                	jmp    80100520 <cprintf+0x142>
        consputc(*s);
80100507:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010050a:	0f b6 00             	movzbl (%eax),%eax
8010050d:	0f be c0             	movsbl %al,%eax
80100510:	83 ec 0c             	sub    $0xc,%esp
80100513:	50                   	push   %eax
80100514:	e8 ba 02 00 00       	call   801007d3 <consputc>
80100519:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010051c:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100520:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100523:	0f b6 00             	movzbl (%eax),%eax
80100526:	84 c0                	test   %al,%al
80100528:	75 dd                	jne    80100507 <cprintf+0x129>
      break;
8010052a:	eb 2b                	jmp    80100557 <cprintf+0x179>
    case '%':
      consputc('%');
8010052c:	83 ec 0c             	sub    $0xc,%esp
8010052f:	6a 25                	push   $0x25
80100531:	e8 9d 02 00 00       	call   801007d3 <consputc>
80100536:	83 c4 10             	add    $0x10,%esp
      break;
80100539:	eb 1c                	jmp    80100557 <cprintf+0x179>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010053b:	83 ec 0c             	sub    $0xc,%esp
8010053e:	6a 25                	push   $0x25
80100540:	e8 8e 02 00 00       	call   801007d3 <consputc>
80100545:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100548:	83 ec 0c             	sub    $0xc,%esp
8010054b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010054e:	e8 80 02 00 00       	call   801007d3 <consputc>
80100553:	83 c4 10             	add    $0x10,%esp
      break;
80100556:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100557:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010055b:	8b 55 08             	mov    0x8(%ebp),%edx
8010055e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100561:	01 d0                	add    %edx,%eax
80100563:	0f b6 00             	movzbl (%eax),%eax
80100566:	0f be c0             	movsbl %al,%eax
80100569:	25 ff 00 00 00       	and    $0xff,%eax
8010056e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100571:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100575:	0f 85 b1 fe ff ff    	jne    8010042c <cprintf+0x4e>
8010057b:	eb 01                	jmp    8010057e <cprintf+0x1a0>
      break;
8010057d:	90                   	nop
    }
  }

  if(locking)
8010057e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100582:	74 10                	je     80100594 <cprintf+0x1b6>
    release(&cons.lock);
80100584:	83 ec 0c             	sub    $0xc,%esp
80100587:	68 c0 d5 10 80       	push   $0x8010d5c0
8010058c:	e8 fe 58 00 00       	call   80105e8f <release>
80100591:	83 c4 10             	add    $0x10,%esp
}
80100594:	90                   	nop
80100595:	c9                   	leave  
80100596:	c3                   	ret    

80100597 <panic>:

void
panic(char *s)
{
80100597:	f3 0f 1e fb          	endbr32 
8010059b:	55                   	push   %ebp
8010059c:	89 e5                	mov    %esp,%ebp
8010059e:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
801005a1:	e8 81 fd ff ff       	call   80100327 <cli>
  cons.locking = 0;
801005a6:	c7 05 f4 d5 10 80 00 	movl   $0x0,0x8010d5f4
801005ad:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
801005b0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801005b6:	0f b6 00             	movzbl (%eax),%eax
801005b9:	0f b6 c0             	movzbl %al,%eax
801005bc:	83 ec 08             	sub    $0x8,%esp
801005bf:	50                   	push   %eax
801005c0:	68 16 a0 10 80       	push   $0x8010a016
801005c5:	e8 14 fe ff ff       	call   801003de <cprintf>
801005ca:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005cd:	8b 45 08             	mov    0x8(%ebp),%eax
801005d0:	83 ec 0c             	sub    $0xc,%esp
801005d3:	50                   	push   %eax
801005d4:	e8 05 fe ff ff       	call   801003de <cprintf>
801005d9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005dc:	83 ec 0c             	sub    $0xc,%esp
801005df:	68 25 a0 10 80       	push   $0x8010a025
801005e4:	e8 f5 fd ff ff       	call   801003de <cprintf>
801005e9:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ec:	83 ec 08             	sub    $0x8,%esp
801005ef:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f2:	50                   	push   %eax
801005f3:	8d 45 08             	lea    0x8(%ebp),%eax
801005f6:	50                   	push   %eax
801005f7:	e8 e9 58 00 00       	call   80105ee5 <getcallerpcs>
801005fc:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100606:	eb 1c                	jmp    80100624 <panic+0x8d>
    cprintf(" %p", pcs[i]);
80100608:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010060b:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010060f:	83 ec 08             	sub    $0x8,%esp
80100612:	50                   	push   %eax
80100613:	68 27 a0 10 80       	push   $0x8010a027
80100618:	e8 c1 fd ff ff       	call   801003de <cprintf>
8010061d:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100620:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100624:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100628:	7e de                	jle    80100608 <panic+0x71>
  panicked = 1; // freeze other CPU
8010062a:	c7 05 a0 d5 10 80 01 	movl   $0x1,0x8010d5a0
80100631:	00 00 00 
  for(;;)
80100634:	eb fe                	jmp    80100634 <panic+0x9d>

80100636 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100636:	f3 0f 1e fb          	endbr32 
8010063a:	55                   	push   %ebp
8010063b:	89 e5                	mov    %esp,%ebp
8010063d:	53                   	push   %ebx
8010063e:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100641:	6a 0e                	push   $0xe
80100643:	68 d4 03 00 00       	push   $0x3d4
80100648:	e8 b9 fc ff ff       	call   80100306 <outb>
8010064d:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100650:	68 d5 03 00 00       	push   $0x3d5
80100655:	e8 8f fc ff ff       	call   801002e9 <inb>
8010065a:	83 c4 04             	add    $0x4,%esp
8010065d:	0f b6 c0             	movzbl %al,%eax
80100660:	c1 e0 08             	shl    $0x8,%eax
80100663:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100666:	6a 0f                	push   $0xf
80100668:	68 d4 03 00 00       	push   $0x3d4
8010066d:	e8 94 fc ff ff       	call   80100306 <outb>
80100672:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100675:	68 d5 03 00 00       	push   $0x3d5
8010067a:	e8 6a fc ff ff       	call   801002e9 <inb>
8010067f:	83 c4 04             	add    $0x4,%esp
80100682:	0f b6 c0             	movzbl %al,%eax
80100685:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100688:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
8010068c:	75 30                	jne    801006be <cgaputc+0x88>
    pos += 80 - pos%80;
8010068e:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100691:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100696:	89 c8                	mov    %ecx,%eax
80100698:	f7 ea                	imul   %edx
8010069a:	c1 fa 05             	sar    $0x5,%edx
8010069d:	89 c8                	mov    %ecx,%eax
8010069f:	c1 f8 1f             	sar    $0x1f,%eax
801006a2:	29 c2                	sub    %eax,%edx
801006a4:	89 d0                	mov    %edx,%eax
801006a6:	c1 e0 02             	shl    $0x2,%eax
801006a9:	01 d0                	add    %edx,%eax
801006ab:	c1 e0 04             	shl    $0x4,%eax
801006ae:	29 c1                	sub    %eax,%ecx
801006b0:	89 ca                	mov    %ecx,%edx
801006b2:	b8 50 00 00 00       	mov    $0x50,%eax
801006b7:	29 d0                	sub    %edx,%eax
801006b9:	01 45 f4             	add    %eax,-0xc(%ebp)
801006bc:	eb 38                	jmp    801006f6 <cgaputc+0xc0>
  else if(c == BACKSPACE){
801006be:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006c5:	75 0c                	jne    801006d3 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006c7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006cb:	7e 29                	jle    801006f6 <cgaputc+0xc0>
801006cd:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006d1:	eb 23                	jmp    801006f6 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006d3:	8b 45 08             	mov    0x8(%ebp),%eax
801006d6:	0f b6 c0             	movzbl %al,%eax
801006d9:	80 cc 07             	or     $0x7,%ah
801006dc:	89 c3                	mov    %eax,%ebx
801006de:	8b 0d 00 b0 10 80    	mov    0x8010b000,%ecx
801006e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006e7:	8d 50 01             	lea    0x1(%eax),%edx
801006ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006ed:	01 c0                	add    %eax,%eax
801006ef:	01 c8                	add    %ecx,%eax
801006f1:	89 da                	mov    %ebx,%edx
801006f3:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006fa:	78 09                	js     80100705 <cgaputc+0xcf>
801006fc:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100703:	7e 0d                	jle    80100712 <cgaputc+0xdc>
    panic("pos under/overflow");
80100705:	83 ec 0c             	sub    $0xc,%esp
80100708:	68 2b a0 10 80       	push   $0x8010a02b
8010070d:	e8 85 fe ff ff       	call   80100597 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
80100712:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
80100719:	7e 4c                	jle    80100767 <cgaputc+0x131>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
8010071b:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100720:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100726:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010072b:	83 ec 04             	sub    $0x4,%esp
8010072e:	68 60 0e 00 00       	push   $0xe60
80100733:	52                   	push   %edx
80100734:	50                   	push   %eax
80100735:	e8 2d 5a 00 00       	call   80106167 <memmove>
8010073a:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
8010073d:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100741:	b8 80 07 00 00       	mov    $0x780,%eax
80100746:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100749:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010074c:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100751:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100754:	01 c9                	add    %ecx,%ecx
80100756:	01 c8                	add    %ecx,%eax
80100758:	83 ec 04             	sub    $0x4,%esp
8010075b:	52                   	push   %edx
8010075c:	6a 00                	push   $0x0
8010075e:	50                   	push   %eax
8010075f:	e8 3c 59 00 00       	call   801060a0 <memset>
80100764:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100767:	83 ec 08             	sub    $0x8,%esp
8010076a:	6a 0e                	push   $0xe
8010076c:	68 d4 03 00 00       	push   $0x3d4
80100771:	e8 90 fb ff ff       	call   80100306 <outb>
80100776:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010077c:	c1 f8 08             	sar    $0x8,%eax
8010077f:	0f b6 c0             	movzbl %al,%eax
80100782:	83 ec 08             	sub    $0x8,%esp
80100785:	50                   	push   %eax
80100786:	68 d5 03 00 00       	push   $0x3d5
8010078b:	e8 76 fb ff ff       	call   80100306 <outb>
80100790:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100793:	83 ec 08             	sub    $0x8,%esp
80100796:	6a 0f                	push   $0xf
80100798:	68 d4 03 00 00       	push   $0x3d4
8010079d:	e8 64 fb ff ff       	call   80100306 <outb>
801007a2:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
801007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a8:	0f b6 c0             	movzbl %al,%eax
801007ab:	83 ec 08             	sub    $0x8,%esp
801007ae:	50                   	push   %eax
801007af:	68 d5 03 00 00       	push   $0x3d5
801007b4:	e8 4d fb ff ff       	call   80100306 <outb>
801007b9:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
801007bc:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801007c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801007c4:	01 d2                	add    %edx,%edx
801007c6:	01 d0                	add    %edx,%eax
801007c8:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007cd:	90                   	nop
801007ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007d1:	c9                   	leave  
801007d2:	c3                   	ret    

801007d3 <consputc>:

void
consputc(int c)
{
801007d3:	f3 0f 1e fb          	endbr32 
801007d7:	55                   	push   %ebp
801007d8:	89 e5                	mov    %esp,%ebp
801007da:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007dd:	a1 a0 d5 10 80       	mov    0x8010d5a0,%eax
801007e2:	85 c0                	test   %eax,%eax
801007e4:	74 07                	je     801007ed <consputc+0x1a>
    cli();
801007e6:	e8 3c fb ff ff       	call   80100327 <cli>
    for(;;)
801007eb:	eb fe                	jmp    801007eb <consputc+0x18>
      ;
  }

  if(c == BACKSPACE){
801007ed:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007f4:	75 29                	jne    8010081f <consputc+0x4c>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007f6:	83 ec 0c             	sub    $0xc,%esp
801007f9:	6a 08                	push   $0x8
801007fb:	e8 14 73 00 00       	call   80107b14 <uartputc>
80100800:	83 c4 10             	add    $0x10,%esp
80100803:	83 ec 0c             	sub    $0xc,%esp
80100806:	6a 20                	push   $0x20
80100808:	e8 07 73 00 00       	call   80107b14 <uartputc>
8010080d:	83 c4 10             	add    $0x10,%esp
80100810:	83 ec 0c             	sub    $0xc,%esp
80100813:	6a 08                	push   $0x8
80100815:	e8 fa 72 00 00       	call   80107b14 <uartputc>
8010081a:	83 c4 10             	add    $0x10,%esp
8010081d:	eb 0e                	jmp    8010082d <consputc+0x5a>
  } else
    uartputc(c);
8010081f:	83 ec 0c             	sub    $0xc,%esp
80100822:	ff 75 08             	pushl  0x8(%ebp)
80100825:	e8 ea 72 00 00       	call   80107b14 <uartputc>
8010082a:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010082d:	83 ec 0c             	sub    $0xc,%esp
80100830:	ff 75 08             	pushl  0x8(%ebp)
80100833:	e8 fe fd ff ff       	call   80100636 <cgaputc>
80100838:	83 c4 10             	add    $0x10,%esp
}
8010083b:	90                   	nop
8010083c:	c9                   	leave  
8010083d:	c3                   	ret    

8010083e <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010083e:	f3 0f 1e fb          	endbr32 
80100842:	55                   	push   %ebp
80100843:	89 e5                	mov    %esp,%ebp
80100845:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100848:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
8010084f:	83 ec 0c             	sub    $0xc,%esp
80100852:	68 c0 d5 10 80       	push   $0x8010d5c0
80100857:	e8 c8 55 00 00       	call   80105e24 <acquire>
8010085c:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010085f:	e9 52 01 00 00       	jmp    801009b6 <consoleintr+0x178>
    switch(c){
80100864:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100868:	0f 84 81 00 00 00    	je     801008ef <consoleintr+0xb1>
8010086e:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100872:	0f 8f ac 00 00 00    	jg     80100924 <consoleintr+0xe6>
80100878:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010087c:	74 43                	je     801008c1 <consoleintr+0x83>
8010087e:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100882:	0f 8f 9c 00 00 00    	jg     80100924 <consoleintr+0xe6>
80100888:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
8010088c:	74 61                	je     801008ef <consoleintr+0xb1>
8010088e:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100892:	0f 85 8c 00 00 00    	jne    80100924 <consoleintr+0xe6>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100898:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010089f:	e9 12 01 00 00       	jmp    801009b6 <consoleintr+0x178>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008a4:	a1 08 38 11 80       	mov    0x80113808,%eax
801008a9:	83 e8 01             	sub    $0x1,%eax
801008ac:	a3 08 38 11 80       	mov    %eax,0x80113808
        consputc(BACKSPACE);
801008b1:	83 ec 0c             	sub    $0xc,%esp
801008b4:	68 00 01 00 00       	push   $0x100
801008b9:	e8 15 ff ff ff       	call   801007d3 <consputc>
801008be:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
801008c1:	8b 15 08 38 11 80    	mov    0x80113808,%edx
801008c7:	a1 04 38 11 80       	mov    0x80113804,%eax
801008cc:	39 c2                	cmp    %eax,%edx
801008ce:	0f 84 e2 00 00 00    	je     801009b6 <consoleintr+0x178>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008d4:	a1 08 38 11 80       	mov    0x80113808,%eax
801008d9:	83 e8 01             	sub    $0x1,%eax
801008dc:	83 e0 7f             	and    $0x7f,%eax
801008df:	0f b6 80 80 37 11 80 	movzbl -0x7feec880(%eax),%eax
      while(input.e != input.w &&
801008e6:	3c 0a                	cmp    $0xa,%al
801008e8:	75 ba                	jne    801008a4 <consoleintr+0x66>
      }
      break;
801008ea:	e9 c7 00 00 00       	jmp    801009b6 <consoleintr+0x178>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008ef:	8b 15 08 38 11 80    	mov    0x80113808,%edx
801008f5:	a1 04 38 11 80       	mov    0x80113804,%eax
801008fa:	39 c2                	cmp    %eax,%edx
801008fc:	0f 84 b4 00 00 00    	je     801009b6 <consoleintr+0x178>
        input.e--;
80100902:	a1 08 38 11 80       	mov    0x80113808,%eax
80100907:	83 e8 01             	sub    $0x1,%eax
8010090a:	a3 08 38 11 80       	mov    %eax,0x80113808
        consputc(BACKSPACE);
8010090f:	83 ec 0c             	sub    $0xc,%esp
80100912:	68 00 01 00 00       	push   $0x100
80100917:	e8 b7 fe ff ff       	call   801007d3 <consputc>
8010091c:	83 c4 10             	add    $0x10,%esp
      }
      break;
8010091f:	e9 92 00 00 00       	jmp    801009b6 <consoleintr+0x178>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100924:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100928:	0f 84 87 00 00 00    	je     801009b5 <consoleintr+0x177>
8010092e:	8b 15 08 38 11 80    	mov    0x80113808,%edx
80100934:	a1 00 38 11 80       	mov    0x80113800,%eax
80100939:	29 c2                	sub    %eax,%edx
8010093b:	89 d0                	mov    %edx,%eax
8010093d:	83 f8 7f             	cmp    $0x7f,%eax
80100940:	77 73                	ja     801009b5 <consoleintr+0x177>
        c = (c == '\r') ? '\n' : c;
80100942:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100946:	74 05                	je     8010094d <consoleintr+0x10f>
80100948:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010094b:	eb 05                	jmp    80100952 <consoleintr+0x114>
8010094d:	b8 0a 00 00 00       	mov    $0xa,%eax
80100952:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100955:	a1 08 38 11 80       	mov    0x80113808,%eax
8010095a:	8d 50 01             	lea    0x1(%eax),%edx
8010095d:	89 15 08 38 11 80    	mov    %edx,0x80113808
80100963:	83 e0 7f             	and    $0x7f,%eax
80100966:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100969:	88 90 80 37 11 80    	mov    %dl,-0x7feec880(%eax)
        consputc(c);
8010096f:	83 ec 0c             	sub    $0xc,%esp
80100972:	ff 75 f0             	pushl  -0x10(%ebp)
80100975:	e8 59 fe ff ff       	call   801007d3 <consputc>
8010097a:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010097d:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100981:	74 18                	je     8010099b <consoleintr+0x15d>
80100983:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100987:	74 12                	je     8010099b <consoleintr+0x15d>
80100989:	a1 08 38 11 80       	mov    0x80113808,%eax
8010098e:	8b 15 00 38 11 80    	mov    0x80113800,%edx
80100994:	83 ea 80             	sub    $0xffffff80,%edx
80100997:	39 d0                	cmp    %edx,%eax
80100999:	75 1a                	jne    801009b5 <consoleintr+0x177>
          input.w = input.e;
8010099b:	a1 08 38 11 80       	mov    0x80113808,%eax
801009a0:	a3 04 38 11 80       	mov    %eax,0x80113804
          wakeup(&input.r);
801009a5:	83 ec 0c             	sub    $0xc,%esp
801009a8:	68 00 38 11 80       	push   $0x80113800
801009ad:	e8 3a 50 00 00       	call   801059ec <wakeup>
801009b2:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
801009b5:	90                   	nop
  while((c = getc()) >= 0){
801009b6:	8b 45 08             	mov    0x8(%ebp),%eax
801009b9:	ff d0                	call   *%eax
801009bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801009be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801009c2:	0f 89 9c fe ff ff    	jns    80100864 <consoleintr+0x26>
    }
  }
  release(&cons.lock);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	68 c0 d5 10 80       	push   $0x8010d5c0
801009d0:	e8 ba 54 00 00       	call   80105e8f <release>
801009d5:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009d8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009dc:	74 05                	je     801009e3 <consoleintr+0x1a5>
    procdump();  // now call procdump() wo. cons.lock held
801009de:	e8 8f 51 00 00       	call   80105b72 <procdump>
  }
}
801009e3:	90                   	nop
801009e4:	c9                   	leave  
801009e5:	c3                   	ret    

801009e6 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009e6:	f3 0f 1e fb          	endbr32 
801009ea:	55                   	push   %ebp
801009eb:	89 e5                	mov    %esp,%ebp
801009ed:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009f0:	83 ec 0c             	sub    $0xc,%esp
801009f3:	ff 75 08             	pushl  0x8(%ebp)
801009f6:	e8 78 11 00 00       	call   80101b73 <iunlock>
801009fb:	83 c4 10             	add    $0x10,%esp
  target = n;
801009fe:	8b 45 10             	mov    0x10(%ebp),%eax
80100a01:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a04:	83 ec 0c             	sub    $0xc,%esp
80100a07:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a0c:	e8 13 54 00 00       	call   80105e24 <acquire>
80100a11:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100a14:	e9 ac 00 00 00       	jmp    80100ac5 <consoleread+0xdf>
    while(input.r == input.w){
      if(proc->killed){
80100a19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100a1f:	8b 40 24             	mov    0x24(%eax),%eax
80100a22:	85 c0                	test   %eax,%eax
80100a24:	74 28                	je     80100a4e <consoleread+0x68>
        release(&cons.lock);
80100a26:	83 ec 0c             	sub    $0xc,%esp
80100a29:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a2e:	e8 5c 54 00 00       	call   80105e8f <release>
80100a33:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a36:	83 ec 0c             	sub    $0xc,%esp
80100a39:	ff 75 08             	pushl  0x8(%ebp)
80100a3c:	e8 d0 0f 00 00       	call   80101a11 <ilock>
80100a41:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a49:	e9 ab 00 00 00       	jmp    80100af9 <consoleread+0x113>
      }
      sleep(&input.r, &cons.lock);
80100a4e:	83 ec 08             	sub    $0x8,%esp
80100a51:	68 c0 d5 10 80       	push   $0x8010d5c0
80100a56:	68 00 38 11 80       	push   $0x80113800
80100a5b:	e8 95 4e 00 00       	call   801058f5 <sleep>
80100a60:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a63:	8b 15 00 38 11 80    	mov    0x80113800,%edx
80100a69:	a1 04 38 11 80       	mov    0x80113804,%eax
80100a6e:	39 c2                	cmp    %eax,%edx
80100a70:	74 a7                	je     80100a19 <consoleread+0x33>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a72:	a1 00 38 11 80       	mov    0x80113800,%eax
80100a77:	8d 50 01             	lea    0x1(%eax),%edx
80100a7a:	89 15 00 38 11 80    	mov    %edx,0x80113800
80100a80:	83 e0 7f             	and    $0x7f,%eax
80100a83:	0f b6 80 80 37 11 80 	movzbl -0x7feec880(%eax),%eax
80100a8a:	0f be c0             	movsbl %al,%eax
80100a8d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a90:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a94:	75 17                	jne    80100aad <consoleread+0xc7>
      if(n < target){
80100a96:	8b 45 10             	mov    0x10(%ebp),%eax
80100a99:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a9c:	76 2f                	jbe    80100acd <consoleread+0xe7>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a9e:	a1 00 38 11 80       	mov    0x80113800,%eax
80100aa3:	83 e8 01             	sub    $0x1,%eax
80100aa6:	a3 00 38 11 80       	mov    %eax,0x80113800
      }
      break;
80100aab:	eb 20                	jmp    80100acd <consoleread+0xe7>
    }
    *dst++ = c;
80100aad:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ab0:	8d 50 01             	lea    0x1(%eax),%edx
80100ab3:	89 55 0c             	mov    %edx,0xc(%ebp)
80100ab6:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100ab9:	88 10                	mov    %dl,(%eax)
    --n;
80100abb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100abf:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100ac3:	74 0b                	je     80100ad0 <consoleread+0xea>
  while(n > 0){
80100ac5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100ac9:	7f 98                	jg     80100a63 <consoleread+0x7d>
80100acb:	eb 04                	jmp    80100ad1 <consoleread+0xeb>
      break;
80100acd:	90                   	nop
80100ace:	eb 01                	jmp    80100ad1 <consoleread+0xeb>
      break;
80100ad0:	90                   	nop
  }
  release(&cons.lock);
80100ad1:	83 ec 0c             	sub    $0xc,%esp
80100ad4:	68 c0 d5 10 80       	push   $0x8010d5c0
80100ad9:	e8 b1 53 00 00       	call   80105e8f <release>
80100ade:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ae1:	83 ec 0c             	sub    $0xc,%esp
80100ae4:	ff 75 08             	pushl  0x8(%ebp)
80100ae7:	e8 25 0f 00 00       	call   80101a11 <ilock>
80100aec:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100aef:	8b 45 10             	mov    0x10(%ebp),%eax
80100af2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100af5:	29 c2                	sub    %eax,%edx
80100af7:	89 d0                	mov    %edx,%eax
}
80100af9:	c9                   	leave  
80100afa:	c3                   	ret    

80100afb <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100afb:	f3 0f 1e fb          	endbr32 
80100aff:	55                   	push   %ebp
80100b00:	89 e5                	mov    %esp,%ebp
80100b02:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100b05:	83 ec 0c             	sub    $0xc,%esp
80100b08:	ff 75 08             	pushl  0x8(%ebp)
80100b0b:	e8 63 10 00 00       	call   80101b73 <iunlock>
80100b10:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100b13:	83 ec 0c             	sub    $0xc,%esp
80100b16:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b1b:	e8 04 53 00 00       	call   80105e24 <acquire>
80100b20:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b2a:	eb 21                	jmp    80100b4d <consolewrite+0x52>
    consputc(buf[i] & 0xff);
80100b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b32:	01 d0                	add    %edx,%eax
80100b34:	0f b6 00             	movzbl (%eax),%eax
80100b37:	0f be c0             	movsbl %al,%eax
80100b3a:	0f b6 c0             	movzbl %al,%eax
80100b3d:	83 ec 0c             	sub    $0xc,%esp
80100b40:	50                   	push   %eax
80100b41:	e8 8d fc ff ff       	call   801007d3 <consputc>
80100b46:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b49:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b50:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b53:	7c d7                	jl     80100b2c <consolewrite+0x31>
  release(&cons.lock);
80100b55:	83 ec 0c             	sub    $0xc,%esp
80100b58:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b5d:	e8 2d 53 00 00       	call   80105e8f <release>
80100b62:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b65:	83 ec 0c             	sub    $0xc,%esp
80100b68:	ff 75 08             	pushl  0x8(%ebp)
80100b6b:	e8 a1 0e 00 00       	call   80101a11 <ilock>
80100b70:	83 c4 10             	add    $0x10,%esp

  return n;
80100b73:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consoleinit>:

void
consoleinit(void)
{
80100b78:	f3 0f 1e fb          	endbr32 
80100b7c:	55                   	push   %ebp
80100b7d:	89 e5                	mov    %esp,%ebp
80100b7f:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b82:	83 ec 08             	sub    $0x8,%esp
80100b85:	68 3e a0 10 80       	push   $0x8010a03e
80100b8a:	68 c0 d5 10 80       	push   $0x8010d5c0
80100b8f:	e8 6a 52 00 00       	call   80105dfe <initlock>
80100b94:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b97:	c7 05 cc 41 11 80 fb 	movl   $0x80100afb,0x801141cc
80100b9e:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100ba1:	c7 05 c8 41 11 80 e6 	movl   $0x801009e6,0x801141c8
80100ba8:	09 10 80 
  cons.locking = 1;
80100bab:	c7 05 f4 d5 10 80 01 	movl   $0x1,0x8010d5f4
80100bb2:	00 00 00 

  picenable(IRQ_KBD);
80100bb5:	83 ec 0c             	sub    $0xc,%esp
80100bb8:	6a 01                	push   $0x1
80100bba:	e8 b3 3c 00 00       	call   80104872 <picenable>
80100bbf:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100bc2:	83 ec 08             	sub    $0x8,%esp
80100bc5:	6a 00                	push   $0x0
80100bc7:	6a 01                	push   $0x1
80100bc9:	e8 57 27 00 00       	call   80103325 <ioapicenable>
80100bce:	83 c4 10             	add    $0x10,%esp
}
80100bd1:	90                   	nop
80100bd2:	c9                   	leave  
80100bd3:	c3                   	ret    

80100bd4 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100bd4:	f3 0f 1e fb          	endbr32 
80100bd8:	55                   	push   %ebp
80100bd9:	89 e5                	mov    %esp,%ebp
80100bdb:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100be1:	e8 50 32 00 00       	call   80103e36 <begin_op>
  if((ip = namei(path)) == 0){
80100be6:	83 ec 0c             	sub    $0xc,%esp
80100be9:	ff 75 08             	pushl  0x8(%ebp)
80100bec:	e8 09 1a 00 00       	call   801025fa <namei>
80100bf1:	83 c4 10             	add    $0x10,%esp
80100bf4:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bf7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bfb:	75 0f                	jne    80100c0c <exec+0x38>
    end_op();
80100bfd:	e8 c4 32 00 00       	call   80103ec6 <end_op>
    return -1;
80100c02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c07:	e9 ce 03 00 00       	jmp    80100fda <exec+0x406>
  }
  ilock(ip);
80100c0c:	83 ec 0c             	sub    $0xc,%esp
80100c0f:	ff 75 d8             	pushl  -0x28(%ebp)
80100c12:	e8 fa 0d 00 00       	call   80101a11 <ilock>
80100c17:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100c1a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100c21:	6a 34                	push   $0x34
80100c23:	6a 00                	push   $0x0
80100c25:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100c2b:	50                   	push   %eax
80100c2c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c2f:	e8 62 13 00 00       	call   80101f96 <readi>
80100c34:	83 c4 10             	add    $0x10,%esp
80100c37:	83 f8 33             	cmp    $0x33,%eax
80100c3a:	0f 86 49 03 00 00    	jbe    80100f89 <exec+0x3b5>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c40:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c46:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c4b:	0f 85 3b 03 00 00    	jne    80100f8c <exec+0x3b8>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c51:	e8 2b 80 00 00       	call   80108c81 <setupkvm>
80100c56:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c59:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c5d:	0f 84 2c 03 00 00    	je     80100f8f <exec+0x3bb>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c63:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c6a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c71:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c77:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c7a:	e9 ab 00 00 00       	jmp    80100d2a <exec+0x156>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c82:	6a 20                	push   $0x20
80100c84:	50                   	push   %eax
80100c85:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c8b:	50                   	push   %eax
80100c8c:	ff 75 d8             	pushl  -0x28(%ebp)
80100c8f:	e8 02 13 00 00       	call   80101f96 <readi>
80100c94:	83 c4 10             	add    $0x10,%esp
80100c97:	83 f8 20             	cmp    $0x20,%eax
80100c9a:	0f 85 f2 02 00 00    	jne    80100f92 <exec+0x3be>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100ca0:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ca6:	83 f8 01             	cmp    $0x1,%eax
80100ca9:	75 71                	jne    80100d1c <exec+0x148>
      continue;
    if(ph.memsz < ph.filesz)
80100cab:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100cb1:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb7:	39 c2                	cmp    %eax,%edx
80100cb9:	0f 82 d6 02 00 00    	jb     80100f95 <exec+0x3c1>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cbf:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100cc5:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100ccb:	01 d0                	add    %edx,%eax
80100ccd:	83 ec 04             	sub    $0x4,%esp
80100cd0:	50                   	push   %eax
80100cd1:	ff 75 e0             	pushl  -0x20(%ebp)
80100cd4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cd7:	e8 e0 8b 00 00       	call   801098bc <allocuvm>
80100cdc:	83 c4 10             	add    $0x10,%esp
80100cdf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce6:	0f 84 ac 02 00 00    	je     80100f98 <exec+0x3c4>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cec:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cf2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf8:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cfe:	83 ec 0c             	sub    $0xc,%esp
80100d01:	52                   	push   %edx
80100d02:	50                   	push   %eax
80100d03:	ff 75 d8             	pushl  -0x28(%ebp)
80100d06:	51                   	push   %ecx
80100d07:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d0a:	e8 57 82 00 00       	call   80108f66 <loaduvm>
80100d0f:	83 c4 20             	add    $0x20,%esp
80100d12:	85 c0                	test   %eax,%eax
80100d14:	0f 88 81 02 00 00    	js     80100f9b <exec+0x3c7>
80100d1a:	eb 01                	jmp    80100d1d <exec+0x149>
      continue;
80100d1c:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d1d:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d24:	83 c0 20             	add    $0x20,%eax
80100d27:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d2a:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100d31:	0f b7 c0             	movzwl %ax,%eax
80100d34:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d37:	0f 8c 42 ff ff ff    	jl     80100c7f <exec+0xab>
      goto bad;
  }
  iunlockput(ip);
80100d3d:	83 ec 0c             	sub    $0xc,%esp
80100d40:	ff 75 d8             	pushl  -0x28(%ebp)
80100d43:	e8 95 0f 00 00       	call   80101cdd <iunlockput>
80100d48:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d4b:	e8 76 31 00 00       	call   80103ec6 <end_op>
  ip = 0;
80100d50:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d57:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5a:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d5f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d64:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*pageSize)) == 0)
80100d67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6a:	05 00 20 00 00       	add    $0x2000,%eax
80100d6f:	83 ec 04             	sub    $0x4,%esp
80100d72:	50                   	push   %eax
80100d73:	ff 75 e0             	pushl  -0x20(%ebp)
80100d76:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d79:	e8 3e 8b 00 00       	call   801098bc <allocuvm>
80100d7e:	83 c4 10             	add    $0x10,%esp
80100d81:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d84:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d88:	0f 84 10 02 00 00    	je     80100f9e <exec+0x3ca>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*pageSize));
80100d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d91:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d96:	83 ec 08             	sub    $0x8,%esp
80100d99:	50                   	push   %eax
80100d9a:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d9d:	e8 aa 8f 00 00       	call   80109d4c <clearpteu>
80100da2:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da8:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dab:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100db2:	e9 96 00 00 00       	jmp    80100e4d <exec+0x279>
    if(argc >= MAXARG)
80100db7:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100dbb:	0f 87 e0 01 00 00    	ja     80100fa1 <exec+0x3cd>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dce:	01 d0                	add    %edx,%eax
80100dd0:	8b 00                	mov    (%eax),%eax
80100dd2:	83 ec 0c             	sub    $0xc,%esp
80100dd5:	50                   	push   %eax
80100dd6:	e8 2e 55 00 00       	call   80106309 <strlen>
80100ddb:	83 c4 10             	add    $0x10,%esp
80100dde:	89 c2                	mov    %eax,%edx
80100de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de3:	29 d0                	sub    %edx,%eax
80100de5:	83 e8 01             	sub    $0x1,%eax
80100de8:	83 e0 fc             	and    $0xfffffffc,%eax
80100deb:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100df1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dfb:	01 d0                	add    %edx,%eax
80100dfd:	8b 00                	mov    (%eax),%eax
80100dff:	83 ec 0c             	sub    $0xc,%esp
80100e02:	50                   	push   %eax
80100e03:	e8 01 55 00 00       	call   80106309 <strlen>
80100e08:	83 c4 10             	add    $0x10,%esp
80100e0b:	83 c0 01             	add    $0x1,%eax
80100e0e:	89 c1                	mov    %eax,%ecx
80100e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1d:	01 d0                	add    %edx,%eax
80100e1f:	8b 00                	mov    (%eax),%eax
80100e21:	51                   	push   %ecx
80100e22:	50                   	push   %eax
80100e23:	ff 75 dc             	pushl  -0x24(%ebp)
80100e26:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e29:	e8 10 91 00 00       	call   80109f3e <copyout>
80100e2e:	83 c4 10             	add    $0x10,%esp
80100e31:	85 c0                	test   %eax,%eax
80100e33:	0f 88 6b 01 00 00    	js     80100fa4 <exec+0x3d0>
      goto bad;
    ustack[3+argc] = sp;
80100e39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e3c:	8d 50 03             	lea    0x3(%eax),%edx
80100e3f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e42:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e49:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e57:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e5a:	01 d0                	add    %edx,%eax
80100e5c:	8b 00                	mov    (%eax),%eax
80100e5e:	85 c0                	test   %eax,%eax
80100e60:	0f 85 51 ff ff ff    	jne    80100db7 <exec+0x1e3>
  }
  ustack[3+argc] = 0;
80100e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e69:	83 c0 03             	add    $0x3,%eax
80100e6c:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e73:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e77:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e7e:	ff ff ff 
  ustack[1] = argc;
80100e81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e84:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8d:	83 c0 01             	add    $0x1,%eax
80100e90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e9a:	29 d0                	sub    %edx,%eax
80100e9c:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100ea2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea5:	83 c0 04             	add    $0x4,%eax
80100ea8:	c1 e0 02             	shl    $0x2,%eax
80100eab:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eb1:	83 c0 04             	add    $0x4,%eax
80100eb4:	c1 e0 02             	shl    $0x2,%eax
80100eb7:	50                   	push   %eax
80100eb8:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100ebe:	50                   	push   %eax
80100ebf:	ff 75 dc             	pushl  -0x24(%ebp)
80100ec2:	ff 75 d4             	pushl  -0x2c(%ebp)
80100ec5:	e8 74 90 00 00       	call   80109f3e <copyout>
80100eca:	83 c4 10             	add    $0x10,%esp
80100ecd:	85 c0                	test   %eax,%eax
80100ecf:	0f 88 d2 00 00 00    	js     80100fa7 <exec+0x3d3>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ede:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ee1:	eb 17                	jmp    80100efa <exec+0x326>
    if(*s == '/')
80100ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee6:	0f b6 00             	movzbl (%eax),%eax
80100ee9:	3c 2f                	cmp    $0x2f,%al
80100eeb:	75 09                	jne    80100ef6 <exec+0x322>
      last = s+1;
80100eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ef0:	83 c0 01             	add    $0x1,%eax
80100ef3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efd:	0f b6 00             	movzbl (%eax),%eax
80100f00:	84 c0                	test   %al,%al
80100f02:	75 df                	jne    80100ee3 <exec+0x30f>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100f04:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f0a:	83 c0 6c             	add    $0x6c,%eax
80100f0d:	83 ec 04             	sub    $0x4,%esp
80100f10:	6a 10                	push   $0x10
80100f12:	ff 75 f0             	pushl  -0x10(%ebp)
80100f15:	50                   	push   %eax
80100f16:	e8 a0 53 00 00       	call   801062bb <safestrcpy>
80100f1b:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.

  oldpgdir = proc->pgdir;
80100f1e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f24:	8b 40 04             	mov    0x4(%eax),%eax
80100f27:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100f2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f30:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f33:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f3c:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f3f:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f47:	8b 40 18             	mov    0x18(%eax),%eax
80100f4a:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f50:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f53:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f59:	8b 40 18             	mov    0x18(%eax),%eax
80100f5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f5f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f62:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f68:	83 ec 0c             	sub    $0xc,%esp
80100f6b:	50                   	push   %eax
80100f6c:	e8 03 7e 00 00       	call   80108d74 <switchuvm>
80100f71:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f74:	83 ec 0c             	sub    $0xc,%esp
80100f77:	ff 75 d0             	pushl  -0x30(%ebp)
80100f7a:	e8 1e 8d 00 00       	call   80109c9d <freevm>
80100f7f:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f82:	b8 00 00 00 00       	mov    $0x0,%eax
80100f87:	eb 51                	jmp    80100fda <exec+0x406>
    goto bad;
80100f89:	90                   	nop
80100f8a:	eb 1c                	jmp    80100fa8 <exec+0x3d4>
    goto bad;
80100f8c:	90                   	nop
80100f8d:	eb 19                	jmp    80100fa8 <exec+0x3d4>
    goto bad;
80100f8f:	90                   	nop
80100f90:	eb 16                	jmp    80100fa8 <exec+0x3d4>
      goto bad;
80100f92:	90                   	nop
80100f93:	eb 13                	jmp    80100fa8 <exec+0x3d4>
      goto bad;
80100f95:	90                   	nop
80100f96:	eb 10                	jmp    80100fa8 <exec+0x3d4>
      goto bad;
80100f98:	90                   	nop
80100f99:	eb 0d                	jmp    80100fa8 <exec+0x3d4>
      goto bad;
80100f9b:	90                   	nop
80100f9c:	eb 0a                	jmp    80100fa8 <exec+0x3d4>
    goto bad;
80100f9e:	90                   	nop
80100f9f:	eb 07                	jmp    80100fa8 <exec+0x3d4>
      goto bad;
80100fa1:	90                   	nop
80100fa2:	eb 04                	jmp    80100fa8 <exec+0x3d4>
      goto bad;
80100fa4:	90                   	nop
80100fa5:	eb 01                	jmp    80100fa8 <exec+0x3d4>
    goto bad;
80100fa7:	90                   	nop

 bad:
  if(pgdir)
80100fa8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100fac:	74 0e                	je     80100fbc <exec+0x3e8>
    freevm(pgdir);
80100fae:	83 ec 0c             	sub    $0xc,%esp
80100fb1:	ff 75 d4             	pushl  -0x2c(%ebp)
80100fb4:	e8 e4 8c 00 00       	call   80109c9d <freevm>
80100fb9:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fbc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fc0:	74 13                	je     80100fd5 <exec+0x401>
    iunlockput(ip);
80100fc2:	83 ec 0c             	sub    $0xc,%esp
80100fc5:	ff 75 d8             	pushl  -0x28(%ebp)
80100fc8:	e8 10 0d 00 00       	call   80101cdd <iunlockput>
80100fcd:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fd0:	e8 f1 2e 00 00       	call   80103ec6 <end_op>
  }
  return -1;
80100fd5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fda:	c9                   	leave  
80100fdb:	c3                   	ret    

80100fdc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fdc:	f3 0f 1e fb          	endbr32 
80100fe0:	55                   	push   %ebp
80100fe1:	89 e5                	mov    %esp,%ebp
80100fe3:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fe6:	83 ec 08             	sub    $0x8,%esp
80100fe9:	68 46 a0 10 80       	push   $0x8010a046
80100fee:	68 20 38 11 80       	push   $0x80113820
80100ff3:	e8 06 4e 00 00       	call   80105dfe <initlock>
80100ff8:	83 c4 10             	add    $0x10,%esp
}
80100ffb:	90                   	nop
80100ffc:	c9                   	leave  
80100ffd:	c3                   	ret    

80100ffe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100ffe:	f3 0f 1e fb          	endbr32 
80101002:	55                   	push   %ebp
80101003:	89 e5                	mov    %esp,%ebp
80101005:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80101008:	83 ec 0c             	sub    $0xc,%esp
8010100b:	68 20 38 11 80       	push   $0x80113820
80101010:	e8 0f 4e 00 00       	call   80105e24 <acquire>
80101015:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101018:	c7 45 f4 54 38 11 80 	movl   $0x80113854,-0xc(%ebp)
8010101f:	eb 2d                	jmp    8010104e <filealloc+0x50>
    if(f->ref == 0){
80101021:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101024:	8b 40 04             	mov    0x4(%eax),%eax
80101027:	85 c0                	test   %eax,%eax
80101029:	75 1f                	jne    8010104a <filealloc+0x4c>
      f->ref = 1;
8010102b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102e:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101035:	83 ec 0c             	sub    $0xc,%esp
80101038:	68 20 38 11 80       	push   $0x80113820
8010103d:	e8 4d 4e 00 00       	call   80105e8f <release>
80101042:	83 c4 10             	add    $0x10,%esp
      return f;
80101045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101048:	eb 23                	jmp    8010106d <filealloc+0x6f>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010104a:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010104e:	b8 b4 41 11 80       	mov    $0x801141b4,%eax
80101053:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101056:	72 c9                	jb     80101021 <filealloc+0x23>
    }
  }
  release(&ftable.lock);
80101058:	83 ec 0c             	sub    $0xc,%esp
8010105b:	68 20 38 11 80       	push   $0x80113820
80101060:	e8 2a 4e 00 00       	call   80105e8f <release>
80101065:	83 c4 10             	add    $0x10,%esp
  return 0;
80101068:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010106d:	c9                   	leave  
8010106e:	c3                   	ret    

8010106f <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010106f:	f3 0f 1e fb          	endbr32 
80101073:	55                   	push   %ebp
80101074:	89 e5                	mov    %esp,%ebp
80101076:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101079:	83 ec 0c             	sub    $0xc,%esp
8010107c:	68 20 38 11 80       	push   $0x80113820
80101081:	e8 9e 4d 00 00       	call   80105e24 <acquire>
80101086:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101089:	8b 45 08             	mov    0x8(%ebp),%eax
8010108c:	8b 40 04             	mov    0x4(%eax),%eax
8010108f:	85 c0                	test   %eax,%eax
80101091:	7f 0d                	jg     801010a0 <filedup+0x31>
    panic("filedup");
80101093:	83 ec 0c             	sub    $0xc,%esp
80101096:	68 4d a0 10 80       	push   $0x8010a04d
8010109b:	e8 f7 f4 ff ff       	call   80100597 <panic>
  f->ref++;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
801010a3:	8b 40 04             	mov    0x4(%eax),%eax
801010a6:	8d 50 01             	lea    0x1(%eax),%edx
801010a9:	8b 45 08             	mov    0x8(%ebp),%eax
801010ac:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	68 20 38 11 80       	push   $0x80113820
801010b7:	e8 d3 4d 00 00       	call   80105e8f <release>
801010bc:	83 c4 10             	add    $0x10,%esp
  return f;
801010bf:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010c2:	c9                   	leave  
801010c3:	c3                   	ret    

801010c4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010c4:	f3 0f 1e fb          	endbr32 
801010c8:	55                   	push   %ebp
801010c9:	89 e5                	mov    %esp,%ebp
801010cb:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ce:	83 ec 0c             	sub    $0xc,%esp
801010d1:	68 20 38 11 80       	push   $0x80113820
801010d6:	e8 49 4d 00 00       	call   80105e24 <acquire>
801010db:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010de:	8b 45 08             	mov    0x8(%ebp),%eax
801010e1:	8b 40 04             	mov    0x4(%eax),%eax
801010e4:	85 c0                	test   %eax,%eax
801010e6:	7f 0d                	jg     801010f5 <fileclose+0x31>
    panic("fileclose");
801010e8:	83 ec 0c             	sub    $0xc,%esp
801010eb:	68 55 a0 10 80       	push   $0x8010a055
801010f0:	e8 a2 f4 ff ff       	call   80100597 <panic>
  if(--f->ref > 0){
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	8b 40 04             	mov    0x4(%eax),%eax
801010fb:	8d 50 ff             	lea    -0x1(%eax),%edx
801010fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101101:	89 50 04             	mov    %edx,0x4(%eax)
80101104:	8b 45 08             	mov    0x8(%ebp),%eax
80101107:	8b 40 04             	mov    0x4(%eax),%eax
8010110a:	85 c0                	test   %eax,%eax
8010110c:	7e 15                	jle    80101123 <fileclose+0x5f>
    release(&ftable.lock);
8010110e:	83 ec 0c             	sub    $0xc,%esp
80101111:	68 20 38 11 80       	push   $0x80113820
80101116:	e8 74 4d 00 00       	call   80105e8f <release>
8010111b:	83 c4 10             	add    $0x10,%esp
8010111e:	e9 8b 00 00 00       	jmp    801011ae <fileclose+0xea>
    return;
  }
  ff = *f;
80101123:	8b 45 08             	mov    0x8(%ebp),%eax
80101126:	8b 10                	mov    (%eax),%edx
80101128:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010112b:	8b 50 04             	mov    0x4(%eax),%edx
8010112e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101131:	8b 50 08             	mov    0x8(%eax),%edx
80101134:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101137:	8b 50 0c             	mov    0xc(%eax),%edx
8010113a:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010113d:	8b 50 10             	mov    0x10(%eax),%edx
80101140:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101143:	8b 40 14             	mov    0x14(%eax),%eax
80101146:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101149:	8b 45 08             	mov    0x8(%ebp),%eax
8010114c:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101153:	8b 45 08             	mov    0x8(%ebp),%eax
80101156:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
8010115c:	83 ec 0c             	sub    $0xc,%esp
8010115f:	68 20 38 11 80       	push   $0x80113820
80101164:	e8 26 4d 00 00       	call   80105e8f <release>
80101169:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
8010116c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116f:	83 f8 01             	cmp    $0x1,%eax
80101172:	75 19                	jne    8010118d <fileclose+0xc9>
    pipeclose(ff.pipe, ff.writable);
80101174:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101178:	0f be d0             	movsbl %al,%edx
8010117b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010117e:	83 ec 08             	sub    $0x8,%esp
80101181:	52                   	push   %edx
80101182:	50                   	push   %eax
80101183:	e8 5e 39 00 00       	call   80104ae6 <pipeclose>
80101188:	83 c4 10             	add    $0x10,%esp
8010118b:	eb 21                	jmp    801011ae <fileclose+0xea>
  else if(ff.type == FD_INODE){
8010118d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101190:	83 f8 02             	cmp    $0x2,%eax
80101193:	75 19                	jne    801011ae <fileclose+0xea>
    begin_op();
80101195:	e8 9c 2c 00 00       	call   80103e36 <begin_op>
    iput(ff.ip);
8010119a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010119d:	83 ec 0c             	sub    $0xc,%esp
801011a0:	50                   	push   %eax
801011a1:	e8 43 0a 00 00       	call   80101be9 <iput>
801011a6:	83 c4 10             	add    $0x10,%esp
    end_op();
801011a9:	e8 18 2d 00 00       	call   80103ec6 <end_op>
  }
}
801011ae:	c9                   	leave  
801011af:	c3                   	ret    

801011b0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011b0:	f3 0f 1e fb          	endbr32 
801011b4:	55                   	push   %ebp
801011b5:	89 e5                	mov    %esp,%ebp
801011b7:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
801011ba:	8b 45 08             	mov    0x8(%ebp),%eax
801011bd:	8b 00                	mov    (%eax),%eax
801011bf:	83 f8 02             	cmp    $0x2,%eax
801011c2:	75 40                	jne    80101204 <filestat+0x54>
    ilock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 3e 08 00 00       	call   80101a11 <ilock>
801011d3:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	8b 40 10             	mov    0x10(%eax),%eax
801011dc:	83 ec 08             	sub    $0x8,%esp
801011df:	ff 75 0c             	pushl  0xc(%ebp)
801011e2:	50                   	push   %eax
801011e3:	e8 64 0d 00 00       	call   80101f4c <stati>
801011e8:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011eb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ee:	8b 40 10             	mov    0x10(%eax),%eax
801011f1:	83 ec 0c             	sub    $0xc,%esp
801011f4:	50                   	push   %eax
801011f5:	e8 79 09 00 00       	call   80101b73 <iunlock>
801011fa:	83 c4 10             	add    $0x10,%esp
    return 0;
801011fd:	b8 00 00 00 00       	mov    $0x0,%eax
80101202:	eb 05                	jmp    80101209 <filestat+0x59>
  }
  return -1;
80101204:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101209:	c9                   	leave  
8010120a:	c3                   	ret    

8010120b <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010120b:	f3 0f 1e fb          	endbr32 
8010120f:	55                   	push   %ebp
80101210:	89 e5                	mov    %esp,%ebp
80101212:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
80101215:	8b 45 08             	mov    0x8(%ebp),%eax
80101218:	0f b6 40 08          	movzbl 0x8(%eax),%eax
8010121c:	84 c0                	test   %al,%al
8010121e:	75 0a                	jne    8010122a <fileread+0x1f>
    return -1;
80101220:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101225:	e9 9b 00 00 00       	jmp    801012c5 <fileread+0xba>
  if(f->type == FD_PIPE)
8010122a:	8b 45 08             	mov    0x8(%ebp),%eax
8010122d:	8b 00                	mov    (%eax),%eax
8010122f:	83 f8 01             	cmp    $0x1,%eax
80101232:	75 1a                	jne    8010124e <fileread+0x43>
    return piperead(f->pipe, addr, n);
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	8b 40 0c             	mov    0xc(%eax),%eax
8010123a:	83 ec 04             	sub    $0x4,%esp
8010123d:	ff 75 10             	pushl  0x10(%ebp)
80101240:	ff 75 0c             	pushl  0xc(%ebp)
80101243:	50                   	push   %eax
80101244:	e8 53 3a 00 00       	call   80104c9c <piperead>
80101249:	83 c4 10             	add    $0x10,%esp
8010124c:	eb 77                	jmp    801012c5 <fileread+0xba>
  if(f->type == FD_INODE){
8010124e:	8b 45 08             	mov    0x8(%ebp),%eax
80101251:	8b 00                	mov    (%eax),%eax
80101253:	83 f8 02             	cmp    $0x2,%eax
80101256:	75 60                	jne    801012b8 <fileread+0xad>
    ilock(f->ip);
80101258:	8b 45 08             	mov    0x8(%ebp),%eax
8010125b:	8b 40 10             	mov    0x10(%eax),%eax
8010125e:	83 ec 0c             	sub    $0xc,%esp
80101261:	50                   	push   %eax
80101262:	e8 aa 07 00 00       	call   80101a11 <ilock>
80101267:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010126a:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010126d:	8b 45 08             	mov    0x8(%ebp),%eax
80101270:	8b 50 14             	mov    0x14(%eax),%edx
80101273:	8b 45 08             	mov    0x8(%ebp),%eax
80101276:	8b 40 10             	mov    0x10(%eax),%eax
80101279:	51                   	push   %ecx
8010127a:	52                   	push   %edx
8010127b:	ff 75 0c             	pushl  0xc(%ebp)
8010127e:	50                   	push   %eax
8010127f:	e8 12 0d 00 00       	call   80101f96 <readi>
80101284:	83 c4 10             	add    $0x10,%esp
80101287:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010128a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010128e:	7e 11                	jle    801012a1 <fileread+0x96>
      f->off += r;
80101290:	8b 45 08             	mov    0x8(%ebp),%eax
80101293:	8b 50 14             	mov    0x14(%eax),%edx
80101296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101299:	01 c2                	add    %eax,%edx
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
8010129e:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012a1:	8b 45 08             	mov    0x8(%ebp),%eax
801012a4:	8b 40 10             	mov    0x10(%eax),%eax
801012a7:	83 ec 0c             	sub    $0xc,%esp
801012aa:	50                   	push   %eax
801012ab:	e8 c3 08 00 00       	call   80101b73 <iunlock>
801012b0:	83 c4 10             	add    $0x10,%esp
    return r;
801012b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b6:	eb 0d                	jmp    801012c5 <fileread+0xba>
  }
  panic("fileread");
801012b8:	83 ec 0c             	sub    $0xc,%esp
801012bb:	68 5f a0 10 80       	push   $0x8010a05f
801012c0:	e8 d2 f2 ff ff       	call   80100597 <panic>
}
801012c5:	c9                   	leave  
801012c6:	c3                   	ret    

801012c7 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012c7:	f3 0f 1e fb          	endbr32 
801012cb:	55                   	push   %ebp
801012cc:	89 e5                	mov    %esp,%ebp
801012ce:	53                   	push   %ebx
801012cf:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012d2:	8b 45 08             	mov    0x8(%ebp),%eax
801012d5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012d9:	84 c0                	test   %al,%al
801012db:	75 0a                	jne    801012e7 <filewrite+0x20>
    return -1;
801012dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012e2:	e9 1b 01 00 00       	jmp    80101402 <filewrite+0x13b>
  if(f->type == FD_PIPE)
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8b 00                	mov    (%eax),%eax
801012ec:	83 f8 01             	cmp    $0x1,%eax
801012ef:	75 1d                	jne    8010130e <filewrite+0x47>
    return pipewrite(f->pipe, addr, n);
801012f1:	8b 45 08             	mov    0x8(%ebp),%eax
801012f4:	8b 40 0c             	mov    0xc(%eax),%eax
801012f7:	83 ec 04             	sub    $0x4,%esp
801012fa:	ff 75 10             	pushl  0x10(%ebp)
801012fd:	ff 75 0c             	pushl  0xc(%ebp)
80101300:	50                   	push   %eax
80101301:	e8 8f 38 00 00       	call   80104b95 <pipewrite>
80101306:	83 c4 10             	add    $0x10,%esp
80101309:	e9 f4 00 00 00       	jmp    80101402 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 00                	mov    (%eax),%eax
80101313:	83 f8 02             	cmp    $0x2,%eax
80101316:	0f 85 d9 00 00 00    	jne    801013f5 <filewrite+0x12e>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010131c:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101323:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010132a:	e9 a3 00 00 00       	jmp    801013d2 <filewrite+0x10b>
      int n1 = n - i;
8010132f:	8b 45 10             	mov    0x10(%ebp),%eax
80101332:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101335:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101338:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010133b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010133e:	7e 06                	jle    80101346 <filewrite+0x7f>
        n1 = max;
80101340:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101343:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101346:	e8 eb 2a 00 00       	call   80103e36 <begin_op>
      ilock(f->ip);
8010134b:	8b 45 08             	mov    0x8(%ebp),%eax
8010134e:	8b 40 10             	mov    0x10(%eax),%eax
80101351:	83 ec 0c             	sub    $0xc,%esp
80101354:	50                   	push   %eax
80101355:	e8 b7 06 00 00       	call   80101a11 <ilock>
8010135a:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010135d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101360:	8b 45 08             	mov    0x8(%ebp),%eax
80101363:	8b 50 14             	mov    0x14(%eax),%edx
80101366:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101369:	8b 45 0c             	mov    0xc(%ebp),%eax
8010136c:	01 c3                	add    %eax,%ebx
8010136e:	8b 45 08             	mov    0x8(%ebp),%eax
80101371:	8b 40 10             	mov    0x10(%eax),%eax
80101374:	51                   	push   %ecx
80101375:	52                   	push   %edx
80101376:	53                   	push   %ebx
80101377:	50                   	push   %eax
80101378:	e8 72 0d 00 00       	call   801020ef <writei>
8010137d:	83 c4 10             	add    $0x10,%esp
80101380:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101383:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101387:	7e 11                	jle    8010139a <filewrite+0xd3>
        f->off += r;
80101389:	8b 45 08             	mov    0x8(%ebp),%eax
8010138c:	8b 50 14             	mov    0x14(%eax),%edx
8010138f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101392:	01 c2                	add    %eax,%edx
80101394:	8b 45 08             	mov    0x8(%ebp),%eax
80101397:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010139a:	8b 45 08             	mov    0x8(%ebp),%eax
8010139d:	8b 40 10             	mov    0x10(%eax),%eax
801013a0:	83 ec 0c             	sub    $0xc,%esp
801013a3:	50                   	push   %eax
801013a4:	e8 ca 07 00 00       	call   80101b73 <iunlock>
801013a9:	83 c4 10             	add    $0x10,%esp
      end_op();
801013ac:	e8 15 2b 00 00       	call   80103ec6 <end_op>

      if(r < 0)
801013b1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013b5:	78 29                	js     801013e0 <filewrite+0x119>
        break;
      if(r != n1)
801013b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ba:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013bd:	74 0d                	je     801013cc <filewrite+0x105>
        panic("short filewrite");
801013bf:	83 ec 0c             	sub    $0xc,%esp
801013c2:	68 68 a0 10 80       	push   $0x8010a068
801013c7:	e8 cb f1 ff ff       	call   80100597 <panic>
      i += r;
801013cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013cf:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013d8:	0f 8c 51 ff ff ff    	jl     8010132f <filewrite+0x68>
801013de:	eb 01                	jmp    801013e1 <filewrite+0x11a>
        break;
801013e0:	90                   	nop
    }
    return i == n ? n : -1;
801013e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e4:	3b 45 10             	cmp    0x10(%ebp),%eax
801013e7:	75 05                	jne    801013ee <filewrite+0x127>
801013e9:	8b 45 10             	mov    0x10(%ebp),%eax
801013ec:	eb 14                	jmp    80101402 <filewrite+0x13b>
801013ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013f3:	eb 0d                	jmp    80101402 <filewrite+0x13b>
  }
  panic("filewrite");
801013f5:	83 ec 0c             	sub    $0xc,%esp
801013f8:	68 78 a0 10 80       	push   $0x8010a078
801013fd:	e8 95 f1 ff ff       	call   80100597 <panic>
}
80101402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101405:	c9                   	leave  
80101406:	c3                   	ret    

80101407 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101407:	f3 0f 1e fb          	endbr32 
8010140b:	55                   	push   %ebp
8010140c:	89 e5                	mov    %esp,%ebp
8010140e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
80101411:	8b 45 08             	mov    0x8(%ebp),%eax
80101414:	83 ec 08             	sub    $0x8,%esp
80101417:	6a 01                	push   $0x1
80101419:	50                   	push   %eax
8010141a:	e8 a0 ed ff ff       	call   801001bf <bread>
8010141f:	83 c4 10             	add    $0x10,%esp
80101422:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101428:	83 c0 18             	add    $0x18,%eax
8010142b:	83 ec 04             	sub    $0x4,%esp
8010142e:	6a 1c                	push   $0x1c
80101430:	50                   	push   %eax
80101431:	ff 75 0c             	pushl  0xc(%ebp)
80101434:	e8 2e 4d 00 00       	call   80106167 <memmove>
80101439:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010143c:	83 ec 0c             	sub    $0xc,%esp
8010143f:	ff 75 f4             	pushl  -0xc(%ebp)
80101442:	e8 f8 ed ff ff       	call   8010023f <brelse>
80101447:	83 c4 10             	add    $0x10,%esp
}
8010144a:	90                   	nop
8010144b:	c9                   	leave  
8010144c:	c3                   	ret    

8010144d <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010144d:	f3 0f 1e fb          	endbr32 
80101451:	55                   	push   %ebp
80101452:	89 e5                	mov    %esp,%ebp
80101454:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
80101457:	8b 55 0c             	mov    0xc(%ebp),%edx
8010145a:	8b 45 08             	mov    0x8(%ebp),%eax
8010145d:	83 ec 08             	sub    $0x8,%esp
80101460:	52                   	push   %edx
80101461:	50                   	push   %eax
80101462:	e8 58 ed ff ff       	call   801001bf <bread>
80101467:	83 c4 10             	add    $0x10,%esp
8010146a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010146d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101470:	83 c0 18             	add    $0x18,%eax
80101473:	83 ec 04             	sub    $0x4,%esp
80101476:	68 00 02 00 00       	push   $0x200
8010147b:	6a 00                	push   $0x0
8010147d:	50                   	push   %eax
8010147e:	e8 1d 4c 00 00       	call   801060a0 <memset>
80101483:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101486:	83 ec 0c             	sub    $0xc,%esp
80101489:	ff 75 f4             	pushl  -0xc(%ebp)
8010148c:	e8 ee 2b 00 00       	call   8010407f <log_write>
80101491:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101494:	83 ec 0c             	sub    $0xc,%esp
80101497:	ff 75 f4             	pushl  -0xc(%ebp)
8010149a:	e8 a0 ed ff ff       	call   8010023f <brelse>
8010149f:	83 c4 10             	add    $0x10,%esp
}
801014a2:	90                   	nop
801014a3:	c9                   	leave  
801014a4:	c3                   	ret    

801014a5 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014a5:	f3 0f 1e fb          	endbr32 
801014a9:	55                   	push   %ebp
801014aa:	89 e5                	mov    %esp,%ebp
801014ac:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014af:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014bd:	e9 13 01 00 00       	jmp    801015d5 <balloc+0x130>
    bp = bread(dev, BBLOCK(b, sb));
801014c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014c5:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
801014cb:	85 c0                	test   %eax,%eax
801014cd:	0f 48 c2             	cmovs  %edx,%eax
801014d0:	c1 f8 0c             	sar    $0xc,%eax
801014d3:	89 c2                	mov    %eax,%edx
801014d5:	a1 38 42 11 80       	mov    0x80114238,%eax
801014da:	01 d0                	add    %edx,%eax
801014dc:	83 ec 08             	sub    $0x8,%esp
801014df:	50                   	push   %eax
801014e0:	ff 75 08             	pushl  0x8(%ebp)
801014e3:	e8 d7 ec ff ff       	call   801001bf <bread>
801014e8:	83 c4 10             	add    $0x10,%esp
801014eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014ee:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014f5:	e9 a6 00 00 00       	jmp    801015a0 <balloc+0xfb>
      m = 1 << (bi % 8);
801014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014fd:	99                   	cltd   
801014fe:	c1 ea 1d             	shr    $0x1d,%edx
80101501:	01 d0                	add    %edx,%eax
80101503:	83 e0 07             	and    $0x7,%eax
80101506:	29 d0                	sub    %edx,%eax
80101508:	ba 01 00 00 00       	mov    $0x1,%edx
8010150d:	89 c1                	mov    %eax,%ecx
8010150f:	d3 e2                	shl    %cl,%edx
80101511:	89 d0                	mov    %edx,%eax
80101513:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101516:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101519:	8d 50 07             	lea    0x7(%eax),%edx
8010151c:	85 c0                	test   %eax,%eax
8010151e:	0f 48 c2             	cmovs  %edx,%eax
80101521:	c1 f8 03             	sar    $0x3,%eax
80101524:	89 c2                	mov    %eax,%edx
80101526:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101529:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010152e:	0f b6 c0             	movzbl %al,%eax
80101531:	23 45 e8             	and    -0x18(%ebp),%eax
80101534:	85 c0                	test   %eax,%eax
80101536:	75 64                	jne    8010159c <balloc+0xf7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153b:	8d 50 07             	lea    0x7(%eax),%edx
8010153e:	85 c0                	test   %eax,%eax
80101540:	0f 48 c2             	cmovs  %edx,%eax
80101543:	c1 f8 03             	sar    $0x3,%eax
80101546:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101549:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010154e:	89 d1                	mov    %edx,%ecx
80101550:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101553:	09 ca                	or     %ecx,%edx
80101555:	89 d1                	mov    %edx,%ecx
80101557:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010155a:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
8010155e:	83 ec 0c             	sub    $0xc,%esp
80101561:	ff 75 ec             	pushl  -0x14(%ebp)
80101564:	e8 16 2b 00 00       	call   8010407f <log_write>
80101569:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
8010156c:	83 ec 0c             	sub    $0xc,%esp
8010156f:	ff 75 ec             	pushl  -0x14(%ebp)
80101572:	e8 c8 ec ff ff       	call   8010023f <brelse>
80101577:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
8010157a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010157d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101580:	01 c2                	add    %eax,%edx
80101582:	8b 45 08             	mov    0x8(%ebp),%eax
80101585:	83 ec 08             	sub    $0x8,%esp
80101588:	52                   	push   %edx
80101589:	50                   	push   %eax
8010158a:	e8 be fe ff ff       	call   8010144d <bzero>
8010158f:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101592:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101598:	01 d0                	add    %edx,%eax
8010159a:	eb 57                	jmp    801015f3 <balloc+0x14e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010159c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801015a0:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015a7:	7f 17                	jg     801015c0 <balloc+0x11b>
801015a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015af:	01 d0                	add    %edx,%eax
801015b1:	89 c2                	mov    %eax,%edx
801015b3:	a1 20 42 11 80       	mov    0x80114220,%eax
801015b8:	39 c2                	cmp    %eax,%edx
801015ba:	0f 82 3a ff ff ff    	jb     801014fa <balloc+0x55>
      }
    }
    brelse(bp);
801015c0:	83 ec 0c             	sub    $0xc,%esp
801015c3:	ff 75 ec             	pushl  -0x14(%ebp)
801015c6:	e8 74 ec ff ff       	call   8010023f <brelse>
801015cb:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
801015ce:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015d5:	8b 15 20 42 11 80    	mov    0x80114220,%edx
801015db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015de:	39 c2                	cmp    %eax,%edx
801015e0:	0f 87 dc fe ff ff    	ja     801014c2 <balloc+0x1d>
  }
  panic("balloc: out of blocks");
801015e6:	83 ec 0c             	sub    $0xc,%esp
801015e9:	68 84 a0 10 80       	push   $0x8010a084
801015ee:	e8 a4 ef ff ff       	call   80100597 <panic>
}
801015f3:	c9                   	leave  
801015f4:	c3                   	ret    

801015f5 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015f5:	f3 0f 1e fb          	endbr32 
801015f9:	55                   	push   %ebp
801015fa:	89 e5                	mov    %esp,%ebp
801015fc:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015ff:	83 ec 08             	sub    $0x8,%esp
80101602:	68 20 42 11 80       	push   $0x80114220
80101607:	ff 75 08             	pushl  0x8(%ebp)
8010160a:	e8 f8 fd ff ff       	call   80101407 <readsb>
8010160f:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101612:	8b 45 0c             	mov    0xc(%ebp),%eax
80101615:	c1 e8 0c             	shr    $0xc,%eax
80101618:	89 c2                	mov    %eax,%edx
8010161a:	a1 38 42 11 80       	mov    0x80114238,%eax
8010161f:	01 c2                	add    %eax,%edx
80101621:	8b 45 08             	mov    0x8(%ebp),%eax
80101624:	83 ec 08             	sub    $0x8,%esp
80101627:	52                   	push   %edx
80101628:	50                   	push   %eax
80101629:	e8 91 eb ff ff       	call   801001bf <bread>
8010162e:	83 c4 10             	add    $0x10,%esp
80101631:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101634:	8b 45 0c             	mov    0xc(%ebp),%eax
80101637:	25 ff 0f 00 00       	and    $0xfff,%eax
8010163c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101642:	99                   	cltd   
80101643:	c1 ea 1d             	shr    $0x1d,%edx
80101646:	01 d0                	add    %edx,%eax
80101648:	83 e0 07             	and    $0x7,%eax
8010164b:	29 d0                	sub    %edx,%eax
8010164d:	ba 01 00 00 00       	mov    $0x1,%edx
80101652:	89 c1                	mov    %eax,%ecx
80101654:	d3 e2                	shl    %cl,%edx
80101656:	89 d0                	mov    %edx,%eax
80101658:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165e:	8d 50 07             	lea    0x7(%eax),%edx
80101661:	85 c0                	test   %eax,%eax
80101663:	0f 48 c2             	cmovs  %edx,%eax
80101666:	c1 f8 03             	sar    $0x3,%eax
80101669:	89 c2                	mov    %eax,%edx
8010166b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010166e:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101673:	0f b6 c0             	movzbl %al,%eax
80101676:	23 45 ec             	and    -0x14(%ebp),%eax
80101679:	85 c0                	test   %eax,%eax
8010167b:	75 0d                	jne    8010168a <bfree+0x95>
    panic("freeing free block");
8010167d:	83 ec 0c             	sub    $0xc,%esp
80101680:	68 9a a0 10 80       	push   $0x8010a09a
80101685:	e8 0d ef ff ff       	call   80100597 <panic>
  bp->data[bi/8] &= ~m;
8010168a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010168d:	8d 50 07             	lea    0x7(%eax),%edx
80101690:	85 c0                	test   %eax,%eax
80101692:	0f 48 c2             	cmovs  %edx,%eax
80101695:	c1 f8 03             	sar    $0x3,%eax
80101698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010169b:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801016a0:	89 d1                	mov    %edx,%ecx
801016a2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801016a5:	f7 d2                	not    %edx
801016a7:	21 ca                	and    %ecx,%edx
801016a9:	89 d1                	mov    %edx,%ecx
801016ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016ae:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
801016b2:	83 ec 0c             	sub    $0xc,%esp
801016b5:	ff 75 f4             	pushl  -0xc(%ebp)
801016b8:	e8 c2 29 00 00       	call   8010407f <log_write>
801016bd:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801016c0:	83 ec 0c             	sub    $0xc,%esp
801016c3:	ff 75 f4             	pushl  -0xc(%ebp)
801016c6:	e8 74 eb ff ff       	call   8010023f <brelse>
801016cb:	83 c4 10             	add    $0x10,%esp
}
801016ce:	90                   	nop
801016cf:	c9                   	leave  
801016d0:	c3                   	ret    

801016d1 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016d1:	f3 0f 1e fb          	endbr32 
801016d5:	55                   	push   %ebp
801016d6:	89 e5                	mov    %esp,%ebp
801016d8:	57                   	push   %edi
801016d9:	56                   	push   %esi
801016da:	53                   	push   %ebx
801016db:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
801016de:	83 ec 08             	sub    $0x8,%esp
801016e1:	68 ad a0 10 80       	push   $0x8010a0ad
801016e6:	68 40 42 11 80       	push   $0x80114240
801016eb:	e8 0e 47 00 00       	call   80105dfe <initlock>
801016f0:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
801016f3:	83 ec 08             	sub    $0x8,%esp
801016f6:	68 20 42 11 80       	push   $0x80114220
801016fb:	ff 75 08             	pushl  0x8(%ebp)
801016fe:	e8 04 fd ff ff       	call   80101407 <readsb>
80101703:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101706:	a1 38 42 11 80       	mov    0x80114238,%eax
8010170b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010170e:	8b 3d 34 42 11 80    	mov    0x80114234,%edi
80101714:	8b 35 30 42 11 80    	mov    0x80114230,%esi
8010171a:	8b 1d 2c 42 11 80    	mov    0x8011422c,%ebx
80101720:	8b 0d 28 42 11 80    	mov    0x80114228,%ecx
80101726:	8b 15 24 42 11 80    	mov    0x80114224,%edx
8010172c:	a1 20 42 11 80       	mov    0x80114220,%eax
80101731:	ff 75 e4             	pushl  -0x1c(%ebp)
80101734:	57                   	push   %edi
80101735:	56                   	push   %esi
80101736:	53                   	push   %ebx
80101737:	51                   	push   %ecx
80101738:	52                   	push   %edx
80101739:	50                   	push   %eax
8010173a:	68 b4 a0 10 80       	push   $0x8010a0b4
8010173f:	e8 9a ec ff ff       	call   801003de <cprintf>
80101744:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101747:	90                   	nop
80101748:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010174b:	5b                   	pop    %ebx
8010174c:	5e                   	pop    %esi
8010174d:	5f                   	pop    %edi
8010174e:	5d                   	pop    %ebp
8010174f:	c3                   	ret    

80101750 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101750:	f3 0f 1e fb          	endbr32 
80101754:	55                   	push   %ebp
80101755:	89 e5                	mov    %esp,%ebp
80101757:	83 ec 28             	sub    $0x28,%esp
8010175a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010175d:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101761:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101768:	e9 9e 00 00 00       	jmp    8010180b <ialloc+0xbb>
    bp = bread(dev, IBLOCK(inum, sb));
8010176d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101770:	c1 e8 03             	shr    $0x3,%eax
80101773:	89 c2                	mov    %eax,%edx
80101775:	a1 34 42 11 80       	mov    0x80114234,%eax
8010177a:	01 d0                	add    %edx,%eax
8010177c:	83 ec 08             	sub    $0x8,%esp
8010177f:	50                   	push   %eax
80101780:	ff 75 08             	pushl  0x8(%ebp)
80101783:	e8 37 ea ff ff       	call   801001bf <bread>
80101788:	83 c4 10             	add    $0x10,%esp
8010178b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101791:	8d 50 18             	lea    0x18(%eax),%edx
80101794:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101797:	83 e0 07             	and    $0x7,%eax
8010179a:	c1 e0 06             	shl    $0x6,%eax
8010179d:	01 d0                	add    %edx,%eax
8010179f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017a5:	0f b7 00             	movzwl (%eax),%eax
801017a8:	66 85 c0             	test   %ax,%ax
801017ab:	75 4c                	jne    801017f9 <ialloc+0xa9>
      memset(dip, 0, sizeof(*dip));
801017ad:	83 ec 04             	sub    $0x4,%esp
801017b0:	6a 40                	push   $0x40
801017b2:	6a 00                	push   $0x0
801017b4:	ff 75 ec             	pushl  -0x14(%ebp)
801017b7:	e8 e4 48 00 00       	call   801060a0 <memset>
801017bc:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017c2:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017c6:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017c9:	83 ec 0c             	sub    $0xc,%esp
801017cc:	ff 75 f0             	pushl  -0x10(%ebp)
801017cf:	e8 ab 28 00 00       	call   8010407f <log_write>
801017d4:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017d7:	83 ec 0c             	sub    $0xc,%esp
801017da:	ff 75 f0             	pushl  -0x10(%ebp)
801017dd:	e8 5d ea ff ff       	call   8010023f <brelse>
801017e2:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017e8:	83 ec 08             	sub    $0x8,%esp
801017eb:	50                   	push   %eax
801017ec:	ff 75 08             	pushl  0x8(%ebp)
801017ef:	e8 fc 00 00 00       	call   801018f0 <iget>
801017f4:	83 c4 10             	add    $0x10,%esp
801017f7:	eb 30                	jmp    80101829 <ialloc+0xd9>
    }
    brelse(bp);
801017f9:	83 ec 0c             	sub    $0xc,%esp
801017fc:	ff 75 f0             	pushl  -0x10(%ebp)
801017ff:	e8 3b ea ff ff       	call   8010023f <brelse>
80101804:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101807:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010180b:	8b 15 28 42 11 80    	mov    0x80114228,%edx
80101811:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101814:	39 c2                	cmp    %eax,%edx
80101816:	0f 87 51 ff ff ff    	ja     8010176d <ialloc+0x1d>
  }
  panic("ialloc: no inodes");
8010181c:	83 ec 0c             	sub    $0xc,%esp
8010181f:	68 07 a1 10 80       	push   $0x8010a107
80101824:	e8 6e ed ff ff       	call   80100597 <panic>
}
80101829:	c9                   	leave  
8010182a:	c3                   	ret    

8010182b <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
8010182b:	f3 0f 1e fb          	endbr32 
8010182f:	55                   	push   %ebp
80101830:	89 e5                	mov    %esp,%ebp
80101832:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101835:	8b 45 08             	mov    0x8(%ebp),%eax
80101838:	8b 40 04             	mov    0x4(%eax),%eax
8010183b:	c1 e8 03             	shr    $0x3,%eax
8010183e:	89 c2                	mov    %eax,%edx
80101840:	a1 34 42 11 80       	mov    0x80114234,%eax
80101845:	01 c2                	add    %eax,%edx
80101847:	8b 45 08             	mov    0x8(%ebp),%eax
8010184a:	8b 00                	mov    (%eax),%eax
8010184c:	83 ec 08             	sub    $0x8,%esp
8010184f:	52                   	push   %edx
80101850:	50                   	push   %eax
80101851:	e8 69 e9 ff ff       	call   801001bf <bread>
80101856:	83 c4 10             	add    $0x10,%esp
80101859:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185f:	8d 50 18             	lea    0x18(%eax),%edx
80101862:	8b 45 08             	mov    0x8(%ebp),%eax
80101865:	8b 40 04             	mov    0x4(%eax),%eax
80101868:	83 e0 07             	and    $0x7,%eax
8010186b:	c1 e0 06             	shl    $0x6,%eax
8010186e:	01 d0                	add    %edx,%eax
80101870:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101873:	8b 45 08             	mov    0x8(%ebp),%eax
80101876:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010187a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187d:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101880:	8b 45 08             	mov    0x8(%ebp),%eax
80101883:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101887:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010188e:	8b 45 08             	mov    0x8(%ebp),%eax
80101891:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101898:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a6:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801018aa:	8b 45 08             	mov    0x8(%ebp),%eax
801018ad:	8b 50 18             	mov    0x18(%eax),%edx
801018b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b3:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018b6:	8b 45 08             	mov    0x8(%ebp),%eax
801018b9:	8d 50 1c             	lea    0x1c(%eax),%edx
801018bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018bf:	83 c0 0c             	add    $0xc,%eax
801018c2:	83 ec 04             	sub    $0x4,%esp
801018c5:	6a 34                	push   $0x34
801018c7:	52                   	push   %edx
801018c8:	50                   	push   %eax
801018c9:	e8 99 48 00 00       	call   80106167 <memmove>
801018ce:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018d1:	83 ec 0c             	sub    $0xc,%esp
801018d4:	ff 75 f4             	pushl  -0xc(%ebp)
801018d7:	e8 a3 27 00 00       	call   8010407f <log_write>
801018dc:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018df:	83 ec 0c             	sub    $0xc,%esp
801018e2:	ff 75 f4             	pushl  -0xc(%ebp)
801018e5:	e8 55 e9 ff ff       	call   8010023f <brelse>
801018ea:	83 c4 10             	add    $0x10,%esp
}
801018ed:	90                   	nop
801018ee:	c9                   	leave  
801018ef:	c3                   	ret    

801018f0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018f0:	f3 0f 1e fb          	endbr32 
801018f4:	55                   	push   %ebp
801018f5:	89 e5                	mov    %esp,%ebp
801018f7:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018fa:	83 ec 0c             	sub    $0xc,%esp
801018fd:	68 40 42 11 80       	push   $0x80114240
80101902:	e8 1d 45 00 00       	call   80105e24 <acquire>
80101907:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010190a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101911:	c7 45 f4 74 42 11 80 	movl   $0x80114274,-0xc(%ebp)
80101918:	eb 5d                	jmp    80101977 <iget+0x87>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010191a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191d:	8b 40 08             	mov    0x8(%eax),%eax
80101920:	85 c0                	test   %eax,%eax
80101922:	7e 39                	jle    8010195d <iget+0x6d>
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	8b 00                	mov    (%eax),%eax
80101929:	39 45 08             	cmp    %eax,0x8(%ebp)
8010192c:	75 2f                	jne    8010195d <iget+0x6d>
8010192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101931:	8b 40 04             	mov    0x4(%eax),%eax
80101934:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101937:	75 24                	jne    8010195d <iget+0x6d>
      ip->ref++;
80101939:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193c:	8b 40 08             	mov    0x8(%eax),%eax
8010193f:	8d 50 01             	lea    0x1(%eax),%edx
80101942:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101945:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101948:	83 ec 0c             	sub    $0xc,%esp
8010194b:	68 40 42 11 80       	push   $0x80114240
80101950:	e8 3a 45 00 00       	call   80105e8f <release>
80101955:	83 c4 10             	add    $0x10,%esp
      return ip;
80101958:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010195b:	eb 74                	jmp    801019d1 <iget+0xe1>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010195d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101961:	75 10                	jne    80101973 <iget+0x83>
80101963:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101966:	8b 40 08             	mov    0x8(%eax),%eax
80101969:	85 c0                	test   %eax,%eax
8010196b:	75 06                	jne    80101973 <iget+0x83>
      empty = ip;
8010196d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101970:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101973:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101977:	81 7d f4 14 52 11 80 	cmpl   $0x80115214,-0xc(%ebp)
8010197e:	72 9a                	jb     8010191a <iget+0x2a>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101984:	75 0d                	jne    80101993 <iget+0xa3>
    panic("iget: no inodes");
80101986:	83 ec 0c             	sub    $0xc,%esp
80101989:	68 19 a1 10 80       	push   $0x8010a119
8010198e:	e8 04 ec ff ff       	call   80100597 <panic>

  ip = empty;
80101993:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101996:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	8b 55 08             	mov    0x8(%ebp),%edx
8010199f:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019a4:	8b 55 0c             	mov    0xc(%ebp),%edx
801019a7:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019ad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 40 42 11 80       	push   $0x80114240
801019c6:	e8 c4 44 00 00       	call   80105e8f <release>
801019cb:	83 c4 10             	add    $0x10,%esp

  return ip;
801019ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019d1:	c9                   	leave  
801019d2:	c3                   	ret    

801019d3 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019d3:	f3 0f 1e fb          	endbr32 
801019d7:	55                   	push   %ebp
801019d8:	89 e5                	mov    %esp,%ebp
801019da:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 40 42 11 80       	push   $0x80114240
801019e5:	e8 3a 44 00 00       	call   80105e24 <acquire>
801019ea:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
801019f0:	8b 40 08             	mov    0x8(%eax),%eax
801019f3:	8d 50 01             	lea    0x1(%eax),%edx
801019f6:	8b 45 08             	mov    0x8(%ebp),%eax
801019f9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019fc:	83 ec 0c             	sub    $0xc,%esp
801019ff:	68 40 42 11 80       	push   $0x80114240
80101a04:	e8 86 44 00 00       	call   80105e8f <release>
80101a09:	83 c4 10             	add    $0x10,%esp
  return ip;
80101a0c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a0f:	c9                   	leave  
80101a10:	c3                   	ret    

80101a11 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a11:	f3 0f 1e fb          	endbr32 
80101a15:	55                   	push   %ebp
80101a16:	89 e5                	mov    %esp,%ebp
80101a18:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a1b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a1f:	74 0a                	je     80101a2b <ilock+0x1a>
80101a21:	8b 45 08             	mov    0x8(%ebp),%eax
80101a24:	8b 40 08             	mov    0x8(%eax),%eax
80101a27:	85 c0                	test   %eax,%eax
80101a29:	7f 0d                	jg     80101a38 <ilock+0x27>
    panic("ilock");
80101a2b:	83 ec 0c             	sub    $0xc,%esp
80101a2e:	68 29 a1 10 80       	push   $0x8010a129
80101a33:	e8 5f eb ff ff       	call   80100597 <panic>

  acquire(&icache.lock);
80101a38:	83 ec 0c             	sub    $0xc,%esp
80101a3b:	68 40 42 11 80       	push   $0x80114240
80101a40:	e8 df 43 00 00       	call   80105e24 <acquire>
80101a45:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a48:	eb 13                	jmp    80101a5d <ilock+0x4c>
    sleep(ip, &icache.lock);
80101a4a:	83 ec 08             	sub    $0x8,%esp
80101a4d:	68 40 42 11 80       	push   $0x80114240
80101a52:	ff 75 08             	pushl  0x8(%ebp)
80101a55:	e8 9b 3e 00 00       	call   801058f5 <sleep>
80101a5a:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	8b 40 0c             	mov    0xc(%eax),%eax
80101a63:	83 e0 01             	and    $0x1,%eax
80101a66:	85 c0                	test   %eax,%eax
80101a68:	75 e0                	jne    80101a4a <ilock+0x39>
  ip->flags |= I_BUSY;
80101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a6d:	8b 40 0c             	mov    0xc(%eax),%eax
80101a70:	83 c8 01             	or     $0x1,%eax
80101a73:	89 c2                	mov    %eax,%edx
80101a75:	8b 45 08             	mov    0x8(%ebp),%eax
80101a78:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101a7b:	83 ec 0c             	sub    $0xc,%esp
80101a7e:	68 40 42 11 80       	push   $0x80114240
80101a83:	e8 07 44 00 00       	call   80105e8f <release>
80101a88:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8e:	8b 40 0c             	mov    0xc(%eax),%eax
80101a91:	83 e0 02             	and    $0x2,%eax
80101a94:	85 c0                	test   %eax,%eax
80101a96:	0f 85 d4 00 00 00    	jne    80101b70 <ilock+0x15f>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9f:	8b 40 04             	mov    0x4(%eax),%eax
80101aa2:	c1 e8 03             	shr    $0x3,%eax
80101aa5:	89 c2                	mov    %eax,%edx
80101aa7:	a1 34 42 11 80       	mov    0x80114234,%eax
80101aac:	01 c2                	add    %eax,%edx
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	8b 00                	mov    (%eax),%eax
80101ab3:	83 ec 08             	sub    $0x8,%esp
80101ab6:	52                   	push   %edx
80101ab7:	50                   	push   %eax
80101ab8:	e8 02 e7 ff ff       	call   801001bf <bread>
80101abd:	83 c4 10             	add    $0x10,%esp
80101ac0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101ac3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac6:	8d 50 18             	lea    0x18(%eax),%edx
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	8b 40 04             	mov    0x4(%eax),%eax
80101acf:	83 e0 07             	and    $0x7,%eax
80101ad2:	c1 e0 06             	shl    $0x6,%eax
80101ad5:	01 d0                	add    %edx,%eax
80101ad7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101add:	0f b7 10             	movzwl (%eax),%edx
80101ae0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae3:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101ae7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aea:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101aee:	8b 45 08             	mov    0x8(%ebp),%eax
80101af1:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101af5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101af8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101afc:	8b 45 08             	mov    0x8(%ebp),%eax
80101aff:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101b03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b06:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0d:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101b11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b14:	8b 50 08             	mov    0x8(%eax),%edx
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b20:	8d 50 0c             	lea    0xc(%eax),%edx
80101b23:	8b 45 08             	mov    0x8(%ebp),%eax
80101b26:	83 c0 1c             	add    $0x1c,%eax
80101b29:	83 ec 04             	sub    $0x4,%esp
80101b2c:	6a 34                	push   $0x34
80101b2e:	52                   	push   %edx
80101b2f:	50                   	push   %eax
80101b30:	e8 32 46 00 00       	call   80106167 <memmove>
80101b35:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101b38:	83 ec 0c             	sub    $0xc,%esp
80101b3b:	ff 75 f4             	pushl  -0xc(%ebp)
80101b3e:	e8 fc e6 ff ff       	call   8010023f <brelse>
80101b43:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101b46:	8b 45 08             	mov    0x8(%ebp),%eax
80101b49:	8b 40 0c             	mov    0xc(%eax),%eax
80101b4c:	83 c8 02             	or     $0x2,%eax
80101b4f:	89 c2                	mov    %eax,%edx
80101b51:	8b 45 08             	mov    0x8(%ebp),%eax
80101b54:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101b57:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101b5e:	66 85 c0             	test   %ax,%ax
80101b61:	75 0d                	jne    80101b70 <ilock+0x15f>
      panic("ilock: no type");
80101b63:	83 ec 0c             	sub    $0xc,%esp
80101b66:	68 2f a1 10 80       	push   $0x8010a12f
80101b6b:	e8 27 ea ff ff       	call   80100597 <panic>
  }
}
80101b70:	90                   	nop
80101b71:	c9                   	leave  
80101b72:	c3                   	ret    

80101b73 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b73:	f3 0f 1e fb          	endbr32 
80101b77:	55                   	push   %ebp
80101b78:	89 e5                	mov    %esp,%ebp
80101b7a:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101b7d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b81:	74 17                	je     80101b9a <iunlock+0x27>
80101b83:	8b 45 08             	mov    0x8(%ebp),%eax
80101b86:	8b 40 0c             	mov    0xc(%eax),%eax
80101b89:	83 e0 01             	and    $0x1,%eax
80101b8c:	85 c0                	test   %eax,%eax
80101b8e:	74 0a                	je     80101b9a <iunlock+0x27>
80101b90:	8b 45 08             	mov    0x8(%ebp),%eax
80101b93:	8b 40 08             	mov    0x8(%eax),%eax
80101b96:	85 c0                	test   %eax,%eax
80101b98:	7f 0d                	jg     80101ba7 <iunlock+0x34>
    panic("iunlock");
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 3e a1 10 80       	push   $0x8010a13e
80101ba2:	e8 f0 e9 ff ff       	call   80100597 <panic>

  acquire(&icache.lock);
80101ba7:	83 ec 0c             	sub    $0xc,%esp
80101baa:	68 40 42 11 80       	push   $0x80114240
80101baf:	e8 70 42 00 00       	call   80105e24 <acquire>
80101bb4:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bba:	8b 40 0c             	mov    0xc(%eax),%eax
80101bbd:	83 e0 fe             	and    $0xfffffffe,%eax
80101bc0:	89 c2                	mov    %eax,%edx
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101bc8:	83 ec 0c             	sub    $0xc,%esp
80101bcb:	ff 75 08             	pushl  0x8(%ebp)
80101bce:	e8 19 3e 00 00       	call   801059ec <wakeup>
80101bd3:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101bd6:	83 ec 0c             	sub    $0xc,%esp
80101bd9:	68 40 42 11 80       	push   $0x80114240
80101bde:	e8 ac 42 00 00       	call   80105e8f <release>
80101be3:	83 c4 10             	add    $0x10,%esp
}
80101be6:	90                   	nop
80101be7:	c9                   	leave  
80101be8:	c3                   	ret    

80101be9 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101be9:	f3 0f 1e fb          	endbr32 
80101bed:	55                   	push   %ebp
80101bee:	89 e5                	mov    %esp,%ebp
80101bf0:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101bf3:	83 ec 0c             	sub    $0xc,%esp
80101bf6:	68 40 42 11 80       	push   $0x80114240
80101bfb:	e8 24 42 00 00       	call   80105e24 <acquire>
80101c00:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101c03:	8b 45 08             	mov    0x8(%ebp),%eax
80101c06:	8b 40 08             	mov    0x8(%eax),%eax
80101c09:	83 f8 01             	cmp    $0x1,%eax
80101c0c:	0f 85 a9 00 00 00    	jne    80101cbb <iput+0xd2>
80101c12:	8b 45 08             	mov    0x8(%ebp),%eax
80101c15:	8b 40 0c             	mov    0xc(%eax),%eax
80101c18:	83 e0 02             	and    $0x2,%eax
80101c1b:	85 c0                	test   %eax,%eax
80101c1d:	0f 84 98 00 00 00    	je     80101cbb <iput+0xd2>
80101c23:	8b 45 08             	mov    0x8(%ebp),%eax
80101c26:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101c2a:	66 85 c0             	test   %ax,%ax
80101c2d:	0f 85 88 00 00 00    	jne    80101cbb <iput+0xd2>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101c33:	8b 45 08             	mov    0x8(%ebp),%eax
80101c36:	8b 40 0c             	mov    0xc(%eax),%eax
80101c39:	83 e0 01             	and    $0x1,%eax
80101c3c:	85 c0                	test   %eax,%eax
80101c3e:	74 0d                	je     80101c4d <iput+0x64>
      panic("iput busy");
80101c40:	83 ec 0c             	sub    $0xc,%esp
80101c43:	68 46 a1 10 80       	push   $0x8010a146
80101c48:	e8 4a e9 ff ff       	call   80100597 <panic>
    ip->flags |= I_BUSY;
80101c4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c50:	8b 40 0c             	mov    0xc(%eax),%eax
80101c53:	83 c8 01             	or     $0x1,%eax
80101c56:	89 c2                	mov    %eax,%edx
80101c58:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5b:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101c5e:	83 ec 0c             	sub    $0xc,%esp
80101c61:	68 40 42 11 80       	push   $0x80114240
80101c66:	e8 24 42 00 00       	call   80105e8f <release>
80101c6b:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101c6e:	83 ec 0c             	sub    $0xc,%esp
80101c71:	ff 75 08             	pushl  0x8(%ebp)
80101c74:	e8 ab 01 00 00       	call   80101e24 <itrunc>
80101c79:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7f:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101c85:	83 ec 0c             	sub    $0xc,%esp
80101c88:	ff 75 08             	pushl  0x8(%ebp)
80101c8b:	e8 9b fb ff ff       	call   8010182b <iupdate>
80101c90:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101c93:	83 ec 0c             	sub    $0xc,%esp
80101c96:	68 40 42 11 80       	push   $0x80114240
80101c9b:	e8 84 41 00 00       	call   80105e24 <acquire>
80101ca0:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101cad:	83 ec 0c             	sub    $0xc,%esp
80101cb0:	ff 75 08             	pushl  0x8(%ebp)
80101cb3:	e8 34 3d 00 00       	call   801059ec <wakeup>
80101cb8:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101cbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cbe:	8b 40 08             	mov    0x8(%eax),%eax
80101cc1:	8d 50 ff             	lea    -0x1(%eax),%edx
80101cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc7:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101cca:	83 ec 0c             	sub    $0xc,%esp
80101ccd:	68 40 42 11 80       	push   $0x80114240
80101cd2:	e8 b8 41 00 00       	call   80105e8f <release>
80101cd7:	83 c4 10             	add    $0x10,%esp
}
80101cda:	90                   	nop
80101cdb:	c9                   	leave  
80101cdc:	c3                   	ret    

80101cdd <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101cdd:	f3 0f 1e fb          	endbr32 
80101ce1:	55                   	push   %ebp
80101ce2:	89 e5                	mov    %esp,%ebp
80101ce4:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101ce7:	83 ec 0c             	sub    $0xc,%esp
80101cea:	ff 75 08             	pushl  0x8(%ebp)
80101ced:	e8 81 fe ff ff       	call   80101b73 <iunlock>
80101cf2:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101cf5:	83 ec 0c             	sub    $0xc,%esp
80101cf8:	ff 75 08             	pushl  0x8(%ebp)
80101cfb:	e8 e9 fe ff ff       	call   80101be9 <iput>
80101d00:	83 c4 10             	add    $0x10,%esp
}
80101d03:	90                   	nop
80101d04:	c9                   	leave  
80101d05:	c3                   	ret    

80101d06 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d06:	f3 0f 1e fb          	endbr32 
80101d0a:	55                   	push   %ebp
80101d0b:	89 e5                	mov    %esp,%ebp
80101d0d:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d10:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d14:	77 42                	ja     80101d58 <bmap+0x52>
    if((addr = ip->addrs[bn]) == 0)
80101d16:	8b 45 08             	mov    0x8(%ebp),%eax
80101d19:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d1c:	83 c2 04             	add    $0x4,%edx
80101d1f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d2a:	75 24                	jne    80101d50 <bmap+0x4a>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	8b 00                	mov    (%eax),%eax
80101d31:	83 ec 0c             	sub    $0xc,%esp
80101d34:	50                   	push   %eax
80101d35:	e8 6b f7 ff ff       	call   801014a5 <balloc>
80101d3a:	83 c4 10             	add    $0x10,%esp
80101d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d40:	8b 45 08             	mov    0x8(%ebp),%eax
80101d43:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d46:	8d 4a 04             	lea    0x4(%edx),%ecx
80101d49:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d53:	e9 ca 00 00 00       	jmp    80101e22 <bmap+0x11c>
  }
  bn -= NDIRECT;
80101d58:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d5c:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d60:	0f 87 af 00 00 00    	ja     80101e15 <bmap+0x10f>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d66:	8b 45 08             	mov    0x8(%ebp),%eax
80101d69:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d73:	75 1d                	jne    80101d92 <bmap+0x8c>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d75:	8b 45 08             	mov    0x8(%ebp),%eax
80101d78:	8b 00                	mov    (%eax),%eax
80101d7a:	83 ec 0c             	sub    $0xc,%esp
80101d7d:	50                   	push   %eax
80101d7e:	e8 22 f7 ff ff       	call   801014a5 <balloc>
80101d83:	83 c4 10             	add    $0x10,%esp
80101d86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d89:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8f:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101d92:	8b 45 08             	mov    0x8(%ebp),%eax
80101d95:	8b 00                	mov    (%eax),%eax
80101d97:	83 ec 08             	sub    $0x8,%esp
80101d9a:	ff 75 f4             	pushl  -0xc(%ebp)
80101d9d:	50                   	push   %eax
80101d9e:	e8 1c e4 ff ff       	call   801001bf <bread>
80101da3:	83 c4 10             	add    $0x10,%esp
80101da6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101da9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101dac:	83 c0 18             	add    $0x18,%eax
80101daf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101db2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101db5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dbf:	01 d0                	add    %edx,%eax
80101dc1:	8b 00                	mov    (%eax),%eax
80101dc3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dc6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dca:	75 36                	jne    80101e02 <bmap+0xfc>
      a[bn] = addr = balloc(ip->dev);
80101dcc:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcf:	8b 00                	mov    (%eax),%eax
80101dd1:	83 ec 0c             	sub    $0xc,%esp
80101dd4:	50                   	push   %eax
80101dd5:	e8 cb f6 ff ff       	call   801014a5 <balloc>
80101dda:	83 c4 10             	add    $0x10,%esp
80101ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101de3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dea:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ded:	01 c2                	add    %eax,%edx
80101def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101df2:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101df4:	83 ec 0c             	sub    $0xc,%esp
80101df7:	ff 75 f0             	pushl  -0x10(%ebp)
80101dfa:	e8 80 22 00 00       	call   8010407f <log_write>
80101dff:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101e02:	83 ec 0c             	sub    $0xc,%esp
80101e05:	ff 75 f0             	pushl  -0x10(%ebp)
80101e08:	e8 32 e4 ff ff       	call   8010023f <brelse>
80101e0d:	83 c4 10             	add    $0x10,%esp
    return addr;
80101e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e13:	eb 0d                	jmp    80101e22 <bmap+0x11c>
  }

  panic("bmap: out of range");
80101e15:	83 ec 0c             	sub    $0xc,%esp
80101e18:	68 50 a1 10 80       	push   $0x8010a150
80101e1d:	e8 75 e7 ff ff       	call   80100597 <panic>
}
80101e22:	c9                   	leave  
80101e23:	c3                   	ret    

80101e24 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e24:	f3 0f 1e fb          	endbr32 
80101e28:	55                   	push   %ebp
80101e29:	89 e5                	mov    %esp,%ebp
80101e2b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e2e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e35:	eb 45                	jmp    80101e7c <itrunc+0x58>
    if(ip->addrs[i]){
80101e37:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e3d:	83 c2 04             	add    $0x4,%edx
80101e40:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e44:	85 c0                	test   %eax,%eax
80101e46:	74 30                	je     80101e78 <itrunc+0x54>
      bfree(ip->dev, ip->addrs[i]);
80101e48:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e4e:	83 c2 04             	add    $0x4,%edx
80101e51:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e55:	8b 55 08             	mov    0x8(%ebp),%edx
80101e58:	8b 12                	mov    (%edx),%edx
80101e5a:	83 ec 08             	sub    $0x8,%esp
80101e5d:	50                   	push   %eax
80101e5e:	52                   	push   %edx
80101e5f:	e8 91 f7 ff ff       	call   801015f5 <bfree>
80101e64:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101e67:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6d:	83 c2 04             	add    $0x4,%edx
80101e70:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e77:	00 
  for(i = 0; i < NDIRECT; i++){
80101e78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101e7c:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e80:	7e b5                	jle    80101e37 <itrunc+0x13>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101e82:	8b 45 08             	mov    0x8(%ebp),%eax
80101e85:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e88:	85 c0                	test   %eax,%eax
80101e8a:	0f 84 a1 00 00 00    	je     80101f31 <itrunc+0x10d>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e90:	8b 45 08             	mov    0x8(%ebp),%eax
80101e93:	8b 50 4c             	mov    0x4c(%eax),%edx
80101e96:	8b 45 08             	mov    0x8(%ebp),%eax
80101e99:	8b 00                	mov    (%eax),%eax
80101e9b:	83 ec 08             	sub    $0x8,%esp
80101e9e:	52                   	push   %edx
80101e9f:	50                   	push   %eax
80101ea0:	e8 1a e3 ff ff       	call   801001bf <bread>
80101ea5:	83 c4 10             	add    $0x10,%esp
80101ea8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101eab:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eae:	83 c0 18             	add    $0x18,%eax
80101eb1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101eb4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101ebb:	eb 3c                	jmp    80101ef9 <itrunc+0xd5>
      if(a[j])
80101ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ec0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ec7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101eca:	01 d0                	add    %edx,%eax
80101ecc:	8b 00                	mov    (%eax),%eax
80101ece:	85 c0                	test   %eax,%eax
80101ed0:	74 23                	je     80101ef5 <itrunc+0xd1>
        bfree(ip->dev, a[j]);
80101ed2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ed5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101edc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101edf:	01 d0                	add    %edx,%eax
80101ee1:	8b 00                	mov    (%eax),%eax
80101ee3:	8b 55 08             	mov    0x8(%ebp),%edx
80101ee6:	8b 12                	mov    (%edx),%edx
80101ee8:	83 ec 08             	sub    $0x8,%esp
80101eeb:	50                   	push   %eax
80101eec:	52                   	push   %edx
80101eed:	e8 03 f7 ff ff       	call   801015f5 <bfree>
80101ef2:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101ef5:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101efc:	83 f8 7f             	cmp    $0x7f,%eax
80101eff:	76 bc                	jbe    80101ebd <itrunc+0x99>
    }
    brelse(bp);
80101f01:	83 ec 0c             	sub    $0xc,%esp
80101f04:	ff 75 ec             	pushl  -0x14(%ebp)
80101f07:	e8 33 e3 ff ff       	call   8010023f <brelse>
80101f0c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f12:	8b 40 4c             	mov    0x4c(%eax),%eax
80101f15:	8b 55 08             	mov    0x8(%ebp),%edx
80101f18:	8b 12                	mov    (%edx),%edx
80101f1a:	83 ec 08             	sub    $0x8,%esp
80101f1d:	50                   	push   %eax
80101f1e:	52                   	push   %edx
80101f1f:	e8 d1 f6 ff ff       	call   801015f5 <bfree>
80101f24:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101f31:	8b 45 08             	mov    0x8(%ebp),%eax
80101f34:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101f3b:	83 ec 0c             	sub    $0xc,%esp
80101f3e:	ff 75 08             	pushl  0x8(%ebp)
80101f41:	e8 e5 f8 ff ff       	call   8010182b <iupdate>
80101f46:	83 c4 10             	add    $0x10,%esp
}
80101f49:	90                   	nop
80101f4a:	c9                   	leave  
80101f4b:	c3                   	ret    

80101f4c <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101f4c:	f3 0f 1e fb          	endbr32 
80101f50:	55                   	push   %ebp
80101f51:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f53:	8b 45 08             	mov    0x8(%ebp),%eax
80101f56:	8b 00                	mov    (%eax),%eax
80101f58:	89 c2                	mov    %eax,%edx
80101f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f5d:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	8b 50 04             	mov    0x4(%eax),%edx
80101f66:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f69:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f6f:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101f73:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f76:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101f79:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7c:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f83:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101f87:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8a:	8b 50 18             	mov    0x18(%eax),%edx
80101f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f90:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f93:	90                   	nop
80101f94:	5d                   	pop    %ebp
80101f95:	c3                   	ret    

80101f96 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f96:	f3 0f 1e fb          	endbr32 
80101f9a:	55                   	push   %ebp
80101f9b:	89 e5                	mov    %esp,%ebp
80101f9d:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fa0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fa7:	66 83 f8 03          	cmp    $0x3,%ax
80101fab:	75 5c                	jne    80102009 <readi+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fad:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fb4:	66 85 c0             	test   %ax,%ax
80101fb7:	78 20                	js     80101fd9 <readi+0x43>
80101fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fbc:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fc0:	66 83 f8 09          	cmp    $0x9,%ax
80101fc4:	7f 13                	jg     80101fd9 <readi+0x43>
80101fc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fcd:	98                   	cwtl   
80101fce:	8b 04 c5 c0 41 11 80 	mov    -0x7feebe40(,%eax,8),%eax
80101fd5:	85 c0                	test   %eax,%eax
80101fd7:	75 0a                	jne    80101fe3 <readi+0x4d>
      return -1;
80101fd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fde:	e9 0a 01 00 00       	jmp    801020ed <readi+0x157>
    return devsw[ip->major].read(ip, dst, n);
80101fe3:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe6:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fea:	98                   	cwtl   
80101feb:	8b 04 c5 c0 41 11 80 	mov    -0x7feebe40(,%eax,8),%eax
80101ff2:	8b 55 14             	mov    0x14(%ebp),%edx
80101ff5:	83 ec 04             	sub    $0x4,%esp
80101ff8:	52                   	push   %edx
80101ff9:	ff 75 0c             	pushl  0xc(%ebp)
80101ffc:	ff 75 08             	pushl  0x8(%ebp)
80101fff:	ff d0                	call   *%eax
80102001:	83 c4 10             	add    $0x10,%esp
80102004:	e9 e4 00 00 00       	jmp    801020ed <readi+0x157>
  }

  if(off > ip->size || off + n < off)
80102009:	8b 45 08             	mov    0x8(%ebp),%eax
8010200c:	8b 40 18             	mov    0x18(%eax),%eax
8010200f:	39 45 10             	cmp    %eax,0x10(%ebp)
80102012:	77 0d                	ja     80102021 <readi+0x8b>
80102014:	8b 55 10             	mov    0x10(%ebp),%edx
80102017:	8b 45 14             	mov    0x14(%ebp),%eax
8010201a:	01 d0                	add    %edx,%eax
8010201c:	39 45 10             	cmp    %eax,0x10(%ebp)
8010201f:	76 0a                	jbe    8010202b <readi+0x95>
    return -1;
80102021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102026:	e9 c2 00 00 00       	jmp    801020ed <readi+0x157>
  if(off + n > ip->size)
8010202b:	8b 55 10             	mov    0x10(%ebp),%edx
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
80102031:	01 c2                	add    %eax,%edx
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	8b 40 18             	mov    0x18(%eax),%eax
80102039:	39 c2                	cmp    %eax,%edx
8010203b:	76 0c                	jbe    80102049 <readi+0xb3>
    n = ip->size - off;
8010203d:	8b 45 08             	mov    0x8(%ebp),%eax
80102040:	8b 40 18             	mov    0x18(%eax),%eax
80102043:	2b 45 10             	sub    0x10(%ebp),%eax
80102046:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102049:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102050:	e9 89 00 00 00       	jmp    801020de <readi+0x148>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102055:	8b 45 10             	mov    0x10(%ebp),%eax
80102058:	c1 e8 09             	shr    $0x9,%eax
8010205b:	83 ec 08             	sub    $0x8,%esp
8010205e:	50                   	push   %eax
8010205f:	ff 75 08             	pushl  0x8(%ebp)
80102062:	e8 9f fc ff ff       	call   80101d06 <bmap>
80102067:	83 c4 10             	add    $0x10,%esp
8010206a:	8b 55 08             	mov    0x8(%ebp),%edx
8010206d:	8b 12                	mov    (%edx),%edx
8010206f:	83 ec 08             	sub    $0x8,%esp
80102072:	50                   	push   %eax
80102073:	52                   	push   %edx
80102074:	e8 46 e1 ff ff       	call   801001bf <bread>
80102079:	83 c4 10             	add    $0x10,%esp
8010207c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010207f:	8b 45 10             	mov    0x10(%ebp),%eax
80102082:	25 ff 01 00 00       	and    $0x1ff,%eax
80102087:	ba 00 02 00 00       	mov    $0x200,%edx
8010208c:	29 c2                	sub    %eax,%edx
8010208e:	8b 45 14             	mov    0x14(%ebp),%eax
80102091:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102094:	39 c2                	cmp    %eax,%edx
80102096:	0f 46 c2             	cmovbe %edx,%eax
80102099:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
8010209c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010209f:	8d 50 18             	lea    0x18(%eax),%edx
801020a2:	8b 45 10             	mov    0x10(%ebp),%eax
801020a5:	25 ff 01 00 00       	and    $0x1ff,%eax
801020aa:	01 d0                	add    %edx,%eax
801020ac:	83 ec 04             	sub    $0x4,%esp
801020af:	ff 75 ec             	pushl  -0x14(%ebp)
801020b2:	50                   	push   %eax
801020b3:	ff 75 0c             	pushl  0xc(%ebp)
801020b6:	e8 ac 40 00 00       	call   80106167 <memmove>
801020bb:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020be:	83 ec 0c             	sub    $0xc,%esp
801020c1:	ff 75 f0             	pushl  -0x10(%ebp)
801020c4:	e8 76 e1 ff ff       	call   8010023f <brelse>
801020c9:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020cc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020cf:	01 45 f4             	add    %eax,-0xc(%ebp)
801020d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020d5:	01 45 10             	add    %eax,0x10(%ebp)
801020d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020db:	01 45 0c             	add    %eax,0xc(%ebp)
801020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020e1:	3b 45 14             	cmp    0x14(%ebp),%eax
801020e4:	0f 82 6b ff ff ff    	jb     80102055 <readi+0xbf>
  }
  return n;
801020ea:	8b 45 14             	mov    0x14(%ebp),%eax
}
801020ed:	c9                   	leave  
801020ee:	c3                   	ret    

801020ef <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801020ef:	f3 0f 1e fb          	endbr32 
801020f3:	55                   	push   %ebp
801020f4:	89 e5                	mov    %esp,%ebp
801020f6:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801020f9:	8b 45 08             	mov    0x8(%ebp),%eax
801020fc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102100:	66 83 f8 03          	cmp    $0x3,%ax
80102104:	75 5c                	jne    80102162 <writei+0x73>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102106:	8b 45 08             	mov    0x8(%ebp),%eax
80102109:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010210d:	66 85 c0             	test   %ax,%ax
80102110:	78 20                	js     80102132 <writei+0x43>
80102112:	8b 45 08             	mov    0x8(%ebp),%eax
80102115:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102119:	66 83 f8 09          	cmp    $0x9,%ax
8010211d:	7f 13                	jg     80102132 <writei+0x43>
8010211f:	8b 45 08             	mov    0x8(%ebp),%eax
80102122:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102126:	98                   	cwtl   
80102127:	8b 04 c5 c4 41 11 80 	mov    -0x7feebe3c(,%eax,8),%eax
8010212e:	85 c0                	test   %eax,%eax
80102130:	75 0a                	jne    8010213c <writei+0x4d>
      return -1;
80102132:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102137:	e9 3b 01 00 00       	jmp    80102277 <writei+0x188>
    return devsw[ip->major].write(ip, src, n);
8010213c:	8b 45 08             	mov    0x8(%ebp),%eax
8010213f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102143:	98                   	cwtl   
80102144:	8b 04 c5 c4 41 11 80 	mov    -0x7feebe3c(,%eax,8),%eax
8010214b:	8b 55 14             	mov    0x14(%ebp),%edx
8010214e:	83 ec 04             	sub    $0x4,%esp
80102151:	52                   	push   %edx
80102152:	ff 75 0c             	pushl  0xc(%ebp)
80102155:	ff 75 08             	pushl  0x8(%ebp)
80102158:	ff d0                	call   *%eax
8010215a:	83 c4 10             	add    $0x10,%esp
8010215d:	e9 15 01 00 00       	jmp    80102277 <writei+0x188>
  }

  if(off > ip->size || off + n < off)
80102162:	8b 45 08             	mov    0x8(%ebp),%eax
80102165:	8b 40 18             	mov    0x18(%eax),%eax
80102168:	39 45 10             	cmp    %eax,0x10(%ebp)
8010216b:	77 0d                	ja     8010217a <writei+0x8b>
8010216d:	8b 55 10             	mov    0x10(%ebp),%edx
80102170:	8b 45 14             	mov    0x14(%ebp),%eax
80102173:	01 d0                	add    %edx,%eax
80102175:	39 45 10             	cmp    %eax,0x10(%ebp)
80102178:	76 0a                	jbe    80102184 <writei+0x95>
    return -1;
8010217a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010217f:	e9 f3 00 00 00       	jmp    80102277 <writei+0x188>
  if(off + n > MAXFILE*BSIZE)
80102184:	8b 55 10             	mov    0x10(%ebp),%edx
80102187:	8b 45 14             	mov    0x14(%ebp),%eax
8010218a:	01 d0                	add    %edx,%eax
8010218c:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102191:	76 0a                	jbe    8010219d <writei+0xae>
    return -1;
80102193:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102198:	e9 da 00 00 00       	jmp    80102277 <writei+0x188>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010219d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021a4:	e9 97 00 00 00       	jmp    80102240 <writei+0x151>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021a9:	8b 45 10             	mov    0x10(%ebp),%eax
801021ac:	c1 e8 09             	shr    $0x9,%eax
801021af:	83 ec 08             	sub    $0x8,%esp
801021b2:	50                   	push   %eax
801021b3:	ff 75 08             	pushl  0x8(%ebp)
801021b6:	e8 4b fb ff ff       	call   80101d06 <bmap>
801021bb:	83 c4 10             	add    $0x10,%esp
801021be:	8b 55 08             	mov    0x8(%ebp),%edx
801021c1:	8b 12                	mov    (%edx),%edx
801021c3:	83 ec 08             	sub    $0x8,%esp
801021c6:	50                   	push   %eax
801021c7:	52                   	push   %edx
801021c8:	e8 f2 df ff ff       	call   801001bf <bread>
801021cd:	83 c4 10             	add    $0x10,%esp
801021d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801021d3:	8b 45 10             	mov    0x10(%ebp),%eax
801021d6:	25 ff 01 00 00       	and    $0x1ff,%eax
801021db:	ba 00 02 00 00       	mov    $0x200,%edx
801021e0:	29 c2                	sub    %eax,%edx
801021e2:	8b 45 14             	mov    0x14(%ebp),%eax
801021e5:	2b 45 f4             	sub    -0xc(%ebp),%eax
801021e8:	39 c2                	cmp    %eax,%edx
801021ea:	0f 46 c2             	cmovbe %edx,%eax
801021ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021f3:	8d 50 18             	lea    0x18(%eax),%edx
801021f6:	8b 45 10             	mov    0x10(%ebp),%eax
801021f9:	25 ff 01 00 00       	and    $0x1ff,%eax
801021fe:	01 d0                	add    %edx,%eax
80102200:	83 ec 04             	sub    $0x4,%esp
80102203:	ff 75 ec             	pushl  -0x14(%ebp)
80102206:	ff 75 0c             	pushl  0xc(%ebp)
80102209:	50                   	push   %eax
8010220a:	e8 58 3f 00 00       	call   80106167 <memmove>
8010220f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102212:	83 ec 0c             	sub    $0xc,%esp
80102215:	ff 75 f0             	pushl  -0x10(%ebp)
80102218:	e8 62 1e 00 00       	call   8010407f <log_write>
8010221d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102220:	83 ec 0c             	sub    $0xc,%esp
80102223:	ff 75 f0             	pushl  -0x10(%ebp)
80102226:	e8 14 e0 ff ff       	call   8010023f <brelse>
8010222b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010222e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102231:	01 45 f4             	add    %eax,-0xc(%ebp)
80102234:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102237:	01 45 10             	add    %eax,0x10(%ebp)
8010223a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010223d:	01 45 0c             	add    %eax,0xc(%ebp)
80102240:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102243:	3b 45 14             	cmp    0x14(%ebp),%eax
80102246:	0f 82 5d ff ff ff    	jb     801021a9 <writei+0xba>
  }

  if(n > 0 && off > ip->size){
8010224c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102250:	74 22                	je     80102274 <writei+0x185>
80102252:	8b 45 08             	mov    0x8(%ebp),%eax
80102255:	8b 40 18             	mov    0x18(%eax),%eax
80102258:	39 45 10             	cmp    %eax,0x10(%ebp)
8010225b:	76 17                	jbe    80102274 <writei+0x185>
    ip->size = off;
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 55 10             	mov    0x10(%ebp),%edx
80102263:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102266:	83 ec 0c             	sub    $0xc,%esp
80102269:	ff 75 08             	pushl  0x8(%ebp)
8010226c:	e8 ba f5 ff ff       	call   8010182b <iupdate>
80102271:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102274:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102277:	c9                   	leave  
80102278:	c3                   	ret    

80102279 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102279:	f3 0f 1e fb          	endbr32 
8010227d:	55                   	push   %ebp
8010227e:	89 e5                	mov    %esp,%ebp
80102280:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102283:	83 ec 04             	sub    $0x4,%esp
80102286:	6a 0e                	push   $0xe
80102288:	ff 75 0c             	pushl  0xc(%ebp)
8010228b:	ff 75 08             	pushl  0x8(%ebp)
8010228e:	e8 72 3f 00 00       	call   80106205 <strncmp>
80102293:	83 c4 10             	add    $0x10,%esp
}
80102296:	c9                   	leave  
80102297:	c3                   	ret    

80102298 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102298:	f3 0f 1e fb          	endbr32 
8010229c:	55                   	push   %ebp
8010229d:	89 e5                	mov    %esp,%ebp
8010229f:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801022a2:	8b 45 08             	mov    0x8(%ebp),%eax
801022a5:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801022a9:	66 83 f8 01          	cmp    $0x1,%ax
801022ad:	74 0d                	je     801022bc <dirlookup+0x24>
    panic("dirlookup not DIR");
801022af:	83 ec 0c             	sub    $0xc,%esp
801022b2:	68 63 a1 10 80       	push   $0x8010a163
801022b7:	e8 db e2 ff ff       	call   80100597 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801022bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022c3:	eb 7b                	jmp    80102340 <dirlookup+0xa8>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022c5:	6a 10                	push   $0x10
801022c7:	ff 75 f4             	pushl  -0xc(%ebp)
801022ca:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022cd:	50                   	push   %eax
801022ce:	ff 75 08             	pushl  0x8(%ebp)
801022d1:	e8 c0 fc ff ff       	call   80101f96 <readi>
801022d6:	83 c4 10             	add    $0x10,%esp
801022d9:	83 f8 10             	cmp    $0x10,%eax
801022dc:	74 0d                	je     801022eb <dirlookup+0x53>
      panic("dirlink read");
801022de:	83 ec 0c             	sub    $0xc,%esp
801022e1:	68 75 a1 10 80       	push   $0x8010a175
801022e6:	e8 ac e2 ff ff       	call   80100597 <panic>
    if(de.inum == 0)
801022eb:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022ef:	66 85 c0             	test   %ax,%ax
801022f2:	74 47                	je     8010233b <dirlookup+0xa3>
      continue;
    if(namecmp(name, de.name) == 0){
801022f4:	83 ec 08             	sub    $0x8,%esp
801022f7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022fa:	83 c0 02             	add    $0x2,%eax
801022fd:	50                   	push   %eax
801022fe:	ff 75 0c             	pushl  0xc(%ebp)
80102301:	e8 73 ff ff ff       	call   80102279 <namecmp>
80102306:	83 c4 10             	add    $0x10,%esp
80102309:	85 c0                	test   %eax,%eax
8010230b:	75 2f                	jne    8010233c <dirlookup+0xa4>
      // entry matches path element
      if(poff)
8010230d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102311:	74 08                	je     8010231b <dirlookup+0x83>
        *poff = off;
80102313:	8b 45 10             	mov    0x10(%ebp),%eax
80102316:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102319:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010231b:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010231f:	0f b7 c0             	movzwl %ax,%eax
80102322:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102325:	8b 45 08             	mov    0x8(%ebp),%eax
80102328:	8b 00                	mov    (%eax),%eax
8010232a:	83 ec 08             	sub    $0x8,%esp
8010232d:	ff 75 f0             	pushl  -0x10(%ebp)
80102330:	50                   	push   %eax
80102331:	e8 ba f5 ff ff       	call   801018f0 <iget>
80102336:	83 c4 10             	add    $0x10,%esp
80102339:	eb 19                	jmp    80102354 <dirlookup+0xbc>
      continue;
8010233b:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
8010233c:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102340:	8b 45 08             	mov    0x8(%ebp),%eax
80102343:	8b 40 18             	mov    0x18(%eax),%eax
80102346:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102349:	0f 82 76 ff ff ff    	jb     801022c5 <dirlookup+0x2d>
    }
  }

  return 0;
8010234f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102354:	c9                   	leave  
80102355:	c3                   	ret    

80102356 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102356:	f3 0f 1e fb          	endbr32 
8010235a:	55                   	push   %ebp
8010235b:	89 e5                	mov    %esp,%ebp
8010235d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102360:	83 ec 04             	sub    $0x4,%esp
80102363:	6a 00                	push   $0x0
80102365:	ff 75 0c             	pushl  0xc(%ebp)
80102368:	ff 75 08             	pushl  0x8(%ebp)
8010236b:	e8 28 ff ff ff       	call   80102298 <dirlookup>
80102370:	83 c4 10             	add    $0x10,%esp
80102373:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102376:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010237a:	74 18                	je     80102394 <dirlink+0x3e>
    iput(ip);
8010237c:	83 ec 0c             	sub    $0xc,%esp
8010237f:	ff 75 f0             	pushl  -0x10(%ebp)
80102382:	e8 62 f8 ff ff       	call   80101be9 <iput>
80102387:	83 c4 10             	add    $0x10,%esp
    return -1;
8010238a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010238f:	e9 9c 00 00 00       	jmp    80102430 <dirlink+0xda>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102394:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010239b:	eb 39                	jmp    801023d6 <dirlink+0x80>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010239d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023a0:	6a 10                	push   $0x10
801023a2:	50                   	push   %eax
801023a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023a6:	50                   	push   %eax
801023a7:	ff 75 08             	pushl  0x8(%ebp)
801023aa:	e8 e7 fb ff ff       	call   80101f96 <readi>
801023af:	83 c4 10             	add    $0x10,%esp
801023b2:	83 f8 10             	cmp    $0x10,%eax
801023b5:	74 0d                	je     801023c4 <dirlink+0x6e>
      panic("dirlink read");
801023b7:	83 ec 0c             	sub    $0xc,%esp
801023ba:	68 75 a1 10 80       	push   $0x8010a175
801023bf:	e8 d3 e1 ff ff       	call   80100597 <panic>
    if(de.inum == 0)
801023c4:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801023c8:	66 85 c0             	test   %ax,%ax
801023cb:	74 18                	je     801023e5 <dirlink+0x8f>
  for(off = 0; off < dp->size; off += sizeof(de)){
801023cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d0:	83 c0 10             	add    $0x10,%eax
801023d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023d6:	8b 45 08             	mov    0x8(%ebp),%eax
801023d9:	8b 50 18             	mov    0x18(%eax),%edx
801023dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023df:	39 c2                	cmp    %eax,%edx
801023e1:	77 ba                	ja     8010239d <dirlink+0x47>
801023e3:	eb 01                	jmp    801023e6 <dirlink+0x90>
      break;
801023e5:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801023e6:	83 ec 04             	sub    $0x4,%esp
801023e9:	6a 0e                	push   $0xe
801023eb:	ff 75 0c             	pushl  0xc(%ebp)
801023ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023f1:	83 c0 02             	add    $0x2,%eax
801023f4:	50                   	push   %eax
801023f5:	e8 65 3e 00 00       	call   8010625f <strncpy>
801023fa:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801023fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102400:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102404:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102407:	6a 10                	push   $0x10
80102409:	50                   	push   %eax
8010240a:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010240d:	50                   	push   %eax
8010240e:	ff 75 08             	pushl  0x8(%ebp)
80102411:	e8 d9 fc ff ff       	call   801020ef <writei>
80102416:	83 c4 10             	add    $0x10,%esp
80102419:	83 f8 10             	cmp    $0x10,%eax
8010241c:	74 0d                	je     8010242b <dirlink+0xd5>
    panic("dirlink");
8010241e:	83 ec 0c             	sub    $0xc,%esp
80102421:	68 82 a1 10 80       	push   $0x8010a182
80102426:	e8 6c e1 ff ff       	call   80100597 <panic>
  
  return 0;
8010242b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102430:	c9                   	leave  
80102431:	c3                   	ret    

80102432 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102432:	f3 0f 1e fb          	endbr32 
80102436:	55                   	push   %ebp
80102437:	89 e5                	mov    %esp,%ebp
80102439:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010243c:	eb 04                	jmp    80102442 <skipelem+0x10>
    path++;
8010243e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102442:	8b 45 08             	mov    0x8(%ebp),%eax
80102445:	0f b6 00             	movzbl (%eax),%eax
80102448:	3c 2f                	cmp    $0x2f,%al
8010244a:	74 f2                	je     8010243e <skipelem+0xc>
  if(*path == 0)
8010244c:	8b 45 08             	mov    0x8(%ebp),%eax
8010244f:	0f b6 00             	movzbl (%eax),%eax
80102452:	84 c0                	test   %al,%al
80102454:	75 07                	jne    8010245d <skipelem+0x2b>
    return 0;
80102456:	b8 00 00 00 00       	mov    $0x0,%eax
8010245b:	eb 77                	jmp    801024d4 <skipelem+0xa2>
  s = path;
8010245d:	8b 45 08             	mov    0x8(%ebp),%eax
80102460:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102463:	eb 04                	jmp    80102469 <skipelem+0x37>
    path++;
80102465:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102469:	8b 45 08             	mov    0x8(%ebp),%eax
8010246c:	0f b6 00             	movzbl (%eax),%eax
8010246f:	3c 2f                	cmp    $0x2f,%al
80102471:	74 0a                	je     8010247d <skipelem+0x4b>
80102473:	8b 45 08             	mov    0x8(%ebp),%eax
80102476:	0f b6 00             	movzbl (%eax),%eax
80102479:	84 c0                	test   %al,%al
8010247b:	75 e8                	jne    80102465 <skipelem+0x33>
  len = path - s;
8010247d:	8b 45 08             	mov    0x8(%ebp),%eax
80102480:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102483:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102486:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010248a:	7e 15                	jle    801024a1 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
8010248c:	83 ec 04             	sub    $0x4,%esp
8010248f:	6a 0e                	push   $0xe
80102491:	ff 75 f4             	pushl  -0xc(%ebp)
80102494:	ff 75 0c             	pushl  0xc(%ebp)
80102497:	e8 cb 3c 00 00       	call   80106167 <memmove>
8010249c:	83 c4 10             	add    $0x10,%esp
8010249f:	eb 26                	jmp    801024c7 <skipelem+0x95>
  else {
    memmove(name, s, len);
801024a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024a4:	83 ec 04             	sub    $0x4,%esp
801024a7:	50                   	push   %eax
801024a8:	ff 75 f4             	pushl  -0xc(%ebp)
801024ab:	ff 75 0c             	pushl  0xc(%ebp)
801024ae:	e8 b4 3c 00 00       	call   80106167 <memmove>
801024b3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801024b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801024b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801024bc:	01 d0                	add    %edx,%eax
801024be:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801024c1:	eb 04                	jmp    801024c7 <skipelem+0x95>
    path++;
801024c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801024c7:	8b 45 08             	mov    0x8(%ebp),%eax
801024ca:	0f b6 00             	movzbl (%eax),%eax
801024cd:	3c 2f                	cmp    $0x2f,%al
801024cf:	74 f2                	je     801024c3 <skipelem+0x91>
  return path;
801024d1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024d4:	c9                   	leave  
801024d5:	c3                   	ret    

801024d6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024d6:	f3 0f 1e fb          	endbr32 
801024da:	55                   	push   %ebp
801024db:	89 e5                	mov    %esp,%ebp
801024dd:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801024e0:	8b 45 08             	mov    0x8(%ebp),%eax
801024e3:	0f b6 00             	movzbl (%eax),%eax
801024e6:	3c 2f                	cmp    $0x2f,%al
801024e8:	75 17                	jne    80102501 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
801024ea:	83 ec 08             	sub    $0x8,%esp
801024ed:	6a 01                	push   $0x1
801024ef:	6a 01                	push   $0x1
801024f1:	e8 fa f3 ff ff       	call   801018f0 <iget>
801024f6:	83 c4 10             	add    $0x10,%esp
801024f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024fc:	e9 bb 00 00 00       	jmp    801025bc <namex+0xe6>
  else
    ip = idup(proc->cwd);
80102501:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102507:	8b 40 68             	mov    0x68(%eax),%eax
8010250a:	83 ec 0c             	sub    $0xc,%esp
8010250d:	50                   	push   %eax
8010250e:	e8 c0 f4 ff ff       	call   801019d3 <idup>
80102513:	83 c4 10             	add    $0x10,%esp
80102516:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102519:	e9 9e 00 00 00       	jmp    801025bc <namex+0xe6>
    ilock(ip);
8010251e:	83 ec 0c             	sub    $0xc,%esp
80102521:	ff 75 f4             	pushl  -0xc(%ebp)
80102524:	e8 e8 f4 ff ff       	call   80101a11 <ilock>
80102529:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010252c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102533:	66 83 f8 01          	cmp    $0x1,%ax
80102537:	74 18                	je     80102551 <namex+0x7b>
      iunlockput(ip);
80102539:	83 ec 0c             	sub    $0xc,%esp
8010253c:	ff 75 f4             	pushl  -0xc(%ebp)
8010253f:	e8 99 f7 ff ff       	call   80101cdd <iunlockput>
80102544:	83 c4 10             	add    $0x10,%esp
      return 0;
80102547:	b8 00 00 00 00       	mov    $0x0,%eax
8010254c:	e9 a7 00 00 00       	jmp    801025f8 <namex+0x122>
    }
    if(nameiparent && *path == '\0'){
80102551:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102555:	74 20                	je     80102577 <namex+0xa1>
80102557:	8b 45 08             	mov    0x8(%ebp),%eax
8010255a:	0f b6 00             	movzbl (%eax),%eax
8010255d:	84 c0                	test   %al,%al
8010255f:	75 16                	jne    80102577 <namex+0xa1>
      // Stop one level early.
      iunlock(ip);
80102561:	83 ec 0c             	sub    $0xc,%esp
80102564:	ff 75 f4             	pushl  -0xc(%ebp)
80102567:	e8 07 f6 ff ff       	call   80101b73 <iunlock>
8010256c:	83 c4 10             	add    $0x10,%esp
      return ip;
8010256f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102572:	e9 81 00 00 00       	jmp    801025f8 <namex+0x122>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102577:	83 ec 04             	sub    $0x4,%esp
8010257a:	6a 00                	push   $0x0
8010257c:	ff 75 10             	pushl  0x10(%ebp)
8010257f:	ff 75 f4             	pushl  -0xc(%ebp)
80102582:	e8 11 fd ff ff       	call   80102298 <dirlookup>
80102587:	83 c4 10             	add    $0x10,%esp
8010258a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010258d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102591:	75 15                	jne    801025a8 <namex+0xd2>
      iunlockput(ip);
80102593:	83 ec 0c             	sub    $0xc,%esp
80102596:	ff 75 f4             	pushl  -0xc(%ebp)
80102599:	e8 3f f7 ff ff       	call   80101cdd <iunlockput>
8010259e:	83 c4 10             	add    $0x10,%esp
      return 0;
801025a1:	b8 00 00 00 00       	mov    $0x0,%eax
801025a6:	eb 50                	jmp    801025f8 <namex+0x122>
    }
    iunlockput(ip);
801025a8:	83 ec 0c             	sub    $0xc,%esp
801025ab:	ff 75 f4             	pushl  -0xc(%ebp)
801025ae:	e8 2a f7 ff ff       	call   80101cdd <iunlockput>
801025b3:	83 c4 10             	add    $0x10,%esp
    ip = next;
801025b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801025b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801025bc:	83 ec 08             	sub    $0x8,%esp
801025bf:	ff 75 10             	pushl  0x10(%ebp)
801025c2:	ff 75 08             	pushl  0x8(%ebp)
801025c5:	e8 68 fe ff ff       	call   80102432 <skipelem>
801025ca:	83 c4 10             	add    $0x10,%esp
801025cd:	89 45 08             	mov    %eax,0x8(%ebp)
801025d0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025d4:	0f 85 44 ff ff ff    	jne    8010251e <namex+0x48>
  }
  if(nameiparent){
801025da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025de:	74 15                	je     801025f5 <namex+0x11f>
    iput(ip);
801025e0:	83 ec 0c             	sub    $0xc,%esp
801025e3:	ff 75 f4             	pushl  -0xc(%ebp)
801025e6:	e8 fe f5 ff ff       	call   80101be9 <iput>
801025eb:	83 c4 10             	add    $0x10,%esp
    return 0;
801025ee:	b8 00 00 00 00       	mov    $0x0,%eax
801025f3:	eb 03                	jmp    801025f8 <namex+0x122>
  }
  return ip;
801025f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801025f8:	c9                   	leave  
801025f9:	c3                   	ret    

801025fa <namei>:

struct inode*
namei(char *path)
{
801025fa:	f3 0f 1e fb          	endbr32 
801025fe:	55                   	push   %ebp
801025ff:	89 e5                	mov    %esp,%ebp
80102601:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102604:	83 ec 04             	sub    $0x4,%esp
80102607:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010260a:	50                   	push   %eax
8010260b:	6a 00                	push   $0x0
8010260d:	ff 75 08             	pushl  0x8(%ebp)
80102610:	e8 c1 fe ff ff       	call   801024d6 <namex>
80102615:	83 c4 10             	add    $0x10,%esp
}
80102618:	c9                   	leave  
80102619:	c3                   	ret    

8010261a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010261a:	f3 0f 1e fb          	endbr32 
8010261e:	55                   	push   %ebp
8010261f:	89 e5                	mov    %esp,%ebp
80102621:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102624:	83 ec 04             	sub    $0x4,%esp
80102627:	ff 75 0c             	pushl  0xc(%ebp)
8010262a:	6a 01                	push   $0x1
8010262c:	ff 75 08             	pushl  0x8(%ebp)
8010262f:	e8 a2 fe ff ff       	call   801024d6 <namex>
80102634:	83 c4 10             	add    $0x10,%esp
}
80102637:	c9                   	leave  
80102638:	c3                   	ret    

80102639 <itoa>:

#include "fcntl.h"
#define DIGITS 14

char* itoa(int i, char b[]){
80102639:	f3 0f 1e fb          	endbr32 
8010263d:	55                   	push   %ebp
8010263e:	89 e5                	mov    %esp,%ebp
80102640:	83 ec 20             	sub    $0x20,%esp
    char const digit[] = "0123456789";
80102643:	c7 45 ed 30 31 32 33 	movl   $0x33323130,-0x13(%ebp)
8010264a:	c7 45 f1 34 35 36 37 	movl   $0x37363534,-0xf(%ebp)
80102651:	66 c7 45 f5 38 39    	movw   $0x3938,-0xb(%ebp)
80102657:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
    char* p = b;
8010265b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010265e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(i<0){
80102661:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102665:	79 0f                	jns    80102676 <itoa+0x3d>
        *p++ = '-';
80102667:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010266a:	8d 50 01             	lea    0x1(%eax),%edx
8010266d:	89 55 fc             	mov    %edx,-0x4(%ebp)
80102670:	c6 00 2d             	movb   $0x2d,(%eax)
        i *= -1;
80102673:	f7 5d 08             	negl   0x8(%ebp)
    }
    int shifter = i;
80102676:	8b 45 08             	mov    0x8(%ebp),%eax
80102679:	89 45 f8             	mov    %eax,-0x8(%ebp)
    do{ //Move to where representation ends
        ++p;
8010267c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
        shifter = shifter/10;
80102680:	8b 4d f8             	mov    -0x8(%ebp),%ecx
80102683:	ba 67 66 66 66       	mov    $0x66666667,%edx
80102688:	89 c8                	mov    %ecx,%eax
8010268a:	f7 ea                	imul   %edx
8010268c:	c1 fa 02             	sar    $0x2,%edx
8010268f:	89 c8                	mov    %ecx,%eax
80102691:	c1 f8 1f             	sar    $0x1f,%eax
80102694:	29 c2                	sub    %eax,%edx
80102696:	89 d0                	mov    %edx,%eax
80102698:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }while(shifter);
8010269b:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
8010269f:	75 db                	jne    8010267c <itoa+0x43>
    *p = '\0';
801026a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026a4:	c6 00 00             	movb   $0x0,(%eax)
    do{ //Move back, inserting digits as u go
        *--p = digit[i%10];
801026a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801026aa:	ba 67 66 66 66       	mov    $0x66666667,%edx
801026af:	89 c8                	mov    %ecx,%eax
801026b1:	f7 ea                	imul   %edx
801026b3:	c1 fa 02             	sar    $0x2,%edx
801026b6:	89 c8                	mov    %ecx,%eax
801026b8:	c1 f8 1f             	sar    $0x1f,%eax
801026bb:	29 c2                	sub    %eax,%edx
801026bd:	89 d0                	mov    %edx,%eax
801026bf:	c1 e0 02             	shl    $0x2,%eax
801026c2:	01 d0                	add    %edx,%eax
801026c4:	01 c0                	add    %eax,%eax
801026c6:	29 c1                	sub    %eax,%ecx
801026c8:	89 ca                	mov    %ecx,%edx
801026ca:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801026ce:	0f b6 54 15 ed       	movzbl -0x13(%ebp,%edx,1),%edx
801026d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801026d6:	88 10                	mov    %dl,(%eax)
        i = i/10;
801026d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801026db:	ba 67 66 66 66       	mov    $0x66666667,%edx
801026e0:	89 c8                	mov    %ecx,%eax
801026e2:	f7 ea                	imul   %edx
801026e4:	c1 fa 02             	sar    $0x2,%edx
801026e7:	89 c8                	mov    %ecx,%eax
801026e9:	c1 f8 1f             	sar    $0x1f,%eax
801026ec:	29 c2                	sub    %eax,%edx
801026ee:	89 d0                	mov    %edx,%eax
801026f0:	89 45 08             	mov    %eax,0x8(%ebp)
    }while(i);
801026f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f7:	75 ae                	jne    801026a7 <itoa+0x6e>
    return b;
801026f9:	8b 45 0c             	mov    0xc(%ebp),%eax
}
801026fc:	c9                   	leave  
801026fd:	c3                   	ret    

801026fe <removeSwapFile>:
//remove swap file of proc p;
int removeSwapFile(struct proc* p){
801026fe:	f3 0f 1e fb          	endbr32 
80102702:	55                   	push   %ebp
80102703:	89 e5                	mov    %esp,%ebp
80102705:	83 ec 48             	sub    $0x48,%esp
	//path of proccess
	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102708:	83 ec 04             	sub    $0x4,%esp
8010270b:	6a 06                	push   $0x6
8010270d:	68 8a a1 10 80       	push   $0x8010a18a
80102712:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102715:	50                   	push   %eax
80102716:	e8 4c 3a 00 00       	call   80106167 <memmove>
8010271b:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
8010271e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102721:	83 c0 06             	add    $0x6,%eax
80102724:	8b 55 08             	mov    0x8(%ebp),%edx
80102727:	8b 52 10             	mov    0x10(%edx),%edx
8010272a:	83 ec 08             	sub    $0x8,%esp
8010272d:	50                   	push   %eax
8010272e:	52                   	push   %edx
8010272f:	e8 05 ff ff ff       	call   80102639 <itoa>
80102734:	83 c4 10             	add    $0x10,%esp
	struct inode *ip, *dp;
	struct dirent de;
	char name[DIRSIZ];
	uint off;

	if(0 == p->swapFile)
80102737:	8b 45 08             	mov    0x8(%ebp),%eax
8010273a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102740:	85 c0                	test   %eax,%eax
80102742:	75 0a                	jne    8010274e <removeSwapFile+0x50>
	{
		return -1;
80102744:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102749:	e9 d4 01 00 00       	jmp    80102922 <removeSwapFile+0x224>
	}
	fileclose(p->swapFile);
8010274e:	8b 45 08             	mov    0x8(%ebp),%eax
80102751:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102757:	83 ec 0c             	sub    $0xc,%esp
8010275a:	50                   	push   %eax
8010275b:	e8 64 e9 ff ff       	call   801010c4 <fileclose>
80102760:	83 c4 10             	add    $0x10,%esp

	begin_op();
80102763:	e8 ce 16 00 00       	call   80103e36 <begin_op>
	if((dp = nameiparent(path, name)) == 0)
80102768:	83 ec 08             	sub    $0x8,%esp
8010276b:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010276e:	50                   	push   %eax
8010276f:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80102772:	50                   	push   %eax
80102773:	e8 a2 fe ff ff       	call   8010261a <nameiparent>
80102778:	83 c4 10             	add    $0x10,%esp
8010277b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010277e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102782:	75 0f                	jne    80102793 <removeSwapFile+0x95>
	{
		end_op();
80102784:	e8 3d 17 00 00       	call   80103ec6 <end_op>
		return -1;
80102789:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010278e:	e9 8f 01 00 00       	jmp    80102922 <removeSwapFile+0x224>
	}

	ilock(dp);
80102793:	83 ec 0c             	sub    $0xc,%esp
80102796:	ff 75 f4             	pushl  -0xc(%ebp)
80102799:	e8 73 f2 ff ff       	call   80101a11 <ilock>
8010279e:	83 c4 10             	add    $0x10,%esp

	  // Cannot unlink "." or "..".
	if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801027a1:	83 ec 08             	sub    $0x8,%esp
801027a4:	68 91 a1 10 80       	push   $0x8010a191
801027a9:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801027ac:	50                   	push   %eax
801027ad:	e8 c7 fa ff ff       	call   80102279 <namecmp>
801027b2:	83 c4 10             	add    $0x10,%esp
801027b5:	85 c0                	test   %eax,%eax
801027b7:	0f 84 49 01 00 00    	je     80102906 <removeSwapFile+0x208>
801027bd:	83 ec 08             	sub    $0x8,%esp
801027c0:	68 93 a1 10 80       	push   $0x8010a193
801027c5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801027c8:	50                   	push   %eax
801027c9:	e8 ab fa ff ff       	call   80102279 <namecmp>
801027ce:	83 c4 10             	add    $0x10,%esp
801027d1:	85 c0                	test   %eax,%eax
801027d3:	0f 84 2d 01 00 00    	je     80102906 <removeSwapFile+0x208>
	   goto bad;

	if((ip = dirlookup(dp, name, &off)) == 0)
801027d9:	83 ec 04             	sub    $0x4,%esp
801027dc:	8d 45 c0             	lea    -0x40(%ebp),%eax
801027df:	50                   	push   %eax
801027e0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801027e3:	50                   	push   %eax
801027e4:	ff 75 f4             	pushl  -0xc(%ebp)
801027e7:	e8 ac fa ff ff       	call   80102298 <dirlookup>
801027ec:	83 c4 10             	add    $0x10,%esp
801027ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
801027f2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801027f6:	0f 84 0d 01 00 00    	je     80102909 <removeSwapFile+0x20b>
		goto bad;
	ilock(ip);
801027fc:	83 ec 0c             	sub    $0xc,%esp
801027ff:	ff 75 f0             	pushl  -0x10(%ebp)
80102802:	e8 0a f2 ff ff       	call   80101a11 <ilock>
80102807:	83 c4 10             	add    $0x10,%esp

	if(ip->nlink < 1)
8010280a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010280d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80102811:	66 85 c0             	test   %ax,%ax
80102814:	7f 0d                	jg     80102823 <removeSwapFile+0x125>
		panic("unlink: nlink < 1");
80102816:	83 ec 0c             	sub    $0xc,%esp
80102819:	68 96 a1 10 80       	push   $0x8010a196
8010281e:	e8 74 dd ff ff       	call   80100597 <panic>
	if(ip->type == T_DIR && !isdirempty(ip)){
80102823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102826:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010282a:	66 83 f8 01          	cmp    $0x1,%ax
8010282e:	75 25                	jne    80102855 <removeSwapFile+0x157>
80102830:	83 ec 0c             	sub    $0xc,%esp
80102833:	ff 75 f0             	pushl  -0x10(%ebp)
80102836:	e8 4f 41 00 00       	call   8010698a <isdirempty>
8010283b:	83 c4 10             	add    $0x10,%esp
8010283e:	85 c0                	test   %eax,%eax
80102840:	75 13                	jne    80102855 <removeSwapFile+0x157>
		iunlockput(ip);
80102842:	83 ec 0c             	sub    $0xc,%esp
80102845:	ff 75 f0             	pushl  -0x10(%ebp)
80102848:	e8 90 f4 ff ff       	call   80101cdd <iunlockput>
8010284d:	83 c4 10             	add    $0x10,%esp
		goto bad;
80102850:	e9 b5 00 00 00       	jmp    8010290a <removeSwapFile+0x20c>
	}

	memset(&de, 0, sizeof(de));
80102855:	83 ec 04             	sub    $0x4,%esp
80102858:	6a 10                	push   $0x10
8010285a:	6a 00                	push   $0x0
8010285c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010285f:	50                   	push   %eax
80102860:	e8 3b 38 00 00       	call   801060a0 <memset>
80102865:	83 c4 10             	add    $0x10,%esp
	if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102868:	8b 45 c0             	mov    -0x40(%ebp),%eax
8010286b:	6a 10                	push   $0x10
8010286d:	50                   	push   %eax
8010286e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80102871:	50                   	push   %eax
80102872:	ff 75 f4             	pushl  -0xc(%ebp)
80102875:	e8 75 f8 ff ff       	call   801020ef <writei>
8010287a:	83 c4 10             	add    $0x10,%esp
8010287d:	83 f8 10             	cmp    $0x10,%eax
80102880:	74 0d                	je     8010288f <removeSwapFile+0x191>
		panic("unlink: writei");
80102882:	83 ec 0c             	sub    $0xc,%esp
80102885:	68 a8 a1 10 80       	push   $0x8010a1a8
8010288a:	e8 08 dd ff ff       	call   80100597 <panic>
	if(ip->type == T_DIR){
8010288f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102892:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102896:	66 83 f8 01          	cmp    $0x1,%ax
8010289a:	75 21                	jne    801028bd <removeSwapFile+0x1bf>
		dp->nlink--;
8010289c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289f:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801028a3:	83 e8 01             	sub    $0x1,%eax
801028a6:	89 c2                	mov    %eax,%edx
801028a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ab:	66 89 50 16          	mov    %dx,0x16(%eax)
		iupdate(dp);
801028af:	83 ec 0c             	sub    $0xc,%esp
801028b2:	ff 75 f4             	pushl  -0xc(%ebp)
801028b5:	e8 71 ef ff ff       	call   8010182b <iupdate>
801028ba:	83 c4 10             	add    $0x10,%esp
	}
	iunlockput(dp);
801028bd:	83 ec 0c             	sub    $0xc,%esp
801028c0:	ff 75 f4             	pushl  -0xc(%ebp)
801028c3:	e8 15 f4 ff ff       	call   80101cdd <iunlockput>
801028c8:	83 c4 10             	add    $0x10,%esp

	ip->nlink--;
801028cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ce:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801028d2:	83 e8 01             	sub    $0x1,%eax
801028d5:	89 c2                	mov    %eax,%edx
801028d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028da:	66 89 50 16          	mov    %dx,0x16(%eax)
	iupdate(ip);
801028de:	83 ec 0c             	sub    $0xc,%esp
801028e1:	ff 75 f0             	pushl  -0x10(%ebp)
801028e4:	e8 42 ef ff ff       	call   8010182b <iupdate>
801028e9:	83 c4 10             	add    $0x10,%esp
	iunlockput(ip);
801028ec:	83 ec 0c             	sub    $0xc,%esp
801028ef:	ff 75 f0             	pushl  -0x10(%ebp)
801028f2:	e8 e6 f3 ff ff       	call   80101cdd <iunlockput>
801028f7:	83 c4 10             	add    $0x10,%esp

	end_op();
801028fa:	e8 c7 15 00 00       	call   80103ec6 <end_op>

	return 0;
801028ff:	b8 00 00 00 00       	mov    $0x0,%eax
80102904:	eb 1c                	jmp    80102922 <removeSwapFile+0x224>
	   goto bad;
80102906:	90                   	nop
80102907:	eb 01                	jmp    8010290a <removeSwapFile+0x20c>
		goto bad;
80102909:	90                   	nop

	bad:
		iunlockput(dp);
8010290a:	83 ec 0c             	sub    $0xc,%esp
8010290d:	ff 75 f4             	pushl  -0xc(%ebp)
80102910:	e8 c8 f3 ff ff       	call   80101cdd <iunlockput>
80102915:	83 c4 10             	add    $0x10,%esp
		end_op();
80102918:	e8 a9 15 00 00       	call   80103ec6 <end_op>
		return -1;
8010291d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80102922:	c9                   	leave  
80102923:	c3                   	ret    

80102924 <readFromSwapFile>:

//return as sys_read (-1 when error)
int readFromSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size){
80102924:	f3 0f 1e fb          	endbr32 
80102928:	55                   	push   %ebp
80102929:	89 e5                	mov    %esp,%ebp
8010292b:	83 ec 08             	sub    $0x8,%esp
  p->swapFile->off = placeOnFile;
8010292e:	8b 45 08             	mov    0x8(%ebp),%eax
80102931:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102937:	8b 55 10             	mov    0x10(%ebp),%edx
8010293a:	89 50 14             	mov    %edx,0x14(%eax)
  return fileread(p->swapFile, buffer,  size);
8010293d:	8b 55 14             	mov    0x14(%ebp),%edx
80102940:	8b 45 08             	mov    0x8(%ebp),%eax
80102943:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102949:	83 ec 04             	sub    $0x4,%esp
8010294c:	52                   	push   %edx
8010294d:	ff 75 0c             	pushl  0xc(%ebp)
80102950:	50                   	push   %eax
80102951:	e8 b5 e8 ff ff       	call   8010120b <fileread>
80102956:	83 c4 10             	add    $0x10,%esp
}
80102959:	c9                   	leave  
8010295a:	c3                   	ret    

8010295b <writeToSwapFile>:

//return as sys_write (-1 when error)
int writeToSwapFile(struct proc * p, char* buffer, uint placeOnFile, uint size){
8010295b:	f3 0f 1e fb          	endbr32 
8010295f:	55                   	push   %ebp
80102960:	89 e5                	mov    %esp,%ebp
80102962:	83 ec 08             	sub    $0x8,%esp
  p->swapFile->off = placeOnFile;
80102965:	8b 45 08             	mov    0x8(%ebp),%eax
80102968:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
8010296e:	8b 55 10             	mov    0x10(%ebp),%edx
80102971:	89 50 14             	mov    %edx,0x14(%eax)
  return filewrite(p->swapFile, buffer, size);
80102974:	8b 55 14             	mov    0x14(%ebp),%edx
80102977:	8b 45 08             	mov    0x8(%ebp),%eax
8010297a:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102980:	83 ec 04             	sub    $0x4,%esp
80102983:	52                   	push   %edx
80102984:	ff 75 0c             	pushl  0xc(%ebp)
80102987:	50                   	push   %eax
80102988:	e8 3a e9 ff ff       	call   801012c7 <filewrite>
8010298d:	83 c4 10             	add    $0x10,%esp
}
80102990:	c9                   	leave  
80102991:	c3                   	ret    

80102992 <getFreeSlot>:

int getFreeSlot(struct proc * p) {
80102992:	f3 0f 1e fb          	endbr32 
80102996:	55                   	push   %ebp
80102997:	89 e5                	mov    %esp,%ebp
80102999:	83 ec 10             	sub    $0x10,%esp
  int maxStructCount = (maxNumberOfPages - allPhysicalPages);
8010299c:	c7 45 f8 0f 00 00 00 	movl   $0xf,-0x8(%ebp)
  int i;
  for (i = 0; i < maxStructCount; i++) {
801029a3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801029aa:	eb 26                	jmp    801029d2 <getFreeSlot+0x40>
    if (p->fileCtrlr[i].state == NOTUSED)
801029ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
801029af:	8b 55 fc             	mov    -0x4(%ebp),%edx
801029b2:	89 d0                	mov    %edx,%eax
801029b4:	c1 e0 02             	shl    $0x2,%eax
801029b7:	01 d0                	add    %edx,%eax
801029b9:	c1 e0 02             	shl    $0x2,%eax
801029bc:	01 c8                	add    %ecx,%eax
801029be:	05 88 00 00 00       	add    $0x88,%eax
801029c3:	8b 00                	mov    (%eax),%eax
801029c5:	85 c0                	test   %eax,%eax
801029c7:	75 05                	jne    801029ce <getFreeSlot+0x3c>
      return i;
801029c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029cc:	eb 11                	jmp    801029df <getFreeSlot+0x4d>
  for (i = 0; i < maxStructCount; i++) {
801029ce:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801029d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801029d5:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801029d8:	7c d2                	jl     801029ac <getFreeSlot+0x1a>
  }
  return -1; //file is full
801029da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801029df:	c9                   	leave  
801029e0:	c3                   	ret    

801029e1 <writePageToFile>:

int writePageToFile(struct proc * p, int userPageVAddr, pde_t *pgdir) {
801029e1:	f3 0f 1e fb          	endbr32 
801029e5:	55                   	push   %ebp
801029e6:	89 e5                	mov    %esp,%ebp
801029e8:	53                   	push   %ebx
801029e9:	83 ec 14             	sub    $0x14,%esp
  int freePlace = getFreeSlot(p);
801029ec:	ff 75 08             	pushl  0x8(%ebp)
801029ef:	e8 9e ff ff ff       	call   80102992 <getFreeSlot>
801029f4:	83 c4 04             	add    $0x4,%esp
801029f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int retInt = writeToSwapFile(p, (char*)userPageVAddr, pageSize*freePlace, pageSize);
801029fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fd:	c1 e0 0c             	shl    $0xc,%eax
80102a00:	89 c2                	mov    %eax,%edx
80102a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a05:	68 00 10 00 00       	push   $0x1000
80102a0a:	52                   	push   %edx
80102a0b:	50                   	push   %eax
80102a0c:	ff 75 08             	pushl  0x8(%ebp)
80102a0f:	e8 47 ff ff ff       	call   8010295b <writeToSwapFile>
80102a14:	83 c4 10             	add    $0x10,%esp
80102a17:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if (retInt == -1)
80102a1a:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80102a1e:	75 0a                	jne    80102a2a <writePageToFile+0x49>
    return -1;
80102a20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102a25:	e9 93 00 00 00       	jmp    80102abd <writePageToFile+0xdc>
  //if reached here - data was successfully placed in file
  p->fileCtrlr[freePlace].state = USED;
80102a2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102a2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a30:	89 d0                	mov    %edx,%eax
80102a32:	c1 e0 02             	shl    $0x2,%eax
80102a35:	01 d0                	add    %edx,%eax
80102a37:	c1 e0 02             	shl    $0x2,%eax
80102a3a:	01 c8                	add    %ecx,%eax
80102a3c:	05 88 00 00 00       	add    $0x88,%eax
80102a41:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  p->fileCtrlr[freePlace].myPageVirtualAddress = userPageVAddr;
80102a47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102a4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102a4d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a50:	89 d0                	mov    %edx,%eax
80102a52:	c1 e0 02             	shl    $0x2,%eax
80102a55:	01 d0                	add    %edx,%eax
80102a57:	c1 e0 02             	shl    $0x2,%eax
80102a5a:	01 d8                	add    %ebx,%eax
80102a5c:	05 90 00 00 00       	add    $0x90,%eax
80102a61:	89 08                	mov    %ecx,(%eax)
  p->fileCtrlr[freePlace].pageDir = pgdir;
80102a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102a66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a69:	89 d0                	mov    %edx,%eax
80102a6b:	c1 e0 02             	shl    $0x2,%eax
80102a6e:	01 d0                	add    %edx,%eax
80102a70:	c1 e0 02             	shl    $0x2,%eax
80102a73:	01 c8                	add    %ecx,%eax
80102a75:	8d 90 8c 00 00 00    	lea    0x8c(%eax),%edx
80102a7b:	8b 45 10             	mov    0x10(%ebp),%eax
80102a7e:	89 02                	mov    %eax,(%edx)
  p->fileCtrlr[freePlace].accessNumber = 0;
80102a80:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102a83:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102a86:	89 d0                	mov    %edx,%eax
80102a88:	c1 e0 02             	shl    $0x2,%eax
80102a8b:	01 d0                	add    %edx,%eax
80102a8d:	c1 e0 02             	shl    $0x2,%eax
80102a90:	01 c8                	add    %ecx,%eax
80102a92:	05 94 00 00 00       	add    $0x94,%eax
80102a97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  p->fileCtrlr[freePlace].Order = 0;
80102a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102aa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102aa3:	89 d0                	mov    %edx,%eax
80102aa5:	c1 e0 02             	shl    $0x2,%eax
80102aa8:	01 d0                	add    %edx,%eax
80102aaa:	c1 e0 02             	shl    $0x2,%eax
80102aad:	01 c8                	add    %ecx,%eax
80102aaf:	05 98 00 00 00       	add    $0x98,%eax
80102ab4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return retInt;
80102aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80102abd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102ac0:	c9                   	leave  
80102ac1:	c3                   	ret    

80102ac2 <readPageFromFile>:

int readPageFromFile(struct proc * p, int ramCtrlrIndex, int userPageVAddr, char* buff) {
80102ac2:	f3 0f 1e fb          	endbr32 
80102ac6:	55                   	push   %ebp
80102ac7:	89 e5                	mov    %esp,%ebp
80102ac9:	53                   	push   %ebx
80102aca:	83 ec 14             	sub    $0x14,%esp
  int maxStructCount = (maxNumberOfPages - allPhysicalPages);
80102acd:	c7 45 f0 0f 00 00 00 	movl   $0xf,-0x10(%ebp)
  int i;
  int retInt;
  for (i = 0; i < maxStructCount; i++) {
80102ad4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102adb:	e9 ea 00 00 00       	jmp    80102bca <readPageFromFile+0x108>
    if (p->fileCtrlr[i].myPageVirtualAddress == userPageVAddr) {
80102ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102ae3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102ae6:	89 d0                	mov    %edx,%eax
80102ae8:	c1 e0 02             	shl    $0x2,%eax
80102aeb:	01 d0                	add    %edx,%eax
80102aed:	c1 e0 02             	shl    $0x2,%eax
80102af0:	01 c8                	add    %ecx,%eax
80102af2:	05 90 00 00 00       	add    $0x90,%eax
80102af7:	8b 10                	mov    (%eax),%edx
80102af9:	8b 45 10             	mov    0x10(%ebp),%eax
80102afc:	39 c2                	cmp    %eax,%edx
80102afe:	0f 85 c2 00 00 00    	jne    80102bc6 <readPageFromFile+0x104>
      retInt = readFromSwapFile(p, buff, i*pageSize, pageSize);
80102b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b07:	c1 e0 0c             	shl    $0xc,%eax
80102b0a:	68 00 10 00 00       	push   $0x1000
80102b0f:	50                   	push   %eax
80102b10:	ff 75 14             	pushl  0x14(%ebp)
80102b13:	ff 75 08             	pushl  0x8(%ebp)
80102b16:	e8 09 fe ff ff       	call   80102924 <readFromSwapFile>
80102b1b:	83 c4 10             	add    $0x10,%esp
80102b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if (retInt == -1)
80102b21:	83 7d ec ff          	cmpl   $0xffffffff,-0x14(%ebp)
80102b25:	0f 84 ad 00 00 00    	je     80102bd8 <readPageFromFile+0x116>
        break; //error in read
      p->memController[ramCtrlrIndex] = p->fileCtrlr[i];
80102b2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b31:	89 d0                	mov    %edx,%eax
80102b33:	c1 e0 02             	shl    $0x2,%eax
80102b36:	01 d0                	add    %edx,%eax
80102b38:	c1 e0 02             	shl    $0x2,%eax
80102b3b:	01 c8                	add    %ecx,%eax
80102b3d:	8d 90 b0 01 00 00    	lea    0x1b0(%eax),%edx
80102b43:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102b46:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80102b49:	89 c8                	mov    %ecx,%eax
80102b4b:	c1 e0 02             	shl    $0x2,%eax
80102b4e:	01 c8                	add    %ecx,%eax
80102b50:	c1 e0 02             	shl    $0x2,%eax
80102b53:	01 d8                	add    %ebx,%eax
80102b55:	83 e8 80             	sub    $0xffffff80,%eax
80102b58:	8b 48 08             	mov    0x8(%eax),%ecx
80102b5b:	89 4a 04             	mov    %ecx,0x4(%edx)
80102b5e:	8b 48 0c             	mov    0xc(%eax),%ecx
80102b61:	89 4a 08             	mov    %ecx,0x8(%edx)
80102b64:	8b 48 10             	mov    0x10(%eax),%ecx
80102b67:	89 4a 0c             	mov    %ecx,0xc(%edx)
80102b6a:	8b 48 14             	mov    0x14(%eax),%ecx
80102b6d:	89 4a 10             	mov    %ecx,0x10(%edx)
80102b70:	8b 40 18             	mov    0x18(%eax),%eax
80102b73:	89 42 14             	mov    %eax,0x14(%edx)
      p->memController[ramCtrlrIndex].Order = proc->loadOrderCounter++;
80102b76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102b7c:	8b 90 e0 02 00 00    	mov    0x2e0(%eax),%edx
80102b82:	8d 4a 01             	lea    0x1(%edx),%ecx
80102b85:	89 88 e0 02 00 00    	mov    %ecx,0x2e0(%eax)
80102b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102b91:	89 c8                	mov    %ecx,%eax
80102b93:	c1 e0 02             	shl    $0x2,%eax
80102b96:	01 c8                	add    %ecx,%eax
80102b98:	c1 e0 02             	shl    $0x2,%eax
80102b9b:	01 d8                	add    %ebx,%eax
80102b9d:	05 c4 01 00 00       	add    $0x1c4,%eax
80102ba2:	89 10                	mov    %edx,(%eax)
      p->fileCtrlr[i].state = NOTUSED;
80102ba4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80102ba7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102baa:	89 d0                	mov    %edx,%eax
80102bac:	c1 e0 02             	shl    $0x2,%eax
80102baf:	01 d0                	add    %edx,%eax
80102bb1:	c1 e0 02             	shl    $0x2,%eax
80102bb4:	01 c8                	add    %ecx,%eax
80102bb6:	05 88 00 00 00       	add    $0x88,%eax
80102bbb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      return retInt;
80102bc1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102bc4:	eb 18                	jmp    80102bde <readPageFromFile+0x11c>
  for (i = 0; i < maxStructCount; i++) {
80102bc6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bcd:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102bd0:	0f 8c 0a ff ff ff    	jl     80102ae0 <readPageFromFile+0x1e>
80102bd6:	eb 01                	jmp    80102bd9 <readPageFromFile+0x117>
        break; //error in read
80102bd8:	90                   	nop
    }
  }
  //if reached here - physical address given is not paged out (not found)
  return -1;
80102bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102be1:	c9                   	leave  
80102be2:	c3                   	ret    

80102be3 <createSwapFile>:

//return 0 on success
int createSwapFile(struct proc* p){
80102be3:	f3 0f 1e fb          	endbr32 
80102be7:	55                   	push   %ebp
80102be8:	89 e5                	mov    %esp,%ebp
80102bea:	83 ec 28             	sub    $0x28,%esp

	char path[DIGITS];
	memmove(path,"/.swap", 6);
80102bed:	83 ec 04             	sub    $0x4,%esp
80102bf0:	6a 06                	push   $0x6
80102bf2:	68 8a a1 10 80       	push   $0x8010a18a
80102bf7:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102bfa:	50                   	push   %eax
80102bfb:	e8 67 35 00 00       	call   80106167 <memmove>
80102c00:	83 c4 10             	add    $0x10,%esp
	itoa(p->pid, path+ 6);
80102c03:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102c06:	83 c0 06             	add    $0x6,%eax
80102c09:	8b 55 08             	mov    0x8(%ebp),%edx
80102c0c:	8b 52 10             	mov    0x10(%edx),%edx
80102c0f:	83 ec 08             	sub    $0x8,%esp
80102c12:	50                   	push   %eax
80102c13:	52                   	push   %edx
80102c14:	e8 20 fa ff ff       	call   80102639 <itoa>
80102c19:	83 c4 10             	add    $0x10,%esp

  begin_op();
80102c1c:	e8 15 12 00 00       	call   80103e36 <begin_op>
  struct inode * in = create(path, T_FILE, 0, 0);
80102c21:	6a 00                	push   $0x0
80102c23:	6a 00                	push   $0x0
80102c25:	6a 02                	push   $0x2
80102c27:	8d 45 e6             	lea    -0x1a(%ebp),%eax
80102c2a:	50                   	push   %eax
80102c2b:	e8 ab 3f 00 00       	call   80106bdb <create>
80102c30:	83 c4 10             	add    $0x10,%esp
80102c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
	iunlock(in);
80102c36:	83 ec 0c             	sub    $0xc,%esp
80102c39:	ff 75 f4             	pushl  -0xc(%ebp)
80102c3c:	e8 32 ef ff ff       	call   80101b73 <iunlock>
80102c41:	83 c4 10             	add    $0x10,%esp

	p->swapFile = filealloc();
80102c44:	e8 b5 e3 ff ff       	call   80100ffe <filealloc>
80102c49:	8b 55 08             	mov    0x8(%ebp),%edx
80102c4c:	89 82 84 00 00 00    	mov    %eax,0x84(%edx)
	if (p->swapFile == 0)
80102c52:	8b 45 08             	mov    0x8(%ebp),%eax
80102c55:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102c5b:	85 c0                	test   %eax,%eax
80102c5d:	75 0d                	jne    80102c6c <createSwapFile+0x89>
	 panic("no slot for files on /store");
80102c5f:	83 ec 0c             	sub    $0xc,%esp
80102c62:	68 b7 a1 10 80       	push   $0x8010a1b7
80102c67:	e8 2b d9 ff ff       	call   80100597 <panic>
	p->swapFile->ip = in;
80102c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80102c6f:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102c75:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102c78:	89 50 10             	mov    %edx,0x10(%eax)
	p->swapFile->type = FD_INODE;
80102c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7e:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102c84:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
	p->swapFile->off = 0;
80102c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8d:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102c93:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
	p->swapFile->readable = O_WRONLY;
80102c9a:	8b 45 08             	mov    0x8(%ebp),%eax
80102c9d:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102ca3:	c6 40 08 01          	movb   $0x1,0x8(%eax)
	p->swapFile->writable = O_RDWR;
80102ca7:	8b 45 08             	mov    0x8(%ebp),%eax
80102caa:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80102cb0:	c6 40 09 02          	movb   $0x2,0x9(%eax)
  end_op();
80102cb4:	e8 0d 12 00 00       	call   80103ec6 <end_op>
  return 0;
80102cb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102cbe:	c9                   	leave  
80102cbf:	c3                   	ret    

80102cc0 <copySwapFile>:

void copySwapFile(struct proc* fromP, struct proc* toP){
80102cc0:	f3 0f 1e fb          	endbr32 
80102cc4:	55                   	push   %ebp
80102cc5:	89 e5                	mov    %esp,%ebp
80102cc7:	81 ec 00 10 00 00    	sub    $0x1000,%esp
80102ccd:	83 0c 24 00          	orl    $0x0,(%esp)
80102cd1:	83 ec 18             	sub    $0x18,%esp
  if (fromP->pid < 3)
80102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd7:	8b 40 10             	mov    0x10(%eax),%eax
80102cda:	83 f8 02             	cmp    $0x2,%eax
80102cdd:	0f 8e a2 00 00 00    	jle    80102d85 <copySwapFile+0xc5>
    return;
  char buff[pageSize];
  int i;
  for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++){
80102ce3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102cea:	e9 8a 00 00 00       	jmp    80102d79 <copySwapFile+0xb9>
    if (proc->fileCtrlr[i].state == USED){
80102cef:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80102cf6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102cf9:	89 d0                	mov    %edx,%eax
80102cfb:	c1 e0 02             	shl    $0x2,%eax
80102cfe:	01 d0                	add    %edx,%eax
80102d00:	c1 e0 02             	shl    $0x2,%eax
80102d03:	01 c8                	add    %ecx,%eax
80102d05:	05 88 00 00 00       	add    $0x88,%eax
80102d0a:	8b 00                	mov    (%eax),%eax
80102d0c:	83 f8 01             	cmp    $0x1,%eax
80102d0f:	75 64                	jne    80102d75 <copySwapFile+0xb5>
      if (readFromSwapFile(fromP, buff, pageSize*i, pageSize) != pageSize)
80102d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d14:	c1 e0 0c             	shl    $0xc,%eax
80102d17:	68 00 10 00 00       	push   $0x1000
80102d1c:	50                   	push   %eax
80102d1d:	8d 85 f4 ef ff ff    	lea    -0x100c(%ebp),%eax
80102d23:	50                   	push   %eax
80102d24:	ff 75 08             	pushl  0x8(%ebp)
80102d27:	e8 f8 fb ff ff       	call   80102924 <readFromSwapFile>
80102d2c:	83 c4 10             	add    $0x10,%esp
80102d2f:	3d 00 10 00 00       	cmp    $0x1000,%eax
80102d34:	74 0d                	je     80102d43 <copySwapFile+0x83>
        panic("CopySwapFile error");
80102d36:	83 ec 0c             	sub    $0xc,%esp
80102d39:	68 d3 a1 10 80       	push   $0x8010a1d3
80102d3e:	e8 54 d8 ff ff       	call   80100597 <panic>
      if (writeToSwapFile(toP, buff, pageSize*i, pageSize) != pageSize)
80102d43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d46:	c1 e0 0c             	shl    $0xc,%eax
80102d49:	68 00 10 00 00       	push   $0x1000
80102d4e:	50                   	push   %eax
80102d4f:	8d 85 f4 ef ff ff    	lea    -0x100c(%ebp),%eax
80102d55:	50                   	push   %eax
80102d56:	ff 75 0c             	pushl  0xc(%ebp)
80102d59:	e8 fd fb ff ff       	call   8010295b <writeToSwapFile>
80102d5e:	83 c4 10             	add    $0x10,%esp
80102d61:	3d 00 10 00 00       	cmp    $0x1000,%eax
80102d66:	74 0d                	je     80102d75 <copySwapFile+0xb5>
        panic("CopySwapFile error");
80102d68:	83 ec 0c             	sub    $0xc,%esp
80102d6b:	68 d3 a1 10 80       	push   $0x8010a1d3
80102d70:	e8 22 d8 ff ff       	call   80100597 <panic>
  for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++){
80102d75:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102d79:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80102d7d:	0f 8e 6c ff ff ff    	jle    80102cef <copySwapFile+0x2f>
80102d83:	eb 01                	jmp    80102d86 <copySwapFile+0xc6>
    return;
80102d85:	90                   	nop
    }
  }
}
80102d86:	c9                   	leave  
80102d87:	c3                   	ret    

80102d88 <inb>:
{
80102d88:	55                   	push   %ebp
80102d89:	89 e5                	mov    %esp,%ebp
80102d8b:	83 ec 14             	sub    $0x14,%esp
80102d8e:	8b 45 08             	mov    0x8(%ebp),%eax
80102d91:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d95:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	ec                   	in     (%dx),%al
80102d9c:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102d9f:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102da3:	c9                   	leave  
80102da4:	c3                   	ret    

80102da5 <insl>:
{
80102da5:	55                   	push   %ebp
80102da6:	89 e5                	mov    %esp,%ebp
80102da8:	57                   	push   %edi
80102da9:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102daa:	8b 55 08             	mov    0x8(%ebp),%edx
80102dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102db0:	8b 45 10             	mov    0x10(%ebp),%eax
80102db3:	89 cb                	mov    %ecx,%ebx
80102db5:	89 df                	mov    %ebx,%edi
80102db7:	89 c1                	mov    %eax,%ecx
80102db9:	fc                   	cld    
80102dba:	f3 6d                	rep insl (%dx),%es:(%edi)
80102dbc:	89 c8                	mov    %ecx,%eax
80102dbe:	89 fb                	mov    %edi,%ebx
80102dc0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102dc3:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102dc6:	90                   	nop
80102dc7:	5b                   	pop    %ebx
80102dc8:	5f                   	pop    %edi
80102dc9:	5d                   	pop    %ebp
80102dca:	c3                   	ret    

80102dcb <outb>:
{
80102dcb:	55                   	push   %ebp
80102dcc:	89 e5                	mov    %esp,%ebp
80102dce:	83 ec 08             	sub    $0x8,%esp
80102dd1:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd4:	8b 55 0c             	mov    0xc(%ebp),%edx
80102dd7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102ddb:	89 d0                	mov    %edx,%eax
80102ddd:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102de0:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102de4:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102de8:	ee                   	out    %al,(%dx)
}
80102de9:	90                   	nop
80102dea:	c9                   	leave  
80102deb:	c3                   	ret    

80102dec <outsl>:
{
80102dec:	55                   	push   %ebp
80102ded:	89 e5                	mov    %esp,%ebp
80102def:	56                   	push   %esi
80102df0:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102df1:	8b 55 08             	mov    0x8(%ebp),%edx
80102df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102df7:	8b 45 10             	mov    0x10(%ebp),%eax
80102dfa:	89 cb                	mov    %ecx,%ebx
80102dfc:	89 de                	mov    %ebx,%esi
80102dfe:	89 c1                	mov    %eax,%ecx
80102e00:	fc                   	cld    
80102e01:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102e03:	89 c8                	mov    %ecx,%eax
80102e05:	89 f3                	mov    %esi,%ebx
80102e07:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102e0a:	89 45 10             	mov    %eax,0x10(%ebp)
}
80102e0d:	90                   	nop
80102e0e:	5b                   	pop    %ebx
80102e0f:	5e                   	pop    %esi
80102e10:	5d                   	pop    %ebp
80102e11:	c3                   	ret    

80102e12 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102e12:	f3 0f 1e fb          	endbr32 
80102e16:	55                   	push   %ebp
80102e17:	89 e5                	mov    %esp,%ebp
80102e19:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102e1c:	90                   	nop
80102e1d:	68 f7 01 00 00       	push   $0x1f7
80102e22:	e8 61 ff ff ff       	call   80102d88 <inb>
80102e27:	83 c4 04             	add    $0x4,%esp
80102e2a:	0f b6 c0             	movzbl %al,%eax
80102e2d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102e30:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e33:	25 c0 00 00 00       	and    $0xc0,%eax
80102e38:	83 f8 40             	cmp    $0x40,%eax
80102e3b:	75 e0                	jne    80102e1d <idewait+0xb>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102e3d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102e41:	74 11                	je     80102e54 <idewait+0x42>
80102e43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e46:	83 e0 21             	and    $0x21,%eax
80102e49:	85 c0                	test   %eax,%eax
80102e4b:	74 07                	je     80102e54 <idewait+0x42>
    return -1;
80102e4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e52:	eb 05                	jmp    80102e59 <idewait+0x47>
  return 0;
80102e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102e59:	c9                   	leave  
80102e5a:	c3                   	ret    

80102e5b <ideinit>:

void
ideinit(void)
{
80102e5b:	f3 0f 1e fb          	endbr32 
80102e5f:	55                   	push   %ebp
80102e60:	89 e5                	mov    %esp,%ebp
80102e62:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102e65:	83 ec 08             	sub    $0x8,%esp
80102e68:	68 e6 a1 10 80       	push   $0x8010a1e6
80102e6d:	68 00 d6 10 80       	push   $0x8010d600
80102e72:	e8 87 2f 00 00       	call   80105dfe <initlock>
80102e77:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102e7a:	83 ec 0c             	sub    $0xc,%esp
80102e7d:	6a 0e                	push   $0xe
80102e7f:	e8 ee 19 00 00       	call   80104872 <picenable>
80102e84:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102e87:	a1 40 59 11 80       	mov    0x80115940,%eax
80102e8c:	83 e8 01             	sub    $0x1,%eax
80102e8f:	83 ec 08             	sub    $0x8,%esp
80102e92:	50                   	push   %eax
80102e93:	6a 0e                	push   $0xe
80102e95:	e8 8b 04 00 00       	call   80103325 <ioapicenable>
80102e9a:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102e9d:	83 ec 0c             	sub    $0xc,%esp
80102ea0:	6a 00                	push   $0x0
80102ea2:	e8 6b ff ff ff       	call   80102e12 <idewait>
80102ea7:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102eaa:	83 ec 08             	sub    $0x8,%esp
80102ead:	68 f0 00 00 00       	push   $0xf0
80102eb2:	68 f6 01 00 00       	push   $0x1f6
80102eb7:	e8 0f ff ff ff       	call   80102dcb <outb>
80102ebc:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102ebf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ec6:	eb 24                	jmp    80102eec <ideinit+0x91>
    if(inb(0x1f7) != 0){
80102ec8:	83 ec 0c             	sub    $0xc,%esp
80102ecb:	68 f7 01 00 00       	push   $0x1f7
80102ed0:	e8 b3 fe ff ff       	call   80102d88 <inb>
80102ed5:	83 c4 10             	add    $0x10,%esp
80102ed8:	84 c0                	test   %al,%al
80102eda:	74 0c                	je     80102ee8 <ideinit+0x8d>
      havedisk1 = 1;
80102edc:	c7 05 38 d6 10 80 01 	movl   $0x1,0x8010d638
80102ee3:	00 00 00 
      break;
80102ee6:	eb 0d                	jmp    80102ef5 <ideinit+0x9a>
  for(i=0; i<1000; i++){
80102ee8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102eec:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102ef3:	7e d3                	jle    80102ec8 <ideinit+0x6d>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102ef5:	83 ec 08             	sub    $0x8,%esp
80102ef8:	68 e0 00 00 00       	push   $0xe0
80102efd:	68 f6 01 00 00       	push   $0x1f6
80102f02:	e8 c4 fe ff ff       	call   80102dcb <outb>
80102f07:	83 c4 10             	add    $0x10,%esp
}
80102f0a:	90                   	nop
80102f0b:	c9                   	leave  
80102f0c:	c3                   	ret    

80102f0d <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102f0d:	f3 0f 1e fb          	endbr32 
80102f11:	55                   	push   %ebp
80102f12:	89 e5                	mov    %esp,%ebp
80102f14:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
80102f17:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102f1b:	75 0d                	jne    80102f2a <idestart+0x1d>
    panic("idestart");
80102f1d:	83 ec 0c             	sub    $0xc,%esp
80102f20:	68 ea a1 10 80       	push   $0x8010a1ea
80102f25:	e8 6d d6 ff ff       	call   80100597 <panic>
  if(b->blockno >= FSSIZE)
80102f2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f2d:	8b 40 08             	mov    0x8(%eax),%eax
80102f30:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102f35:	76 0d                	jbe    80102f44 <idestart+0x37>
    panic("incorrect blockno");
80102f37:	83 ec 0c             	sub    $0xc,%esp
80102f3a:	68 f3 a1 10 80       	push   $0x8010a1f3
80102f3f:	e8 53 d6 ff ff       	call   80100597 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102f44:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102f4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102f4e:	8b 50 08             	mov    0x8(%eax),%edx
80102f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f54:	0f af c2             	imul   %edx,%eax
80102f57:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102f5a:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102f5e:	7e 0d                	jle    80102f6d <idestart+0x60>
80102f60:	83 ec 0c             	sub    $0xc,%esp
80102f63:	68 ea a1 10 80       	push   $0x8010a1ea
80102f68:	e8 2a d6 ff ff       	call   80100597 <panic>
  
  idewait(0);
80102f6d:	83 ec 0c             	sub    $0xc,%esp
80102f70:	6a 00                	push   $0x0
80102f72:	e8 9b fe ff ff       	call   80102e12 <idewait>
80102f77:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102f7a:	83 ec 08             	sub    $0x8,%esp
80102f7d:	6a 00                	push   $0x0
80102f7f:	68 f6 03 00 00       	push   $0x3f6
80102f84:	e8 42 fe ff ff       	call   80102dcb <outb>
80102f89:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f8f:	0f b6 c0             	movzbl %al,%eax
80102f92:	83 ec 08             	sub    $0x8,%esp
80102f95:	50                   	push   %eax
80102f96:	68 f2 01 00 00       	push   $0x1f2
80102f9b:	e8 2b fe ff ff       	call   80102dcb <outb>
80102fa0:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fa6:	0f b6 c0             	movzbl %al,%eax
80102fa9:	83 ec 08             	sub    $0x8,%esp
80102fac:	50                   	push   %eax
80102fad:	68 f3 01 00 00       	push   $0x1f3
80102fb2:	e8 14 fe ff ff       	call   80102dcb <outb>
80102fb7:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102fba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbd:	c1 f8 08             	sar    $0x8,%eax
80102fc0:	0f b6 c0             	movzbl %al,%eax
80102fc3:	83 ec 08             	sub    $0x8,%esp
80102fc6:	50                   	push   %eax
80102fc7:	68 f4 01 00 00       	push   $0x1f4
80102fcc:	e8 fa fd ff ff       	call   80102dcb <outb>
80102fd1:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102fd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fd7:	c1 f8 10             	sar    $0x10,%eax
80102fda:	0f b6 c0             	movzbl %al,%eax
80102fdd:	83 ec 08             	sub    $0x8,%esp
80102fe0:	50                   	push   %eax
80102fe1:	68 f5 01 00 00       	push   $0x1f5
80102fe6:	e8 e0 fd ff ff       	call   80102dcb <outb>
80102feb:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102fee:	8b 45 08             	mov    0x8(%ebp),%eax
80102ff1:	8b 40 04             	mov    0x4(%eax),%eax
80102ff4:	c1 e0 04             	shl    $0x4,%eax
80102ff7:	83 e0 10             	and    $0x10,%eax
80102ffa:	89 c2                	mov    %eax,%edx
80102ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fff:	c1 f8 18             	sar    $0x18,%eax
80103002:	83 e0 0f             	and    $0xf,%eax
80103005:	09 d0                	or     %edx,%eax
80103007:	83 c8 e0             	or     $0xffffffe0,%eax
8010300a:	0f b6 c0             	movzbl %al,%eax
8010300d:	83 ec 08             	sub    $0x8,%esp
80103010:	50                   	push   %eax
80103011:	68 f6 01 00 00       	push   $0x1f6
80103016:	e8 b0 fd ff ff       	call   80102dcb <outb>
8010301b:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
8010301e:	8b 45 08             	mov    0x8(%ebp),%eax
80103021:	8b 00                	mov    (%eax),%eax
80103023:	83 e0 04             	and    $0x4,%eax
80103026:	85 c0                	test   %eax,%eax
80103028:	74 30                	je     8010305a <idestart+0x14d>
    outb(0x1f7, IDE_CMD_WRITE);
8010302a:	83 ec 08             	sub    $0x8,%esp
8010302d:	6a 30                	push   $0x30
8010302f:	68 f7 01 00 00       	push   $0x1f7
80103034:	e8 92 fd ff ff       	call   80102dcb <outb>
80103039:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
8010303c:	8b 45 08             	mov    0x8(%ebp),%eax
8010303f:	83 c0 18             	add    $0x18,%eax
80103042:	83 ec 04             	sub    $0x4,%esp
80103045:	68 80 00 00 00       	push   $0x80
8010304a:	50                   	push   %eax
8010304b:	68 f0 01 00 00       	push   $0x1f0
80103050:	e8 97 fd ff ff       	call   80102dec <outsl>
80103055:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80103058:	eb 12                	jmp    8010306c <idestart+0x15f>
    outb(0x1f7, IDE_CMD_READ);
8010305a:	83 ec 08             	sub    $0x8,%esp
8010305d:	6a 20                	push   $0x20
8010305f:	68 f7 01 00 00       	push   $0x1f7
80103064:	e8 62 fd ff ff       	call   80102dcb <outb>
80103069:	83 c4 10             	add    $0x10,%esp
}
8010306c:	90                   	nop
8010306d:	c9                   	leave  
8010306e:	c3                   	ret    

8010306f <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010306f:	f3 0f 1e fb          	endbr32 
80103073:	55                   	push   %ebp
80103074:	89 e5                	mov    %esp,%ebp
80103076:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80103079:	83 ec 0c             	sub    $0xc,%esp
8010307c:	68 00 d6 10 80       	push   $0x8010d600
80103081:	e8 9e 2d 00 00       	call   80105e24 <acquire>
80103086:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80103089:	a1 34 d6 10 80       	mov    0x8010d634,%eax
8010308e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103091:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103095:	75 15                	jne    801030ac <ideintr+0x3d>
    release(&idelock);
80103097:	83 ec 0c             	sub    $0xc,%esp
8010309a:	68 00 d6 10 80       	push   $0x8010d600
8010309f:	e8 eb 2d 00 00       	call   80105e8f <release>
801030a4:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801030a7:	e9 9a 00 00 00       	jmp    80103146 <ideintr+0xd7>
  }
  idequeue = b->qnext;
801030ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030af:	8b 40 14             	mov    0x14(%eax),%eax
801030b2:	a3 34 d6 10 80       	mov    %eax,0x8010d634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801030b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030ba:	8b 00                	mov    (%eax),%eax
801030bc:	83 e0 04             	and    $0x4,%eax
801030bf:	85 c0                	test   %eax,%eax
801030c1:	75 2d                	jne    801030f0 <ideintr+0x81>
801030c3:	83 ec 0c             	sub    $0xc,%esp
801030c6:	6a 01                	push   $0x1
801030c8:	e8 45 fd ff ff       	call   80102e12 <idewait>
801030cd:	83 c4 10             	add    $0x10,%esp
801030d0:	85 c0                	test   %eax,%eax
801030d2:	78 1c                	js     801030f0 <ideintr+0x81>
    insl(0x1f0, b->data, BSIZE/4);
801030d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030d7:	83 c0 18             	add    $0x18,%eax
801030da:	83 ec 04             	sub    $0x4,%esp
801030dd:	68 80 00 00 00       	push   $0x80
801030e2:	50                   	push   %eax
801030e3:	68 f0 01 00 00       	push   $0x1f0
801030e8:	e8 b8 fc ff ff       	call   80102da5 <insl>
801030ed:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801030f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030f3:	8b 00                	mov    (%eax),%eax
801030f5:	83 c8 02             	or     $0x2,%eax
801030f8:	89 c2                	mov    %eax,%edx
801030fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801030fd:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801030ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103102:	8b 00                	mov    (%eax),%eax
80103104:	83 e0 fb             	and    $0xfffffffb,%eax
80103107:	89 c2                	mov    %eax,%edx
80103109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010310c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010310e:	83 ec 0c             	sub    $0xc,%esp
80103111:	ff 75 f4             	pushl  -0xc(%ebp)
80103114:	e8 d3 28 00 00       	call   801059ec <wakeup>
80103119:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
8010311c:	a1 34 d6 10 80       	mov    0x8010d634,%eax
80103121:	85 c0                	test   %eax,%eax
80103123:	74 11                	je     80103136 <ideintr+0xc7>
    idestart(idequeue);
80103125:	a1 34 d6 10 80       	mov    0x8010d634,%eax
8010312a:	83 ec 0c             	sub    $0xc,%esp
8010312d:	50                   	push   %eax
8010312e:	e8 da fd ff ff       	call   80102f0d <idestart>
80103133:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 00 d6 10 80       	push   $0x8010d600
8010313e:	e8 4c 2d 00 00       	call   80105e8f <release>
80103143:	83 c4 10             	add    $0x10,%esp
}
80103146:	c9                   	leave  
80103147:	c3                   	ret    

80103148 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80103148:	f3 0f 1e fb          	endbr32 
8010314c:	55                   	push   %ebp
8010314d:	89 e5                	mov    %esp,%ebp
8010314f:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80103152:	8b 45 08             	mov    0x8(%ebp),%eax
80103155:	8b 00                	mov    (%eax),%eax
80103157:	83 e0 01             	and    $0x1,%eax
8010315a:	85 c0                	test   %eax,%eax
8010315c:	75 0d                	jne    8010316b <iderw+0x23>
    panic("iderw: buf not busy");
8010315e:	83 ec 0c             	sub    $0xc,%esp
80103161:	68 05 a2 10 80       	push   $0x8010a205
80103166:	e8 2c d4 ff ff       	call   80100597 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010316b:	8b 45 08             	mov    0x8(%ebp),%eax
8010316e:	8b 00                	mov    (%eax),%eax
80103170:	83 e0 06             	and    $0x6,%eax
80103173:	83 f8 02             	cmp    $0x2,%eax
80103176:	75 0d                	jne    80103185 <iderw+0x3d>
    panic("iderw: nothing to do");
80103178:	83 ec 0c             	sub    $0xc,%esp
8010317b:	68 19 a2 10 80       	push   $0x8010a219
80103180:	e8 12 d4 ff ff       	call   80100597 <panic>
  if(b->dev != 0 && !havedisk1)
80103185:	8b 45 08             	mov    0x8(%ebp),%eax
80103188:	8b 40 04             	mov    0x4(%eax),%eax
8010318b:	85 c0                	test   %eax,%eax
8010318d:	74 16                	je     801031a5 <iderw+0x5d>
8010318f:	a1 38 d6 10 80       	mov    0x8010d638,%eax
80103194:	85 c0                	test   %eax,%eax
80103196:	75 0d                	jne    801031a5 <iderw+0x5d>
    panic("iderw: ide disk 1 not present");
80103198:	83 ec 0c             	sub    $0xc,%esp
8010319b:	68 2e a2 10 80       	push   $0x8010a22e
801031a0:	e8 f2 d3 ff ff       	call   80100597 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801031a5:	83 ec 0c             	sub    $0xc,%esp
801031a8:	68 00 d6 10 80       	push   $0x8010d600
801031ad:	e8 72 2c 00 00       	call   80105e24 <acquire>
801031b2:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801031b5:	8b 45 08             	mov    0x8(%ebp),%eax
801031b8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801031bf:	c7 45 f4 34 d6 10 80 	movl   $0x8010d634,-0xc(%ebp)
801031c6:	eb 0b                	jmp    801031d3 <iderw+0x8b>
801031c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031cb:	8b 00                	mov    (%eax),%eax
801031cd:	83 c0 14             	add    $0x14,%eax
801031d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801031d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031d6:	8b 00                	mov    (%eax),%eax
801031d8:	85 c0                	test   %eax,%eax
801031da:	75 ec                	jne    801031c8 <iderw+0x80>
    ;
  *pp = b;
801031dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031df:	8b 55 08             	mov    0x8(%ebp),%edx
801031e2:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801031e4:	a1 34 d6 10 80       	mov    0x8010d634,%eax
801031e9:	39 45 08             	cmp    %eax,0x8(%ebp)
801031ec:	75 23                	jne    80103211 <iderw+0xc9>
    idestart(b);
801031ee:	83 ec 0c             	sub    $0xc,%esp
801031f1:	ff 75 08             	pushl  0x8(%ebp)
801031f4:	e8 14 fd ff ff       	call   80102f0d <idestart>
801031f9:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801031fc:	eb 13                	jmp    80103211 <iderw+0xc9>
    sleep(b, &idelock);
801031fe:	83 ec 08             	sub    $0x8,%esp
80103201:	68 00 d6 10 80       	push   $0x8010d600
80103206:	ff 75 08             	pushl  0x8(%ebp)
80103209:	e8 e7 26 00 00       	call   801058f5 <sleep>
8010320e:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80103211:	8b 45 08             	mov    0x8(%ebp),%eax
80103214:	8b 00                	mov    (%eax),%eax
80103216:	83 e0 06             	and    $0x6,%eax
80103219:	83 f8 02             	cmp    $0x2,%eax
8010321c:	75 e0                	jne    801031fe <iderw+0xb6>
  }

  release(&idelock);
8010321e:	83 ec 0c             	sub    $0xc,%esp
80103221:	68 00 d6 10 80       	push   $0x8010d600
80103226:	e8 64 2c 00 00       	call   80105e8f <release>
8010322b:	83 c4 10             	add    $0x10,%esp
}
8010322e:	90                   	nop
8010322f:	c9                   	leave  
80103230:	c3                   	ret    

80103231 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80103231:	f3 0f 1e fb          	endbr32 
80103235:	55                   	push   %ebp
80103236:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103238:	a1 14 52 11 80       	mov    0x80115214,%eax
8010323d:	8b 55 08             	mov    0x8(%ebp),%edx
80103240:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80103242:	a1 14 52 11 80       	mov    0x80115214,%eax
80103247:	8b 40 10             	mov    0x10(%eax),%eax
}
8010324a:	5d                   	pop    %ebp
8010324b:	c3                   	ret    

8010324c <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
8010324c:	f3 0f 1e fb          	endbr32 
80103250:	55                   	push   %ebp
80103251:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80103253:	a1 14 52 11 80       	mov    0x80115214,%eax
80103258:	8b 55 08             	mov    0x8(%ebp),%edx
8010325b:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
8010325d:	a1 14 52 11 80       	mov    0x80115214,%eax
80103262:	8b 55 0c             	mov    0xc(%ebp),%edx
80103265:	89 50 10             	mov    %edx,0x10(%eax)
}
80103268:	90                   	nop
80103269:	5d                   	pop    %ebp
8010326a:	c3                   	ret    

8010326b <ioapicinit>:

void
ioapicinit(void)
{
8010326b:	f3 0f 1e fb          	endbr32 
8010326f:	55                   	push   %ebp
80103270:	89 e5                	mov    %esp,%ebp
80103272:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80103275:	a1 44 53 11 80       	mov    0x80115344,%eax
8010327a:	85 c0                	test   %eax,%eax
8010327c:	0f 84 a0 00 00 00    	je     80103322 <ioapicinit+0xb7>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80103282:	c7 05 14 52 11 80 00 	movl   $0xfec00000,0x80115214
80103289:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010328c:	6a 01                	push   $0x1
8010328e:	e8 9e ff ff ff       	call   80103231 <ioapicread>
80103293:	83 c4 04             	add    $0x4,%esp
80103296:	c1 e8 10             	shr    $0x10,%eax
80103299:	25 ff 00 00 00       	and    $0xff,%eax
8010329e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801032a1:	6a 00                	push   $0x0
801032a3:	e8 89 ff ff ff       	call   80103231 <ioapicread>
801032a8:	83 c4 04             	add    $0x4,%esp
801032ab:	c1 e8 18             	shr    $0x18,%eax
801032ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801032b1:	0f b6 05 40 53 11 80 	movzbl 0x80115340,%eax
801032b8:	0f b6 c0             	movzbl %al,%eax
801032bb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801032be:	74 10                	je     801032d0 <ioapicinit+0x65>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801032c0:	83 ec 0c             	sub    $0xc,%esp
801032c3:	68 4c a2 10 80       	push   $0x8010a24c
801032c8:	e8 11 d1 ff ff       	call   801003de <cprintf>
801032cd:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801032d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d7:	eb 3f                	jmp    80103318 <ioapicinit+0xad>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801032d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032dc:	83 c0 20             	add    $0x20,%eax
801032df:	0d 00 00 01 00       	or     $0x10000,%eax
801032e4:	89 c2                	mov    %eax,%edx
801032e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032e9:	83 c0 08             	add    $0x8,%eax
801032ec:	01 c0                	add    %eax,%eax
801032ee:	83 ec 08             	sub    $0x8,%esp
801032f1:	52                   	push   %edx
801032f2:	50                   	push   %eax
801032f3:	e8 54 ff ff ff       	call   8010324c <ioapicwrite>
801032f8:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
801032fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032fe:	83 c0 08             	add    $0x8,%eax
80103301:	01 c0                	add    %eax,%eax
80103303:	83 c0 01             	add    $0x1,%eax
80103306:	83 ec 08             	sub    $0x8,%esp
80103309:	6a 00                	push   $0x0
8010330b:	50                   	push   %eax
8010330c:	e8 3b ff ff ff       	call   8010324c <ioapicwrite>
80103311:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80103314:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010331e:	7e b9                	jle    801032d9 <ioapicinit+0x6e>
80103320:	eb 01                	jmp    80103323 <ioapicinit+0xb8>
    return;
80103322:	90                   	nop
  }
}
80103323:	c9                   	leave  
80103324:	c3                   	ret    

80103325 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80103325:	f3 0f 1e fb          	endbr32 
80103329:	55                   	push   %ebp
8010332a:	89 e5                	mov    %esp,%ebp
  if(!ismp)
8010332c:	a1 44 53 11 80       	mov    0x80115344,%eax
80103331:	85 c0                	test   %eax,%eax
80103333:	74 39                	je     8010336e <ioapicenable+0x49>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	83 c0 20             	add    $0x20,%eax
8010333b:	89 c2                	mov    %eax,%edx
8010333d:	8b 45 08             	mov    0x8(%ebp),%eax
80103340:	83 c0 08             	add    $0x8,%eax
80103343:	01 c0                	add    %eax,%eax
80103345:	52                   	push   %edx
80103346:	50                   	push   %eax
80103347:	e8 00 ff ff ff       	call   8010324c <ioapicwrite>
8010334c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010334f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103352:	c1 e0 18             	shl    $0x18,%eax
80103355:	89 c2                	mov    %eax,%edx
80103357:	8b 45 08             	mov    0x8(%ebp),%eax
8010335a:	83 c0 08             	add    $0x8,%eax
8010335d:	01 c0                	add    %eax,%eax
8010335f:	83 c0 01             	add    $0x1,%eax
80103362:	52                   	push   %edx
80103363:	50                   	push   %eax
80103364:	e8 e3 fe ff ff       	call   8010324c <ioapicwrite>
80103369:	83 c4 08             	add    $0x8,%esp
8010336c:	eb 01                	jmp    8010336f <ioapicenable+0x4a>
    return;
8010336e:	90                   	nop
}
8010336f:	c9                   	leave  
80103370:	c3                   	ret    

80103371 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80103371:	55                   	push   %ebp
80103372:	89 e5                	mov    %esp,%ebp
80103374:	8b 45 08             	mov    0x8(%ebp),%eax
80103377:	05 00 00 00 80       	add    $0x80000000,%eax
8010337c:	5d                   	pop    %ebp
8010337d:	c3                   	ret    

8010337e <getFreePages>:
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

int getFreePages(){
8010337e:	f3 0f 1e fb          	endbr32 
80103382:	55                   	push   %ebp
80103383:	89 e5                	mov    %esp,%ebp
  return freePages;
80103385:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
}
8010338a:	5d                   	pop    %ebp
8010338b:	c3                   	ret    

8010338c <getTotalPages>:

int getTotalPages(){
8010338c:	f3 0f 1e fb          	endbr32 
80103390:	55                   	push   %ebp
80103391:	89 e5                	mov    %esp,%ebp
  return PGROUNDDOWN(PHYSTOP-v2p(end))/pageSize;
80103393:	68 3c 1c 12 80       	push   $0x80121c3c
80103398:	e8 d4 ff ff ff       	call   80103371 <v2p>
8010339d:	83 c4 04             	add    $0x4,%esp
801033a0:	ba 00 00 00 0e       	mov    $0xe000000,%edx
801033a5:	29 c2                	sub    %eax,%edx
801033a7:	89 d0                	mov    %edx,%eax
801033a9:	c1 e8 0c             	shr    $0xc,%eax
}
801033ac:	c9                   	leave  
801033ad:	c3                   	ret    

801033ae <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
801033ae:	f3 0f 1e fb          	endbr32 
801033b2:	55                   	push   %ebp
801033b3:	89 e5                	mov    %esp,%ebp
801033b5:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
801033b8:	83 ec 08             	sub    $0x8,%esp
801033bb:	68 7e a2 10 80       	push   $0x8010a27e
801033c0:	68 20 52 11 80       	push   $0x80115220
801033c5:	e8 34 2a 00 00       	call   80105dfe <initlock>
801033ca:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801033cd:	c7 05 54 52 11 80 00 	movl   $0x0,0x80115254
801033d4:	00 00 00 
  freerange(vstart, vend);
801033d7:	83 ec 08             	sub    $0x8,%esp
801033da:	ff 75 0c             	pushl  0xc(%ebp)
801033dd:	ff 75 08             	pushl  0x8(%ebp)
801033e0:	e8 2e 00 00 00       	call   80103413 <freerange>
801033e5:	83 c4 10             	add    $0x10,%esp
}
801033e8:	90                   	nop
801033e9:	c9                   	leave  
801033ea:	c3                   	ret    

801033eb <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801033eb:	f3 0f 1e fb          	endbr32 
801033ef:	55                   	push   %ebp
801033f0:	89 e5                	mov    %esp,%ebp
801033f2:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801033f5:	83 ec 08             	sub    $0x8,%esp
801033f8:	ff 75 0c             	pushl  0xc(%ebp)
801033fb:	ff 75 08             	pushl  0x8(%ebp)
801033fe:	e8 10 00 00 00       	call   80103413 <freerange>
80103403:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80103406:	c7 05 54 52 11 80 01 	movl   $0x1,0x80115254
8010340d:	00 00 00 
}
80103410:	90                   	nop
80103411:	c9                   	leave  
80103412:	c3                   	ret    

80103413 <freerange>:

void
freerange(void *vstart, void *vend)
{
80103413:	f3 0f 1e fb          	endbr32 
80103417:	55                   	push   %ebp
80103418:	89 e5                	mov    %esp,%ebp
8010341a:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010341d:	8b 45 08             	mov    0x8(%ebp),%eax
80103420:	05 ff 0f 00 00       	add    $0xfff,%eax
80103425:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010342a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + pageSize <= (char*)vend; p += pageSize)
8010342d:	eb 15                	jmp    80103444 <freerange+0x31>
    kfree(p);
8010342f:	83 ec 0c             	sub    $0xc,%esp
80103432:	ff 75 f4             	pushl  -0xc(%ebp)
80103435:	e8 1b 00 00 00       	call   80103455 <kfree>
8010343a:	83 c4 10             	add    $0x10,%esp
  for(; p + pageSize <= (char*)vend; p += pageSize)
8010343d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80103444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103447:	05 00 10 00 00       	add    $0x1000,%eax
8010344c:	39 45 0c             	cmp    %eax,0xc(%ebp)
8010344f:	73 de                	jae    8010342f <freerange+0x1c>
}
80103451:	90                   	nop
80103452:	90                   	nop
80103453:	c9                   	leave  
80103454:	c3                   	ret    

80103455 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80103455:	f3 0f 1e fb          	endbr32 
80103459:	55                   	push   %ebp
8010345a:	89 e5                	mov    %esp,%ebp
8010345c:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % pageSize || v < end || v2p(v) >= PHYSTOP)
8010345f:	8b 45 08             	mov    0x8(%ebp),%eax
80103462:	25 ff 0f 00 00       	and    $0xfff,%eax
80103467:	85 c0                	test   %eax,%eax
80103469:	75 1b                	jne    80103486 <kfree+0x31>
8010346b:	81 7d 08 3c 1c 12 80 	cmpl   $0x80121c3c,0x8(%ebp)
80103472:	72 12                	jb     80103486 <kfree+0x31>
80103474:	ff 75 08             	pushl  0x8(%ebp)
80103477:	e8 f5 fe ff ff       	call   80103371 <v2p>
8010347c:	83 c4 04             	add    $0x4,%esp
8010347f:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80103484:	76 0d                	jbe    80103493 <kfree+0x3e>
    panic("kfree");
80103486:	83 ec 0c             	sub    $0xc,%esp
80103489:	68 83 a2 10 80       	push   $0x8010a283
8010348e:	e8 04 d1 ff ff       	call   80100597 <panic>
  freePages++;
80103493:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
80103498:	83 c0 01             	add    $0x1,%eax
8010349b:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  // Fill with junk to catch dangling refs.
  memset(v, 1, pageSize);
801034a0:	83 ec 04             	sub    $0x4,%esp
801034a3:	68 00 10 00 00       	push   $0x1000
801034a8:	6a 01                	push   $0x1
801034aa:	ff 75 08             	pushl  0x8(%ebp)
801034ad:	e8 ee 2b 00 00       	call   801060a0 <memset>
801034b2:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
801034b5:	a1 54 52 11 80       	mov    0x80115254,%eax
801034ba:	85 c0                	test   %eax,%eax
801034bc:	74 10                	je     801034ce <kfree+0x79>
    acquire(&kmem.lock);
801034be:	83 ec 0c             	sub    $0xc,%esp
801034c1:	68 20 52 11 80       	push   $0x80115220
801034c6:	e8 59 29 00 00       	call   80105e24 <acquire>
801034cb:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
801034ce:	8b 45 08             	mov    0x8(%ebp),%eax
801034d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
801034d4:	8b 15 58 52 11 80    	mov    0x80115258,%edx
801034da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034dd:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
801034df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034e2:	a3 58 52 11 80       	mov    %eax,0x80115258
  if(kmem.use_lock)
801034e7:	a1 54 52 11 80       	mov    0x80115254,%eax
801034ec:	85 c0                	test   %eax,%eax
801034ee:	74 10                	je     80103500 <kfree+0xab>
    release(&kmem.lock);
801034f0:	83 ec 0c             	sub    $0xc,%esp
801034f3:	68 20 52 11 80       	push   $0x80115220
801034f8:	e8 92 29 00 00       	call   80105e8f <release>
801034fd:	83 c4 10             	add    $0x10,%esp
}
80103500:	90                   	nop
80103501:	c9                   	leave  
80103502:	c3                   	ret    

80103503 <kalloc>:

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char* kalloc(void){
80103503:	f3 0f 1e fb          	endbr32 
80103507:	55                   	push   %ebp
80103508:	89 e5                	mov    %esp,%ebp
8010350a:	83 ec 18             	sub    $0x18,%esp
  struct run *r;
  if(kmem.use_lock)
8010350d:	a1 54 52 11 80       	mov    0x80115254,%eax
80103512:	85 c0                	test   %eax,%eax
80103514:	74 10                	je     80103526 <kalloc+0x23>
    acquire(&kmem.lock);
80103516:	83 ec 0c             	sub    $0xc,%esp
80103519:	68 20 52 11 80       	push   $0x80115220
8010351e:	e8 01 29 00 00       	call   80105e24 <acquire>
80103523:	83 c4 10             	add    $0x10,%esp
  freePages--;
80103526:	a1 3c d6 10 80       	mov    0x8010d63c,%eax
8010352b:	83 e8 01             	sub    $0x1,%eax
8010352e:	a3 3c d6 10 80       	mov    %eax,0x8010d63c
  r = kmem.freelist;
80103533:	a1 58 52 11 80       	mov    0x80115258,%eax
80103538:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
8010353b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010353f:	74 0a                	je     8010354b <kalloc+0x48>
    kmem.freelist = r->next;
80103541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103544:	8b 00                	mov    (%eax),%eax
80103546:	a3 58 52 11 80       	mov    %eax,0x80115258
  if(kmem.use_lock)
8010354b:	a1 54 52 11 80       	mov    0x80115254,%eax
80103550:	85 c0                	test   %eax,%eax
80103552:	74 10                	je     80103564 <kalloc+0x61>
    release(&kmem.lock);
80103554:	83 ec 0c             	sub    $0xc,%esp
80103557:	68 20 52 11 80       	push   $0x80115220
8010355c:	e8 2e 29 00 00       	call   80105e8f <release>
80103561:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80103564:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103567:	c9                   	leave  
80103568:	c3                   	ret    

80103569 <inb>:
{
80103569:	55                   	push   %ebp
8010356a:	89 e5                	mov    %esp,%ebp
8010356c:	83 ec 14             	sub    $0x14,%esp
8010356f:	8b 45 08             	mov    0x8(%ebp),%eax
80103572:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103576:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010357a:	89 c2                	mov    %eax,%edx
8010357c:	ec                   	in     (%dx),%al
8010357d:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103580:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103584:	c9                   	leave  
80103585:	c3                   	ret    

80103586 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80103586:	f3 0f 1e fb          	endbr32 
8010358a:	55                   	push   %ebp
8010358b:	89 e5                	mov    %esp,%ebp
8010358d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103590:	6a 64                	push   $0x64
80103592:	e8 d2 ff ff ff       	call   80103569 <inb>
80103597:	83 c4 04             	add    $0x4,%esp
8010359a:	0f b6 c0             	movzbl %al,%eax
8010359d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
801035a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035a3:	83 e0 01             	and    $0x1,%eax
801035a6:	85 c0                	test   %eax,%eax
801035a8:	75 0a                	jne    801035b4 <kbdgetc+0x2e>
    return -1;
801035aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035af:	e9 23 01 00 00       	jmp    801036d7 <kbdgetc+0x151>
  data = inb(KBDATAP);
801035b4:	6a 60                	push   $0x60
801035b6:	e8 ae ff ff ff       	call   80103569 <inb>
801035bb:	83 c4 04             	add    $0x4,%esp
801035be:	0f b6 c0             	movzbl %al,%eax
801035c1:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801035c4:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801035cb:	75 17                	jne    801035e4 <kbdgetc+0x5e>
    shift |= E0ESC;
801035cd:	a1 40 d6 10 80       	mov    0x8010d640,%eax
801035d2:	83 c8 40             	or     $0x40,%eax
801035d5:	a3 40 d6 10 80       	mov    %eax,0x8010d640
    return 0;
801035da:	b8 00 00 00 00       	mov    $0x0,%eax
801035df:	e9 f3 00 00 00       	jmp    801036d7 <kbdgetc+0x151>
  } else if(data & 0x80){
801035e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035e7:	25 80 00 00 00       	and    $0x80,%eax
801035ec:	85 c0                	test   %eax,%eax
801035ee:	74 45                	je     80103635 <kbdgetc+0xaf>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801035f0:	a1 40 d6 10 80       	mov    0x8010d640,%eax
801035f5:	83 e0 40             	and    $0x40,%eax
801035f8:	85 c0                	test   %eax,%eax
801035fa:	75 08                	jne    80103604 <kbdgetc+0x7e>
801035fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
801035ff:	83 e0 7f             	and    $0x7f,%eax
80103602:	eb 03                	jmp    80103607 <kbdgetc+0x81>
80103604:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103607:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010360a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010360d:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103612:	0f b6 00             	movzbl (%eax),%eax
80103615:	83 c8 40             	or     $0x40,%eax
80103618:	0f b6 c0             	movzbl %al,%eax
8010361b:	f7 d0                	not    %eax
8010361d:	89 c2                	mov    %eax,%edx
8010361f:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80103624:	21 d0                	and    %edx,%eax
80103626:	a3 40 d6 10 80       	mov    %eax,0x8010d640
    return 0;
8010362b:	b8 00 00 00 00       	mov    $0x0,%eax
80103630:	e9 a2 00 00 00       	jmp    801036d7 <kbdgetc+0x151>
  } else if(shift & E0ESC){
80103635:	a1 40 d6 10 80       	mov    0x8010d640,%eax
8010363a:	83 e0 40             	and    $0x40,%eax
8010363d:	85 c0                	test   %eax,%eax
8010363f:	74 14                	je     80103655 <kbdgetc+0xcf>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103641:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80103648:	a1 40 d6 10 80       	mov    0x8010d640,%eax
8010364d:	83 e0 bf             	and    $0xffffffbf,%eax
80103650:	a3 40 d6 10 80       	mov    %eax,0x8010d640
  }

  shift |= shiftcode[data];
80103655:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103658:	05 20 b0 10 80       	add    $0x8010b020,%eax
8010365d:	0f b6 00             	movzbl (%eax),%eax
80103660:	0f b6 d0             	movzbl %al,%edx
80103663:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80103668:	09 d0                	or     %edx,%eax
8010366a:	a3 40 d6 10 80       	mov    %eax,0x8010d640
  shift ^= togglecode[data];
8010366f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103672:	05 20 b1 10 80       	add    $0x8010b120,%eax
80103677:	0f b6 00             	movzbl (%eax),%eax
8010367a:	0f b6 d0             	movzbl %al,%edx
8010367d:	a1 40 d6 10 80       	mov    0x8010d640,%eax
80103682:	31 d0                	xor    %edx,%eax
80103684:	a3 40 d6 10 80       	mov    %eax,0x8010d640
  c = charcode[shift & (CTL | SHIFT)][data];
80103689:	a1 40 d6 10 80       	mov    0x8010d640,%eax
8010368e:	83 e0 03             	and    $0x3,%eax
80103691:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
80103698:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010369b:	01 d0                	add    %edx,%eax
8010369d:	0f b6 00             	movzbl (%eax),%eax
801036a0:	0f b6 c0             	movzbl %al,%eax
801036a3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
801036a6:	a1 40 d6 10 80       	mov    0x8010d640,%eax
801036ab:	83 e0 08             	and    $0x8,%eax
801036ae:	85 c0                	test   %eax,%eax
801036b0:	74 22                	je     801036d4 <kbdgetc+0x14e>
    if('a' <= c && c <= 'z')
801036b2:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
801036b6:	76 0c                	jbe    801036c4 <kbdgetc+0x13e>
801036b8:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
801036bc:	77 06                	ja     801036c4 <kbdgetc+0x13e>
      c += 'A' - 'a';
801036be:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801036c2:	eb 10                	jmp    801036d4 <kbdgetc+0x14e>
    else if('A' <= c && c <= 'Z')
801036c4:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801036c8:	76 0a                	jbe    801036d4 <kbdgetc+0x14e>
801036ca:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801036ce:	77 04                	ja     801036d4 <kbdgetc+0x14e>
      c += 'a' - 'A';
801036d0:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801036d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801036d7:	c9                   	leave  
801036d8:	c3                   	ret    

801036d9 <kbdintr>:

void
kbdintr(void)
{
801036d9:	f3 0f 1e fb          	endbr32 
801036dd:	55                   	push   %ebp
801036de:	89 e5                	mov    %esp,%ebp
801036e0:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
801036e3:	83 ec 0c             	sub    $0xc,%esp
801036e6:	68 86 35 10 80       	push   $0x80103586
801036eb:	e8 4e d1 ff ff       	call   8010083e <consoleintr>
801036f0:	83 c4 10             	add    $0x10,%esp
}
801036f3:	90                   	nop
801036f4:	c9                   	leave  
801036f5:	c3                   	ret    

801036f6 <inb>:
{
801036f6:	55                   	push   %ebp
801036f7:	89 e5                	mov    %esp,%ebp
801036f9:	83 ec 14             	sub    $0x14,%esp
801036fc:	8b 45 08             	mov    0x8(%ebp),%eax
801036ff:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103703:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103707:	89 c2                	mov    %eax,%edx
80103709:	ec                   	in     (%dx),%al
8010370a:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010370d:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103711:	c9                   	leave  
80103712:	c3                   	ret    

80103713 <outb>:
{
80103713:	55                   	push   %ebp
80103714:	89 e5                	mov    %esp,%ebp
80103716:	83 ec 08             	sub    $0x8,%esp
80103719:	8b 45 08             	mov    0x8(%ebp),%eax
8010371c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010371f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103723:	89 d0                	mov    %edx,%eax
80103725:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103728:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010372c:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103730:	ee                   	out    %al,(%dx)
}
80103731:	90                   	nop
80103732:	c9                   	leave  
80103733:	c3                   	ret    

80103734 <readeflags>:
{
80103734:	55                   	push   %ebp
80103735:	89 e5                	mov    %esp,%ebp
80103737:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010373a:	9c                   	pushf  
8010373b:	58                   	pop    %eax
8010373c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010373f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103742:	c9                   	leave  
80103743:	c3                   	ret    

80103744 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80103744:	f3 0f 1e fb          	endbr32 
80103748:	55                   	push   %ebp
80103749:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010374b:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103750:	8b 55 08             	mov    0x8(%ebp),%edx
80103753:	c1 e2 02             	shl    $0x2,%edx
80103756:	01 c2                	add    %eax,%edx
80103758:	8b 45 0c             	mov    0xc(%ebp),%eax
8010375b:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010375d:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103762:	83 c0 20             	add    $0x20,%eax
80103765:	8b 00                	mov    (%eax),%eax
}
80103767:	90                   	nop
80103768:	5d                   	pop    %ebp
80103769:	c3                   	ret    

8010376a <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
8010376a:	f3 0f 1e fb          	endbr32 
8010376e:	55                   	push   %ebp
8010376f:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80103771:	a1 5c 52 11 80       	mov    0x8011525c,%eax
80103776:	85 c0                	test   %eax,%eax
80103778:	0f 84 0c 01 00 00    	je     8010388a <lapicinit+0x120>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010377e:	68 3f 01 00 00       	push   $0x13f
80103783:	6a 3c                	push   $0x3c
80103785:	e8 ba ff ff ff       	call   80103744 <lapicw>
8010378a:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
8010378d:	6a 0b                	push   $0xb
8010378f:	68 f8 00 00 00       	push   $0xf8
80103794:	e8 ab ff ff ff       	call   80103744 <lapicw>
80103799:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010379c:	68 20 00 02 00       	push   $0x20020
801037a1:	68 c8 00 00 00       	push   $0xc8
801037a6:	e8 99 ff ff ff       	call   80103744 <lapicw>
801037ab:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
801037ae:	68 80 96 98 00       	push   $0x989680
801037b3:	68 e0 00 00 00       	push   $0xe0
801037b8:	e8 87 ff ff ff       	call   80103744 <lapicw>
801037bd:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801037c0:	68 00 00 01 00       	push   $0x10000
801037c5:	68 d4 00 00 00       	push   $0xd4
801037ca:	e8 75 ff ff ff       	call   80103744 <lapicw>
801037cf:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
801037d2:	68 00 00 01 00       	push   $0x10000
801037d7:	68 d8 00 00 00       	push   $0xd8
801037dc:	e8 63 ff ff ff       	call   80103744 <lapicw>
801037e1:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801037e4:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801037e9:	83 c0 30             	add    $0x30,%eax
801037ec:	8b 00                	mov    (%eax),%eax
801037ee:	c1 e8 10             	shr    $0x10,%eax
801037f1:	25 fc 00 00 00       	and    $0xfc,%eax
801037f6:	85 c0                	test   %eax,%eax
801037f8:	74 12                	je     8010380c <lapicinit+0xa2>
    lapicw(PCINT, MASKED);
801037fa:	68 00 00 01 00       	push   $0x10000
801037ff:	68 d0 00 00 00       	push   $0xd0
80103804:	e8 3b ff ff ff       	call   80103744 <lapicw>
80103809:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010380c:	6a 33                	push   $0x33
8010380e:	68 dc 00 00 00       	push   $0xdc
80103813:	e8 2c ff ff ff       	call   80103744 <lapicw>
80103818:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
8010381b:	6a 00                	push   $0x0
8010381d:	68 a0 00 00 00       	push   $0xa0
80103822:	e8 1d ff ff ff       	call   80103744 <lapicw>
80103827:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
8010382a:	6a 00                	push   $0x0
8010382c:	68 a0 00 00 00       	push   $0xa0
80103831:	e8 0e ff ff ff       	call   80103744 <lapicw>
80103836:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103839:	6a 00                	push   $0x0
8010383b:	6a 2c                	push   $0x2c
8010383d:	e8 02 ff ff ff       	call   80103744 <lapicw>
80103842:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103845:	6a 00                	push   $0x0
80103847:	68 c4 00 00 00       	push   $0xc4
8010384c:	e8 f3 fe ff ff       	call   80103744 <lapicw>
80103851:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103854:	68 00 85 08 00       	push   $0x88500
80103859:	68 c0 00 00 00       	push   $0xc0
8010385e:	e8 e1 fe ff ff       	call   80103744 <lapicw>
80103863:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80103866:	90                   	nop
80103867:	a1 5c 52 11 80       	mov    0x8011525c,%eax
8010386c:	05 00 03 00 00       	add    $0x300,%eax
80103871:	8b 00                	mov    (%eax),%eax
80103873:	25 00 10 00 00       	and    $0x1000,%eax
80103878:	85 c0                	test   %eax,%eax
8010387a:	75 eb                	jne    80103867 <lapicinit+0xfd>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010387c:	6a 00                	push   $0x0
8010387e:	6a 20                	push   $0x20
80103880:	e8 bf fe ff ff       	call   80103744 <lapicw>
80103885:	83 c4 08             	add    $0x8,%esp
80103888:	eb 01                	jmp    8010388b <lapicinit+0x121>
    return;
8010388a:	90                   	nop
}
8010388b:	c9                   	leave  
8010388c:	c3                   	ret    

8010388d <cpunum>:

int
cpunum(void)
{
8010388d:	f3 0f 1e fb          	endbr32 
80103891:	55                   	push   %ebp
80103892:	89 e5                	mov    %esp,%ebp
80103894:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103897:	e8 98 fe ff ff       	call   80103734 <readeflags>
8010389c:	25 00 02 00 00       	and    $0x200,%eax
801038a1:	85 c0                	test   %eax,%eax
801038a3:	74 26                	je     801038cb <cpunum+0x3e>
    static int n;
    if(n++ == 0)
801038a5:	a1 44 d6 10 80       	mov    0x8010d644,%eax
801038aa:	8d 50 01             	lea    0x1(%eax),%edx
801038ad:	89 15 44 d6 10 80    	mov    %edx,0x8010d644
801038b3:	85 c0                	test   %eax,%eax
801038b5:	75 14                	jne    801038cb <cpunum+0x3e>
      cprintf("cpu called from %x with interrupts enabled\n",
801038b7:	8b 45 04             	mov    0x4(%ebp),%eax
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	50                   	push   %eax
801038be:	68 8c a2 10 80       	push   $0x8010a28c
801038c3:	e8 16 cb ff ff       	call   801003de <cprintf>
801038c8:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
801038cb:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801038d0:	85 c0                	test   %eax,%eax
801038d2:	74 0f                	je     801038e3 <cpunum+0x56>
    return lapic[ID]>>24;
801038d4:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801038d9:	83 c0 20             	add    $0x20,%eax
801038dc:	8b 00                	mov    (%eax),%eax
801038de:	c1 e8 18             	shr    $0x18,%eax
801038e1:	eb 05                	jmp    801038e8 <cpunum+0x5b>
  return 0;
801038e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801038e8:	c9                   	leave  
801038e9:	c3                   	ret    

801038ea <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801038ea:	f3 0f 1e fb          	endbr32 
801038ee:	55                   	push   %ebp
801038ef:	89 e5                	mov    %esp,%ebp
  if(lapic)
801038f1:	a1 5c 52 11 80       	mov    0x8011525c,%eax
801038f6:	85 c0                	test   %eax,%eax
801038f8:	74 0c                	je     80103906 <lapiceoi+0x1c>
    lapicw(EOI, 0);
801038fa:	6a 00                	push   $0x0
801038fc:	6a 2c                	push   $0x2c
801038fe:	e8 41 fe ff ff       	call   80103744 <lapicw>
80103903:	83 c4 08             	add    $0x8,%esp
}
80103906:	90                   	nop
80103907:	c9                   	leave  
80103908:	c3                   	ret    

80103909 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103909:	f3 0f 1e fb          	endbr32 
8010390d:	55                   	push   %ebp
8010390e:	89 e5                	mov    %esp,%ebp
}
80103910:	90                   	nop
80103911:	5d                   	pop    %ebp
80103912:	c3                   	ret    

80103913 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103913:	f3 0f 1e fb          	endbr32 
80103917:	55                   	push   %ebp
80103918:	89 e5                	mov    %esp,%ebp
8010391a:	83 ec 14             	sub    $0x14,%esp
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103923:	6a 0f                	push   $0xf
80103925:	6a 70                	push   $0x70
80103927:	e8 e7 fd ff ff       	call   80103713 <outb>
8010392c:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010392f:	6a 0a                	push   $0xa
80103931:	6a 71                	push   $0x71
80103933:	e8 db fd ff ff       	call   80103713 <outb>
80103938:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010393b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103942:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103945:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010394a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010394d:	c1 e8 04             	shr    $0x4,%eax
80103950:	89 c2                	mov    %eax,%edx
80103952:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103955:	83 c0 02             	add    $0x2,%eax
80103958:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010395b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010395f:	c1 e0 18             	shl    $0x18,%eax
80103962:	50                   	push   %eax
80103963:	68 c4 00 00 00       	push   $0xc4
80103968:	e8 d7 fd ff ff       	call   80103744 <lapicw>
8010396d:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103970:	68 00 c5 00 00       	push   $0xc500
80103975:	68 c0 00 00 00       	push   $0xc0
8010397a:	e8 c5 fd ff ff       	call   80103744 <lapicw>
8010397f:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103982:	68 c8 00 00 00       	push   $0xc8
80103987:	e8 7d ff ff ff       	call   80103909 <microdelay>
8010398c:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010398f:	68 00 85 00 00       	push   $0x8500
80103994:	68 c0 00 00 00       	push   $0xc0
80103999:	e8 a6 fd ff ff       	call   80103744 <lapicw>
8010399e:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801039a1:	6a 64                	push   $0x64
801039a3:	e8 61 ff ff ff       	call   80103909 <microdelay>
801039a8:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801039ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039b2:	eb 3d                	jmp    801039f1 <lapicstartap+0xde>
    lapicw(ICRHI, apicid<<24);
801039b4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801039b8:	c1 e0 18             	shl    $0x18,%eax
801039bb:	50                   	push   %eax
801039bc:	68 c4 00 00 00       	push   $0xc4
801039c1:	e8 7e fd ff ff       	call   80103744 <lapicw>
801039c6:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801039c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801039cc:	c1 e8 0c             	shr    $0xc,%eax
801039cf:	80 cc 06             	or     $0x6,%ah
801039d2:	50                   	push   %eax
801039d3:	68 c0 00 00 00       	push   $0xc0
801039d8:	e8 67 fd ff ff       	call   80103744 <lapicw>
801039dd:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801039e0:	68 c8 00 00 00       	push   $0xc8
801039e5:	e8 1f ff ff ff       	call   80103909 <microdelay>
801039ea:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
801039ed:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801039f1:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801039f5:	7e bd                	jle    801039b4 <lapicstartap+0xa1>
  }
}
801039f7:	90                   	nop
801039f8:	90                   	nop
801039f9:	c9                   	leave  
801039fa:	c3                   	ret    

801039fb <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801039fb:	f3 0f 1e fb          	endbr32 
801039ff:	55                   	push   %ebp
80103a00:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103a02:	8b 45 08             	mov    0x8(%ebp),%eax
80103a05:	0f b6 c0             	movzbl %al,%eax
80103a08:	50                   	push   %eax
80103a09:	6a 70                	push   $0x70
80103a0b:	e8 03 fd ff ff       	call   80103713 <outb>
80103a10:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103a13:	68 c8 00 00 00       	push   $0xc8
80103a18:	e8 ec fe ff ff       	call   80103909 <microdelay>
80103a1d:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80103a20:	6a 71                	push   $0x71
80103a22:	e8 cf fc ff ff       	call   801036f6 <inb>
80103a27:	83 c4 04             	add    $0x4,%esp
80103a2a:	0f b6 c0             	movzbl %al,%eax
}
80103a2d:	c9                   	leave  
80103a2e:	c3                   	ret    

80103a2f <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103a2f:	f3 0f 1e fb          	endbr32 
80103a33:	55                   	push   %ebp
80103a34:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80103a36:	6a 00                	push   $0x0
80103a38:	e8 be ff ff ff       	call   801039fb <cmos_read>
80103a3d:	83 c4 04             	add    $0x4,%esp
80103a40:	8b 55 08             	mov    0x8(%ebp),%edx
80103a43:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103a45:	6a 02                	push   $0x2
80103a47:	e8 af ff ff ff       	call   801039fb <cmos_read>
80103a4c:	83 c4 04             	add    $0x4,%esp
80103a4f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a52:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103a55:	6a 04                	push   $0x4
80103a57:	e8 9f ff ff ff       	call   801039fb <cmos_read>
80103a5c:	83 c4 04             	add    $0x4,%esp
80103a5f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a62:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103a65:	6a 07                	push   $0x7
80103a67:	e8 8f ff ff ff       	call   801039fb <cmos_read>
80103a6c:	83 c4 04             	add    $0x4,%esp
80103a6f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a72:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103a75:	6a 08                	push   $0x8
80103a77:	e8 7f ff ff ff       	call   801039fb <cmos_read>
80103a7c:	83 c4 04             	add    $0x4,%esp
80103a7f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a82:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103a85:	6a 09                	push   $0x9
80103a87:	e8 6f ff ff ff       	call   801039fb <cmos_read>
80103a8c:	83 c4 04             	add    $0x4,%esp
80103a8f:	8b 55 08             	mov    0x8(%ebp),%edx
80103a92:	89 42 14             	mov    %eax,0x14(%edx)
}
80103a95:	90                   	nop
80103a96:	c9                   	leave  
80103a97:	c3                   	ret    

80103a98 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103a98:	f3 0f 1e fb          	endbr32 
80103a9c:	55                   	push   %ebp
80103a9d:	89 e5                	mov    %esp,%ebp
80103a9f:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103aa2:	6a 0b                	push   $0xb
80103aa4:	e8 52 ff ff ff       	call   801039fb <cmos_read>
80103aa9:	83 c4 04             	add    $0x4,%esp
80103aac:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab2:	83 e0 04             	and    $0x4,%eax
80103ab5:	85 c0                	test   %eax,%eax
80103ab7:	0f 94 c0             	sete   %al
80103aba:	0f b6 c0             	movzbl %al,%eax
80103abd:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103ac0:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103ac3:	50                   	push   %eax
80103ac4:	e8 66 ff ff ff       	call   80103a2f <fill_rtcdate>
80103ac9:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103acc:	6a 0a                	push   $0xa
80103ace:	e8 28 ff ff ff       	call   801039fb <cmos_read>
80103ad3:	83 c4 04             	add    $0x4,%esp
80103ad6:	25 80 00 00 00       	and    $0x80,%eax
80103adb:	85 c0                	test   %eax,%eax
80103add:	75 27                	jne    80103b06 <cmostime+0x6e>
        continue;
    fill_rtcdate(&t2);
80103adf:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103ae2:	50                   	push   %eax
80103ae3:	e8 47 ff ff ff       	call   80103a2f <fill_rtcdate>
80103ae8:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103aeb:	83 ec 04             	sub    $0x4,%esp
80103aee:	6a 18                	push   $0x18
80103af0:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103af3:	50                   	push   %eax
80103af4:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103af7:	50                   	push   %eax
80103af8:	e8 0e 26 00 00       	call   8010610b <memcmp>
80103afd:	83 c4 10             	add    $0x10,%esp
80103b00:	85 c0                	test   %eax,%eax
80103b02:	74 05                	je     80103b09 <cmostime+0x71>
80103b04:	eb ba                	jmp    80103ac0 <cmostime+0x28>
        continue;
80103b06:	90                   	nop
    fill_rtcdate(&t1);
80103b07:	eb b7                	jmp    80103ac0 <cmostime+0x28>
      break;
80103b09:	90                   	nop
  }

  // convert
  if (bcd) {
80103b0a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b0e:	0f 84 b4 00 00 00    	je     80103bc8 <cmostime+0x130>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103b14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103b17:	c1 e8 04             	shr    $0x4,%eax
80103b1a:	89 c2                	mov    %eax,%edx
80103b1c:	89 d0                	mov    %edx,%eax
80103b1e:	c1 e0 02             	shl    $0x2,%eax
80103b21:	01 d0                	add    %edx,%eax
80103b23:	01 c0                	add    %eax,%eax
80103b25:	89 c2                	mov    %eax,%edx
80103b27:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103b2a:	83 e0 0f             	and    $0xf,%eax
80103b2d:	01 d0                	add    %edx,%eax
80103b2f:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103b32:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103b35:	c1 e8 04             	shr    $0x4,%eax
80103b38:	89 c2                	mov    %eax,%edx
80103b3a:	89 d0                	mov    %edx,%eax
80103b3c:	c1 e0 02             	shl    $0x2,%eax
80103b3f:	01 d0                	add    %edx,%eax
80103b41:	01 c0                	add    %eax,%eax
80103b43:	89 c2                	mov    %eax,%edx
80103b45:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103b48:	83 e0 0f             	and    $0xf,%eax
80103b4b:	01 d0                	add    %edx,%eax
80103b4d:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103b53:	c1 e8 04             	shr    $0x4,%eax
80103b56:	89 c2                	mov    %eax,%edx
80103b58:	89 d0                	mov    %edx,%eax
80103b5a:	c1 e0 02             	shl    $0x2,%eax
80103b5d:	01 d0                	add    %edx,%eax
80103b5f:	01 c0                	add    %eax,%eax
80103b61:	89 c2                	mov    %eax,%edx
80103b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103b66:	83 e0 0f             	and    $0xf,%eax
80103b69:	01 d0                	add    %edx,%eax
80103b6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80103b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103b71:	c1 e8 04             	shr    $0x4,%eax
80103b74:	89 c2                	mov    %eax,%edx
80103b76:	89 d0                	mov    %edx,%eax
80103b78:	c1 e0 02             	shl    $0x2,%eax
80103b7b:	01 d0                	add    %edx,%eax
80103b7d:	01 c0                	add    %eax,%eax
80103b7f:	89 c2                	mov    %eax,%edx
80103b81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103b84:	83 e0 0f             	and    $0xf,%eax
80103b87:	01 d0                	add    %edx,%eax
80103b89:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103b8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103b8f:	c1 e8 04             	shr    $0x4,%eax
80103b92:	89 c2                	mov    %eax,%edx
80103b94:	89 d0                	mov    %edx,%eax
80103b96:	c1 e0 02             	shl    $0x2,%eax
80103b99:	01 d0                	add    %edx,%eax
80103b9b:	01 c0                	add    %eax,%eax
80103b9d:	89 c2                	mov    %eax,%edx
80103b9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103ba2:	83 e0 0f             	and    $0xf,%eax
80103ba5:	01 d0                	add    %edx,%eax
80103ba7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103baa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bad:	c1 e8 04             	shr    $0x4,%eax
80103bb0:	89 c2                	mov    %eax,%edx
80103bb2:	89 d0                	mov    %edx,%eax
80103bb4:	c1 e0 02             	shl    $0x2,%eax
80103bb7:	01 d0                	add    %edx,%eax
80103bb9:	01 c0                	add    %eax,%eax
80103bbb:	89 c2                	mov    %eax,%edx
80103bbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bc0:	83 e0 0f             	and    $0xf,%eax
80103bc3:	01 d0                	add    %edx,%eax
80103bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103bc8:	8b 45 08             	mov    0x8(%ebp),%eax
80103bcb:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103bce:	89 10                	mov    %edx,(%eax)
80103bd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103bd3:	89 50 04             	mov    %edx,0x4(%eax)
80103bd6:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103bd9:	89 50 08             	mov    %edx,0x8(%eax)
80103bdc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103bdf:	89 50 0c             	mov    %edx,0xc(%eax)
80103be2:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103be5:	89 50 10             	mov    %edx,0x10(%eax)
80103be8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103beb:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103bee:	8b 45 08             	mov    0x8(%ebp),%eax
80103bf1:	8b 40 14             	mov    0x14(%eax),%eax
80103bf4:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103bfa:	8b 45 08             	mov    0x8(%ebp),%eax
80103bfd:	89 50 14             	mov    %edx,0x14(%eax)
}
80103c00:	90                   	nop
80103c01:	c9                   	leave  
80103c02:	c3                   	ret    

80103c03 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103c03:	f3 0f 1e fb          	endbr32 
80103c07:	55                   	push   %ebp
80103c08:	89 e5                	mov    %esp,%ebp
80103c0a:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103c0d:	83 ec 08             	sub    $0x8,%esp
80103c10:	68 b8 a2 10 80       	push   $0x8010a2b8
80103c15:	68 60 52 11 80       	push   $0x80115260
80103c1a:	e8 df 21 00 00       	call   80105dfe <initlock>
80103c1f:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103c22:	83 ec 08             	sub    $0x8,%esp
80103c25:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c28:	50                   	push   %eax
80103c29:	ff 75 08             	pushl  0x8(%ebp)
80103c2c:	e8 d6 d7 ff ff       	call   80101407 <readsb>
80103c31:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103c34:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c37:	a3 94 52 11 80       	mov    %eax,0x80115294
  log.size = sb.nlog;
80103c3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103c3f:	a3 98 52 11 80       	mov    %eax,0x80115298
  log.dev = dev;
80103c44:	8b 45 08             	mov    0x8(%ebp),%eax
80103c47:	a3 a4 52 11 80       	mov    %eax,0x801152a4
  recover_from_log();
80103c4c:	e8 bf 01 00 00       	call   80103e10 <recover_from_log>
}
80103c51:	90                   	nop
80103c52:	c9                   	leave  
80103c53:	c3                   	ret    

80103c54 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103c54:	f3 0f 1e fb          	endbr32 
80103c58:	55                   	push   %ebp
80103c59:	89 e5                	mov    %esp,%ebp
80103c5b:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103c5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103c65:	e9 95 00 00 00       	jmp    80103cff <install_trans+0xab>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103c6a:	8b 15 94 52 11 80    	mov    0x80115294,%edx
80103c70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c73:	01 d0                	add    %edx,%eax
80103c75:	83 c0 01             	add    $0x1,%eax
80103c78:	89 c2                	mov    %eax,%edx
80103c7a:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103c7f:	83 ec 08             	sub    $0x8,%esp
80103c82:	52                   	push   %edx
80103c83:	50                   	push   %eax
80103c84:	e8 36 c5 ff ff       	call   801001bf <bread>
80103c89:	83 c4 10             	add    $0x10,%esp
80103c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c92:	83 c0 10             	add    $0x10,%eax
80103c95:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103c9c:	89 c2                	mov    %eax,%edx
80103c9e:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103ca3:	83 ec 08             	sub    $0x8,%esp
80103ca6:	52                   	push   %edx
80103ca7:	50                   	push   %eax
80103ca8:	e8 12 c5 ff ff       	call   801001bf <bread>
80103cad:	83 c4 10             	add    $0x10,%esp
80103cb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb6:	8d 50 18             	lea    0x18(%eax),%edx
80103cb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cbc:	83 c0 18             	add    $0x18,%eax
80103cbf:	83 ec 04             	sub    $0x4,%esp
80103cc2:	68 00 02 00 00       	push   $0x200
80103cc7:	52                   	push   %edx
80103cc8:	50                   	push   %eax
80103cc9:	e8 99 24 00 00       	call   80106167 <memmove>
80103cce:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80103cd1:	83 ec 0c             	sub    $0xc,%esp
80103cd4:	ff 75 ec             	pushl  -0x14(%ebp)
80103cd7:	e8 20 c5 ff ff       	call   801001fc <bwrite>
80103cdc:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
80103cdf:	83 ec 0c             	sub    $0xc,%esp
80103ce2:	ff 75 f0             	pushl  -0x10(%ebp)
80103ce5:	e8 55 c5 ff ff       	call   8010023f <brelse>
80103cea:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103ced:	83 ec 0c             	sub    $0xc,%esp
80103cf0:	ff 75 ec             	pushl  -0x14(%ebp)
80103cf3:	e8 47 c5 ff ff       	call   8010023f <brelse>
80103cf8:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103cfb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103cff:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103d04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103d07:	0f 8c 5d ff ff ff    	jl     80103c6a <install_trans+0x16>
  }
}
80103d0d:	90                   	nop
80103d0e:	90                   	nop
80103d0f:	c9                   	leave  
80103d10:	c3                   	ret    

80103d11 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103d11:	f3 0f 1e fb          	endbr32 
80103d15:	55                   	push   %ebp
80103d16:	89 e5                	mov    %esp,%ebp
80103d18:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103d1b:	a1 94 52 11 80       	mov    0x80115294,%eax
80103d20:	89 c2                	mov    %eax,%edx
80103d22:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103d27:	83 ec 08             	sub    $0x8,%esp
80103d2a:	52                   	push   %edx
80103d2b:	50                   	push   %eax
80103d2c:	e8 8e c4 ff ff       	call   801001bf <bread>
80103d31:	83 c4 10             	add    $0x10,%esp
80103d34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3a:	83 c0 18             	add    $0x18,%eax
80103d3d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103d40:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d43:	8b 00                	mov    (%eax),%eax
80103d45:	a3 a8 52 11 80       	mov    %eax,0x801152a8
  for (i = 0; i < log.lh.n; i++) {
80103d4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103d51:	eb 1b                	jmp    80103d6e <read_head+0x5d>
    log.lh.block[i] = lh->block[i];
80103d53:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d56:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d59:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103d5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d60:	83 c2 10             	add    $0x10,%edx
80103d63:	89 04 95 6c 52 11 80 	mov    %eax,-0x7feead94(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103d6a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103d6e:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103d73:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103d76:	7c db                	jl     80103d53 <read_head+0x42>
  }
  brelse(buf);
80103d78:	83 ec 0c             	sub    $0xc,%esp
80103d7b:	ff 75 f0             	pushl  -0x10(%ebp)
80103d7e:	e8 bc c4 ff ff       	call   8010023f <brelse>
80103d83:	83 c4 10             	add    $0x10,%esp
}
80103d86:	90                   	nop
80103d87:	c9                   	leave  
80103d88:	c3                   	ret    

80103d89 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103d89:	f3 0f 1e fb          	endbr32 
80103d8d:	55                   	push   %ebp
80103d8e:	89 e5                	mov    %esp,%ebp
80103d90:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103d93:	a1 94 52 11 80       	mov    0x80115294,%eax
80103d98:	89 c2                	mov    %eax,%edx
80103d9a:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103d9f:	83 ec 08             	sub    $0x8,%esp
80103da2:	52                   	push   %edx
80103da3:	50                   	push   %eax
80103da4:	e8 16 c4 ff ff       	call   801001bf <bread>
80103da9:	83 c4 10             	add    $0x10,%esp
80103dac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103daf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db2:	83 c0 18             	add    $0x18,%eax
80103db5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103db8:	8b 15 a8 52 11 80    	mov    0x801152a8,%edx
80103dbe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dc1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103dc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103dca:	eb 1b                	jmp    80103de7 <write_head+0x5e>
    hb->block[i] = log.lh.block[i];
80103dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcf:	83 c0 10             	add    $0x10,%eax
80103dd2:	8b 0c 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%ecx
80103dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ddc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ddf:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103de3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103de7:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80103dec:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103def:	7c db                	jl     80103dcc <write_head+0x43>
  }
  bwrite(buf);
80103df1:	83 ec 0c             	sub    $0xc,%esp
80103df4:	ff 75 f0             	pushl  -0x10(%ebp)
80103df7:	e8 00 c4 ff ff       	call   801001fc <bwrite>
80103dfc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103dff:	83 ec 0c             	sub    $0xc,%esp
80103e02:	ff 75 f0             	pushl  -0x10(%ebp)
80103e05:	e8 35 c4 ff ff       	call   8010023f <brelse>
80103e0a:	83 c4 10             	add    $0x10,%esp
}
80103e0d:	90                   	nop
80103e0e:	c9                   	leave  
80103e0f:	c3                   	ret    

80103e10 <recover_from_log>:

static void
recover_from_log(void)
{
80103e10:	f3 0f 1e fb          	endbr32 
80103e14:	55                   	push   %ebp
80103e15:	89 e5                	mov    %esp,%ebp
80103e17:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103e1a:	e8 f2 fe ff ff       	call   80103d11 <read_head>
  install_trans(); // if committed, copy from log to disk
80103e1f:	e8 30 fe ff ff       	call   80103c54 <install_trans>
  log.lh.n = 0;
80103e24:	c7 05 a8 52 11 80 00 	movl   $0x0,0x801152a8
80103e2b:	00 00 00 
  write_head(); // clear the log
80103e2e:	e8 56 ff ff ff       	call   80103d89 <write_head>
}
80103e33:	90                   	nop
80103e34:	c9                   	leave  
80103e35:	c3                   	ret    

80103e36 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103e36:	f3 0f 1e fb          	endbr32 
80103e3a:	55                   	push   %ebp
80103e3b:	89 e5                	mov    %esp,%ebp
80103e3d:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103e40:	83 ec 0c             	sub    $0xc,%esp
80103e43:	68 60 52 11 80       	push   $0x80115260
80103e48:	e8 d7 1f 00 00       	call   80105e24 <acquire>
80103e4d:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103e50:	a1 a0 52 11 80       	mov    0x801152a0,%eax
80103e55:	85 c0                	test   %eax,%eax
80103e57:	74 17                	je     80103e70 <begin_op+0x3a>
      sleep(&log, &log.lock);
80103e59:	83 ec 08             	sub    $0x8,%esp
80103e5c:	68 60 52 11 80       	push   $0x80115260
80103e61:	68 60 52 11 80       	push   $0x80115260
80103e66:	e8 8a 1a 00 00       	call   801058f5 <sleep>
80103e6b:	83 c4 10             	add    $0x10,%esp
80103e6e:	eb e0                	jmp    80103e50 <begin_op+0x1a>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103e70:	8b 0d a8 52 11 80    	mov    0x801152a8,%ecx
80103e76:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103e7b:	8d 50 01             	lea    0x1(%eax),%edx
80103e7e:	89 d0                	mov    %edx,%eax
80103e80:	c1 e0 02             	shl    $0x2,%eax
80103e83:	01 d0                	add    %edx,%eax
80103e85:	01 c0                	add    %eax,%eax
80103e87:	01 c8                	add    %ecx,%eax
80103e89:	83 f8 1e             	cmp    $0x1e,%eax
80103e8c:	7e 17                	jle    80103ea5 <begin_op+0x6f>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103e8e:	83 ec 08             	sub    $0x8,%esp
80103e91:	68 60 52 11 80       	push   $0x80115260
80103e96:	68 60 52 11 80       	push   $0x80115260
80103e9b:	e8 55 1a 00 00       	call   801058f5 <sleep>
80103ea0:	83 c4 10             	add    $0x10,%esp
80103ea3:	eb ab                	jmp    80103e50 <begin_op+0x1a>
    } else {
      log.outstanding += 1;
80103ea5:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103eaa:	83 c0 01             	add    $0x1,%eax
80103ead:	a3 9c 52 11 80       	mov    %eax,0x8011529c
      release(&log.lock);
80103eb2:	83 ec 0c             	sub    $0xc,%esp
80103eb5:	68 60 52 11 80       	push   $0x80115260
80103eba:	e8 d0 1f 00 00       	call   80105e8f <release>
80103ebf:	83 c4 10             	add    $0x10,%esp
      break;
80103ec2:	90                   	nop
    }
  }
}
80103ec3:	90                   	nop
80103ec4:	c9                   	leave  
80103ec5:	c3                   	ret    

80103ec6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103ec6:	f3 0f 1e fb          	endbr32 
80103eca:	55                   	push   %ebp
80103ecb:	89 e5                	mov    %esp,%ebp
80103ecd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103ed0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103ed7:	83 ec 0c             	sub    $0xc,%esp
80103eda:	68 60 52 11 80       	push   $0x80115260
80103edf:	e8 40 1f 00 00       	call   80105e24 <acquire>
80103ee4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80103ee7:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103eec:	83 e8 01             	sub    $0x1,%eax
80103eef:	a3 9c 52 11 80       	mov    %eax,0x8011529c
  if(log.committing)
80103ef4:	a1 a0 52 11 80       	mov    0x801152a0,%eax
80103ef9:	85 c0                	test   %eax,%eax
80103efb:	74 0d                	je     80103f0a <end_op+0x44>
    panic("log.committing");
80103efd:	83 ec 0c             	sub    $0xc,%esp
80103f00:	68 bc a2 10 80       	push   $0x8010a2bc
80103f05:	e8 8d c6 ff ff       	call   80100597 <panic>
  if(log.outstanding == 0){
80103f0a:	a1 9c 52 11 80       	mov    0x8011529c,%eax
80103f0f:	85 c0                	test   %eax,%eax
80103f11:	75 13                	jne    80103f26 <end_op+0x60>
    do_commit = 1;
80103f13:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103f1a:	c7 05 a0 52 11 80 01 	movl   $0x1,0x801152a0
80103f21:	00 00 00 
80103f24:	eb 10                	jmp    80103f36 <end_op+0x70>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
80103f26:	83 ec 0c             	sub    $0xc,%esp
80103f29:	68 60 52 11 80       	push   $0x80115260
80103f2e:	e8 b9 1a 00 00       	call   801059ec <wakeup>
80103f33:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103f36:	83 ec 0c             	sub    $0xc,%esp
80103f39:	68 60 52 11 80       	push   $0x80115260
80103f3e:	e8 4c 1f 00 00       	call   80105e8f <release>
80103f43:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103f46:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f4a:	74 3f                	je     80103f8b <end_op+0xc5>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103f4c:	e8 fa 00 00 00       	call   8010404b <commit>
    acquire(&log.lock);
80103f51:	83 ec 0c             	sub    $0xc,%esp
80103f54:	68 60 52 11 80       	push   $0x80115260
80103f59:	e8 c6 1e 00 00       	call   80105e24 <acquire>
80103f5e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103f61:	c7 05 a0 52 11 80 00 	movl   $0x0,0x801152a0
80103f68:	00 00 00 
    wakeup(&log);
80103f6b:	83 ec 0c             	sub    $0xc,%esp
80103f6e:	68 60 52 11 80       	push   $0x80115260
80103f73:	e8 74 1a 00 00       	call   801059ec <wakeup>
80103f78:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103f7b:	83 ec 0c             	sub    $0xc,%esp
80103f7e:	68 60 52 11 80       	push   $0x80115260
80103f83:	e8 07 1f 00 00       	call   80105e8f <release>
80103f88:	83 c4 10             	add    $0x10,%esp
  }
}
80103f8b:	90                   	nop
80103f8c:	c9                   	leave  
80103f8d:	c3                   	ret    

80103f8e <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103f8e:	f3 0f 1e fb          	endbr32 
80103f92:	55                   	push   %ebp
80103f93:	89 e5                	mov    %esp,%ebp
80103f95:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103f98:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f9f:	e9 95 00 00 00       	jmp    80104039 <write_log+0xab>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103fa4:	8b 15 94 52 11 80    	mov    0x80115294,%edx
80103faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fad:	01 d0                	add    %edx,%eax
80103faf:	83 c0 01             	add    $0x1,%eax
80103fb2:	89 c2                	mov    %eax,%edx
80103fb4:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103fb9:	83 ec 08             	sub    $0x8,%esp
80103fbc:	52                   	push   %edx
80103fbd:	50                   	push   %eax
80103fbe:	e8 fc c1 ff ff       	call   801001bf <bread>
80103fc3:	83 c4 10             	add    $0x10,%esp
80103fc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fcc:	83 c0 10             	add    $0x10,%eax
80103fcf:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
80103fd6:	89 c2                	mov    %eax,%edx
80103fd8:	a1 a4 52 11 80       	mov    0x801152a4,%eax
80103fdd:	83 ec 08             	sub    $0x8,%esp
80103fe0:	52                   	push   %edx
80103fe1:	50                   	push   %eax
80103fe2:	e8 d8 c1 ff ff       	call   801001bf <bread>
80103fe7:	83 c4 10             	add    $0x10,%esp
80103fea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103fed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ff0:	8d 50 18             	lea    0x18(%eax),%edx
80103ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ff6:	83 c0 18             	add    $0x18,%eax
80103ff9:	83 ec 04             	sub    $0x4,%esp
80103ffc:	68 00 02 00 00       	push   $0x200
80104001:	52                   	push   %edx
80104002:	50                   	push   %eax
80104003:	e8 5f 21 00 00       	call   80106167 <memmove>
80104008:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010400b:	83 ec 0c             	sub    $0xc,%esp
8010400e:	ff 75 f0             	pushl  -0x10(%ebp)
80104011:	e8 e6 c1 ff ff       	call   801001fc <bwrite>
80104016:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80104019:	83 ec 0c             	sub    $0xc,%esp
8010401c:	ff 75 ec             	pushl  -0x14(%ebp)
8010401f:	e8 1b c2 ff ff       	call   8010023f <brelse>
80104024:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80104027:	83 ec 0c             	sub    $0xc,%esp
8010402a:	ff 75 f0             	pushl  -0x10(%ebp)
8010402d:	e8 0d c2 ff ff       	call   8010023f <brelse>
80104032:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80104035:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104039:	a1 a8 52 11 80       	mov    0x801152a8,%eax
8010403e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104041:	0f 8c 5d ff ff ff    	jl     80103fa4 <write_log+0x16>
  }
}
80104047:	90                   	nop
80104048:	90                   	nop
80104049:	c9                   	leave  
8010404a:	c3                   	ret    

8010404b <commit>:

static void
commit()
{
8010404b:	f3 0f 1e fb          	endbr32 
8010404f:	55                   	push   %ebp
80104050:	89 e5                	mov    %esp,%ebp
80104052:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80104055:	a1 a8 52 11 80       	mov    0x801152a8,%eax
8010405a:	85 c0                	test   %eax,%eax
8010405c:	7e 1e                	jle    8010407c <commit+0x31>
    write_log();     // Write modified blocks from cache to log
8010405e:	e8 2b ff ff ff       	call   80103f8e <write_log>
    write_head();    // Write header to disk -- the real commit
80104063:	e8 21 fd ff ff       	call   80103d89 <write_head>
    install_trans(); // Now install writes to home locations
80104068:	e8 e7 fb ff ff       	call   80103c54 <install_trans>
    log.lh.n = 0; 
8010406d:	c7 05 a8 52 11 80 00 	movl   $0x0,0x801152a8
80104074:	00 00 00 
    write_head();    // Erase the transaction from the log
80104077:	e8 0d fd ff ff       	call   80103d89 <write_head>
  }
}
8010407c:	90                   	nop
8010407d:	c9                   	leave  
8010407e:	c3                   	ret    

8010407f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010407f:	f3 0f 1e fb          	endbr32 
80104083:	55                   	push   %ebp
80104084:	89 e5                	mov    %esp,%ebp
80104086:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80104089:	a1 a8 52 11 80       	mov    0x801152a8,%eax
8010408e:	83 f8 1d             	cmp    $0x1d,%eax
80104091:	7f 12                	jg     801040a5 <log_write+0x26>
80104093:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80104098:	8b 15 98 52 11 80    	mov    0x80115298,%edx
8010409e:	83 ea 01             	sub    $0x1,%edx
801040a1:	39 d0                	cmp    %edx,%eax
801040a3:	7c 0d                	jl     801040b2 <log_write+0x33>
    panic("too big a transaction");
801040a5:	83 ec 0c             	sub    $0xc,%esp
801040a8:	68 cb a2 10 80       	push   $0x8010a2cb
801040ad:	e8 e5 c4 ff ff       	call   80100597 <panic>
  if (log.outstanding < 1)
801040b2:	a1 9c 52 11 80       	mov    0x8011529c,%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	7f 0d                	jg     801040c8 <log_write+0x49>
    panic("log_write outside of trans");
801040bb:	83 ec 0c             	sub    $0xc,%esp
801040be:	68 e1 a2 10 80       	push   $0x8010a2e1
801040c3:	e8 cf c4 ff ff       	call   80100597 <panic>

  acquire(&log.lock);
801040c8:	83 ec 0c             	sub    $0xc,%esp
801040cb:	68 60 52 11 80       	push   $0x80115260
801040d0:	e8 4f 1d 00 00       	call   80105e24 <acquire>
801040d5:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801040d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040df:	eb 1d                	jmp    801040fe <log_write+0x7f>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801040e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e4:	83 c0 10             	add    $0x10,%eax
801040e7:	8b 04 85 6c 52 11 80 	mov    -0x7feead94(,%eax,4),%eax
801040ee:	89 c2                	mov    %eax,%edx
801040f0:	8b 45 08             	mov    0x8(%ebp),%eax
801040f3:	8b 40 08             	mov    0x8(%eax),%eax
801040f6:	39 c2                	cmp    %eax,%edx
801040f8:	74 10                	je     8010410a <log_write+0x8b>
  for (i = 0; i < log.lh.n; i++) {
801040fa:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801040fe:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80104103:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104106:	7c d9                	jl     801040e1 <log_write+0x62>
80104108:	eb 01                	jmp    8010410b <log_write+0x8c>
      break;
8010410a:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 40 08             	mov    0x8(%eax),%eax
80104111:	89 c2                	mov    %eax,%edx
80104113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104116:	83 c0 10             	add    $0x10,%eax
80104119:	89 14 85 6c 52 11 80 	mov    %edx,-0x7feead94(,%eax,4)
  if (i == log.lh.n)
80104120:	a1 a8 52 11 80       	mov    0x801152a8,%eax
80104125:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104128:	75 0d                	jne    80104137 <log_write+0xb8>
    log.lh.n++;
8010412a:	a1 a8 52 11 80       	mov    0x801152a8,%eax
8010412f:	83 c0 01             	add    $0x1,%eax
80104132:	a3 a8 52 11 80       	mov    %eax,0x801152a8
  b->flags |= B_DIRTY; // prevent eviction
80104137:	8b 45 08             	mov    0x8(%ebp),%eax
8010413a:	8b 00                	mov    (%eax),%eax
8010413c:	83 c8 04             	or     $0x4,%eax
8010413f:	89 c2                	mov    %eax,%edx
80104141:	8b 45 08             	mov    0x8(%ebp),%eax
80104144:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80104146:	83 ec 0c             	sub    $0xc,%esp
80104149:	68 60 52 11 80       	push   $0x80115260
8010414e:	e8 3c 1d 00 00       	call   80105e8f <release>
80104153:	83 c4 10             	add    $0x10,%esp
}
80104156:	90                   	nop
80104157:	c9                   	leave  
80104158:	c3                   	ret    

80104159 <v2p>:
80104159:	55                   	push   %ebp
8010415a:	89 e5                	mov    %esp,%ebp
8010415c:	8b 45 08             	mov    0x8(%ebp),%eax
8010415f:	05 00 00 00 80       	add    $0x80000000,%eax
80104164:	5d                   	pop    %ebp
80104165:	c3                   	ret    

80104166 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80104166:	55                   	push   %ebp
80104167:	89 e5                	mov    %esp,%ebp
80104169:	8b 45 08             	mov    0x8(%ebp),%eax
8010416c:	05 00 00 00 80       	add    $0x80000000,%eax
80104171:	5d                   	pop    %ebp
80104172:	c3                   	ret    

80104173 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80104173:	55                   	push   %ebp
80104174:	89 e5                	mov    %esp,%ebp
80104176:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80104179:	8b 55 08             	mov    0x8(%ebp),%edx
8010417c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010417f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104182:	f0 87 02             	lock xchg %eax,(%edx)
80104185:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80104188:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010418b:	c9                   	leave  
8010418c:	c3                   	ret    

8010418d <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010418d:	f3 0f 1e fb          	endbr32 
80104191:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80104195:	83 e4 f0             	and    $0xfffffff0,%esp
80104198:	ff 71 fc             	pushl  -0x4(%ecx)
8010419b:	55                   	push   %ebp
8010419c:	89 e5                	mov    %esp,%ebp
8010419e:	51                   	push   %ecx
8010419f:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801041a2:	83 ec 08             	sub    $0x8,%esp
801041a5:	68 00 00 40 80       	push   $0x80400000
801041aa:	68 3c 1c 12 80       	push   $0x80121c3c
801041af:	e8 fa f1 ff ff       	call   801033ae <kinit1>
801041b4:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801041b7:	e8 7b 4b 00 00       	call   80108d37 <kvmalloc>
  mpinit();        // collect info about this machine
801041bc:	e8 5a 04 00 00       	call   8010461b <mpinit>
  lapicinit();
801041c1:	e8 a4 f5 ff ff       	call   8010376a <lapicinit>
  seginit();       // set up segments
801041c6:	e8 05 45 00 00       	call   801086d0 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801041cb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801041d1:	0f b6 00             	movzbl (%eax),%eax
801041d4:	0f b6 c0             	movzbl %al,%eax
801041d7:	83 ec 08             	sub    $0x8,%esp
801041da:	50                   	push   %eax
801041db:	68 fc a2 10 80       	push   $0x8010a2fc
801041e0:	e8 f9 c1 ff ff       	call   801003de <cprintf>
801041e5:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801041e8:	e8 b6 06 00 00       	call   801048a3 <picinit>
  ioapicinit();    // another interrupt controller
801041ed:	e8 79 f0 ff ff       	call   8010326b <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801041f2:	e8 81 c9 ff ff       	call   80100b78 <consoleinit>
  uartinit();      // serial port
801041f7:	e8 20 38 00 00       	call   80107a1c <uartinit>
  pinit();         // process table
801041fc:	e8 b3 0b 00 00       	call   80104db4 <pinit>
  tvinit();        // trap vectors
80104201:	e8 74 33 00 00       	call   8010757a <tvinit>
  binit();         // buffer cache
80104206:	e8 29 be ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010420b:	e8 cc cd ff ff       	call   80100fdc <fileinit>
  ideinit();       // disk
80104210:	e8 46 ec ff ff       	call   80102e5b <ideinit>
  if(!ismp)
80104215:	a1 44 53 11 80       	mov    0x80115344,%eax
8010421a:	85 c0                	test   %eax,%eax
8010421c:	75 05                	jne    80104223 <main+0x96>
    timerinit();   // uniprocessor timer
8010421e:	e8 b0 32 00 00       	call   801074d3 <timerinit>
  startothers();   // start other processors
80104223:	e8 87 00 00 00       	call   801042af <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80104228:	83 ec 08             	sub    $0x8,%esp
8010422b:	68 00 00 00 8e       	push   $0x8e000000
80104230:	68 00 00 40 80       	push   $0x80400000
80104235:	e8 b1 f1 ff ff       	call   801033eb <kinit2>
8010423a:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
8010423d:	e8 21 0d 00 00       	call   80104f63 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80104242:	e8 1e 00 00 00       	call   80104265 <mpmain>

80104247 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80104247:	f3 0f 1e fb          	endbr32 
8010424b:	55                   	push   %ebp
8010424c:	89 e5                	mov    %esp,%ebp
8010424e:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80104251:	e8 fd 4a 00 00       	call   80108d53 <switchkvm>
  seginit();
80104256:	e8 75 44 00 00       	call   801086d0 <seginit>
  lapicinit();
8010425b:	e8 0a f5 ff ff       	call   8010376a <lapicinit>
  mpmain();
80104260:	e8 00 00 00 00       	call   80104265 <mpmain>

80104265 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80104265:	f3 0f 1e fb          	endbr32 
80104269:	55                   	push   %ebp
8010426a:	89 e5                	mov    %esp,%ebp
8010426c:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010426f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104275:	0f b6 00             	movzbl (%eax),%eax
80104278:	0f b6 c0             	movzbl %al,%eax
8010427b:	83 ec 08             	sub    $0x8,%esp
8010427e:	50                   	push   %eax
8010427f:	68 13 a3 10 80       	push   $0x8010a313
80104284:	e8 55 c1 ff ff       	call   801003de <cprintf>
80104289:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010428c:	e8 63 34 00 00       	call   801076f4 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80104291:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104297:	05 a8 00 00 00       	add    $0xa8,%eax
8010429c:	83 ec 08             	sub    $0x8,%esp
8010429f:	6a 01                	push   $0x1
801042a1:	50                   	push   %eax
801042a2:	e8 cc fe ff ff       	call   80104173 <xchg>
801042a7:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801042aa:	e8 51 14 00 00       	call   80105700 <scheduler>

801042af <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801042af:	f3 0f 1e fb          	endbr32 
801042b3:	55                   	push   %ebp
801042b4:	89 e5                	mov    %esp,%ebp
801042b6:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801042b9:	68 00 70 00 00       	push   $0x7000
801042be:	e8 a3 fe ff ff       	call   80104166 <p2v>
801042c3:	83 c4 04             	add    $0x4,%esp
801042c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801042c9:	b8 8a 00 00 00       	mov    $0x8a,%eax
801042ce:	83 ec 04             	sub    $0x4,%esp
801042d1:	50                   	push   %eax
801042d2:	68 0c d5 10 80       	push   $0x8010d50c
801042d7:	ff 75 f0             	pushl  -0x10(%ebp)
801042da:	e8 88 1e 00 00       	call   80106167 <memmove>
801042df:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801042e2:	c7 45 f4 60 53 11 80 	movl   $0x80115360,-0xc(%ebp)
801042e9:	e9 8e 00 00 00       	jmp    8010437c <startothers+0xcd>
    if(c == cpus+cpunum())  // We've started already.
801042ee:	e8 9a f5 ff ff       	call   8010388d <cpunum>
801042f3:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801042f9:	05 60 53 11 80       	add    $0x80115360,%eax
801042fe:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104301:	74 71                	je     80104374 <startothers+0xc5>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80104303:	e8 fb f1 ff ff       	call   80103503 <kalloc>
80104308:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010430b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010430e:	83 e8 04             	sub    $0x4,%eax
80104311:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104314:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010431a:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010431c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010431f:	83 e8 08             	sub    $0x8,%eax
80104322:	c7 00 47 42 10 80    	movl   $0x80104247,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80104328:	83 ec 0c             	sub    $0xc,%esp
8010432b:	68 00 c0 10 80       	push   $0x8010c000
80104330:	e8 24 fe ff ff       	call   80104159 <v2p>
80104335:	83 c4 10             	add    $0x10,%esp
80104338:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010433b:	83 ea 0c             	sub    $0xc,%edx
8010433e:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->id, v2p(code));
80104340:	83 ec 0c             	sub    $0xc,%esp
80104343:	ff 75 f0             	pushl  -0x10(%ebp)
80104346:	e8 0e fe ff ff       	call   80104159 <v2p>
8010434b:	83 c4 10             	add    $0x10,%esp
8010434e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104351:	0f b6 12             	movzbl (%edx),%edx
80104354:	0f b6 d2             	movzbl %dl,%edx
80104357:	83 ec 08             	sub    $0x8,%esp
8010435a:	50                   	push   %eax
8010435b:	52                   	push   %edx
8010435c:	e8 b2 f5 ff ff       	call   80103913 <lapicstartap>
80104361:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80104364:	90                   	nop
80104365:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104368:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010436e:	85 c0                	test   %eax,%eax
80104370:	74 f3                	je     80104365 <startothers+0xb6>
80104372:	eb 01                	jmp    80104375 <startothers+0xc6>
      continue;
80104374:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80104375:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
8010437c:	a1 40 59 11 80       	mov    0x80115940,%eax
80104381:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80104387:	05 60 53 11 80       	add    $0x80115360,%eax
8010438c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010438f:	0f 82 59 ff ff ff    	jb     801042ee <startothers+0x3f>
      ;
  }
}
80104395:	90                   	nop
80104396:	90                   	nop
80104397:	c9                   	leave  
80104398:	c3                   	ret    

80104399 <p2v>:
80104399:	55                   	push   %ebp
8010439a:	89 e5                	mov    %esp,%ebp
8010439c:	8b 45 08             	mov    0x8(%ebp),%eax
8010439f:	05 00 00 00 80       	add    $0x80000000,%eax
801043a4:	5d                   	pop    %ebp
801043a5:	c3                   	ret    

801043a6 <inb>:
{
801043a6:	55                   	push   %ebp
801043a7:	89 e5                	mov    %esp,%ebp
801043a9:	83 ec 14             	sub    $0x14,%esp
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801043b3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801043b7:	89 c2                	mov    %eax,%edx
801043b9:	ec                   	in     (%dx),%al
801043ba:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801043bd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801043c1:	c9                   	leave  
801043c2:	c3                   	ret    

801043c3 <outb>:
{
801043c3:	55                   	push   %ebp
801043c4:	89 e5                	mov    %esp,%ebp
801043c6:	83 ec 08             	sub    $0x8,%esp
801043c9:	8b 45 08             	mov    0x8(%ebp),%eax
801043cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801043cf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801043d3:	89 d0                	mov    %edx,%eax
801043d5:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801043d8:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801043dc:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801043e0:	ee                   	out    %al,(%dx)
}
801043e1:	90                   	nop
801043e2:	c9                   	leave  
801043e3:	c3                   	ret    

801043e4 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
801043e4:	f3 0f 1e fb          	endbr32 
801043e8:	55                   	push   %ebp
801043e9:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
801043eb:	a1 48 d6 10 80       	mov    0x8010d648,%eax
801043f0:	2d 60 53 11 80       	sub    $0x80115360,%eax
801043f5:	c1 f8 02             	sar    $0x2,%eax
801043f8:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
801043fe:	5d                   	pop    %ebp
801043ff:	c3                   	ret    

80104400 <sum>:

static uchar
sum(uchar *addr, int len)
{
80104400:	f3 0f 1e fb          	endbr32 
80104404:	55                   	push   %ebp
80104405:	89 e5                	mov    %esp,%ebp
80104407:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
8010440a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80104411:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104418:	eb 15                	jmp    8010442f <sum+0x2f>
    sum += addr[i];
8010441a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010441d:	8b 45 08             	mov    0x8(%ebp),%eax
80104420:	01 d0                	add    %edx,%eax
80104422:	0f b6 00             	movzbl (%eax),%eax
80104425:	0f b6 c0             	movzbl %al,%eax
80104428:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
8010442b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010442f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104432:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104435:	7c e3                	jl     8010441a <sum+0x1a>
  return sum;
80104437:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
8010443a:	c9                   	leave  
8010443b:	c3                   	ret    

8010443c <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
8010443c:	f3 0f 1e fb          	endbr32 
80104440:	55                   	push   %ebp
80104441:	89 e5                	mov    %esp,%ebp
80104443:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80104446:	ff 75 08             	pushl  0x8(%ebp)
80104449:	e8 4b ff ff ff       	call   80104399 <p2v>
8010444e:	83 c4 04             	add    $0x4,%esp
80104451:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80104454:	8b 55 0c             	mov    0xc(%ebp),%edx
80104457:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010445a:	01 d0                	add    %edx,%eax
8010445c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
8010445f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104462:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104465:	eb 36                	jmp    8010449d <mpsearch1+0x61>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80104467:	83 ec 04             	sub    $0x4,%esp
8010446a:	6a 04                	push   $0x4
8010446c:	68 24 a3 10 80       	push   $0x8010a324
80104471:	ff 75 f4             	pushl  -0xc(%ebp)
80104474:	e8 92 1c 00 00       	call   8010610b <memcmp>
80104479:	83 c4 10             	add    $0x10,%esp
8010447c:	85 c0                	test   %eax,%eax
8010447e:	75 19                	jne    80104499 <mpsearch1+0x5d>
80104480:	83 ec 08             	sub    $0x8,%esp
80104483:	6a 10                	push   $0x10
80104485:	ff 75 f4             	pushl  -0xc(%ebp)
80104488:	e8 73 ff ff ff       	call   80104400 <sum>
8010448d:	83 c4 10             	add    $0x10,%esp
80104490:	84 c0                	test   %al,%al
80104492:	75 05                	jne    80104499 <mpsearch1+0x5d>
      return (struct mp*)p;
80104494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104497:	eb 11                	jmp    801044aa <mpsearch1+0x6e>
  for(p = addr; p < e; p += sizeof(struct mp))
80104499:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010449d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801044a3:	72 c2                	jb     80104467 <mpsearch1+0x2b>
  return 0;
801044a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044aa:	c9                   	leave  
801044ab:	c3                   	ret    

801044ac <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
801044ac:	f3 0f 1e fb          	endbr32 
801044b0:	55                   	push   %ebp
801044b1:	89 e5                	mov    %esp,%ebp
801044b3:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
801044b6:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801044bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c0:	83 c0 0f             	add    $0xf,%eax
801044c3:	0f b6 00             	movzbl (%eax),%eax
801044c6:	0f b6 c0             	movzbl %al,%eax
801044c9:	c1 e0 08             	shl    $0x8,%eax
801044cc:	89 c2                	mov    %eax,%edx
801044ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d1:	83 c0 0e             	add    $0xe,%eax
801044d4:	0f b6 00             	movzbl (%eax),%eax
801044d7:	0f b6 c0             	movzbl %al,%eax
801044da:	09 d0                	or     %edx,%eax
801044dc:	c1 e0 04             	shl    $0x4,%eax
801044df:	89 45 f0             	mov    %eax,-0x10(%ebp)
801044e2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801044e6:	74 21                	je     80104509 <mpsearch+0x5d>
    if((mp = mpsearch1(p, 1024)))
801044e8:	83 ec 08             	sub    $0x8,%esp
801044eb:	68 00 04 00 00       	push   $0x400
801044f0:	ff 75 f0             	pushl  -0x10(%ebp)
801044f3:	e8 44 ff ff ff       	call   8010443c <mpsearch1>
801044f8:	83 c4 10             	add    $0x10,%esp
801044fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044fe:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104502:	74 51                	je     80104555 <mpsearch+0xa9>
      return mp;
80104504:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104507:	eb 61                	jmp    8010456a <mpsearch+0xbe>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450c:	83 c0 14             	add    $0x14,%eax
8010450f:	0f b6 00             	movzbl (%eax),%eax
80104512:	0f b6 c0             	movzbl %al,%eax
80104515:	c1 e0 08             	shl    $0x8,%eax
80104518:	89 c2                	mov    %eax,%edx
8010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451d:	83 c0 13             	add    $0x13,%eax
80104520:	0f b6 00             	movzbl (%eax),%eax
80104523:	0f b6 c0             	movzbl %al,%eax
80104526:	09 d0                	or     %edx,%eax
80104528:	c1 e0 0a             	shl    $0xa,%eax
8010452b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
8010452e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104531:	2d 00 04 00 00       	sub    $0x400,%eax
80104536:	83 ec 08             	sub    $0x8,%esp
80104539:	68 00 04 00 00       	push   $0x400
8010453e:	50                   	push   %eax
8010453f:	e8 f8 fe ff ff       	call   8010443c <mpsearch1>
80104544:	83 c4 10             	add    $0x10,%esp
80104547:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010454a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010454e:	74 05                	je     80104555 <mpsearch+0xa9>
      return mp;
80104550:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104553:	eb 15                	jmp    8010456a <mpsearch+0xbe>
  }
  return mpsearch1(0xF0000, 0x10000);
80104555:	83 ec 08             	sub    $0x8,%esp
80104558:	68 00 00 01 00       	push   $0x10000
8010455d:	68 00 00 0f 00       	push   $0xf0000
80104562:	e8 d5 fe ff ff       	call   8010443c <mpsearch1>
80104567:	83 c4 10             	add    $0x10,%esp
}
8010456a:	c9                   	leave  
8010456b:	c3                   	ret    

8010456c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
8010456c:	f3 0f 1e fb          	endbr32 
80104570:	55                   	push   %ebp
80104571:	89 e5                	mov    %esp,%ebp
80104573:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80104576:	e8 31 ff ff ff       	call   801044ac <mpsearch>
8010457b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010457e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104582:	74 0a                	je     8010458e <mpconfig+0x22>
80104584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104587:	8b 40 04             	mov    0x4(%eax),%eax
8010458a:	85 c0                	test   %eax,%eax
8010458c:	75 0a                	jne    80104598 <mpconfig+0x2c>
    return 0;
8010458e:	b8 00 00 00 00       	mov    $0x0,%eax
80104593:	e9 81 00 00 00       	jmp    80104619 <mpconfig+0xad>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80104598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459b:	8b 40 04             	mov    0x4(%eax),%eax
8010459e:	83 ec 0c             	sub    $0xc,%esp
801045a1:	50                   	push   %eax
801045a2:	e8 f2 fd ff ff       	call   80104399 <p2v>
801045a7:	83 c4 10             	add    $0x10,%esp
801045aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
801045ad:	83 ec 04             	sub    $0x4,%esp
801045b0:	6a 04                	push   $0x4
801045b2:	68 29 a3 10 80       	push   $0x8010a329
801045b7:	ff 75 f0             	pushl  -0x10(%ebp)
801045ba:	e8 4c 1b 00 00       	call   8010610b <memcmp>
801045bf:	83 c4 10             	add    $0x10,%esp
801045c2:	85 c0                	test   %eax,%eax
801045c4:	74 07                	je     801045cd <mpconfig+0x61>
    return 0;
801045c6:	b8 00 00 00 00       	mov    $0x0,%eax
801045cb:	eb 4c                	jmp    80104619 <mpconfig+0xad>
  if(conf->version != 1 && conf->version != 4)
801045cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045d0:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801045d4:	3c 01                	cmp    $0x1,%al
801045d6:	74 12                	je     801045ea <mpconfig+0x7e>
801045d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045db:	0f b6 40 06          	movzbl 0x6(%eax),%eax
801045df:	3c 04                	cmp    $0x4,%al
801045e1:	74 07                	je     801045ea <mpconfig+0x7e>
    return 0;
801045e3:	b8 00 00 00 00       	mov    $0x0,%eax
801045e8:	eb 2f                	jmp    80104619 <mpconfig+0xad>
  if(sum((uchar*)conf, conf->length) != 0)
801045ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045ed:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801045f1:	0f b7 c0             	movzwl %ax,%eax
801045f4:	83 ec 08             	sub    $0x8,%esp
801045f7:	50                   	push   %eax
801045f8:	ff 75 f0             	pushl  -0x10(%ebp)
801045fb:	e8 00 fe ff ff       	call   80104400 <sum>
80104600:	83 c4 10             	add    $0x10,%esp
80104603:	84 c0                	test   %al,%al
80104605:	74 07                	je     8010460e <mpconfig+0xa2>
    return 0;
80104607:	b8 00 00 00 00       	mov    $0x0,%eax
8010460c:	eb 0b                	jmp    80104619 <mpconfig+0xad>
  *pmp = mp;
8010460e:	8b 45 08             	mov    0x8(%ebp),%eax
80104611:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104614:	89 10                	mov    %edx,(%eax)
  return conf;
80104616:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104619:	c9                   	leave  
8010461a:	c3                   	ret    

8010461b <mpinit>:

void
mpinit(void)
{
8010461b:	f3 0f 1e fb          	endbr32 
8010461f:	55                   	push   %ebp
80104620:	89 e5                	mov    %esp,%ebp
80104622:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80104625:	c7 05 48 d6 10 80 60 	movl   $0x80115360,0x8010d648
8010462c:	53 11 80 
  if((conf = mpconfig(&mp)) == 0)
8010462f:	83 ec 0c             	sub    $0xc,%esp
80104632:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104635:	50                   	push   %eax
80104636:	e8 31 ff ff ff       	call   8010456c <mpconfig>
8010463b:	83 c4 10             	add    $0x10,%esp
8010463e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104641:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104645:	0f 84 ba 01 00 00    	je     80104805 <mpinit+0x1ea>
    return;
  ismp = 1;
8010464b:	c7 05 44 53 11 80 01 	movl   $0x1,0x80115344
80104652:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80104655:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104658:	8b 40 24             	mov    0x24(%eax),%eax
8010465b:	a3 5c 52 11 80       	mov    %eax,0x8011525c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104660:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104663:	83 c0 2c             	add    $0x2c,%eax
80104666:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104669:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010466c:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80104670:	0f b7 d0             	movzwl %ax,%edx
80104673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104676:	01 d0                	add    %edx,%eax
80104678:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010467b:	e9 16 01 00 00       	jmp    80104796 <mpinit+0x17b>
    switch(*p){
80104680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104683:	0f b6 00             	movzbl (%eax),%eax
80104686:	0f b6 c0             	movzbl %al,%eax
80104689:	83 f8 04             	cmp    $0x4,%eax
8010468c:	0f 8f e0 00 00 00    	jg     80104772 <mpinit+0x157>
80104692:	83 f8 03             	cmp    $0x3,%eax
80104695:	0f 8d d1 00 00 00    	jge    8010476c <mpinit+0x151>
8010469b:	83 f8 02             	cmp    $0x2,%eax
8010469e:	0f 84 b0 00 00 00    	je     80104754 <mpinit+0x139>
801046a4:	83 f8 02             	cmp    $0x2,%eax
801046a7:	0f 8f c5 00 00 00    	jg     80104772 <mpinit+0x157>
801046ad:	85 c0                	test   %eax,%eax
801046af:	74 0e                	je     801046bf <mpinit+0xa4>
801046b1:	83 f8 01             	cmp    $0x1,%eax
801046b4:	0f 84 b2 00 00 00    	je     8010476c <mpinit+0x151>
801046ba:	e9 b3 00 00 00       	jmp    80104772 <mpinit+0x157>
    case MPPROC:
      proc = (struct mpproc*)p;
801046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu != proc->apicid){
801046c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046c8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801046cc:	0f b6 d0             	movzbl %al,%edx
801046cf:	a1 40 59 11 80       	mov    0x80115940,%eax
801046d4:	39 c2                	cmp    %eax,%edx
801046d6:	74 2b                	je     80104703 <mpinit+0xe8>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
801046d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046db:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801046df:	0f b6 d0             	movzbl %al,%edx
801046e2:	a1 40 59 11 80       	mov    0x80115940,%eax
801046e7:	83 ec 04             	sub    $0x4,%esp
801046ea:	52                   	push   %edx
801046eb:	50                   	push   %eax
801046ec:	68 2e a3 10 80       	push   $0x8010a32e
801046f1:	e8 e8 bc ff ff       	call   801003de <cprintf>
801046f6:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
801046f9:	c7 05 44 53 11 80 00 	movl   $0x0,0x80115344
80104700:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80104703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104706:	0f b6 40 03          	movzbl 0x3(%eax),%eax
8010470a:	0f b6 c0             	movzbl %al,%eax
8010470d:	83 e0 02             	and    $0x2,%eax
80104710:	85 c0                	test   %eax,%eax
80104712:	74 15                	je     80104729 <mpinit+0x10e>
        bcpu = &cpus[ncpu];
80104714:	a1 40 59 11 80       	mov    0x80115940,%eax
80104719:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010471f:	05 60 53 11 80       	add    $0x80115360,%eax
80104724:	a3 48 d6 10 80       	mov    %eax,0x8010d648
      cpus[ncpu].id = ncpu;
80104729:	8b 15 40 59 11 80    	mov    0x80115940,%edx
8010472f:	a1 40 59 11 80       	mov    0x80115940,%eax
80104734:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010473a:	05 60 53 11 80       	add    $0x80115360,%eax
8010473f:	88 10                	mov    %dl,(%eax)
      ncpu++;
80104741:	a1 40 59 11 80       	mov    0x80115940,%eax
80104746:	83 c0 01             	add    $0x1,%eax
80104749:	a3 40 59 11 80       	mov    %eax,0x80115940
      p += sizeof(struct mpproc);
8010474e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80104752:	eb 42                	jmp    80104796 <mpinit+0x17b>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80104754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104757:	89 45 e8             	mov    %eax,-0x18(%ebp)
      ioapicid = ioapic->apicno;
8010475a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010475d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80104761:	a2 40 53 11 80       	mov    %al,0x80115340
      p += sizeof(struct mpioapic);
80104766:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
8010476a:	eb 2a                	jmp    80104796 <mpinit+0x17b>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010476c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104770:	eb 24                	jmp    80104796 <mpinit+0x17b>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80104772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104775:	0f b6 00             	movzbl (%eax),%eax
80104778:	0f b6 c0             	movzbl %al,%eax
8010477b:	83 ec 08             	sub    $0x8,%esp
8010477e:	50                   	push   %eax
8010477f:	68 4c a3 10 80       	push   $0x8010a34c
80104784:	e8 55 bc ff ff       	call   801003de <cprintf>
80104789:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
8010478c:	c7 05 44 53 11 80 00 	movl   $0x0,0x80115344
80104793:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104799:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010479c:	0f 82 de fe ff ff    	jb     80104680 <mpinit+0x65>
    }
  }
  if(!ismp){
801047a2:	a1 44 53 11 80       	mov    0x80115344,%eax
801047a7:	85 c0                	test   %eax,%eax
801047a9:	75 1d                	jne    801047c8 <mpinit+0x1ad>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
801047ab:	c7 05 40 59 11 80 01 	movl   $0x1,0x80115940
801047b2:	00 00 00 
    lapic = 0;
801047b5:	c7 05 5c 52 11 80 00 	movl   $0x0,0x8011525c
801047bc:	00 00 00 
    ioapicid = 0;
801047bf:	c6 05 40 53 11 80 00 	movb   $0x0,0x80115340
    return;
801047c6:	eb 3e                	jmp    80104806 <mpinit+0x1eb>
  }

  if(mp->imcrp){
801047c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047cb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801047cf:	84 c0                	test   %al,%al
801047d1:	74 33                	je     80104806 <mpinit+0x1eb>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
801047d3:	83 ec 08             	sub    $0x8,%esp
801047d6:	6a 70                	push   $0x70
801047d8:	6a 22                	push   $0x22
801047da:	e8 e4 fb ff ff       	call   801043c3 <outb>
801047df:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	6a 23                	push   $0x23
801047e7:	e8 ba fb ff ff       	call   801043a6 <inb>
801047ec:	83 c4 10             	add    $0x10,%esp
801047ef:	83 c8 01             	or     $0x1,%eax
801047f2:	0f b6 c0             	movzbl %al,%eax
801047f5:	83 ec 08             	sub    $0x8,%esp
801047f8:	50                   	push   %eax
801047f9:	6a 23                	push   $0x23
801047fb:	e8 c3 fb ff ff       	call   801043c3 <outb>
80104800:	83 c4 10             	add    $0x10,%esp
80104803:	eb 01                	jmp    80104806 <mpinit+0x1eb>
    return;
80104805:	90                   	nop
  }
}
80104806:	c9                   	leave  
80104807:	c3                   	ret    

80104808 <outb>:
{
80104808:	55                   	push   %ebp
80104809:	89 e5                	mov    %esp,%ebp
8010480b:	83 ec 08             	sub    $0x8,%esp
8010480e:	8b 45 08             	mov    0x8(%ebp),%eax
80104811:	8b 55 0c             	mov    0xc(%ebp),%edx
80104814:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80104818:	89 d0                	mov    %edx,%eax
8010481a:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010481d:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80104821:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80104825:	ee                   	out    %al,(%dx)
}
80104826:	90                   	nop
80104827:	c9                   	leave  
80104828:	c3                   	ret    

80104829 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80104829:	f3 0f 1e fb          	endbr32 
8010482d:	55                   	push   %ebp
8010482e:	89 e5                	mov    %esp,%ebp
80104830:	83 ec 04             	sub    $0x4,%esp
80104833:	8b 45 08             	mov    0x8(%ebp),%eax
80104836:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
8010483a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010483e:	66 a3 00 d0 10 80    	mov    %ax,0x8010d000
  outb(IO_PIC1+1, mask);
80104844:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80104848:	0f b6 c0             	movzbl %al,%eax
8010484b:	50                   	push   %eax
8010484c:	6a 21                	push   $0x21
8010484e:	e8 b5 ff ff ff       	call   80104808 <outb>
80104853:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80104856:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010485a:	66 c1 e8 08          	shr    $0x8,%ax
8010485e:	0f b6 c0             	movzbl %al,%eax
80104861:	50                   	push   %eax
80104862:	68 a1 00 00 00       	push   $0xa1
80104867:	e8 9c ff ff ff       	call   80104808 <outb>
8010486c:	83 c4 08             	add    $0x8,%esp
}
8010486f:	90                   	nop
80104870:	c9                   	leave  
80104871:	c3                   	ret    

80104872 <picenable>:

void
picenable(int irq)
{
80104872:	f3 0f 1e fb          	endbr32 
80104876:	55                   	push   %ebp
80104877:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80104879:	8b 45 08             	mov    0x8(%ebp),%eax
8010487c:	ba 01 00 00 00       	mov    $0x1,%edx
80104881:	89 c1                	mov    %eax,%ecx
80104883:	d3 e2                	shl    %cl,%edx
80104885:	89 d0                	mov    %edx,%eax
80104887:	f7 d0                	not    %eax
80104889:	89 c2                	mov    %eax,%edx
8010488b:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104892:	21 d0                	and    %edx,%eax
80104894:	0f b7 c0             	movzwl %ax,%eax
80104897:	50                   	push   %eax
80104898:	e8 8c ff ff ff       	call   80104829 <picsetmask>
8010489d:	83 c4 04             	add    $0x4,%esp
}
801048a0:	90                   	nop
801048a1:	c9                   	leave  
801048a2:	c3                   	ret    

801048a3 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
801048a3:	f3 0f 1e fb          	endbr32 
801048a7:	55                   	push   %ebp
801048a8:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801048aa:	68 ff 00 00 00       	push   $0xff
801048af:	6a 21                	push   $0x21
801048b1:	e8 52 ff ff ff       	call   80104808 <outb>
801048b6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
801048b9:	68 ff 00 00 00       	push   $0xff
801048be:	68 a1 00 00 00       	push   $0xa1
801048c3:	e8 40 ff ff ff       	call   80104808 <outb>
801048c8:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
801048cb:	6a 11                	push   $0x11
801048cd:	6a 20                	push   $0x20
801048cf:	e8 34 ff ff ff       	call   80104808 <outb>
801048d4:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
801048d7:	6a 20                	push   $0x20
801048d9:	6a 21                	push   $0x21
801048db:	e8 28 ff ff ff       	call   80104808 <outb>
801048e0:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
801048e3:	6a 04                	push   $0x4
801048e5:	6a 21                	push   $0x21
801048e7:	e8 1c ff ff ff       	call   80104808 <outb>
801048ec:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
801048ef:	6a 03                	push   $0x3
801048f1:	6a 21                	push   $0x21
801048f3:	e8 10 ff ff ff       	call   80104808 <outb>
801048f8:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
801048fb:	6a 11                	push   $0x11
801048fd:	68 a0 00 00 00       	push   $0xa0
80104902:	e8 01 ff ff ff       	call   80104808 <outb>
80104907:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
8010490a:	6a 28                	push   $0x28
8010490c:	68 a1 00 00 00       	push   $0xa1
80104911:	e8 f2 fe ff ff       	call   80104808 <outb>
80104916:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104919:	6a 02                	push   $0x2
8010491b:	68 a1 00 00 00       	push   $0xa1
80104920:	e8 e3 fe ff ff       	call   80104808 <outb>
80104925:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104928:	6a 03                	push   $0x3
8010492a:	68 a1 00 00 00       	push   $0xa1
8010492f:	e8 d4 fe ff ff       	call   80104808 <outb>
80104934:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80104937:	6a 68                	push   $0x68
80104939:	6a 20                	push   $0x20
8010493b:	e8 c8 fe ff ff       	call   80104808 <outb>
80104940:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104943:	6a 0a                	push   $0xa
80104945:	6a 20                	push   $0x20
80104947:	e8 bc fe ff ff       	call   80104808 <outb>
8010494c:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
8010494f:	6a 68                	push   $0x68
80104951:	68 a0 00 00 00       	push   $0xa0
80104956:	e8 ad fe ff ff       	call   80104808 <outb>
8010495b:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
8010495e:	6a 0a                	push   $0xa
80104960:	68 a0 00 00 00       	push   $0xa0
80104965:	e8 9e fe ff ff       	call   80104808 <outb>
8010496a:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
8010496d:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104974:	66 83 f8 ff          	cmp    $0xffff,%ax
80104978:	74 13                	je     8010498d <picinit+0xea>
    picsetmask(irqmask);
8010497a:	0f b7 05 00 d0 10 80 	movzwl 0x8010d000,%eax
80104981:	0f b7 c0             	movzwl %ax,%eax
80104984:	50                   	push   %eax
80104985:	e8 9f fe ff ff       	call   80104829 <picsetmask>
8010498a:	83 c4 04             	add    $0x4,%esp
}
8010498d:	90                   	nop
8010498e:	c9                   	leave  
8010498f:	c3                   	ret    

80104990 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104990:	f3 0f 1e fb          	endbr32 
80104994:	55                   	push   %ebp
80104995:	89 e5                	mov    %esp,%ebp
80104997:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010499a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
801049a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801049a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
801049aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801049ad:	8b 10                	mov    (%eax),%edx
801049af:	8b 45 08             	mov    0x8(%ebp),%eax
801049b2:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801049b4:	e8 45 c6 ff ff       	call   80100ffe <filealloc>
801049b9:	8b 55 08             	mov    0x8(%ebp),%edx
801049bc:	89 02                	mov    %eax,(%edx)
801049be:	8b 45 08             	mov    0x8(%ebp),%eax
801049c1:	8b 00                	mov    (%eax),%eax
801049c3:	85 c0                	test   %eax,%eax
801049c5:	0f 84 c8 00 00 00    	je     80104a93 <pipealloc+0x103>
801049cb:	e8 2e c6 ff ff       	call   80100ffe <filealloc>
801049d0:	8b 55 0c             	mov    0xc(%ebp),%edx
801049d3:	89 02                	mov    %eax,(%edx)
801049d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801049d8:	8b 00                	mov    (%eax),%eax
801049da:	85 c0                	test   %eax,%eax
801049dc:	0f 84 b1 00 00 00    	je     80104a93 <pipealloc+0x103>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801049e2:	e8 1c eb ff ff       	call   80103503 <kalloc>
801049e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049ee:	0f 84 a2 00 00 00    	je     80104a96 <pipealloc+0x106>
    goto bad;
  p->readopen = 1;
801049f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801049fe:	00 00 00 
  p->writeopen = 1;
80104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a04:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104a0b:	00 00 00 
  p->nwrite = 0;
80104a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a11:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80104a18:	00 00 00 
  p->nread = 0;
80104a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104a25:	00 00 00 
  initlock(&p->lock, "pipe");
80104a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2b:	83 ec 08             	sub    $0x8,%esp
80104a2e:	68 6c a3 10 80       	push   $0x8010a36c
80104a33:	50                   	push   %eax
80104a34:	e8 c5 13 00 00       	call   80105dfe <initlock>
80104a39:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104a3c:	8b 45 08             	mov    0x8(%ebp),%eax
80104a3f:	8b 00                	mov    (%eax),%eax
80104a41:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104a47:	8b 45 08             	mov    0x8(%ebp),%eax
80104a4a:	8b 00                	mov    (%eax),%eax
80104a4c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104a50:	8b 45 08             	mov    0x8(%ebp),%eax
80104a53:	8b 00                	mov    (%eax),%eax
80104a55:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104a59:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5c:	8b 00                	mov    (%eax),%eax
80104a5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a61:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104a64:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a67:	8b 00                	mov    (%eax),%eax
80104a69:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a72:	8b 00                	mov    (%eax),%eax
80104a74:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104a78:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a7b:	8b 00                	mov    (%eax),%eax
80104a7d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104a81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a84:	8b 00                	mov    (%eax),%eax
80104a86:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a89:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104a8c:	b8 00 00 00 00       	mov    $0x0,%eax
80104a91:	eb 51                	jmp    80104ae4 <pipealloc+0x154>
    goto bad;
80104a93:	90                   	nop
80104a94:	eb 01                	jmp    80104a97 <pipealloc+0x107>
    goto bad;
80104a96:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104a97:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104a9b:	74 0e                	je     80104aab <pipealloc+0x11b>
    kfree((char*)p);
80104a9d:	83 ec 0c             	sub    $0xc,%esp
80104aa0:	ff 75 f4             	pushl  -0xc(%ebp)
80104aa3:	e8 ad e9 ff ff       	call   80103455 <kfree>
80104aa8:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80104aab:	8b 45 08             	mov    0x8(%ebp),%eax
80104aae:	8b 00                	mov    (%eax),%eax
80104ab0:	85 c0                	test   %eax,%eax
80104ab2:	74 11                	je     80104ac5 <pipealloc+0x135>
    fileclose(*f0);
80104ab4:	8b 45 08             	mov    0x8(%ebp),%eax
80104ab7:	8b 00                	mov    (%eax),%eax
80104ab9:	83 ec 0c             	sub    $0xc,%esp
80104abc:	50                   	push   %eax
80104abd:	e8 02 c6 ff ff       	call   801010c4 <fileclose>
80104ac2:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ac8:	8b 00                	mov    (%eax),%eax
80104aca:	85 c0                	test   %eax,%eax
80104acc:	74 11                	je     80104adf <pipealloc+0x14f>
    fileclose(*f1);
80104ace:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ad1:	8b 00                	mov    (%eax),%eax
80104ad3:	83 ec 0c             	sub    $0xc,%esp
80104ad6:	50                   	push   %eax
80104ad7:	e8 e8 c5 ff ff       	call   801010c4 <fileclose>
80104adc:	83 c4 10             	add    $0x10,%esp
  return -1;
80104adf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ae4:	c9                   	leave  
80104ae5:	c3                   	ret    

80104ae6 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104ae6:	f3 0f 1e fb          	endbr32 
80104aea:	55                   	push   %ebp
80104aeb:	89 e5                	mov    %esp,%ebp
80104aed:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
80104af0:	8b 45 08             	mov    0x8(%ebp),%eax
80104af3:	83 ec 0c             	sub    $0xc,%esp
80104af6:	50                   	push   %eax
80104af7:	e8 28 13 00 00       	call   80105e24 <acquire>
80104afc:	83 c4 10             	add    $0x10,%esp
  if(writable){
80104aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b03:	74 23                	je     80104b28 <pipeclose+0x42>
    p->writeopen = 0;
80104b05:	8b 45 08             	mov    0x8(%ebp),%eax
80104b08:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104b0f:	00 00 00 
    wakeup(&p->nread);
80104b12:	8b 45 08             	mov    0x8(%ebp),%eax
80104b15:	05 34 02 00 00       	add    $0x234,%eax
80104b1a:	83 ec 0c             	sub    $0xc,%esp
80104b1d:	50                   	push   %eax
80104b1e:	e8 c9 0e 00 00       	call   801059ec <wakeup>
80104b23:	83 c4 10             	add    $0x10,%esp
80104b26:	eb 21                	jmp    80104b49 <pipeclose+0x63>
  } else {
    p->readopen = 0;
80104b28:	8b 45 08             	mov    0x8(%ebp),%eax
80104b2b:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104b32:	00 00 00 
    wakeup(&p->nwrite);
80104b35:	8b 45 08             	mov    0x8(%ebp),%eax
80104b38:	05 38 02 00 00       	add    $0x238,%eax
80104b3d:	83 ec 0c             	sub    $0xc,%esp
80104b40:	50                   	push   %eax
80104b41:	e8 a6 0e 00 00       	call   801059ec <wakeup>
80104b46:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104b49:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104b52:	85 c0                	test   %eax,%eax
80104b54:	75 2c                	jne    80104b82 <pipeclose+0x9c>
80104b56:	8b 45 08             	mov    0x8(%ebp),%eax
80104b59:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104b5f:	85 c0                	test   %eax,%eax
80104b61:	75 1f                	jne    80104b82 <pipeclose+0x9c>
    release(&p->lock);
80104b63:	8b 45 08             	mov    0x8(%ebp),%eax
80104b66:	83 ec 0c             	sub    $0xc,%esp
80104b69:	50                   	push   %eax
80104b6a:	e8 20 13 00 00       	call   80105e8f <release>
80104b6f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104b72:	83 ec 0c             	sub    $0xc,%esp
80104b75:	ff 75 08             	pushl  0x8(%ebp)
80104b78:	e8 d8 e8 ff ff       	call   80103455 <kfree>
80104b7d:	83 c4 10             	add    $0x10,%esp
80104b80:	eb 10                	jmp    80104b92 <pipeclose+0xac>
  } else
    release(&p->lock);
80104b82:	8b 45 08             	mov    0x8(%ebp),%eax
80104b85:	83 ec 0c             	sub    $0xc,%esp
80104b88:	50                   	push   %eax
80104b89:	e8 01 13 00 00       	call   80105e8f <release>
80104b8e:	83 c4 10             	add    $0x10,%esp
}
80104b91:	90                   	nop
80104b92:	90                   	nop
80104b93:	c9                   	leave  
80104b94:	c3                   	ret    

80104b95 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104b95:	f3 0f 1e fb          	endbr32 
80104b99:	55                   	push   %ebp
80104b9a:	89 e5                	mov    %esp,%ebp
80104b9c:	53                   	push   %ebx
80104b9d:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104ba0:	8b 45 08             	mov    0x8(%ebp),%eax
80104ba3:	83 ec 0c             	sub    $0xc,%esp
80104ba6:	50                   	push   %eax
80104ba7:	e8 78 12 00 00       	call   80105e24 <acquire>
80104bac:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104baf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bb6:	e9 ae 00 00 00       	jmp    80104c69 <pipewrite+0xd4>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbe:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104bc4:	85 c0                	test   %eax,%eax
80104bc6:	74 0d                	je     80104bd5 <pipewrite+0x40>
80104bc8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bce:	8b 40 24             	mov    0x24(%eax),%eax
80104bd1:	85 c0                	test   %eax,%eax
80104bd3:	74 19                	je     80104bee <pipewrite+0x59>
        release(&p->lock);
80104bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd8:	83 ec 0c             	sub    $0xc,%esp
80104bdb:	50                   	push   %eax
80104bdc:	e8 ae 12 00 00       	call   80105e8f <release>
80104be1:	83 c4 10             	add    $0x10,%esp
        return -1;
80104be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104be9:	e9 a9 00 00 00       	jmp    80104c97 <pipewrite+0x102>
      }
      wakeup(&p->nread);
80104bee:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf1:	05 34 02 00 00       	add    $0x234,%eax
80104bf6:	83 ec 0c             	sub    $0xc,%esp
80104bf9:	50                   	push   %eax
80104bfa:	e8 ed 0d 00 00       	call   801059ec <wakeup>
80104bff:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104c02:	8b 45 08             	mov    0x8(%ebp),%eax
80104c05:	8b 55 08             	mov    0x8(%ebp),%edx
80104c08:	81 c2 38 02 00 00    	add    $0x238,%edx
80104c0e:	83 ec 08             	sub    $0x8,%esp
80104c11:	50                   	push   %eax
80104c12:	52                   	push   %edx
80104c13:	e8 dd 0c 00 00       	call   801058f5 <sleep>
80104c18:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104c1b:	8b 45 08             	mov    0x8(%ebp),%eax
80104c1e:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104c24:	8b 45 08             	mov    0x8(%ebp),%eax
80104c27:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104c2d:	05 00 02 00 00       	add    $0x200,%eax
80104c32:	39 c2                	cmp    %eax,%edx
80104c34:	74 85                	je     80104bbb <pipewrite+0x26>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104c36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c39:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c3c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104c3f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c42:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104c48:	8d 48 01             	lea    0x1(%eax),%ecx
80104c4b:	8b 55 08             	mov    0x8(%ebp),%edx
80104c4e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104c54:	25 ff 01 00 00       	and    $0x1ff,%eax
80104c59:	89 c1                	mov    %eax,%ecx
80104c5b:	0f b6 13             	movzbl (%ebx),%edx
80104c5e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c61:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104c65:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6c:	3b 45 10             	cmp    0x10(%ebp),%eax
80104c6f:	7c aa                	jl     80104c1b <pipewrite+0x86>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104c71:	8b 45 08             	mov    0x8(%ebp),%eax
80104c74:	05 34 02 00 00       	add    $0x234,%eax
80104c79:	83 ec 0c             	sub    $0xc,%esp
80104c7c:	50                   	push   %eax
80104c7d:	e8 6a 0d 00 00       	call   801059ec <wakeup>
80104c82:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104c85:	8b 45 08             	mov    0x8(%ebp),%eax
80104c88:	83 ec 0c             	sub    $0xc,%esp
80104c8b:	50                   	push   %eax
80104c8c:	e8 fe 11 00 00       	call   80105e8f <release>
80104c91:	83 c4 10             	add    $0x10,%esp
  return n;
80104c94:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104c97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c9a:	c9                   	leave  
80104c9b:	c3                   	ret    

80104c9c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104c9c:	f3 0f 1e fb          	endbr32 
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80104ca9:	83 ec 0c             	sub    $0xc,%esp
80104cac:	50                   	push   %eax
80104cad:	e8 72 11 00 00       	call   80105e24 <acquire>
80104cb2:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104cb5:	eb 3f                	jmp    80104cf6 <piperead+0x5a>
    if(proc->killed){
80104cb7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104cbd:	8b 40 24             	mov    0x24(%eax),%eax
80104cc0:	85 c0                	test   %eax,%eax
80104cc2:	74 19                	je     80104cdd <piperead+0x41>
      release(&p->lock);
80104cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc7:	83 ec 0c             	sub    $0xc,%esp
80104cca:	50                   	push   %eax
80104ccb:	e8 bf 11 00 00       	call   80105e8f <release>
80104cd0:	83 c4 10             	add    $0x10,%esp
      return -1;
80104cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cd8:	e9 be 00 00 00       	jmp    80104d9b <piperead+0xff>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce0:	8b 55 08             	mov    0x8(%ebp),%edx
80104ce3:	81 c2 34 02 00 00    	add    $0x234,%edx
80104ce9:	83 ec 08             	sub    $0x8,%esp
80104cec:	50                   	push   %eax
80104ced:	52                   	push   %edx
80104cee:	e8 02 0c 00 00       	call   801058f5 <sleep>
80104cf3:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80104cf9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104cff:	8b 45 08             	mov    0x8(%ebp),%eax
80104d02:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104d08:	39 c2                	cmp    %eax,%edx
80104d0a:	75 0d                	jne    80104d19 <piperead+0x7d>
80104d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d0f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104d15:	85 c0                	test   %eax,%eax
80104d17:	75 9e                	jne    80104cb7 <piperead+0x1b>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104d19:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d20:	eb 48                	jmp    80104d6a <piperead+0xce>
    if(p->nread == p->nwrite)
80104d22:	8b 45 08             	mov    0x8(%ebp),%eax
80104d25:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104d2b:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104d34:	39 c2                	cmp    %eax,%edx
80104d36:	74 3c                	je     80104d74 <piperead+0xd8>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104d38:	8b 45 08             	mov    0x8(%ebp),%eax
80104d3b:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104d41:	8d 48 01             	lea    0x1(%eax),%ecx
80104d44:	8b 55 08             	mov    0x8(%ebp),%edx
80104d47:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104d4d:	25 ff 01 00 00       	and    $0x1ff,%eax
80104d52:	89 c1                	mov    %eax,%ecx
80104d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d57:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d5a:	01 c2                	add    %eax,%edx
80104d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80104d5f:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104d64:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104d66:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6d:	3b 45 10             	cmp    0x10(%ebp),%eax
80104d70:	7c b0                	jl     80104d22 <piperead+0x86>
80104d72:	eb 01                	jmp    80104d75 <piperead+0xd9>
      break;
80104d74:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104d75:	8b 45 08             	mov    0x8(%ebp),%eax
80104d78:	05 38 02 00 00       	add    $0x238,%eax
80104d7d:	83 ec 0c             	sub    $0xc,%esp
80104d80:	50                   	push   %eax
80104d81:	e8 66 0c 00 00       	call   801059ec <wakeup>
80104d86:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104d89:	8b 45 08             	mov    0x8(%ebp),%eax
80104d8c:	83 ec 0c             	sub    $0xc,%esp
80104d8f:	50                   	push   %eax
80104d90:	e8 fa 10 00 00       	call   80105e8f <release>
80104d95:	83 c4 10             	add    $0x10,%esp
  return i;
80104d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104d9b:	c9                   	leave  
80104d9c:	c3                   	ret    

80104d9d <readeflags>:
{
80104d9d:	55                   	push   %ebp
80104d9e:	89 e5                	mov    %esp,%ebp
80104da0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104da3:	9c                   	pushf  
80104da4:	58                   	pop    %eax
80104da5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104da8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104dab:	c9                   	leave  
80104dac:	c3                   	ret    

80104dad <sti>:
{
80104dad:	55                   	push   %ebp
80104dae:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104db0:	fb                   	sti    
}
80104db1:	90                   	nop
80104db2:	5d                   	pop    %ebp
80104db3:	c3                   	ret    

80104db4 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
80104db4:	f3 0f 1e fb          	endbr32 
80104db8:	55                   	push   %ebp
80104db9:	89 e5                	mov    %esp,%ebp
80104dbb:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104dbe:	83 ec 08             	sub    $0x8,%esp
80104dc1:	68 74 a3 10 80       	push   $0x8010a374
80104dc6:	68 60 59 11 80       	push   $0x80115960
80104dcb:	e8 2e 10 00 00       	call   80105dfe <initlock>
80104dd0:	83 c4 10             	add    $0x10,%esp
}
80104dd3:	90                   	nop
80104dd4:	c9                   	leave  
80104dd5:	c3                   	ret    

80104dd6 <initSwapStructs>:


void initSwapStructs(struct proc* p) {
80104dd6:	f3 0f 1e fb          	endbr32 
80104dda:	55                   	push   %ebp
80104ddb:	89 e5                	mov    %esp,%ebp
80104ddd:	83 ec 10             	sub    $0x10,%esp
  int i;
  for (i = 0; i < maxNumberOfPages - allPhysicalPages; i++)
80104de0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104de7:	eb 21                	jmp    80104e0a <initSwapStructs+0x34>
    p->fileCtrlr[i].state = NOTUSED;
80104de9:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104dec:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104def:	89 d0                	mov    %edx,%eax
80104df1:	c1 e0 02             	shl    $0x2,%eax
80104df4:	01 d0                	add    %edx,%eax
80104df6:	c1 e0 02             	shl    $0x2,%eax
80104df9:	01 c8                	add    %ecx,%eax
80104dfb:	05 88 00 00 00       	add    $0x88,%eax
80104e00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for (i = 0; i < maxNumberOfPages - allPhysicalPages; i++)
80104e06:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104e0a:	83 7d fc 0e          	cmpl   $0xe,-0x4(%ebp)
80104e0e:	7e d9                	jle    80104de9 <initSwapStructs+0x13>
}
80104e10:	90                   	nop
80104e11:	90                   	nop
80104e12:	c9                   	leave  
80104e13:	c3                   	ret    

80104e14 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104e14:	f3 0f 1e fb          	endbr32 
80104e18:	55                   	push   %ebp
80104e19:	89 e5                	mov    %esp,%ebp
80104e1b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80104e1e:	83 ec 0c             	sub    $0xc,%esp
80104e21:	68 60 59 11 80       	push   $0x80115960
80104e26:	e8 f9 0f 00 00       	call   80105e24 <acquire>
80104e2b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e2e:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80104e35:	eb 11                	jmp    80104e48 <allocproc+0x34>
    if(p->state == UNUSED)
80104e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3a:	8b 40 0c             	mov    0xc(%eax),%eax
80104e3d:	85 c0                	test   %eax,%eax
80104e3f:	74 2a                	je     80104e6b <allocproc+0x57>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e41:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
80104e48:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
80104e4f:	72 e6                	jb     80104e37 <allocproc+0x23>
      goto found;
  release(&ptable.lock);
80104e51:	83 ec 0c             	sub    $0xc,%esp
80104e54:	68 60 59 11 80       	push   $0x80115960
80104e59:	e8 31 10 00 00       	call   80105e8f <release>
80104e5e:	83 c4 10             	add    $0x10,%esp
  return 0;
80104e61:	b8 00 00 00 00       	mov    $0x0,%eax
80104e66:	e9 f6 00 00 00       	jmp    80104f61 <allocproc+0x14d>
      goto found;
80104e6b:	90                   	nop
80104e6c:	f3 0f 1e fb          	endbr32 

found:
  p->state = EMBRYO;
80104e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e73:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104e7a:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104e7f:	8d 50 01             	lea    0x1(%eax),%edx
80104e82:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104e88:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e8b:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104e8e:	83 ec 0c             	sub    $0xc,%esp
80104e91:	68 60 59 11 80       	push   $0x80115960
80104e96:	e8 f4 0f 00 00       	call   80105e8f <release>
80104e9b:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104e9e:	e8 60 e6 ff ff       	call   80103503 <kalloc>
80104ea3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea6:	89 42 08             	mov    %eax,0x8(%edx)
80104ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eac:	8b 40 08             	mov    0x8(%eax),%eax
80104eaf:	85 c0                	test   %eax,%eax
80104eb1:	75 14                	jne    80104ec7 <allocproc+0xb3>
    p->state = UNUSED;
80104eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104ebd:	b8 00 00 00 00       	mov    $0x0,%eax
80104ec2:	e9 9a 00 00 00       	jmp    80104f61 <allocproc+0x14d>
  }
  sp = p->kstack + KSTACKSIZE;
80104ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eca:	8b 40 08             	mov    0x8(%eax),%eax
80104ecd:	05 00 10 00 00       	add    $0x1000,%eax
80104ed2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104ed5:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104ed9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104edc:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104edf:	89 50 18             	mov    %edx,0x18(%eax)
  p->loadOrderCounter = 0;
80104ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee5:	c7 80 e0 02 00 00 00 	movl   $0x0,0x2e0(%eax)
80104eec:	00 00 00 
  p->faultCounter = 0;
80104eef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef2:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->countOfPagedOut = 0;
80104ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104efc:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104f03:	00 00 00 

    if(p->pid > 2)
80104f06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f09:	8b 40 10             	mov    0x10(%eax),%eax
80104f0c:	83 f8 02             	cmp    $0x2,%eax
80104f0f:	7e 0e                	jle    80104f1f <allocproc+0x10b>
      createSwapFile(p);
80104f11:	83 ec 0c             	sub    $0xc,%esp
80104f14:	ff 75 f4             	pushl  -0xc(%ebp)
80104f17:	e8 c7 dc ff ff       	call   80102be3 <createSwapFile>
80104f1c:	83 c4 10             	add    $0x10,%esp
    

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104f1f:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104f23:	ba 34 75 10 80       	mov    $0x80107534,%edx
80104f28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f2b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104f2d:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f37:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f3d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f40:	83 ec 04             	sub    $0x4,%esp
80104f43:	6a 14                	push   $0x14
80104f45:	6a 00                	push   $0x0
80104f47:	50                   	push   %eax
80104f48:	e8 53 11 00 00       	call   801060a0 <memset>
80104f4d:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104f50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f53:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f56:	ba ab 58 10 80       	mov    $0x801058ab,%edx
80104f5b:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80104f5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f61:	c9                   	leave  
80104f62:	c3                   	ret    

80104f63 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104f63:	f3 0f 1e fb          	endbr32 
80104f67:	55                   	push   %ebp
80104f68:	89 e5                	mov    %esp,%ebp
80104f6a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
80104f6d:	e8 a2 fe ff ff       	call   80104e14 <allocproc>
80104f72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
80104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f78:	a3 4c d6 10 80       	mov    %eax,0x8010d64c
  if((p->pgdir = setupkvm()) == 0)
80104f7d:	e8 ff 3c 00 00       	call   80108c81 <setupkvm>
80104f82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f85:	89 42 04             	mov    %eax,0x4(%edx)
80104f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f8b:	8b 40 04             	mov    0x4(%eax),%eax
80104f8e:	85 c0                	test   %eax,%eax
80104f90:	75 0d                	jne    80104f9f <userinit+0x3c>
    panic("userinit: out of memory?");
80104f92:	83 ec 0c             	sub    $0xc,%esp
80104f95:	68 7b a3 10 80       	push   $0x8010a37b
80104f9a:	e8 f8 b5 ff ff       	call   80100597 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104f9f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fa7:	8b 40 04             	mov    0x4(%eax),%eax
80104faa:	83 ec 04             	sub    $0x4,%esp
80104fad:	52                   	push   %edx
80104fae:	68 e0 d4 10 80       	push   $0x8010d4e0
80104fb3:	50                   	push   %eax
80104fb4:	e8 33 3f 00 00       	call   80108eec <inituvm>
80104fb9:	83 c4 10             	add    $0x10,%esp
  p->sz = pageSize;
80104fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbf:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc8:	8b 40 18             	mov    0x18(%eax),%eax
80104fcb:	83 ec 04             	sub    $0x4,%esp
80104fce:	6a 4c                	push   $0x4c
80104fd0:	6a 00                	push   $0x0
80104fd2:	50                   	push   %eax
80104fd3:	e8 c8 10 00 00       	call   801060a0 <memset>
80104fd8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fde:	8b 40 18             	mov    0x18(%eax),%eax
80104fe1:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fea:	8b 40 18             	mov    0x18(%eax),%eax
80104fed:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104ff3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff6:	8b 50 18             	mov    0x18(%eax),%edx
80104ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ffc:	8b 40 18             	mov    0x18(%eax),%eax
80104fff:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105003:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80105007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500a:	8b 50 18             	mov    0x18(%eax),%edx
8010500d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105010:	8b 40 18             	mov    0x18(%eax),%eax
80105013:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80105017:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010501b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010501e:	8b 40 18             	mov    0x18(%eax),%eax
80105021:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = pageSize;
80105028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010502b:	8b 40 18             	mov    0x18(%eax),%eax
8010502e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80105035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105038:	8b 40 18             	mov    0x18(%eax),%eax
8010503b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80105042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105045:	83 c0 6c             	add    $0x6c,%eax
80105048:	83 ec 04             	sub    $0x4,%esp
8010504b:	6a 10                	push   $0x10
8010504d:	68 94 a3 10 80       	push   $0x8010a394
80105052:	50                   	push   %eax
80105053:	e8 63 12 00 00       	call   801062bb <safestrcpy>
80105058:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010505b:	83 ec 0c             	sub    $0xc,%esp
8010505e:	68 9d a3 10 80       	push   $0x8010a39d
80105063:	e8 92 d5 ff ff       	call   801025fa <namei>
80105068:	83 c4 10             	add    $0x10,%esp
8010506b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010506e:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
80105071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105074:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
8010507b:	90                   	nop
8010507c:	c9                   	leave  
8010507d:	c3                   	ret    

8010507e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010507e:	f3 0f 1e fb          	endbr32 
80105082:	55                   	push   %ebp
80105083:	89 e5                	mov    %esp,%ebp
80105085:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
80105088:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010508e:	8b 00                	mov    (%eax),%eax
80105090:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80105093:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105097:	7e 31                	jle    801050ca <growproc+0x4c>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80105099:	8b 55 08             	mov    0x8(%ebp),%edx
8010509c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010509f:	01 c2                	add    %eax,%edx
801050a1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050a7:	8b 40 04             	mov    0x4(%eax),%eax
801050aa:	83 ec 04             	sub    $0x4,%esp
801050ad:	52                   	push   %edx
801050ae:	ff 75 f4             	pushl  -0xc(%ebp)
801050b1:	50                   	push   %eax
801050b2:	e8 05 48 00 00       	call   801098bc <allocuvm>
801050b7:	83 c4 10             	add    $0x10,%esp
801050ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050c1:	75 3e                	jne    80105101 <growproc+0x83>
      return -1;
801050c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c8:	eb 59                	jmp    80105123 <growproc+0xa5>
  } else if(n < 0){
801050ca:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801050ce:	79 31                	jns    80105101 <growproc+0x83>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
801050d0:	8b 55 08             	mov    0x8(%ebp),%edx
801050d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050d6:	01 c2                	add    %eax,%edx
801050d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801050de:	8b 40 04             	mov    0x4(%eax),%eax
801050e1:	83 ec 04             	sub    $0x4,%esp
801050e4:	52                   	push   %edx
801050e5:	ff 75 f4             	pushl  -0xc(%ebp)
801050e8:	50                   	push   %eax
801050e9:	e8 c9 4a 00 00       	call   80109bb7 <deallocuvm>
801050ee:	83 c4 10             	add    $0x10,%esp
801050f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050f8:	75 07                	jne    80105101 <growproc+0x83>
      return -1;
801050fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050ff:	eb 22                	jmp    80105123 <growproc+0xa5>
  }
  proc->sz = sz;
80105101:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105107:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010510a:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010510c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105112:	83 ec 0c             	sub    $0xc,%esp
80105115:	50                   	push   %eax
80105116:	e8 59 3c 00 00       	call   80108d74 <switchuvm>
8010511b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010511e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105123:	c9                   	leave  
80105124:	c3                   	ret    

80105125 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80105125:	f3 0f 1e fb          	endbr32 
80105129:	55                   	push   %ebp
8010512a:	89 e5                	mov    %esp,%ebp
8010512c:	57                   	push   %edi
8010512d:	56                   	push   %esi
8010512e:	53                   	push   %ebx
8010512f:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80105132:	e8 dd fc ff ff       	call   80104e14 <allocproc>
80105137:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010513a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010513e:	75 0a                	jne    8010514a <fork+0x25>
    return -1;
80105140:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105145:	e9 bb 02 00 00       	jmp    80105405 <fork+0x2e0>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010514a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105150:	8b 10                	mov    (%eax),%edx
80105152:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105158:	8b 40 04             	mov    0x4(%eax),%eax
8010515b:	83 ec 08             	sub    $0x8,%esp
8010515e:	52                   	push   %edx
8010515f:	50                   	push   %eax
80105160:	e8 2c 4c 00 00       	call   80109d91 <copyuvm>
80105165:	83 c4 10             	add    $0x10,%esp
80105168:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010516b:	89 42 04             	mov    %eax,0x4(%edx)
8010516e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105171:	8b 40 04             	mov    0x4(%eax),%eax
80105174:	85 c0                	test   %eax,%eax
80105176:	75 30                	jne    801051a8 <fork+0x83>
    kfree(np->kstack);
80105178:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010517b:	8b 40 08             	mov    0x8(%eax),%eax
8010517e:	83 ec 0c             	sub    $0xc,%esp
80105181:	50                   	push   %eax
80105182:	e8 ce e2 ff ff       	call   80103455 <kfree>
80105187:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
8010518a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010518d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80105194:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105197:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010519e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051a3:	e9 5d 02 00 00       	jmp    80105405 <fork+0x2e0>
  }
  np->sz = proc->sz;
801051a8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051ae:	8b 10                	mov    (%eax),%edx
801051b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051b3:	89 10                	mov    %edx,(%eax)
    if (proc->pid > 2){
801051b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051bb:	8b 40 10             	mov    0x10(%eax),%eax
801051be:	83 f8 02             	cmp    $0x2,%eax
801051c1:	0f 8e 2e 01 00 00    	jle    801052f5 <fork+0x1d0>
      copySwapFile(proc, np);
801051c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051cd:	83 ec 08             	sub    $0x8,%esp
801051d0:	ff 75 e0             	pushl  -0x20(%ebp)
801051d3:	50                   	push   %eax
801051d4:	e8 e7 da ff ff       	call   80102cc0 <copySwapFile>
801051d9:	83 c4 10             	add    $0x10,%esp
      np->loadOrderCounter = proc->loadOrderCounter;
801051dc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801051e2:	8b 90 e0 02 00 00    	mov    0x2e0(%eax),%edx
801051e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801051eb:	89 90 e0 02 00 00    	mov    %edx,0x2e0(%eax)
      for (i = 0; i < allPhysicalPages; i++){
801051f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801051f8:	eb 74                	jmp    8010526e <fork+0x149>
        np->memController[i] = proc->memController[i]; //deep copies ramCtrlr list
801051fa:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80105201:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80105204:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105207:	89 d0                	mov    %edx,%eax
80105209:	c1 e0 02             	shl    $0x2,%eax
8010520c:	01 d0                	add    %edx,%eax
8010520e:	c1 e0 02             	shl    $0x2,%eax
80105211:	01 c8                	add    %ecx,%eax
80105213:	8d 90 b0 01 00 00    	lea    0x1b0(%eax),%edx
80105219:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010521c:	89 c8                	mov    %ecx,%eax
8010521e:	c1 e0 02             	shl    $0x2,%eax
80105221:	01 c8                	add    %ecx,%eax
80105223:	c1 e0 02             	shl    $0x2,%eax
80105226:	01 d8                	add    %ebx,%eax
80105228:	05 b0 01 00 00       	add    $0x1b0,%eax
8010522d:	8b 48 04             	mov    0x4(%eax),%ecx
80105230:	89 4a 04             	mov    %ecx,0x4(%edx)
80105233:	8b 48 08             	mov    0x8(%eax),%ecx
80105236:	89 4a 08             	mov    %ecx,0x8(%edx)
80105239:	8b 48 0c             	mov    0xc(%eax),%ecx
8010523c:	89 4a 0c             	mov    %ecx,0xc(%edx)
8010523f:	8b 48 10             	mov    0x10(%eax),%ecx
80105242:	89 4a 10             	mov    %ecx,0x10(%edx)
80105245:	8b 40 14             	mov    0x14(%eax),%eax
80105248:	89 42 14             	mov    %eax,0x14(%edx)
        np->memController[i].pageDir = np->pgdir;  //replace parent pgdir with child new pgdir
8010524b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010524e:	8b 48 04             	mov    0x4(%eax),%ecx
80105251:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80105254:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105257:	89 d0                	mov    %edx,%eax
80105259:	c1 e0 02             	shl    $0x2,%eax
8010525c:	01 d0                	add    %edx,%eax
8010525e:	c1 e0 02             	shl    $0x2,%eax
80105261:	01 d8                	add    %ebx,%eax
80105263:	05 b8 01 00 00       	add    $0x1b8,%eax
80105268:	89 08                	mov    %ecx,(%eax)
      for (i = 0; i < allPhysicalPages; i++){
8010526a:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010526e:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
80105272:	7e 86                	jle    801051fa <fork+0xd5>
      }
      for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++){
80105274:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010527b:	eb 72                	jmp    801052ef <fork+0x1ca>
        np->fileCtrlr[i] = proc->fileCtrlr[i]; //deep copies fileCtrlr list
8010527d:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80105284:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80105287:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010528a:	89 d0                	mov    %edx,%eax
8010528c:	c1 e0 02             	shl    $0x2,%eax
8010528f:	01 d0                	add    %edx,%eax
80105291:	c1 e0 02             	shl    $0x2,%eax
80105294:	01 c8                	add    %ecx,%eax
80105296:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx
8010529c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010529f:	89 c8                	mov    %ecx,%eax
801052a1:	c1 e0 02             	shl    $0x2,%eax
801052a4:	01 c8                	add    %ecx,%eax
801052a6:	c1 e0 02             	shl    $0x2,%eax
801052a9:	01 d8                	add    %ebx,%eax
801052ab:	83 e8 80             	sub    $0xffffff80,%eax
801052ae:	8b 48 08             	mov    0x8(%eax),%ecx
801052b1:	89 4a 08             	mov    %ecx,0x8(%edx)
801052b4:	8b 48 0c             	mov    0xc(%eax),%ecx
801052b7:	89 4a 0c             	mov    %ecx,0xc(%edx)
801052ba:	8b 48 10             	mov    0x10(%eax),%ecx
801052bd:	89 4a 10             	mov    %ecx,0x10(%edx)
801052c0:	8b 48 14             	mov    0x14(%eax),%ecx
801052c3:	89 4a 14             	mov    %ecx,0x14(%edx)
801052c6:	8b 40 18             	mov    0x18(%eax),%eax
801052c9:	89 42 18             	mov    %eax,0x18(%edx)
        np->fileCtrlr[i].pageDir = np->pgdir;   //replace parent pgdir with child new pgdir
801052cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052cf:	8b 48 04             	mov    0x4(%eax),%ecx
801052d2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
801052d5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801052d8:	89 d0                	mov    %edx,%eax
801052da:	c1 e0 02             	shl    $0x2,%eax
801052dd:	01 d0                	add    %edx,%eax
801052df:	c1 e0 02             	shl    $0x2,%eax
801052e2:	01 d8                	add    %ebx,%eax
801052e4:	05 8c 00 00 00       	add    $0x8c,%eax
801052e9:	89 08                	mov    %ecx,(%eax)
      for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++){
801052eb:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801052ef:	83 7d e4 0e          	cmpl   $0xe,-0x1c(%ebp)
801052f3:	7e 88                	jle    8010527d <fork+0x158>
      }
    }

  np->parent = proc;
801052f5:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801052fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801052ff:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80105302:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105308:	8b 48 18             	mov    0x18(%eax),%ecx
8010530b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010530e:	8b 40 18             	mov    0x18(%eax),%eax
80105311:	89 c2                	mov    %eax,%edx
80105313:	89 cb                	mov    %ecx,%ebx
80105315:	b8 13 00 00 00       	mov    $0x13,%eax
8010531a:	89 d7                	mov    %edx,%edi
8010531c:	89 de                	mov    %ebx,%esi
8010531e:	89 c1                	mov    %eax,%ecx
80105320:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80105322:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105325:	8b 40 18             	mov    0x18(%eax),%eax
80105328:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010532f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80105336:	eb 41                	jmp    80105379 <fork+0x254>
    if(proc->ofile[i])
80105338:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010533e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105341:	83 c2 08             	add    $0x8,%edx
80105344:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105348:	85 c0                	test   %eax,%eax
8010534a:	74 29                	je     80105375 <fork+0x250>
      np->ofile[i] = filedup(proc->ofile[i]);
8010534c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105352:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105355:	83 c2 08             	add    $0x8,%edx
80105358:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010535c:	83 ec 0c             	sub    $0xc,%esp
8010535f:	50                   	push   %eax
80105360:	e8 0a bd ff ff       	call   8010106f <filedup>
80105365:	83 c4 10             	add    $0x10,%esp
80105368:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010536b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010536e:	83 c1 08             	add    $0x8,%ecx
80105371:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80105375:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80105379:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010537d:	7e b9                	jle    80105338 <fork+0x213>
  np->cwd = idup(proc->cwd);
8010537f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105385:	8b 40 68             	mov    0x68(%eax),%eax
80105388:	83 ec 0c             	sub    $0xc,%esp
8010538b:	50                   	push   %eax
8010538c:	e8 42 c6 ff ff       	call   801019d3 <idup>
80105391:	83 c4 10             	add    $0x10,%esp
80105394:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105397:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010539a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053a0:	8d 50 6c             	lea    0x6c(%eax),%edx
801053a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053a6:	83 c0 6c             	add    $0x6c,%eax
801053a9:	83 ec 04             	sub    $0x4,%esp
801053ac:	6a 10                	push   $0x10
801053ae:	52                   	push   %edx
801053af:	50                   	push   %eax
801053b0:	e8 06 0f 00 00       	call   801062bb <safestrcpy>
801053b5:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801053b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053bb:	8b 40 10             	mov    0x10(%eax),%eax
801053be:	89 45 dc             	mov    %eax,-0x24(%ebp)
  np->faultCounter = 0;
801053c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053c4:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  np->countOfPagedOut = 0;
801053cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053ce:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801053d5:	00 00 00 


  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801053d8:	83 ec 0c             	sub    $0xc,%esp
801053db:	68 60 59 11 80       	push   $0x80115960
801053e0:	e8 3f 0a 00 00       	call   80105e24 <acquire>
801053e5:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801053e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801053eb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801053f2:	83 ec 0c             	sub    $0xc,%esp
801053f5:	68 60 59 11 80       	push   $0x80115960
801053fa:	e8 90 0a 00 00       	call   80105e8f <release>
801053ff:	83 c4 10             	add    $0x10,%esp
  return pid;
80105402:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80105405:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105408:	5b                   	pop    %ebx
80105409:	5e                   	pop    %esi
8010540a:	5f                   	pop    %edi
8010540b:	5d                   	pop    %ebp
8010540c:	c3                   	ret    

8010540d <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010540d:	f3 0f 1e fb          	endbr32 
80105411:	55                   	push   %ebp
80105412:	89 e5                	mov    %esp,%ebp
80105414:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80105417:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010541e:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80105423:	39 c2                	cmp    %eax,%edx
80105425:	75 0d                	jne    80105434 <exit+0x27>
    panic("init exiting");
80105427:	83 ec 0c             	sub    $0xc,%esp
8010542a:	68 9f a3 10 80       	push   $0x8010a39f
8010542f:	e8 63 b1 ff ff       	call   80100597 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80105434:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010543b:	eb 48                	jmp    80105485 <exit+0x78>
    if(proc->ofile[fd]){
8010543d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105443:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105446:	83 c2 08             	add    $0x8,%edx
80105449:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010544d:	85 c0                	test   %eax,%eax
8010544f:	74 30                	je     80105481 <exit+0x74>
      fileclose(proc->ofile[fd]);
80105451:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105457:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010545a:	83 c2 08             	add    $0x8,%edx
8010545d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105461:	83 ec 0c             	sub    $0xc,%esp
80105464:	50                   	push   %eax
80105465:	e8 5a bc ff ff       	call   801010c4 <fileclose>
8010546a:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
8010546d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105473:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105476:	83 c2 08             	add    $0x8,%edx
80105479:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105480:	00 
  for(fd = 0; fd < NOFILE; fd++){
80105481:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105485:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80105489:	7e b2                	jle    8010543d <exit+0x30>
    }
  }
  if (proc->pid > 2) 
8010548b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105491:	8b 40 10             	mov    0x10(%eax),%eax
80105494:	83 f8 02             	cmp    $0x2,%eax
80105497:	7e 12                	jle    801054ab <exit+0x9e>
    removeSwapFile(proc);
80105499:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010549f:	83 ec 0c             	sub    $0xc,%esp
801054a2:	50                   	push   %eax
801054a3:	e8 56 d2 ff ff       	call   801026fe <removeSwapFile>
801054a8:	83 c4 10             	add    $0x10,%esp


  begin_op();
801054ab:	e8 86 e9 ff ff       	call   80103e36 <begin_op>
  iput(proc->cwd);
801054b0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054b6:	8b 40 68             	mov    0x68(%eax),%eax
801054b9:	83 ec 0c             	sub    $0xc,%esp
801054bc:	50                   	push   %eax
801054bd:	e8 27 c7 ff ff       	call   80101be9 <iput>
801054c2:	83 c4 10             	add    $0x10,%esp
  end_op();
801054c5:	e8 fc e9 ff ff       	call   80103ec6 <end_op>
  proc->cwd = 0;
801054ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054d0:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)


  acquire(&ptable.lock);
801054d7:	83 ec 0c             	sub    $0xc,%esp
801054da:	68 60 59 11 80       	push   $0x80115960
801054df:	e8 40 09 00 00       	call   80105e24 <acquire>
801054e4:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801054e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801054ed:	8b 40 14             	mov    0x14(%eax),%eax
801054f0:	83 ec 0c             	sub    $0xc,%esp
801054f3:	50                   	push   %eax
801054f4:	e8 ac 04 00 00       	call   801059a5 <wakeup1>
801054f9:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054fc:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105503:	eb 3f                	jmp    80105544 <exit+0x137>
    if(p->parent == proc){
80105505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105508:	8b 50 14             	mov    0x14(%eax),%edx
8010550b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105511:	39 c2                	cmp    %eax,%edx
80105513:	75 28                	jne    8010553d <exit+0x130>
      p->parent = initproc;
80105515:	8b 15 4c d6 10 80    	mov    0x8010d64c,%edx
8010551b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010551e:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80105521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105524:	8b 40 0c             	mov    0xc(%eax),%eax
80105527:	83 f8 05             	cmp    $0x5,%eax
8010552a:	75 11                	jne    8010553d <exit+0x130>
        wakeup1(initproc);
8010552c:	a1 4c d6 10 80       	mov    0x8010d64c,%eax
80105531:	83 ec 0c             	sub    $0xc,%esp
80105534:	50                   	push   %eax
80105535:	e8 6b 04 00 00       	call   801059a5 <wakeup1>
8010553a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010553d:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
80105544:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
8010554b:	72 b8                	jb     80105505 <exit+0xf8>
    }
  }

  proc->state = ZOMBIE;
8010554d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105553:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
      
  #if TRUE
    procdump();
8010555a:	e8 13 06 00 00       	call   80105b72 <procdump>
  #endif
    
  // Jump into the scheduler, never to return.
  sched();
8010555f:	e8 48 02 00 00       	call   801057ac <sched>
  panic("zombie exit");
80105564:	83 ec 0c             	sub    $0xc,%esp
80105567:	68 ac a3 10 80       	push   $0x8010a3ac
8010556c:	e8 26 b0 ff ff       	call   80100597 <panic>

80105571 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80105571:	f3 0f 1e fb          	endbr32 
80105575:	55                   	push   %ebp
80105576:	89 e5                	mov    %esp,%ebp
80105578:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
8010557b:	83 ec 0c             	sub    $0xc,%esp
8010557e:	68 60 59 11 80       	push   $0x80115960
80105583:	e8 9c 08 00 00       	call   80105e24 <acquire>
80105588:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
8010558b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105592:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105599:	e9 0d 01 00 00       	jmp    801056ab <wait+0x13a>
      if(p->parent != proc)
8010559e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055a1:	8b 50 14             	mov    0x14(%eax),%edx
801055a4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055aa:	39 c2                	cmp    %eax,%edx
801055ac:	0f 85 f1 00 00 00    	jne    801056a3 <wait+0x132>
        continue;
      havekids = 1;
801055b2:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801055b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055bc:	8b 40 0c             	mov    0xc(%eax),%eax
801055bf:	83 f8 05             	cmp    $0x5,%eax
801055c2:	0f 85 dc 00 00 00    	jne    801056a4 <wait+0x133>
        // Found one.
        pid = p->pid;
801055c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055cb:	8b 40 10             	mov    0x10(%eax),%eax
801055ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
801055d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055d4:	8b 40 08             	mov    0x8(%eax),%eax
801055d7:	83 ec 0c             	sub    $0xc,%esp
801055da:	50                   	push   %eax
801055db:	e8 75 de ff ff       	call   80103455 <kfree>
801055e0:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
801055e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801055ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055f0:	8b 40 04             	mov    0x4(%eax),%eax
801055f3:	83 ec 0c             	sub    $0xc,%esp
801055f6:	50                   	push   %eax
801055f7:	e8 a1 46 00 00       	call   80109c9d <freevm>
801055fc:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
801055ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105602:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80105609:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        int i;
        for (i = 0; i < allPhysicalPages; i++)
80105613:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010561a:	eb 21                	jmp    8010563d <wait+0xcc>
          p->memController[i].state = NOTUSED;
8010561c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010561f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105622:	89 d0                	mov    %edx,%eax
80105624:	c1 e0 02             	shl    $0x2,%eax
80105627:	01 d0                	add    %edx,%eax
80105629:	c1 e0 02             	shl    $0x2,%eax
8010562c:	01 c8                	add    %ecx,%eax
8010562e:	05 b4 01 00 00       	add    $0x1b4,%eax
80105633:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        for (i = 0; i < allPhysicalPages; i++)
80105639:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010563d:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80105641:	7e d9                	jle    8010561c <wait+0xab>
        for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++)
80105643:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010564a:	eb 21                	jmp    8010566d <wait+0xfc>
          p->fileCtrlr[i].state = NOTUSED;
8010564c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010564f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105652:	89 d0                	mov    %edx,%eax
80105654:	c1 e0 02             	shl    $0x2,%eax
80105657:	01 d0                	add    %edx,%eax
80105659:	c1 e0 02             	shl    $0x2,%eax
8010565c:	01 c8                	add    %ecx,%eax
8010565e:	05 88 00 00 00       	add    $0x88,%eax
80105663:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++)
80105669:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010566d:	83 7d ec 0e          	cmpl   $0xe,-0x14(%ebp)
80105671:	7e d9                	jle    8010564c <wait+0xdb>
        p->parent = 0;
80105673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105676:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105680:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80105684:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105687:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
8010568e:	83 ec 0c             	sub    $0xc,%esp
80105691:	68 60 59 11 80       	push   $0x80115960
80105696:	e8 f4 07 00 00       	call   80105e8f <release>
8010569b:	83 c4 10             	add    $0x10,%esp
        return pid;
8010569e:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056a1:	eb 5b                	jmp    801056fe <wait+0x18d>
        continue;
801056a3:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801056a4:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
801056ab:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
801056b2:	0f 82 e6 fe ff ff    	jb     8010559e <wait+0x2d>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
801056b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801056bc:	74 0d                	je     801056cb <wait+0x15a>
801056be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c4:	8b 40 24             	mov    0x24(%eax),%eax
801056c7:	85 c0                	test   %eax,%eax
801056c9:	74 17                	je     801056e2 <wait+0x171>
      release(&ptable.lock);
801056cb:	83 ec 0c             	sub    $0xc,%esp
801056ce:	68 60 59 11 80       	push   $0x80115960
801056d3:	e8 b7 07 00 00       	call   80105e8f <release>
801056d8:	83 c4 10             	add    $0x10,%esp
      return -1;
801056db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e0:	eb 1c                	jmp    801056fe <wait+0x18d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
801056e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056e8:	83 ec 08             	sub    $0x8,%esp
801056eb:	68 60 59 11 80       	push   $0x80115960
801056f0:	50                   	push   %eax
801056f1:	e8 ff 01 00 00       	call   801058f5 <sleep>
801056f6:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801056f9:	e9 8d fe ff ff       	jmp    8010558b <wait+0x1a>
  }
}
801056fe:	c9                   	leave  
801056ff:	c3                   	ret    

80105700 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105700:	f3 0f 1e fb          	endbr32 
80105704:	55                   	push   %ebp
80105705:	89 e5                	mov    %esp,%ebp
80105707:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
8010570a:	e8 9e f6 ff ff       	call   80104dad <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
8010570f:	83 ec 0c             	sub    $0xc,%esp
80105712:	68 60 59 11 80       	push   $0x80115960
80105717:	e8 08 07 00 00       	call   80105e24 <acquire>
8010571c:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010571f:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105726:	eb 66                	jmp    8010578e <scheduler+0x8e>
      if(p->state != RUNNABLE)
80105728:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010572b:	8b 40 0c             	mov    0xc(%eax),%eax
8010572e:	83 f8 03             	cmp    $0x3,%eax
80105731:	75 53                	jne    80105786 <scheduler+0x86>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80105733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105736:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
8010573c:	83 ec 0c             	sub    $0xc,%esp
8010573f:	ff 75 f4             	pushl  -0xc(%ebp)
80105742:	e8 2d 36 00 00       	call   80108d74 <switchuvm>
80105747:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
8010574a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010574d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80105754:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010575a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010575d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105764:	83 c2 04             	add    $0x4,%edx
80105767:	83 ec 08             	sub    $0x8,%esp
8010576a:	50                   	push   %eax
8010576b:	52                   	push   %edx
8010576c:	e8 c3 0b 00 00       	call   80106334 <swtch>
80105771:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80105774:	e8 da 35 00 00       	call   80108d53 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80105779:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80105780:	00 00 00 00 
80105784:	eb 01                	jmp    80105787 <scheduler+0x87>
        continue;
80105786:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105787:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
8010578e:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
80105795:	72 91                	jb     80105728 <scheduler+0x28>
    }
    release(&ptable.lock);
80105797:	83 ec 0c             	sub    $0xc,%esp
8010579a:	68 60 59 11 80       	push   $0x80115960
8010579f:	e8 eb 06 00 00       	call   80105e8f <release>
801057a4:	83 c4 10             	add    $0x10,%esp
    sti();
801057a7:	e9 5e ff ff ff       	jmp    8010570a <scheduler+0xa>

801057ac <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
801057ac:	f3 0f 1e fb          	endbr32 
801057b0:	55                   	push   %ebp
801057b1:	89 e5                	mov    %esp,%ebp
801057b3:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
801057b6:	83 ec 0c             	sub    $0xc,%esp
801057b9:	68 60 59 11 80       	push   $0x80115960
801057be:	e8 a1 07 00 00       	call   80105f64 <holding>
801057c3:	83 c4 10             	add    $0x10,%esp
801057c6:	85 c0                	test   %eax,%eax
801057c8:	75 0d                	jne    801057d7 <sched+0x2b>
    panic("sched ptable.lock");
801057ca:	83 ec 0c             	sub    $0xc,%esp
801057cd:	68 b8 a3 10 80       	push   $0x8010a3b8
801057d2:	e8 c0 ad ff ff       	call   80100597 <panic>
  if(cpu->ncli != 1)
801057d7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801057dd:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801057e3:	83 f8 01             	cmp    $0x1,%eax
801057e6:	74 0d                	je     801057f5 <sched+0x49>
    panic("sched locks");
801057e8:	83 ec 0c             	sub    $0xc,%esp
801057eb:	68 ca a3 10 80       	push   $0x8010a3ca
801057f0:	e8 a2 ad ff ff       	call   80100597 <panic>
  if(proc->state == RUNNING)
801057f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057fb:	8b 40 0c             	mov    0xc(%eax),%eax
801057fe:	83 f8 04             	cmp    $0x4,%eax
80105801:	75 0d                	jne    80105810 <sched+0x64>
    panic("sched running");
80105803:	83 ec 0c             	sub    $0xc,%esp
80105806:	68 d6 a3 10 80       	push   $0x8010a3d6
8010580b:	e8 87 ad ff ff       	call   80100597 <panic>
  if(readeflags()&FL_IF)
80105810:	e8 88 f5 ff ff       	call   80104d9d <readeflags>
80105815:	25 00 02 00 00       	and    $0x200,%eax
8010581a:	85 c0                	test   %eax,%eax
8010581c:	74 0d                	je     8010582b <sched+0x7f>
    panic("sched interruptible");
8010581e:	83 ec 0c             	sub    $0xc,%esp
80105821:	68 e4 a3 10 80       	push   $0x8010a3e4
80105826:	e8 6c ad ff ff       	call   80100597 <panic>
  intena = cpu->intena;
8010582b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105831:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105837:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
8010583a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105840:	8b 40 04             	mov    0x4(%eax),%eax
80105843:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
8010584a:	83 c2 1c             	add    $0x1c,%edx
8010584d:	83 ec 08             	sub    $0x8,%esp
80105850:	50                   	push   %eax
80105851:	52                   	push   %edx
80105852:	e8 dd 0a 00 00       	call   80106334 <swtch>
80105857:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
8010585a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105860:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105863:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105869:	90                   	nop
8010586a:	c9                   	leave  
8010586b:	c3                   	ret    

8010586c <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
8010586c:	f3 0f 1e fb          	endbr32 
80105870:	55                   	push   %ebp
80105871:	89 e5                	mov    %esp,%ebp
80105873:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80105876:	83 ec 0c             	sub    $0xc,%esp
80105879:	68 60 59 11 80       	push   $0x80115960
8010587e:	e8 a1 05 00 00       	call   80105e24 <acquire>
80105883:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80105886:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010588c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80105893:	e8 14 ff ff ff       	call   801057ac <sched>
  release(&ptable.lock);
80105898:	83 ec 0c             	sub    $0xc,%esp
8010589b:	68 60 59 11 80       	push   $0x80115960
801058a0:	e8 ea 05 00 00       	call   80105e8f <release>
801058a5:	83 c4 10             	add    $0x10,%esp
}
801058a8:	90                   	nop
801058a9:	c9                   	leave  
801058aa:	c3                   	ret    

801058ab <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801058ab:	f3 0f 1e fb          	endbr32 
801058af:	55                   	push   %ebp
801058b0:	89 e5                	mov    %esp,%ebp
801058b2:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801058b5:	83 ec 0c             	sub    $0xc,%esp
801058b8:	68 60 59 11 80       	push   $0x80115960
801058bd:	e8 cd 05 00 00       	call   80105e8f <release>
801058c2:	83 c4 10             	add    $0x10,%esp

  if (first) {
801058c5:	a1 08 d0 10 80       	mov    0x8010d008,%eax
801058ca:	85 c0                	test   %eax,%eax
801058cc:	74 24                	je     801058f2 <forkret+0x47>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
801058ce:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
801058d5:	00 00 00 
    iinit(ROOTDEV);
801058d8:	83 ec 0c             	sub    $0xc,%esp
801058db:	6a 01                	push   $0x1
801058dd:	e8 ef bd ff ff       	call   801016d1 <iinit>
801058e2:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801058e5:	83 ec 0c             	sub    $0xc,%esp
801058e8:	6a 01                	push   $0x1
801058ea:	e8 14 e3 ff ff       	call   80103c03 <initlog>
801058ef:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
801058f2:	90                   	nop
801058f3:	c9                   	leave  
801058f4:	c3                   	ret    

801058f5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801058f5:	f3 0f 1e fb          	endbr32 
801058f9:	55                   	push   %ebp
801058fa:	89 e5                	mov    %esp,%ebp
801058fc:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
801058ff:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105905:	85 c0                	test   %eax,%eax
80105907:	75 0d                	jne    80105916 <sleep+0x21>
    panic("sleep");
80105909:	83 ec 0c             	sub    $0xc,%esp
8010590c:	68 f8 a3 10 80       	push   $0x8010a3f8
80105911:	e8 81 ac ff ff       	call   80100597 <panic>

  if(lk == 0)
80105916:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010591a:	75 0d                	jne    80105929 <sleep+0x34>
    panic("sleep without lk");
8010591c:	83 ec 0c             	sub    $0xc,%esp
8010591f:	68 fe a3 10 80       	push   $0x8010a3fe
80105924:	e8 6e ac ff ff       	call   80100597 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80105929:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
80105930:	74 1e                	je     80105950 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80105932:	83 ec 0c             	sub    $0xc,%esp
80105935:	68 60 59 11 80       	push   $0x80115960
8010593a:	e8 e5 04 00 00       	call   80105e24 <acquire>
8010593f:	83 c4 10             	add    $0x10,%esp
    release(lk);
80105942:	83 ec 0c             	sub    $0xc,%esp
80105945:	ff 75 0c             	pushl  0xc(%ebp)
80105948:	e8 42 05 00 00       	call   80105e8f <release>
8010594d:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80105950:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105956:	8b 55 08             	mov    0x8(%ebp),%edx
80105959:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
8010595c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105962:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80105969:	e8 3e fe ff ff       	call   801057ac <sched>

  // Tidy up.
  proc->chan = 0;
8010596e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105974:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010597b:	81 7d 0c 60 59 11 80 	cmpl   $0x80115960,0xc(%ebp)
80105982:	74 1e                	je     801059a2 <sleep+0xad>
    release(&ptable.lock);
80105984:	83 ec 0c             	sub    $0xc,%esp
80105987:	68 60 59 11 80       	push   $0x80115960
8010598c:	e8 fe 04 00 00       	call   80105e8f <release>
80105991:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80105994:	83 ec 0c             	sub    $0xc,%esp
80105997:	ff 75 0c             	pushl  0xc(%ebp)
8010599a:	e8 85 04 00 00       	call   80105e24 <acquire>
8010599f:	83 c4 10             	add    $0x10,%esp
  }
}
801059a2:	90                   	nop
801059a3:	c9                   	leave  
801059a4:	c3                   	ret    

801059a5 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801059a5:	f3 0f 1e fb          	endbr32 
801059a9:	55                   	push   %ebp
801059aa:	89 e5                	mov    %esp,%ebp
801059ac:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801059af:	c7 45 fc 94 59 11 80 	movl   $0x80115994,-0x4(%ebp)
801059b6:	eb 27                	jmp    801059df <wakeup1+0x3a>
    if(p->state == SLEEPING && p->chan == chan)
801059b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059bb:	8b 40 0c             	mov    0xc(%eax),%eax
801059be:	83 f8 02             	cmp    $0x2,%eax
801059c1:	75 15                	jne    801059d8 <wakeup1+0x33>
801059c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059c6:	8b 40 20             	mov    0x20(%eax),%eax
801059c9:	39 45 08             	cmp    %eax,0x8(%ebp)
801059cc:	75 0a                	jne    801059d8 <wakeup1+0x33>
      p->state = RUNNABLE;
801059ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059d1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801059d8:	81 45 fc e8 02 00 00 	addl   $0x2e8,-0x4(%ebp)
801059df:	81 7d fc 94 13 12 80 	cmpl   $0x80121394,-0x4(%ebp)
801059e6:	72 d0                	jb     801059b8 <wakeup1+0x13>
}
801059e8:	90                   	nop
801059e9:	90                   	nop
801059ea:	c9                   	leave  
801059eb:	c3                   	ret    

801059ec <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801059ec:	f3 0f 1e fb          	endbr32 
801059f0:	55                   	push   %ebp
801059f1:	89 e5                	mov    %esp,%ebp
801059f3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801059f6:	83 ec 0c             	sub    $0xc,%esp
801059f9:	68 60 59 11 80       	push   $0x80115960
801059fe:	e8 21 04 00 00       	call   80105e24 <acquire>
80105a03:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80105a06:	83 ec 0c             	sub    $0xc,%esp
80105a09:	ff 75 08             	pushl  0x8(%ebp)
80105a0c:	e8 94 ff ff ff       	call   801059a5 <wakeup1>
80105a11:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80105a14:	83 ec 0c             	sub    $0xc,%esp
80105a17:	68 60 59 11 80       	push   $0x80115960
80105a1c:	e8 6e 04 00 00       	call   80105e8f <release>
80105a21:	83 c4 10             	add    $0x10,%esp
}
80105a24:	90                   	nop
80105a25:	c9                   	leave  
80105a26:	c3                   	ret    

80105a27 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105a27:	f3 0f 1e fb          	endbr32 
80105a2b:	55                   	push   %ebp
80105a2c:	89 e5                	mov    %esp,%ebp
80105a2e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80105a31:	83 ec 0c             	sub    $0xc,%esp
80105a34:	68 60 59 11 80       	push   $0x80115960
80105a39:	e8 e6 03 00 00       	call   80105e24 <acquire>
80105a3e:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a41:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105a48:	eb 48                	jmp    80105a92 <kill+0x6b>
    if(p->pid == pid){
80105a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a4d:	8b 40 10             	mov    0x10(%eax),%eax
80105a50:	39 45 08             	cmp    %eax,0x8(%ebp)
80105a53:	75 36                	jne    80105a8b <kill+0x64>
      p->killed = 1;
80105a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a58:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80105a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a62:	8b 40 0c             	mov    0xc(%eax),%eax
80105a65:	83 f8 02             	cmp    $0x2,%eax
80105a68:	75 0a                	jne    80105a74 <kill+0x4d>
        p->state = RUNNABLE;
80105a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105a74:	83 ec 0c             	sub    $0xc,%esp
80105a77:	68 60 59 11 80       	push   $0x80115960
80105a7c:	e8 0e 04 00 00       	call   80105e8f <release>
80105a81:	83 c4 10             	add    $0x10,%esp
      return 0;
80105a84:	b8 00 00 00 00       	mov    $0x0,%eax
80105a89:	eb 25                	jmp    80105ab0 <kill+0x89>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105a8b:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
80105a92:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
80105a99:	72 af                	jb     80105a4a <kill+0x23>
    }
  }
  release(&ptable.lock);
80105a9b:	83 ec 0c             	sub    $0xc,%esp
80105a9e:	68 60 59 11 80       	push   $0x80115960
80105aa3:	e8 e7 03 00 00       	call   80105e8f <release>
80105aa8:	83 c4 10             	add    $0x10,%esp
  return -1;
80105aab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ab0:	c9                   	leave  
80105ab1:	c3                   	ret    

80105ab2 <getPagedOutAmout>:

int getPagedOutAmout(struct proc* p){
80105ab2:	f3 0f 1e fb          	endbr32 
80105ab6:	55                   	push   %ebp
80105ab7:	89 e5                	mov    %esp,%ebp
80105ab9:	83 ec 10             	sub    $0x10,%esp
 
  int i;
  int amout = 0;
80105abc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

  for (i=0;i < allPhysicalPages; i++){
80105ac3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105aca:	eb 26                	jmp    80105af2 <getPagedOutAmout+0x40>
    if (p->fileCtrlr[i].state == USED)
80105acc:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105acf:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ad2:	89 d0                	mov    %edx,%eax
80105ad4:	c1 e0 02             	shl    $0x2,%eax
80105ad7:	01 d0                	add    %edx,%eax
80105ad9:	c1 e0 02             	shl    $0x2,%eax
80105adc:	01 c8                	add    %ecx,%eax
80105ade:	05 88 00 00 00       	add    $0x88,%eax
80105ae3:	8b 00                	mov    (%eax),%eax
80105ae5:	83 f8 01             	cmp    $0x1,%eax
80105ae8:	75 04                	jne    80105aee <getPagedOutAmout+0x3c>
      amout++;
80105aea:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  for (i=0;i < allPhysicalPages; i++){
80105aee:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105af2:	83 7d fc 0e          	cmpl   $0xe,-0x4(%ebp)
80105af6:	7e d4                	jle    80105acc <getPagedOutAmout+0x1a>
  }
  return amout;
80105af8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80105afb:	c9                   	leave  
80105afc:	c3                   	ret    

80105afd <updateLRU>:

void updateLRU(){
80105afd:	f3 0f 1e fb          	endbr32 
80105b01:	55                   	push   %ebp
80105b02:	89 e5                	mov    %esp,%ebp
80105b04:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  acquire(&ptable.lock);
80105b07:	83 ec 0c             	sub    $0xc,%esp
80105b0a:	68 60 59 11 80       	push   $0x80115960
80105b0f:	e8 10 03 00 00       	call   80105e24 <acquire>
80105b14:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b17:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105b1e:	eb 36                	jmp    80105b56 <updateLRU+0x59>
    if (p->pid > 2 && p->state > 1 && p->state < 5) //proc is either running, runnable or sleeping
80105b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b23:	8b 40 10             	mov    0x10(%eax),%eax
80105b26:	83 f8 02             	cmp    $0x2,%eax
80105b29:	7e 24                	jle    80105b4f <updateLRU+0x52>
80105b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b2e:	8b 40 0c             	mov    0xc(%eax),%eax
80105b31:	83 f8 01             	cmp    $0x1,%eax
80105b34:	76 19                	jbe    80105b4f <updateLRU+0x52>
80105b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b39:	8b 40 0c             	mov    0xc(%eax),%eax
80105b3c:	83 f8 04             	cmp    $0x4,%eax
80105b3f:	77 0e                	ja     80105b4f <updateLRU+0x52>
      updateAccessNumber(p); //implemented in vm.c
80105b41:	83 ec 0c             	sub    $0xc,%esp
80105b44:	ff 75 f4             	pushl  -0xc(%ebp)
80105b47:	e8 17 38 00 00       	call   80109363 <updateAccessNumber>
80105b4c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b4f:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
80105b56:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
80105b5d:	72 c1                	jb     80105b20 <updateLRU+0x23>
  }
  release(&ptable.lock);
80105b5f:	83 ec 0c             	sub    $0xc,%esp
80105b62:	68 60 59 11 80       	push   $0x80115960
80105b67:	e8 23 03 00 00       	call   80105e8f <release>
80105b6c:	83 c4 10             	add    $0x10,%esp
}
80105b6f:	90                   	nop
80105b70:	c9                   	leave  
80105b71:	c3                   	ret    

80105b72 <procdump>:
//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.

void procdump(void){
80105b72:	f3 0f 1e fb          	endbr32 
80105b76:	55                   	push   %ebp
80105b77:	89 e5                	mov    %esp,%ebp
80105b79:	53                   	push   %ebx
80105b7a:	83 ec 44             	sub    $0x44,%esp
  char *state;
  uint pc[10];
  int allocatedPages;
  int pagedOutAmount;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105b7d:	c7 45 f0 94 59 11 80 	movl   $0x80115994,-0x10(%ebp)
80105b84:	e9 0f 01 00 00       	jmp    80105c98 <procdump+0x126>
    if(p->state == UNUSED)
80105b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8c:	8b 40 0c             	mov    0xc(%eax),%eax
80105b8f:	85 c0                	test   %eax,%eax
80105b91:	0f 84 f9 00 00 00    	je     80105c90 <procdump+0x11e>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105b97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b9a:	8b 40 0c             	mov    0xc(%eax),%eax
80105b9d:	83 f8 05             	cmp    $0x5,%eax
80105ba0:	77 23                	ja     80105bc5 <procdump+0x53>
80105ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ba5:	8b 40 0c             	mov    0xc(%eax),%eax
80105ba8:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105baf:	85 c0                	test   %eax,%eax
80105bb1:	74 12                	je     80105bc5 <procdump+0x53>
      state = states[p->state];
80105bb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb6:	8b 40 0c             	mov    0xc(%eax),%eax
80105bb9:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
80105bc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105bc3:	eb 07                	jmp    80105bcc <procdump+0x5a>
    else
      state = "???";
80105bc5:	c7 45 ec 0f a4 10 80 	movl   $0x8010a40f,-0x14(%ebp)

    allocatedPages = PGROUNDUP(p->sz)/pageSize;
80105bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bcf:	8b 00                	mov    (%eax),%eax
80105bd1:	05 ff 0f 00 00       	add    $0xfff,%eax
80105bd6:	c1 e8 0c             	shr    $0xc,%eax
80105bd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pagedOutAmount = getPagedOutAmout(p);
80105bdc:	ff 75 f0             	pushl  -0x10(%ebp)
80105bdf:	e8 ce fe ff ff       	call   80105ab2 <getPagedOutAmout>
80105be4:	83 c4 04             	add    $0x4,%esp
80105be7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("%d %s %d %d %d %d %s", p->pid, state, allocatedPages, 
           pagedOutAmount,p->faultCounter , p->countOfPagedOut ,p->name);
80105bea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bed:	8d 58 6c             	lea    0x6c(%eax),%ebx
    cprintf("%d %s %d %d %d %d %s", p->pid, state, allocatedPages, 
80105bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf3:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80105bf9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfc:	8b 50 7c             	mov    0x7c(%eax),%edx
80105bff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c02:	8b 40 10             	mov    0x10(%eax),%eax
80105c05:	53                   	push   %ebx
80105c06:	51                   	push   %ecx
80105c07:	52                   	push   %edx
80105c08:	ff 75 e4             	pushl  -0x1c(%ebp)
80105c0b:	ff 75 e8             	pushl  -0x18(%ebp)
80105c0e:	ff 75 ec             	pushl  -0x14(%ebp)
80105c11:	50                   	push   %eax
80105c12:	68 13 a4 10 80       	push   $0x8010a413
80105c17:	e8 c2 a7 ff ff       	call   801003de <cprintf>
80105c1c:	83 c4 20             	add    $0x20,%esp
    
    if(p->state == SLEEPING){
80105c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c22:	8b 40 0c             	mov    0xc(%eax),%eax
80105c25:	83 f8 02             	cmp    $0x2,%eax
80105c28:	75 54                	jne    80105c7e <procdump+0x10c>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105c2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2d:	8b 40 1c             	mov    0x1c(%eax),%eax
80105c30:	8b 40 0c             	mov    0xc(%eax),%eax
80105c33:	83 c0 08             	add    $0x8,%eax
80105c36:	89 c2                	mov    %eax,%edx
80105c38:	83 ec 08             	sub    $0x8,%esp
80105c3b:	8d 45 bc             	lea    -0x44(%ebp),%eax
80105c3e:	50                   	push   %eax
80105c3f:	52                   	push   %edx
80105c40:	e8 a0 02 00 00       	call   80105ee5 <getcallerpcs>
80105c45:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105c48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105c4f:	eb 1c                	jmp    80105c6d <procdump+0xfb>
        cprintf(" %p", pc[i]);
80105c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c54:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80105c58:	83 ec 08             	sub    $0x8,%esp
80105c5b:	50                   	push   %eax
80105c5c:	68 28 a4 10 80       	push   $0x8010a428
80105c61:	e8 78 a7 ff ff       	call   801003de <cprintf>
80105c66:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80105c69:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105c6d:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105c71:	7f 0b                	jg     80105c7e <procdump+0x10c>
80105c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c76:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80105c7a:	85 c0                	test   %eax,%eax
80105c7c:	75 d3                	jne    80105c51 <procdump+0xdf>
    }

    cprintf("\n");
80105c7e:	83 ec 0c             	sub    $0xc,%esp
80105c81:	68 2c a4 10 80       	push   $0x8010a42c
80105c86:	e8 53 a7 ff ff       	call   801003de <cprintf>
80105c8b:	83 c4 10             	add    $0x10,%esp
80105c8e:	eb 01                	jmp    80105c91 <procdump+0x11f>
      continue;
80105c90:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105c91:	81 45 f0 e8 02 00 00 	addl   $0x2e8,-0x10(%ebp)
80105c98:	81 7d f0 94 13 12 80 	cmpl   $0x80121394,-0x10(%ebp)
80105c9f:	0f 82 e4 fe ff ff    	jb     80105b89 <procdump+0x17>
  }
  cprintf("%d/%d free pages in the system\n",getFreePages(),getTotalPages());
80105ca5:	e8 e2 d6 ff ff       	call   8010338c <getTotalPages>
80105caa:	89 c3                	mov    %eax,%ebx
80105cac:	e8 cd d6 ff ff       	call   8010337e <getFreePages>
80105cb1:	83 ec 04             	sub    $0x4,%esp
80105cb4:	53                   	push   %ebx
80105cb5:	50                   	push   %eax
80105cb6:	68 30 a4 10 80       	push   $0x8010a430
80105cbb:	e8 1e a7 ff ff       	call   801003de <cprintf>
80105cc0:	83 c4 10             	add    $0x10,%esp


}
80105cc3:	90                   	nop
80105cc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105cc7:	c9                   	leave  
80105cc8:	c3                   	ret    

80105cc9 <printMem>:


void
printMem()
{
80105cc9:	f3 0f 1e fb          	endbr32 
80105ccd:	55                   	push   %ebp
80105cce:	89 e5                	mov    %esp,%ebp
80105cd0:	53                   	push   %ebx
80105cd1:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  //char *state;
  //int allocatedPages;
  //int pagedOutAmount;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105cd4:	c7 45 f4 94 59 11 80 	movl   $0x80115994,-0xc(%ebp)
80105cdb:	e9 d2 00 00 00       	jmp    80105db2 <printMem+0xe9>
    if(p->state == UNUSED)
80105ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce3:	8b 40 0c             	mov    0xc(%eax),%eax
80105ce6:	85 c0                	test   %eax,%eax
80105ce8:	0f 84 bc 00 00 00    	je     80105daa <printMem+0xe1>

    

    //allocatedPages = PGROUNDUP(p->sz)/PGSIZE;
   // pagedOutAmount = getPagedOutAmout(p);
    if(p->pid > 2){
80105cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf1:	8b 40 10             	mov    0x10(%eax),%eax
80105cf4:	83 f8 02             	cmp    $0x2,%eax
80105cf7:	0f 8e ae 00 00 00    	jle    80105dab <printMem+0xe2>

     
   // cprintf("\n"); 
    
  //cprintf("%d %d %d", pagedOutAmount,p->faultCounter , p->countOfPagedOut);
  cprintf("%d ", p->whynot);
80105cfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d00:	8b 80 e4 02 00 00    	mov    0x2e4(%eax),%eax
80105d06:	83 ec 08             	sub    $0x8,%esp
80105d09:	50                   	push   %eax
80105d0a:	68 50 a4 10 80       	push   $0x8010a450
80105d0f:	e8 ca a6 ff ff       	call   801003de <cprintf>
80105d14:	83 c4 10             	add    $0x10,%esp
   for (int i = 0; i < allPhysicalPages; i++) {
80105d17:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80105d1e:	eb 72                	jmp    80105d92 <printMem+0xc9>
      
     if (proc->memController[i].state == USED ) {
80105d20:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105d27:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d2a:	89 d0                	mov    %edx,%eax
80105d2c:	c1 e0 02             	shl    $0x2,%eax
80105d2f:	01 d0                	add    %edx,%eax
80105d31:	c1 e0 02             	shl    $0x2,%eax
80105d34:	01 c8                	add    %ecx,%eax
80105d36:	05 b4 01 00 00       	add    $0x1b4,%eax
80105d3b:	8b 00                	mov    (%eax),%eax
80105d3d:	83 f8 01             	cmp    $0x1,%eax
80105d40:	75 4c                	jne    80105d8e <printMem+0xc5>
          cprintf("%d:%d ",proc->memController[i].Order,proc->memController[i].accessNumber);
80105d42:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80105d49:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d4c:	89 d0                	mov    %edx,%eax
80105d4e:	c1 e0 02             	shl    $0x2,%eax
80105d51:	01 d0                	add    %edx,%eax
80105d53:	c1 e0 02             	shl    $0x2,%eax
80105d56:	01 c8                	add    %ecx,%eax
80105d58:	05 c0 01 00 00       	add    $0x1c0,%eax
80105d5d:	8b 08                	mov    (%eax),%ecx
80105d5f:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80105d66:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d69:	89 d0                	mov    %edx,%eax
80105d6b:	c1 e0 02             	shl    $0x2,%eax
80105d6e:	01 d0                	add    %edx,%eax
80105d70:	c1 e0 02             	shl    $0x2,%eax
80105d73:	01 d8                	add    %ebx,%eax
80105d75:	05 c4 01 00 00       	add    $0x1c4,%eax
80105d7a:	8b 00                	mov    (%eax),%eax
80105d7c:	83 ec 04             	sub    $0x4,%esp
80105d7f:	51                   	push   %ecx
80105d80:	50                   	push   %eax
80105d81:	68 54 a4 10 80       	push   $0x8010a454
80105d86:	e8 53 a6 ff ff       	call   801003de <cprintf>
80105d8b:	83 c4 10             	add    $0x10,%esp
   for (int i = 0; i < allPhysicalPages; i++) {
80105d8e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105d92:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
80105d96:	7e 88                	jle    80105d20 <printMem+0x57>
   } 
     
   // }
   // } 
  }
  cprintf("\n");
80105d98:	83 ec 0c             	sub    $0xc,%esp
80105d9b:	68 2c a4 10 80       	push   $0x8010a42c
80105da0:	e8 39 a6 ff ff       	call   801003de <cprintf>
80105da5:	83 c4 10             	add    $0x10,%esp
80105da8:	eb 01                	jmp    80105dab <printMem+0xe2>
      continue;
80105daa:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105dab:	81 45 f4 e8 02 00 00 	addl   $0x2e8,-0xc(%ebp)
80105db2:	81 7d f4 94 13 12 80 	cmpl   $0x80121394,-0xc(%ebp)
80105db9:	0f 82 21 ff ff ff    	jb     80105ce0 <printMem+0x17>
}

}}
80105dbf:	90                   	nop
80105dc0:	90                   	nop
80105dc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105dc4:	c9                   	leave  
80105dc5:	c3                   	ret    

80105dc6 <readeflags>:
{
80105dc6:	55                   	push   %ebp
80105dc7:	89 e5                	mov    %esp,%ebp
80105dc9:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105dcc:	9c                   	pushf  
80105dcd:	58                   	pop    %eax
80105dce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105dd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dd4:	c9                   	leave  
80105dd5:	c3                   	ret    

80105dd6 <cli>:
{
80105dd6:	55                   	push   %ebp
80105dd7:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105dd9:	fa                   	cli    
}
80105dda:	90                   	nop
80105ddb:	5d                   	pop    %ebp
80105ddc:	c3                   	ret    

80105ddd <sti>:
{
80105ddd:	55                   	push   %ebp
80105dde:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105de0:	fb                   	sti    
}
80105de1:	90                   	nop
80105de2:	5d                   	pop    %ebp
80105de3:	c3                   	ret    

80105de4 <xchg>:
{
80105de4:	55                   	push   %ebp
80105de5:	89 e5                	mov    %esp,%ebp
80105de7:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105dea:	8b 55 08             	mov    0x8(%ebp),%edx
80105ded:	8b 45 0c             	mov    0xc(%ebp),%eax
80105df0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105df3:	f0 87 02             	lock xchg %eax,(%edx)
80105df6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dfc:	c9                   	leave  
80105dfd:	c3                   	ret    

80105dfe <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105dfe:	f3 0f 1e fb          	endbr32 
80105e02:	55                   	push   %ebp
80105e03:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105e05:	8b 45 08             	mov    0x8(%ebp),%eax
80105e08:	8b 55 0c             	mov    0xc(%ebp),%edx
80105e0b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105e0e:	8b 45 08             	mov    0x8(%ebp),%eax
80105e11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105e17:	8b 45 08             	mov    0x8(%ebp),%eax
80105e1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105e21:	90                   	nop
80105e22:	5d                   	pop    %ebp
80105e23:	c3                   	ret    

80105e24 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105e24:	f3 0f 1e fb          	endbr32 
80105e28:	55                   	push   %ebp
80105e29:	89 e5                	mov    %esp,%ebp
80105e2b:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105e2e:	e8 5f 01 00 00       	call   80105f92 <pushcli>
  if(holding(lk))
80105e33:	8b 45 08             	mov    0x8(%ebp),%eax
80105e36:	83 ec 0c             	sub    $0xc,%esp
80105e39:	50                   	push   %eax
80105e3a:	e8 25 01 00 00       	call   80105f64 <holding>
80105e3f:	83 c4 10             	add    $0x10,%esp
80105e42:	85 c0                	test   %eax,%eax
80105e44:	74 0d                	je     80105e53 <acquire+0x2f>
    panic("acquire");
80105e46:	83 ec 0c             	sub    $0xc,%esp
80105e49:	68 85 a4 10 80       	push   $0x8010a485
80105e4e:	e8 44 a7 ff ff       	call   80100597 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105e53:	90                   	nop
80105e54:	8b 45 08             	mov    0x8(%ebp),%eax
80105e57:	83 ec 08             	sub    $0x8,%esp
80105e5a:	6a 01                	push   $0x1
80105e5c:	50                   	push   %eax
80105e5d:	e8 82 ff ff ff       	call   80105de4 <xchg>
80105e62:	83 c4 10             	add    $0x10,%esp
80105e65:	85 c0                	test   %eax,%eax
80105e67:	75 eb                	jne    80105e54 <acquire+0x30>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105e69:	8b 45 08             	mov    0x8(%ebp),%eax
80105e6c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105e73:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105e76:	8b 45 08             	mov    0x8(%ebp),%eax
80105e79:	83 c0 0c             	add    $0xc,%eax
80105e7c:	83 ec 08             	sub    $0x8,%esp
80105e7f:	50                   	push   %eax
80105e80:	8d 45 08             	lea    0x8(%ebp),%eax
80105e83:	50                   	push   %eax
80105e84:	e8 5c 00 00 00       	call   80105ee5 <getcallerpcs>
80105e89:	83 c4 10             	add    $0x10,%esp
}
80105e8c:	90                   	nop
80105e8d:	c9                   	leave  
80105e8e:	c3                   	ret    

80105e8f <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80105e8f:	f3 0f 1e fb          	endbr32 
80105e93:	55                   	push   %ebp
80105e94:	89 e5                	mov    %esp,%ebp
80105e96:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105e99:	83 ec 0c             	sub    $0xc,%esp
80105e9c:	ff 75 08             	pushl  0x8(%ebp)
80105e9f:	e8 c0 00 00 00       	call   80105f64 <holding>
80105ea4:	83 c4 10             	add    $0x10,%esp
80105ea7:	85 c0                	test   %eax,%eax
80105ea9:	75 0d                	jne    80105eb8 <release+0x29>
    panic("release");
80105eab:	83 ec 0c             	sub    $0xc,%esp
80105eae:	68 8d a4 10 80       	push   $0x8010a48d
80105eb3:	e8 df a6 ff ff       	call   80100597 <panic>

  lk->pcs[0] = 0;
80105eb8:	8b 45 08             	mov    0x8(%ebp),%eax
80105ebb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105ec2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ec5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105ecc:	8b 45 08             	mov    0x8(%ebp),%eax
80105ecf:	83 ec 08             	sub    $0x8,%esp
80105ed2:	6a 00                	push   $0x0
80105ed4:	50                   	push   %eax
80105ed5:	e8 0a ff ff ff       	call   80105de4 <xchg>
80105eda:	83 c4 10             	add    $0x10,%esp

  popcli();
80105edd:	e8 f9 00 00 00       	call   80105fdb <popcli>
}
80105ee2:	90                   	nop
80105ee3:	c9                   	leave  
80105ee4:	c3                   	ret    

80105ee5 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105ee5:	f3 0f 1e fb          	endbr32 
80105ee9:	55                   	push   %ebp
80105eea:	89 e5                	mov    %esp,%ebp
80105eec:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105eef:	8b 45 08             	mov    0x8(%ebp),%eax
80105ef2:	83 e8 08             	sub    $0x8,%eax
80105ef5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105ef8:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105eff:	eb 38                	jmp    80105f39 <getcallerpcs+0x54>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105f01:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105f05:	74 53                	je     80105f5a <getcallerpcs+0x75>
80105f07:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105f0e:	76 4a                	jbe    80105f5a <getcallerpcs+0x75>
80105f10:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105f14:	74 44                	je     80105f5a <getcallerpcs+0x75>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105f16:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105f20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f23:	01 c2                	add    %eax,%edx
80105f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f28:	8b 40 04             	mov    0x4(%eax),%eax
80105f2b:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105f2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f30:	8b 00                	mov    (%eax),%eax
80105f32:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105f35:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105f39:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105f3d:	7e c2                	jle    80105f01 <getcallerpcs+0x1c>
  }
  for(; i < 10; i++)
80105f3f:	eb 19                	jmp    80105f5a <getcallerpcs+0x75>
    pcs[i] = 0;
80105f41:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105f44:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f4e:	01 d0                	add    %edx,%eax
80105f50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80105f56:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105f5a:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105f5e:	7e e1                	jle    80105f41 <getcallerpcs+0x5c>
}
80105f60:	90                   	nop
80105f61:	90                   	nop
80105f62:	c9                   	leave  
80105f63:	c3                   	ret    

80105f64 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105f64:	f3 0f 1e fb          	endbr32 
80105f68:	55                   	push   %ebp
80105f69:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
80105f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6e:	8b 00                	mov    (%eax),%eax
80105f70:	85 c0                	test   %eax,%eax
80105f72:	74 17                	je     80105f8b <holding+0x27>
80105f74:	8b 45 08             	mov    0x8(%ebp),%eax
80105f77:	8b 50 08             	mov    0x8(%eax),%edx
80105f7a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105f80:	39 c2                	cmp    %eax,%edx
80105f82:	75 07                	jne    80105f8b <holding+0x27>
80105f84:	b8 01 00 00 00       	mov    $0x1,%eax
80105f89:	eb 05                	jmp    80105f90 <holding+0x2c>
80105f8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f90:	5d                   	pop    %ebp
80105f91:	c3                   	ret    

80105f92 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105f92:	f3 0f 1e fb          	endbr32 
80105f96:	55                   	push   %ebp
80105f97:	89 e5                	mov    %esp,%ebp
80105f99:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
80105f9c:	e8 25 fe ff ff       	call   80105dc6 <readeflags>
80105fa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105fa4:	e8 2d fe ff ff       	call   80105dd6 <cli>
  if(cpu->ncli++ == 0)
80105fa9:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105fb0:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105fb6:	8d 48 01             	lea    0x1(%eax),%ecx
80105fb9:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
80105fbf:	85 c0                	test   %eax,%eax
80105fc1:	75 15                	jne    80105fd8 <pushcli+0x46>
    cpu->intena = eflags & FL_IF;
80105fc3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105fc9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105fcc:	81 e2 00 02 00 00    	and    $0x200,%edx
80105fd2:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105fd8:	90                   	nop
80105fd9:	c9                   	leave  
80105fda:	c3                   	ret    

80105fdb <popcli>:

void
popcli(void)
{
80105fdb:	f3 0f 1e fb          	endbr32 
80105fdf:	55                   	push   %ebp
80105fe0:	89 e5                	mov    %esp,%ebp
80105fe2:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105fe5:	e8 dc fd ff ff       	call   80105dc6 <readeflags>
80105fea:	25 00 02 00 00       	and    $0x200,%eax
80105fef:	85 c0                	test   %eax,%eax
80105ff1:	74 0d                	je     80106000 <popcli+0x25>
    panic("popcli - interruptible");
80105ff3:	83 ec 0c             	sub    $0xc,%esp
80105ff6:	68 95 a4 10 80       	push   $0x8010a495
80105ffb:	e8 97 a5 ff ff       	call   80100597 <panic>
  if(--cpu->ncli < 0)
80106000:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106006:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
8010600c:	83 ea 01             	sub    $0x1,%edx
8010600f:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80106015:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010601b:	85 c0                	test   %eax,%eax
8010601d:	79 0d                	jns    8010602c <popcli+0x51>
    panic("popcli");
8010601f:	83 ec 0c             	sub    $0xc,%esp
80106022:	68 ac a4 10 80       	push   $0x8010a4ac
80106027:	e8 6b a5 ff ff       	call   80100597 <panic>
  if(cpu->ncli == 0 && cpu->intena)
8010602c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106032:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80106038:	85 c0                	test   %eax,%eax
8010603a:	75 15                	jne    80106051 <popcli+0x76>
8010603c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106042:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80106048:	85 c0                	test   %eax,%eax
8010604a:	74 05                	je     80106051 <popcli+0x76>
    sti();
8010604c:	e8 8c fd ff ff       	call   80105ddd <sti>
}
80106051:	90                   	nop
80106052:	c9                   	leave  
80106053:	c3                   	ret    

80106054 <stosb>:
{
80106054:	55                   	push   %ebp
80106055:	89 e5                	mov    %esp,%ebp
80106057:	57                   	push   %edi
80106058:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80106059:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010605c:	8b 55 10             	mov    0x10(%ebp),%edx
8010605f:	8b 45 0c             	mov    0xc(%ebp),%eax
80106062:	89 cb                	mov    %ecx,%ebx
80106064:	89 df                	mov    %ebx,%edi
80106066:	89 d1                	mov    %edx,%ecx
80106068:	fc                   	cld    
80106069:	f3 aa                	rep stos %al,%es:(%edi)
8010606b:	89 ca                	mov    %ecx,%edx
8010606d:	89 fb                	mov    %edi,%ebx
8010606f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106072:	89 55 10             	mov    %edx,0x10(%ebp)
}
80106075:	90                   	nop
80106076:	5b                   	pop    %ebx
80106077:	5f                   	pop    %edi
80106078:	5d                   	pop    %ebp
80106079:	c3                   	ret    

8010607a <stosl>:
{
8010607a:	55                   	push   %ebp
8010607b:	89 e5                	mov    %esp,%ebp
8010607d:	57                   	push   %edi
8010607e:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010607f:	8b 4d 08             	mov    0x8(%ebp),%ecx
80106082:	8b 55 10             	mov    0x10(%ebp),%edx
80106085:	8b 45 0c             	mov    0xc(%ebp),%eax
80106088:	89 cb                	mov    %ecx,%ebx
8010608a:	89 df                	mov    %ebx,%edi
8010608c:	89 d1                	mov    %edx,%ecx
8010608e:	fc                   	cld    
8010608f:	f3 ab                	rep stos %eax,%es:(%edi)
80106091:	89 ca                	mov    %ecx,%edx
80106093:	89 fb                	mov    %edi,%ebx
80106095:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106098:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010609b:	90                   	nop
8010609c:	5b                   	pop    %ebx
8010609d:	5f                   	pop    %edi
8010609e:	5d                   	pop    %ebp
8010609f:	c3                   	ret    

801060a0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801060a0:	f3 0f 1e fb          	endbr32 
801060a4:	55                   	push   %ebp
801060a5:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801060a7:	8b 45 08             	mov    0x8(%ebp),%eax
801060aa:	83 e0 03             	and    $0x3,%eax
801060ad:	85 c0                	test   %eax,%eax
801060af:	75 43                	jne    801060f4 <memset+0x54>
801060b1:	8b 45 10             	mov    0x10(%ebp),%eax
801060b4:	83 e0 03             	and    $0x3,%eax
801060b7:	85 c0                	test   %eax,%eax
801060b9:	75 39                	jne    801060f4 <memset+0x54>
    c &= 0xFF;
801060bb:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801060c2:	8b 45 10             	mov    0x10(%ebp),%eax
801060c5:	c1 e8 02             	shr    $0x2,%eax
801060c8:	89 c1                	mov    %eax,%ecx
801060ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801060cd:	c1 e0 18             	shl    $0x18,%eax
801060d0:	89 c2                	mov    %eax,%edx
801060d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801060d5:	c1 e0 10             	shl    $0x10,%eax
801060d8:	09 c2                	or     %eax,%edx
801060da:	8b 45 0c             	mov    0xc(%ebp),%eax
801060dd:	c1 e0 08             	shl    $0x8,%eax
801060e0:	09 d0                	or     %edx,%eax
801060e2:	0b 45 0c             	or     0xc(%ebp),%eax
801060e5:	51                   	push   %ecx
801060e6:	50                   	push   %eax
801060e7:	ff 75 08             	pushl  0x8(%ebp)
801060ea:	e8 8b ff ff ff       	call   8010607a <stosl>
801060ef:	83 c4 0c             	add    $0xc,%esp
801060f2:	eb 12                	jmp    80106106 <memset+0x66>
  } else
    stosb(dst, c, n);
801060f4:	8b 45 10             	mov    0x10(%ebp),%eax
801060f7:	50                   	push   %eax
801060f8:	ff 75 0c             	pushl  0xc(%ebp)
801060fb:	ff 75 08             	pushl  0x8(%ebp)
801060fe:	e8 51 ff ff ff       	call   80106054 <stosb>
80106103:	83 c4 0c             	add    $0xc,%esp
  return dst;
80106106:	8b 45 08             	mov    0x8(%ebp),%eax
}
80106109:	c9                   	leave  
8010610a:	c3                   	ret    

8010610b <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010610b:	f3 0f 1e fb          	endbr32 
8010610f:	55                   	push   %ebp
80106110:	89 e5                	mov    %esp,%ebp
80106112:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80106115:	8b 45 08             	mov    0x8(%ebp),%eax
80106118:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010611b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010611e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80106121:	eb 30                	jmp    80106153 <memcmp+0x48>
    if(*s1 != *s2)
80106123:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106126:	0f b6 10             	movzbl (%eax),%edx
80106129:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010612c:	0f b6 00             	movzbl (%eax),%eax
8010612f:	38 c2                	cmp    %al,%dl
80106131:	74 18                	je     8010614b <memcmp+0x40>
      return *s1 - *s2;
80106133:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106136:	0f b6 00             	movzbl (%eax),%eax
80106139:	0f b6 d0             	movzbl %al,%edx
8010613c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010613f:	0f b6 00             	movzbl (%eax),%eax
80106142:	0f b6 c0             	movzbl %al,%eax
80106145:	29 c2                	sub    %eax,%edx
80106147:	89 d0                	mov    %edx,%eax
80106149:	eb 1a                	jmp    80106165 <memcmp+0x5a>
    s1++, s2++;
8010614b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010614f:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80106153:	8b 45 10             	mov    0x10(%ebp),%eax
80106156:	8d 50 ff             	lea    -0x1(%eax),%edx
80106159:	89 55 10             	mov    %edx,0x10(%ebp)
8010615c:	85 c0                	test   %eax,%eax
8010615e:	75 c3                	jne    80106123 <memcmp+0x18>
  }

  return 0;
80106160:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106165:	c9                   	leave  
80106166:	c3                   	ret    

80106167 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80106167:	f3 0f 1e fb          	endbr32 
8010616b:	55                   	push   %ebp
8010616c:	89 e5                	mov    %esp,%ebp
8010616e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80106171:	8b 45 0c             	mov    0xc(%ebp),%eax
80106174:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80106177:	8b 45 08             	mov    0x8(%ebp),%eax
8010617a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010617d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80106180:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80106183:	73 54                	jae    801061d9 <memmove+0x72>
80106185:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106188:	8b 45 10             	mov    0x10(%ebp),%eax
8010618b:	01 d0                	add    %edx,%eax
8010618d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80106190:	73 47                	jae    801061d9 <memmove+0x72>
    s += n;
80106192:	8b 45 10             	mov    0x10(%ebp),%eax
80106195:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80106198:	8b 45 10             	mov    0x10(%ebp),%eax
8010619b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010619e:	eb 13                	jmp    801061b3 <memmove+0x4c>
      *--d = *--s;
801061a0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801061a4:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801061a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801061ab:	0f b6 10             	movzbl (%eax),%edx
801061ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
801061b1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801061b3:	8b 45 10             	mov    0x10(%ebp),%eax
801061b6:	8d 50 ff             	lea    -0x1(%eax),%edx
801061b9:	89 55 10             	mov    %edx,0x10(%ebp)
801061bc:	85 c0                	test   %eax,%eax
801061be:	75 e0                	jne    801061a0 <memmove+0x39>
  if(s < d && s + n > d){
801061c0:	eb 24                	jmp    801061e6 <memmove+0x7f>
  } else
    while(n-- > 0)
      *d++ = *s++;
801061c2:	8b 55 fc             	mov    -0x4(%ebp),%edx
801061c5:	8d 42 01             	lea    0x1(%edx),%eax
801061c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
801061cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801061ce:	8d 48 01             	lea    0x1(%eax),%ecx
801061d1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801061d4:	0f b6 12             	movzbl (%edx),%edx
801061d7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801061d9:	8b 45 10             	mov    0x10(%ebp),%eax
801061dc:	8d 50 ff             	lea    -0x1(%eax),%edx
801061df:	89 55 10             	mov    %edx,0x10(%ebp)
801061e2:	85 c0                	test   %eax,%eax
801061e4:	75 dc                	jne    801061c2 <memmove+0x5b>

  return dst;
801061e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
801061e9:	c9                   	leave  
801061ea:	c3                   	ret    

801061eb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801061eb:	f3 0f 1e fb          	endbr32 
801061ef:	55                   	push   %ebp
801061f0:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801061f2:	ff 75 10             	pushl  0x10(%ebp)
801061f5:	ff 75 0c             	pushl  0xc(%ebp)
801061f8:	ff 75 08             	pushl  0x8(%ebp)
801061fb:	e8 67 ff ff ff       	call   80106167 <memmove>
80106200:	83 c4 0c             	add    $0xc,%esp
}
80106203:	c9                   	leave  
80106204:	c3                   	ret    

80106205 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80106205:	f3 0f 1e fb          	endbr32 
80106209:	55                   	push   %ebp
8010620a:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010620c:	eb 0c                	jmp    8010621a <strncmp+0x15>
    n--, p++, q++;
8010620e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80106212:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80106216:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010621a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010621e:	74 1a                	je     8010623a <strncmp+0x35>
80106220:	8b 45 08             	mov    0x8(%ebp),%eax
80106223:	0f b6 00             	movzbl (%eax),%eax
80106226:	84 c0                	test   %al,%al
80106228:	74 10                	je     8010623a <strncmp+0x35>
8010622a:	8b 45 08             	mov    0x8(%ebp),%eax
8010622d:	0f b6 10             	movzbl (%eax),%edx
80106230:	8b 45 0c             	mov    0xc(%ebp),%eax
80106233:	0f b6 00             	movzbl (%eax),%eax
80106236:	38 c2                	cmp    %al,%dl
80106238:	74 d4                	je     8010620e <strncmp+0x9>
  if(n == 0)
8010623a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010623e:	75 07                	jne    80106247 <strncmp+0x42>
    return 0;
80106240:	b8 00 00 00 00       	mov    $0x0,%eax
80106245:	eb 16                	jmp    8010625d <strncmp+0x58>
  return (uchar)*p - (uchar)*q;
80106247:	8b 45 08             	mov    0x8(%ebp),%eax
8010624a:	0f b6 00             	movzbl (%eax),%eax
8010624d:	0f b6 d0             	movzbl %al,%edx
80106250:	8b 45 0c             	mov    0xc(%ebp),%eax
80106253:	0f b6 00             	movzbl (%eax),%eax
80106256:	0f b6 c0             	movzbl %al,%eax
80106259:	29 c2                	sub    %eax,%edx
8010625b:	89 d0                	mov    %edx,%eax
}
8010625d:	5d                   	pop    %ebp
8010625e:	c3                   	ret    

8010625f <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
8010625f:	f3 0f 1e fb          	endbr32 
80106263:	55                   	push   %ebp
80106264:	89 e5                	mov    %esp,%ebp
80106266:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80106269:	8b 45 08             	mov    0x8(%ebp),%eax
8010626c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
8010626f:	90                   	nop
80106270:	8b 45 10             	mov    0x10(%ebp),%eax
80106273:	8d 50 ff             	lea    -0x1(%eax),%edx
80106276:	89 55 10             	mov    %edx,0x10(%ebp)
80106279:	85 c0                	test   %eax,%eax
8010627b:	7e 2c                	jle    801062a9 <strncpy+0x4a>
8010627d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106280:	8d 42 01             	lea    0x1(%edx),%eax
80106283:	89 45 0c             	mov    %eax,0xc(%ebp)
80106286:	8b 45 08             	mov    0x8(%ebp),%eax
80106289:	8d 48 01             	lea    0x1(%eax),%ecx
8010628c:	89 4d 08             	mov    %ecx,0x8(%ebp)
8010628f:	0f b6 12             	movzbl (%edx),%edx
80106292:	88 10                	mov    %dl,(%eax)
80106294:	0f b6 00             	movzbl (%eax),%eax
80106297:	84 c0                	test   %al,%al
80106299:	75 d5                	jne    80106270 <strncpy+0x11>
    ;
  while(n-- > 0)
8010629b:	eb 0c                	jmp    801062a9 <strncpy+0x4a>
    *s++ = 0;
8010629d:	8b 45 08             	mov    0x8(%ebp),%eax
801062a0:	8d 50 01             	lea    0x1(%eax),%edx
801062a3:	89 55 08             	mov    %edx,0x8(%ebp)
801062a6:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801062a9:	8b 45 10             	mov    0x10(%ebp),%eax
801062ac:	8d 50 ff             	lea    -0x1(%eax),%edx
801062af:	89 55 10             	mov    %edx,0x10(%ebp)
801062b2:	85 c0                	test   %eax,%eax
801062b4:	7f e7                	jg     8010629d <strncpy+0x3e>
  return os;
801062b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801062b9:	c9                   	leave  
801062ba:	c3                   	ret    

801062bb <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801062bb:	f3 0f 1e fb          	endbr32 
801062bf:	55                   	push   %ebp
801062c0:	89 e5                	mov    %esp,%ebp
801062c2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801062c5:	8b 45 08             	mov    0x8(%ebp),%eax
801062c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801062cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062cf:	7f 05                	jg     801062d6 <safestrcpy+0x1b>
    return os;
801062d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801062d4:	eb 31                	jmp    80106307 <safestrcpy+0x4c>
  while(--n > 0 && (*s++ = *t++) != 0)
801062d6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801062da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801062de:	7e 1e                	jle    801062fe <safestrcpy+0x43>
801062e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801062e3:	8d 42 01             	lea    0x1(%edx),%eax
801062e6:	89 45 0c             	mov    %eax,0xc(%ebp)
801062e9:	8b 45 08             	mov    0x8(%ebp),%eax
801062ec:	8d 48 01             	lea    0x1(%eax),%ecx
801062ef:	89 4d 08             	mov    %ecx,0x8(%ebp)
801062f2:	0f b6 12             	movzbl (%edx),%edx
801062f5:	88 10                	mov    %dl,(%eax)
801062f7:	0f b6 00             	movzbl (%eax),%eax
801062fa:	84 c0                	test   %al,%al
801062fc:	75 d8                	jne    801062d6 <safestrcpy+0x1b>
    ;
  *s = 0;
801062fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106301:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80106304:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106307:	c9                   	leave  
80106308:	c3                   	ret    

80106309 <strlen>:

int
strlen(const char *s)
{
80106309:	f3 0f 1e fb          	endbr32 
8010630d:	55                   	push   %ebp
8010630e:	89 e5                	mov    %esp,%ebp
80106310:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80106313:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010631a:	eb 04                	jmp    80106320 <strlen+0x17>
8010631c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80106320:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106323:	8b 45 08             	mov    0x8(%ebp),%eax
80106326:	01 d0                	add    %edx,%eax
80106328:	0f b6 00             	movzbl (%eax),%eax
8010632b:	84 c0                	test   %al,%al
8010632d:	75 ed                	jne    8010631c <strlen+0x13>
    ;
  return n;
8010632f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106332:	c9                   	leave  
80106333:	c3                   	ret    

80106334 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80106334:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80106338:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
8010633c:	55                   	push   %ebp
  pushl %ebx
8010633d:	53                   	push   %ebx
  pushl %esi
8010633e:	56                   	push   %esi
  pushl %edi
8010633f:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80106340:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80106342:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80106344:	5f                   	pop    %edi
  popl %esi
80106345:	5e                   	pop    %esi
  popl %ebx
80106346:	5b                   	pop    %ebx
  popl %ebp
80106347:	5d                   	pop    %ebp
  ret
80106348:	c3                   	ret    

80106349 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80106349:	f3 0f 1e fb          	endbr32 
8010634d:	55                   	push   %ebp
8010634e:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80106350:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106356:	8b 00                	mov    (%eax),%eax
80106358:	39 45 08             	cmp    %eax,0x8(%ebp)
8010635b:	73 12                	jae    8010636f <fetchint+0x26>
8010635d:	8b 45 08             	mov    0x8(%ebp),%eax
80106360:	8d 50 04             	lea    0x4(%eax),%edx
80106363:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106369:	8b 00                	mov    (%eax),%eax
8010636b:	39 c2                	cmp    %eax,%edx
8010636d:	76 07                	jbe    80106376 <fetchint+0x2d>
    return -1;
8010636f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106374:	eb 0f                	jmp    80106385 <fetchint+0x3c>
  *ip = *(int*)(addr);
80106376:	8b 45 08             	mov    0x8(%ebp),%eax
80106379:	8b 10                	mov    (%eax),%edx
8010637b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010637e:	89 10                	mov    %edx,(%eax)
  return 0;
80106380:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106385:	5d                   	pop    %ebp
80106386:	c3                   	ret    

80106387 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80106387:	f3 0f 1e fb          	endbr32 
8010638b:	55                   	push   %ebp
8010638c:	89 e5                	mov    %esp,%ebp
8010638e:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80106391:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106397:	8b 00                	mov    (%eax),%eax
80106399:	39 45 08             	cmp    %eax,0x8(%ebp)
8010639c:	72 07                	jb     801063a5 <fetchstr+0x1e>
    return -1;
8010639e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063a3:	eb 46                	jmp    801063eb <fetchstr+0x64>
  *pp = (char*)addr;
801063a5:	8b 55 08             	mov    0x8(%ebp),%edx
801063a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801063ab:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801063ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063b3:	8b 00                	mov    (%eax),%eax
801063b5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801063b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801063bb:	8b 00                	mov    (%eax),%eax
801063bd:	89 45 fc             	mov    %eax,-0x4(%ebp)
801063c0:	eb 1c                	jmp    801063de <fetchstr+0x57>
    if(*s == 0)
801063c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801063c5:	0f b6 00             	movzbl (%eax),%eax
801063c8:	84 c0                	test   %al,%al
801063ca:	75 0e                	jne    801063da <fetchstr+0x53>
      return s - *pp;
801063cc:	8b 45 0c             	mov    0xc(%ebp),%eax
801063cf:	8b 00                	mov    (%eax),%eax
801063d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
801063d4:	29 c2                	sub    %eax,%edx
801063d6:	89 d0                	mov    %edx,%eax
801063d8:	eb 11                	jmp    801063eb <fetchstr+0x64>
  for(s = *pp; s < ep; s++)
801063da:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801063de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801063e1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801063e4:	72 dc                	jb     801063c2 <fetchstr+0x3b>
  return -1;
801063e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801063eb:	c9                   	leave  
801063ec:	c3                   	ret    

801063ed <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801063ed:	f3 0f 1e fb          	endbr32 
801063f1:	55                   	push   %ebp
801063f2:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801063f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063fa:	8b 40 18             	mov    0x18(%eax),%eax
801063fd:	8b 40 44             	mov    0x44(%eax),%eax
80106400:	8b 55 08             	mov    0x8(%ebp),%edx
80106403:	c1 e2 02             	shl    $0x2,%edx
80106406:	01 d0                	add    %edx,%eax
80106408:	83 c0 04             	add    $0x4,%eax
8010640b:	ff 75 0c             	pushl  0xc(%ebp)
8010640e:	50                   	push   %eax
8010640f:	e8 35 ff ff ff       	call   80106349 <fetchint>
80106414:	83 c4 08             	add    $0x8,%esp
}
80106417:	c9                   	leave  
80106418:	c3                   	ret    

80106419 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80106419:	f3 0f 1e fb          	endbr32 
8010641d:	55                   	push   %ebp
8010641e:	89 e5                	mov    %esp,%ebp
80106420:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
80106423:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106426:	50                   	push   %eax
80106427:	ff 75 08             	pushl  0x8(%ebp)
8010642a:	e8 be ff ff ff       	call   801063ed <argint>
8010642f:	83 c4 08             	add    $0x8,%esp
80106432:	85 c0                	test   %eax,%eax
80106434:	79 07                	jns    8010643d <argptr+0x24>
    return -1;
80106436:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643b:	eb 3b                	jmp    80106478 <argptr+0x5f>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
8010643d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106443:	8b 00                	mov    (%eax),%eax
80106445:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106448:	39 d0                	cmp    %edx,%eax
8010644a:	76 16                	jbe    80106462 <argptr+0x49>
8010644c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010644f:	89 c2                	mov    %eax,%edx
80106451:	8b 45 10             	mov    0x10(%ebp),%eax
80106454:	01 c2                	add    %eax,%edx
80106456:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010645c:	8b 00                	mov    (%eax),%eax
8010645e:	39 c2                	cmp    %eax,%edx
80106460:	76 07                	jbe    80106469 <argptr+0x50>
    return -1;
80106462:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106467:	eb 0f                	jmp    80106478 <argptr+0x5f>
  *pp = (char*)i;
80106469:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010646c:	89 c2                	mov    %eax,%edx
8010646e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106471:	89 10                	mov    %edx,(%eax)
  return 0;
80106473:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106478:	c9                   	leave  
80106479:	c3                   	ret    

8010647a <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010647a:	f3 0f 1e fb          	endbr32 
8010647e:	55                   	push   %ebp
8010647f:	89 e5                	mov    %esp,%ebp
80106481:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80106484:	8d 45 fc             	lea    -0x4(%ebp),%eax
80106487:	50                   	push   %eax
80106488:	ff 75 08             	pushl  0x8(%ebp)
8010648b:	e8 5d ff ff ff       	call   801063ed <argint>
80106490:	83 c4 08             	add    $0x8,%esp
80106493:	85 c0                	test   %eax,%eax
80106495:	79 07                	jns    8010649e <argstr+0x24>
    return -1;
80106497:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649c:	eb 0f                	jmp    801064ad <argstr+0x33>
  return fetchstr(addr, pp);
8010649e:	8b 45 fc             	mov    -0x4(%ebp),%eax
801064a1:	ff 75 0c             	pushl  0xc(%ebp)
801064a4:	50                   	push   %eax
801064a5:	e8 dd fe ff ff       	call   80106387 <fetchstr>
801064aa:	83 c4 08             	add    $0x8,%esp
}
801064ad:	c9                   	leave  
801064ae:	c3                   	ret    

801064af <syscall>:
[SYS_printMem] sys_printMem,
};

void
syscall(void)
{
801064af:	f3 0f 1e fb          	endbr32 
801064b3:	55                   	push   %ebp
801064b4:	89 e5                	mov    %esp,%ebp
801064b6:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
801064b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064bf:	8b 40 18             	mov    0x18(%eax),%eax
801064c2:	8b 40 1c             	mov    0x1c(%eax),%eax
801064c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801064c8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064cc:	7e 32                	jle    80106500 <syscall+0x51>
801064ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d1:	83 f8 16             	cmp    $0x16,%eax
801064d4:	77 2a                	ja     80106500 <syscall+0x51>
801064d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d9:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
801064e0:	85 c0                	test   %eax,%eax
801064e2:	74 1c                	je     80106500 <syscall+0x51>
    proc->tf->eax = syscalls[num]();
801064e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064e7:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
801064ee:	ff d0                	call   *%eax
801064f0:	89 c2                	mov    %eax,%edx
801064f2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064f8:	8b 40 18             	mov    0x18(%eax),%eax
801064fb:	89 50 1c             	mov    %edx,0x1c(%eax)
801064fe:	eb 35                	jmp    80106535 <syscall+0x86>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80106500:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106506:	8d 50 6c             	lea    0x6c(%eax),%edx
80106509:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
8010650f:	8b 40 10             	mov    0x10(%eax),%eax
80106512:	ff 75 f4             	pushl  -0xc(%ebp)
80106515:	52                   	push   %edx
80106516:	50                   	push   %eax
80106517:	68 b3 a4 10 80       	push   $0x8010a4b3
8010651c:	e8 bd 9e ff ff       	call   801003de <cprintf>
80106521:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
80106524:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652a:	8b 40 18             	mov    0x18(%eax),%eax
8010652d:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106534:	90                   	nop
80106535:	90                   	nop
80106536:	c9                   	leave  
80106537:	c3                   	ret    

80106538 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80106538:	f3 0f 1e fb          	endbr32 
8010653c:	55                   	push   %ebp
8010653d:	89 e5                	mov    %esp,%ebp
8010653f:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106542:	83 ec 08             	sub    $0x8,%esp
80106545:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106548:	50                   	push   %eax
80106549:	ff 75 08             	pushl  0x8(%ebp)
8010654c:	e8 9c fe ff ff       	call   801063ed <argint>
80106551:	83 c4 10             	add    $0x10,%esp
80106554:	85 c0                	test   %eax,%eax
80106556:	79 07                	jns    8010655f <argfd+0x27>
    return -1;
80106558:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655d:	eb 50                	jmp    801065af <argfd+0x77>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010655f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106562:	85 c0                	test   %eax,%eax
80106564:	78 21                	js     80106587 <argfd+0x4f>
80106566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106569:	83 f8 0f             	cmp    $0xf,%eax
8010656c:	7f 19                	jg     80106587 <argfd+0x4f>
8010656e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106574:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106577:	83 c2 08             	add    $0x8,%edx
8010657a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010657e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106581:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106585:	75 07                	jne    8010658e <argfd+0x56>
    return -1;
80106587:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010658c:	eb 21                	jmp    801065af <argfd+0x77>
  if(pfd)
8010658e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106592:	74 08                	je     8010659c <argfd+0x64>
    *pfd = fd;
80106594:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106597:	8b 45 0c             	mov    0xc(%ebp),%eax
8010659a:	89 10                	mov    %edx,(%eax)
  if(pf)
8010659c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801065a0:	74 08                	je     801065aa <argfd+0x72>
    *pf = f;
801065a2:	8b 45 10             	mov    0x10(%ebp),%eax
801065a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065a8:	89 10                	mov    %edx,(%eax)
  return 0;
801065aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065af:	c9                   	leave  
801065b0:	c3                   	ret    

801065b1 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801065b1:	f3 0f 1e fb          	endbr32 
801065b5:	55                   	push   %ebp
801065b6:	89 e5                	mov    %esp,%ebp
801065b8:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801065bb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801065c2:	eb 30                	jmp    801065f4 <fdalloc+0x43>
    if(proc->ofile[fd] == 0){
801065c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
801065cd:	83 c2 08             	add    $0x8,%edx
801065d0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801065d4:	85 c0                	test   %eax,%eax
801065d6:	75 18                	jne    801065f0 <fdalloc+0x3f>
      proc->ofile[fd] = f;
801065d8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065de:	8b 55 fc             	mov    -0x4(%ebp),%edx
801065e1:	8d 4a 08             	lea    0x8(%edx),%ecx
801065e4:	8b 55 08             	mov    0x8(%ebp),%edx
801065e7:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801065eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801065ee:	eb 0f                	jmp    801065ff <fdalloc+0x4e>
  for(fd = 0; fd < NOFILE; fd++){
801065f0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801065f4:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801065f8:	7e ca                	jle    801065c4 <fdalloc+0x13>
    }
  }
  return -1;
801065fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801065ff:	c9                   	leave  
80106600:	c3                   	ret    

80106601 <sys_dup>:

int
sys_dup(void)
{
80106601:	f3 0f 1e fb          	endbr32 
80106605:	55                   	push   %ebp
80106606:	89 e5                	mov    %esp,%ebp
80106608:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
8010660b:	83 ec 04             	sub    $0x4,%esp
8010660e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106611:	50                   	push   %eax
80106612:	6a 00                	push   $0x0
80106614:	6a 00                	push   $0x0
80106616:	e8 1d ff ff ff       	call   80106538 <argfd>
8010661b:	83 c4 10             	add    $0x10,%esp
8010661e:	85 c0                	test   %eax,%eax
80106620:	79 07                	jns    80106629 <sys_dup+0x28>
    return -1;
80106622:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106627:	eb 31                	jmp    8010665a <sys_dup+0x59>
  if((fd=fdalloc(f)) < 0)
80106629:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010662c:	83 ec 0c             	sub    $0xc,%esp
8010662f:	50                   	push   %eax
80106630:	e8 7c ff ff ff       	call   801065b1 <fdalloc>
80106635:	83 c4 10             	add    $0x10,%esp
80106638:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010663b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010663f:	79 07                	jns    80106648 <sys_dup+0x47>
    return -1;
80106641:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106646:	eb 12                	jmp    8010665a <sys_dup+0x59>
  filedup(f);
80106648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010664b:	83 ec 0c             	sub    $0xc,%esp
8010664e:	50                   	push   %eax
8010664f:	e8 1b aa ff ff       	call   8010106f <filedup>
80106654:	83 c4 10             	add    $0x10,%esp
  return fd;
80106657:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010665a:	c9                   	leave  
8010665b:	c3                   	ret    

8010665c <sys_read>:

int
sys_read(void)
{
8010665c:	f3 0f 1e fb          	endbr32 
80106660:	55                   	push   %ebp
80106661:	89 e5                	mov    %esp,%ebp
80106663:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80106666:	83 ec 04             	sub    $0x4,%esp
80106669:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010666c:	50                   	push   %eax
8010666d:	6a 00                	push   $0x0
8010666f:	6a 00                	push   $0x0
80106671:	e8 c2 fe ff ff       	call   80106538 <argfd>
80106676:	83 c4 10             	add    $0x10,%esp
80106679:	85 c0                	test   %eax,%eax
8010667b:	78 2e                	js     801066ab <sys_read+0x4f>
8010667d:	83 ec 08             	sub    $0x8,%esp
80106680:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106683:	50                   	push   %eax
80106684:	6a 02                	push   $0x2
80106686:	e8 62 fd ff ff       	call   801063ed <argint>
8010668b:	83 c4 10             	add    $0x10,%esp
8010668e:	85 c0                	test   %eax,%eax
80106690:	78 19                	js     801066ab <sys_read+0x4f>
80106692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106695:	83 ec 04             	sub    $0x4,%esp
80106698:	50                   	push   %eax
80106699:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010669c:	50                   	push   %eax
8010669d:	6a 01                	push   $0x1
8010669f:	e8 75 fd ff ff       	call   80106419 <argptr>
801066a4:	83 c4 10             	add    $0x10,%esp
801066a7:	85 c0                	test   %eax,%eax
801066a9:	79 07                	jns    801066b2 <sys_read+0x56>
    return -1;
801066ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b0:	eb 17                	jmp    801066c9 <sys_read+0x6d>
  return fileread(f, p, n);
801066b2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801066b5:	8b 55 ec             	mov    -0x14(%ebp),%edx
801066b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066bb:	83 ec 04             	sub    $0x4,%esp
801066be:	51                   	push   %ecx
801066bf:	52                   	push   %edx
801066c0:	50                   	push   %eax
801066c1:	e8 45 ab ff ff       	call   8010120b <fileread>
801066c6:	83 c4 10             	add    $0x10,%esp
}
801066c9:	c9                   	leave  
801066ca:	c3                   	ret    

801066cb <sys_write>:

int
sys_write(void)
{
801066cb:	f3 0f 1e fb          	endbr32 
801066cf:	55                   	push   %ebp
801066d0:	89 e5                	mov    %esp,%ebp
801066d2:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801066d5:	83 ec 04             	sub    $0x4,%esp
801066d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066db:	50                   	push   %eax
801066dc:	6a 00                	push   $0x0
801066de:	6a 00                	push   $0x0
801066e0:	e8 53 fe ff ff       	call   80106538 <argfd>
801066e5:	83 c4 10             	add    $0x10,%esp
801066e8:	85 c0                	test   %eax,%eax
801066ea:	78 2e                	js     8010671a <sys_write+0x4f>
801066ec:	83 ec 08             	sub    $0x8,%esp
801066ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066f2:	50                   	push   %eax
801066f3:	6a 02                	push   $0x2
801066f5:	e8 f3 fc ff ff       	call   801063ed <argint>
801066fa:	83 c4 10             	add    $0x10,%esp
801066fd:	85 c0                	test   %eax,%eax
801066ff:	78 19                	js     8010671a <sys_write+0x4f>
80106701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106704:	83 ec 04             	sub    $0x4,%esp
80106707:	50                   	push   %eax
80106708:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010670b:	50                   	push   %eax
8010670c:	6a 01                	push   $0x1
8010670e:	e8 06 fd ff ff       	call   80106419 <argptr>
80106713:	83 c4 10             	add    $0x10,%esp
80106716:	85 c0                	test   %eax,%eax
80106718:	79 07                	jns    80106721 <sys_write+0x56>
    return -1;
8010671a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010671f:	eb 17                	jmp    80106738 <sys_write+0x6d>
  return filewrite(f, p, n);
80106721:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106724:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106727:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672a:	83 ec 04             	sub    $0x4,%esp
8010672d:	51                   	push   %ecx
8010672e:	52                   	push   %edx
8010672f:	50                   	push   %eax
80106730:	e8 92 ab ff ff       	call   801012c7 <filewrite>
80106735:	83 c4 10             	add    $0x10,%esp
}
80106738:	c9                   	leave  
80106739:	c3                   	ret    

8010673a <sys_close>:

int
sys_close(void)
{
8010673a:	f3 0f 1e fb          	endbr32 
8010673e:	55                   	push   %ebp
8010673f:	89 e5                	mov    %esp,%ebp
80106741:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80106744:	83 ec 04             	sub    $0x4,%esp
80106747:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010674a:	50                   	push   %eax
8010674b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010674e:	50                   	push   %eax
8010674f:	6a 00                	push   $0x0
80106751:	e8 e2 fd ff ff       	call   80106538 <argfd>
80106756:	83 c4 10             	add    $0x10,%esp
80106759:	85 c0                	test   %eax,%eax
8010675b:	79 07                	jns    80106764 <sys_close+0x2a>
    return -1;
8010675d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106762:	eb 28                	jmp    8010678c <sys_close+0x52>
  proc->ofile[fd] = 0;
80106764:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010676a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010676d:	83 c2 08             	add    $0x8,%edx
80106770:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106777:	00 
  fileclose(f);
80106778:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010677b:	83 ec 0c             	sub    $0xc,%esp
8010677e:	50                   	push   %eax
8010677f:	e8 40 a9 ff ff       	call   801010c4 <fileclose>
80106784:	83 c4 10             	add    $0x10,%esp
  return 0;
80106787:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010678c:	c9                   	leave  
8010678d:	c3                   	ret    

8010678e <sys_fstat>:

int
sys_fstat(void)
{
8010678e:	f3 0f 1e fb          	endbr32 
80106792:	55                   	push   %ebp
80106793:	89 e5                	mov    %esp,%ebp
80106795:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106798:	83 ec 04             	sub    $0x4,%esp
8010679b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010679e:	50                   	push   %eax
8010679f:	6a 00                	push   $0x0
801067a1:	6a 00                	push   $0x0
801067a3:	e8 90 fd ff ff       	call   80106538 <argfd>
801067a8:	83 c4 10             	add    $0x10,%esp
801067ab:	85 c0                	test   %eax,%eax
801067ad:	78 17                	js     801067c6 <sys_fstat+0x38>
801067af:	83 ec 04             	sub    $0x4,%esp
801067b2:	6a 14                	push   $0x14
801067b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
801067b7:	50                   	push   %eax
801067b8:	6a 01                	push   $0x1
801067ba:	e8 5a fc ff ff       	call   80106419 <argptr>
801067bf:	83 c4 10             	add    $0x10,%esp
801067c2:	85 c0                	test   %eax,%eax
801067c4:	79 07                	jns    801067cd <sys_fstat+0x3f>
    return -1;
801067c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067cb:	eb 13                	jmp    801067e0 <sys_fstat+0x52>
  return filestat(f, st);
801067cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801067d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d3:	83 ec 08             	sub    $0x8,%esp
801067d6:	52                   	push   %edx
801067d7:	50                   	push   %eax
801067d8:	e8 d3 a9 ff ff       	call   801011b0 <filestat>
801067dd:	83 c4 10             	add    $0x10,%esp
}
801067e0:	c9                   	leave  
801067e1:	c3                   	ret    

801067e2 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801067e2:	f3 0f 1e fb          	endbr32 
801067e6:	55                   	push   %ebp
801067e7:	89 e5                	mov    %esp,%ebp
801067e9:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801067ec:	83 ec 08             	sub    $0x8,%esp
801067ef:	8d 45 d8             	lea    -0x28(%ebp),%eax
801067f2:	50                   	push   %eax
801067f3:	6a 00                	push   $0x0
801067f5:	e8 80 fc ff ff       	call   8010647a <argstr>
801067fa:	83 c4 10             	add    $0x10,%esp
801067fd:	85 c0                	test   %eax,%eax
801067ff:	78 15                	js     80106816 <sys_link+0x34>
80106801:	83 ec 08             	sub    $0x8,%esp
80106804:	8d 45 dc             	lea    -0x24(%ebp),%eax
80106807:	50                   	push   %eax
80106808:	6a 01                	push   $0x1
8010680a:	e8 6b fc ff ff       	call   8010647a <argstr>
8010680f:	83 c4 10             	add    $0x10,%esp
80106812:	85 c0                	test   %eax,%eax
80106814:	79 0a                	jns    80106820 <sys_link+0x3e>
    return -1;
80106816:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010681b:	e9 68 01 00 00       	jmp    80106988 <sys_link+0x1a6>

  begin_op();
80106820:	e8 11 d6 ff ff       	call   80103e36 <begin_op>
  if((ip = namei(old)) == 0){
80106825:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106828:	83 ec 0c             	sub    $0xc,%esp
8010682b:	50                   	push   %eax
8010682c:	e8 c9 bd ff ff       	call   801025fa <namei>
80106831:	83 c4 10             	add    $0x10,%esp
80106834:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106837:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010683b:	75 0f                	jne    8010684c <sys_link+0x6a>
    end_op();
8010683d:	e8 84 d6 ff ff       	call   80103ec6 <end_op>
    return -1;
80106842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106847:	e9 3c 01 00 00       	jmp    80106988 <sys_link+0x1a6>
  }

  ilock(ip);
8010684c:	83 ec 0c             	sub    $0xc,%esp
8010684f:	ff 75 f4             	pushl  -0xc(%ebp)
80106852:	e8 ba b1 ff ff       	call   80101a11 <ilock>
80106857:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010685a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106861:	66 83 f8 01          	cmp    $0x1,%ax
80106865:	75 1d                	jne    80106884 <sys_link+0xa2>
    iunlockput(ip);
80106867:	83 ec 0c             	sub    $0xc,%esp
8010686a:	ff 75 f4             	pushl  -0xc(%ebp)
8010686d:	e8 6b b4 ff ff       	call   80101cdd <iunlockput>
80106872:	83 c4 10             	add    $0x10,%esp
    end_op();
80106875:	e8 4c d6 ff ff       	call   80103ec6 <end_op>
    return -1;
8010687a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687f:	e9 04 01 00 00       	jmp    80106988 <sys_link+0x1a6>
  }

  ip->nlink++;
80106884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106887:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010688b:	83 c0 01             	add    $0x1,%eax
8010688e:	89 c2                	mov    %eax,%edx
80106890:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106893:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106897:	83 ec 0c             	sub    $0xc,%esp
8010689a:	ff 75 f4             	pushl  -0xc(%ebp)
8010689d:	e8 89 af ff ff       	call   8010182b <iupdate>
801068a2:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801068a5:	83 ec 0c             	sub    $0xc,%esp
801068a8:	ff 75 f4             	pushl  -0xc(%ebp)
801068ab:	e8 c3 b2 ff ff       	call   80101b73 <iunlock>
801068b0:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801068b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801068b6:	83 ec 08             	sub    $0x8,%esp
801068b9:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801068bc:	52                   	push   %edx
801068bd:	50                   	push   %eax
801068be:	e8 57 bd ff ff       	call   8010261a <nameiparent>
801068c3:	83 c4 10             	add    $0x10,%esp
801068c6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068cd:	74 71                	je     80106940 <sys_link+0x15e>
    goto bad;
  ilock(dp);
801068cf:	83 ec 0c             	sub    $0xc,%esp
801068d2:	ff 75 f0             	pushl  -0x10(%ebp)
801068d5:	e8 37 b1 ff ff       	call   80101a11 <ilock>
801068da:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801068dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e0:	8b 10                	mov    (%eax),%edx
801068e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e5:	8b 00                	mov    (%eax),%eax
801068e7:	39 c2                	cmp    %eax,%edx
801068e9:	75 1d                	jne    80106908 <sys_link+0x126>
801068eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ee:	8b 40 04             	mov    0x4(%eax),%eax
801068f1:	83 ec 04             	sub    $0x4,%esp
801068f4:	50                   	push   %eax
801068f5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801068f8:	50                   	push   %eax
801068f9:	ff 75 f0             	pushl  -0x10(%ebp)
801068fc:	e8 55 ba ff ff       	call   80102356 <dirlink>
80106901:	83 c4 10             	add    $0x10,%esp
80106904:	85 c0                	test   %eax,%eax
80106906:	79 10                	jns    80106918 <sys_link+0x136>
    iunlockput(dp);
80106908:	83 ec 0c             	sub    $0xc,%esp
8010690b:	ff 75 f0             	pushl  -0x10(%ebp)
8010690e:	e8 ca b3 ff ff       	call   80101cdd <iunlockput>
80106913:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106916:	eb 29                	jmp    80106941 <sys_link+0x15f>
  }
  iunlockput(dp);
80106918:	83 ec 0c             	sub    $0xc,%esp
8010691b:	ff 75 f0             	pushl  -0x10(%ebp)
8010691e:	e8 ba b3 ff ff       	call   80101cdd <iunlockput>
80106923:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106926:	83 ec 0c             	sub    $0xc,%esp
80106929:	ff 75 f4             	pushl  -0xc(%ebp)
8010692c:	e8 b8 b2 ff ff       	call   80101be9 <iput>
80106931:	83 c4 10             	add    $0x10,%esp

  end_op();
80106934:	e8 8d d5 ff ff       	call   80103ec6 <end_op>

  return 0;
80106939:	b8 00 00 00 00       	mov    $0x0,%eax
8010693e:	eb 48                	jmp    80106988 <sys_link+0x1a6>
    goto bad;
80106940:	90                   	nop

bad:
  ilock(ip);
80106941:	83 ec 0c             	sub    $0xc,%esp
80106944:	ff 75 f4             	pushl  -0xc(%ebp)
80106947:	e8 c5 b0 ff ff       	call   80101a11 <ilock>
8010694c:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
8010694f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106952:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106956:	83 e8 01             	sub    $0x1,%eax
80106959:	89 c2                	mov    %eax,%edx
8010695b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010695e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106962:	83 ec 0c             	sub    $0xc,%esp
80106965:	ff 75 f4             	pushl  -0xc(%ebp)
80106968:	e8 be ae ff ff       	call   8010182b <iupdate>
8010696d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106970:	83 ec 0c             	sub    $0xc,%esp
80106973:	ff 75 f4             	pushl  -0xc(%ebp)
80106976:	e8 62 b3 ff ff       	call   80101cdd <iunlockput>
8010697b:	83 c4 10             	add    $0x10,%esp
  end_op();
8010697e:	e8 43 d5 ff ff       	call   80103ec6 <end_op>
  return -1;
80106983:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106988:	c9                   	leave  
80106989:	c3                   	ret    

8010698a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
int
isdirempty(struct inode *dp)
{
8010698a:	f3 0f 1e fb          	endbr32 
8010698e:	55                   	push   %ebp
8010698f:	89 e5                	mov    %esp,%ebp
80106991:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106994:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010699b:	eb 40                	jmp    801069dd <isdirempty+0x53>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010699d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a0:	6a 10                	push   $0x10
801069a2:	50                   	push   %eax
801069a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801069a6:	50                   	push   %eax
801069a7:	ff 75 08             	pushl  0x8(%ebp)
801069aa:	e8 e7 b5 ff ff       	call   80101f96 <readi>
801069af:	83 c4 10             	add    $0x10,%esp
801069b2:	83 f8 10             	cmp    $0x10,%eax
801069b5:	74 0d                	je     801069c4 <isdirempty+0x3a>
      panic("isdirempty: readi");
801069b7:	83 ec 0c             	sub    $0xc,%esp
801069ba:	68 cf a4 10 80       	push   $0x8010a4cf
801069bf:	e8 d3 9b ff ff       	call   80100597 <panic>
    if(de.inum != 0)
801069c4:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801069c8:	66 85 c0             	test   %ax,%ax
801069cb:	74 07                	je     801069d4 <isdirempty+0x4a>
      return 0;
801069cd:	b8 00 00 00 00       	mov    $0x0,%eax
801069d2:	eb 1b                	jmp    801069ef <isdirempty+0x65>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801069d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069d7:	83 c0 10             	add    $0x10,%eax
801069da:	89 45 f4             	mov    %eax,-0xc(%ebp)
801069dd:	8b 45 08             	mov    0x8(%ebp),%eax
801069e0:	8b 50 18             	mov    0x18(%eax),%edx
801069e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069e6:	39 c2                	cmp    %eax,%edx
801069e8:	77 b3                	ja     8010699d <isdirempty+0x13>
  }
  return 1;
801069ea:	b8 01 00 00 00       	mov    $0x1,%eax
}
801069ef:	c9                   	leave  
801069f0:	c3                   	ret    

801069f1 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801069f1:	f3 0f 1e fb          	endbr32 
801069f5:	55                   	push   %ebp
801069f6:	89 e5                	mov    %esp,%ebp
801069f8:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801069fb:	83 ec 08             	sub    $0x8,%esp
801069fe:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106a01:	50                   	push   %eax
80106a02:	6a 00                	push   $0x0
80106a04:	e8 71 fa ff ff       	call   8010647a <argstr>
80106a09:	83 c4 10             	add    $0x10,%esp
80106a0c:	85 c0                	test   %eax,%eax
80106a0e:	79 0a                	jns    80106a1a <sys_unlink+0x29>
    return -1;
80106a10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a15:	e9 bf 01 00 00       	jmp    80106bd9 <sys_unlink+0x1e8>

  begin_op();
80106a1a:	e8 17 d4 ff ff       	call   80103e36 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106a1f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106a22:	83 ec 08             	sub    $0x8,%esp
80106a25:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106a28:	52                   	push   %edx
80106a29:	50                   	push   %eax
80106a2a:	e8 eb bb ff ff       	call   8010261a <nameiparent>
80106a2f:	83 c4 10             	add    $0x10,%esp
80106a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a35:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a39:	75 0f                	jne    80106a4a <sys_unlink+0x59>
    end_op();
80106a3b:	e8 86 d4 ff ff       	call   80103ec6 <end_op>
    return -1;
80106a40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a45:	e9 8f 01 00 00       	jmp    80106bd9 <sys_unlink+0x1e8>
  }

  ilock(dp);
80106a4a:	83 ec 0c             	sub    $0xc,%esp
80106a4d:	ff 75 f4             	pushl  -0xc(%ebp)
80106a50:	e8 bc af ff ff       	call   80101a11 <ilock>
80106a55:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106a58:	83 ec 08             	sub    $0x8,%esp
80106a5b:	68 e1 a4 10 80       	push   $0x8010a4e1
80106a60:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106a63:	50                   	push   %eax
80106a64:	e8 10 b8 ff ff       	call   80102279 <namecmp>
80106a69:	83 c4 10             	add    $0x10,%esp
80106a6c:	85 c0                	test   %eax,%eax
80106a6e:	0f 84 49 01 00 00    	je     80106bbd <sys_unlink+0x1cc>
80106a74:	83 ec 08             	sub    $0x8,%esp
80106a77:	68 e3 a4 10 80       	push   $0x8010a4e3
80106a7c:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106a7f:	50                   	push   %eax
80106a80:	e8 f4 b7 ff ff       	call   80102279 <namecmp>
80106a85:	83 c4 10             	add    $0x10,%esp
80106a88:	85 c0                	test   %eax,%eax
80106a8a:	0f 84 2d 01 00 00    	je     80106bbd <sys_unlink+0x1cc>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106a90:	83 ec 04             	sub    $0x4,%esp
80106a93:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106a96:	50                   	push   %eax
80106a97:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106a9a:	50                   	push   %eax
80106a9b:	ff 75 f4             	pushl  -0xc(%ebp)
80106a9e:	e8 f5 b7 ff ff       	call   80102298 <dirlookup>
80106aa3:	83 c4 10             	add    $0x10,%esp
80106aa6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106aa9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106aad:	0f 84 0d 01 00 00    	je     80106bc0 <sys_unlink+0x1cf>
    goto bad;
  ilock(ip);
80106ab3:	83 ec 0c             	sub    $0xc,%esp
80106ab6:	ff 75 f0             	pushl  -0x10(%ebp)
80106ab9:	e8 53 af ff ff       	call   80101a11 <ilock>
80106abe:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80106ac1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ac4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106ac8:	66 85 c0             	test   %ax,%ax
80106acb:	7f 0d                	jg     80106ada <sys_unlink+0xe9>
    panic("unlink: nlink < 1");
80106acd:	83 ec 0c             	sub    $0xc,%esp
80106ad0:	68 e6 a4 10 80       	push   $0x8010a4e6
80106ad5:	e8 bd 9a ff ff       	call   80100597 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80106ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106add:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106ae1:	66 83 f8 01          	cmp    $0x1,%ax
80106ae5:	75 25                	jne    80106b0c <sys_unlink+0x11b>
80106ae7:	83 ec 0c             	sub    $0xc,%esp
80106aea:	ff 75 f0             	pushl  -0x10(%ebp)
80106aed:	e8 98 fe ff ff       	call   8010698a <isdirempty>
80106af2:	83 c4 10             	add    $0x10,%esp
80106af5:	85 c0                	test   %eax,%eax
80106af7:	75 13                	jne    80106b0c <sys_unlink+0x11b>
    iunlockput(ip);
80106af9:	83 ec 0c             	sub    $0xc,%esp
80106afc:	ff 75 f0             	pushl  -0x10(%ebp)
80106aff:	e8 d9 b1 ff ff       	call   80101cdd <iunlockput>
80106b04:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106b07:	e9 b5 00 00 00       	jmp    80106bc1 <sys_unlink+0x1d0>
  }

  memset(&de, 0, sizeof(de));
80106b0c:	83 ec 04             	sub    $0x4,%esp
80106b0f:	6a 10                	push   $0x10
80106b11:	6a 00                	push   $0x0
80106b13:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106b16:	50                   	push   %eax
80106b17:	e8 84 f5 ff ff       	call   801060a0 <memset>
80106b1c:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106b1f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106b22:	6a 10                	push   $0x10
80106b24:	50                   	push   %eax
80106b25:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106b28:	50                   	push   %eax
80106b29:	ff 75 f4             	pushl  -0xc(%ebp)
80106b2c:	e8 be b5 ff ff       	call   801020ef <writei>
80106b31:	83 c4 10             	add    $0x10,%esp
80106b34:	83 f8 10             	cmp    $0x10,%eax
80106b37:	74 0d                	je     80106b46 <sys_unlink+0x155>
    panic("unlink: writei");
80106b39:	83 ec 0c             	sub    $0xc,%esp
80106b3c:	68 f8 a4 10 80       	push   $0x8010a4f8
80106b41:	e8 51 9a ff ff       	call   80100597 <panic>
  if(ip->type == T_DIR){
80106b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b49:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106b4d:	66 83 f8 01          	cmp    $0x1,%ax
80106b51:	75 21                	jne    80106b74 <sys_unlink+0x183>
    dp->nlink--;
80106b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b56:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b5a:	83 e8 01             	sub    $0x1,%eax
80106b5d:	89 c2                	mov    %eax,%edx
80106b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b62:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106b66:	83 ec 0c             	sub    $0xc,%esp
80106b69:	ff 75 f4             	pushl  -0xc(%ebp)
80106b6c:	e8 ba ac ff ff       	call   8010182b <iupdate>
80106b71:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80106b74:	83 ec 0c             	sub    $0xc,%esp
80106b77:	ff 75 f4             	pushl  -0xc(%ebp)
80106b7a:	e8 5e b1 ff ff       	call   80101cdd <iunlockput>
80106b7f:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80106b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b85:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106b89:	83 e8 01             	sub    $0x1,%eax
80106b8c:	89 c2                	mov    %eax,%edx
80106b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b91:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106b95:	83 ec 0c             	sub    $0xc,%esp
80106b98:	ff 75 f0             	pushl  -0x10(%ebp)
80106b9b:	e8 8b ac ff ff       	call   8010182b <iupdate>
80106ba0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106ba3:	83 ec 0c             	sub    $0xc,%esp
80106ba6:	ff 75 f0             	pushl  -0x10(%ebp)
80106ba9:	e8 2f b1 ff ff       	call   80101cdd <iunlockput>
80106bae:	83 c4 10             	add    $0x10,%esp

  end_op();
80106bb1:	e8 10 d3 ff ff       	call   80103ec6 <end_op>

  return 0;
80106bb6:	b8 00 00 00 00       	mov    $0x0,%eax
80106bbb:	eb 1c                	jmp    80106bd9 <sys_unlink+0x1e8>
    goto bad;
80106bbd:	90                   	nop
80106bbe:	eb 01                	jmp    80106bc1 <sys_unlink+0x1d0>
    goto bad;
80106bc0:	90                   	nop

bad:
  iunlockput(dp);
80106bc1:	83 ec 0c             	sub    $0xc,%esp
80106bc4:	ff 75 f4             	pushl  -0xc(%ebp)
80106bc7:	e8 11 b1 ff ff       	call   80101cdd <iunlockput>
80106bcc:	83 c4 10             	add    $0x10,%esp
  end_op();
80106bcf:	e8 f2 d2 ff ff       	call   80103ec6 <end_op>
  return -1;
80106bd4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106bd9:	c9                   	leave  
80106bda:	c3                   	ret    

80106bdb <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
80106bdb:	f3 0f 1e fb          	endbr32 
80106bdf:	55                   	push   %ebp
80106be0:	89 e5                	mov    %esp,%ebp
80106be2:	83 ec 38             	sub    $0x38,%esp
80106be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106be8:	8b 55 10             	mov    0x10(%ebp),%edx
80106beb:	8b 45 14             	mov    0x14(%ebp),%eax
80106bee:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106bf2:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106bf6:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106bfa:	83 ec 08             	sub    $0x8,%esp
80106bfd:	8d 45 de             	lea    -0x22(%ebp),%eax
80106c00:	50                   	push   %eax
80106c01:	ff 75 08             	pushl  0x8(%ebp)
80106c04:	e8 11 ba ff ff       	call   8010261a <nameiparent>
80106c09:	83 c4 10             	add    $0x10,%esp
80106c0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106c0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106c13:	75 0a                	jne    80106c1f <create+0x44>
    return 0;
80106c15:	b8 00 00 00 00       	mov    $0x0,%eax
80106c1a:	e9 90 01 00 00       	jmp    80106daf <create+0x1d4>
  ilock(dp);
80106c1f:	83 ec 0c             	sub    $0xc,%esp
80106c22:	ff 75 f4             	pushl  -0xc(%ebp)
80106c25:	e8 e7 ad ff ff       	call   80101a11 <ilock>
80106c2a:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106c2d:	83 ec 04             	sub    $0x4,%esp
80106c30:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106c33:	50                   	push   %eax
80106c34:	8d 45 de             	lea    -0x22(%ebp),%eax
80106c37:	50                   	push   %eax
80106c38:	ff 75 f4             	pushl  -0xc(%ebp)
80106c3b:	e8 58 b6 ff ff       	call   80102298 <dirlookup>
80106c40:	83 c4 10             	add    $0x10,%esp
80106c43:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106c46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106c4a:	74 50                	je     80106c9c <create+0xc1>
    iunlockput(dp);
80106c4c:	83 ec 0c             	sub    $0xc,%esp
80106c4f:	ff 75 f4             	pushl  -0xc(%ebp)
80106c52:	e8 86 b0 ff ff       	call   80101cdd <iunlockput>
80106c57:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80106c5a:	83 ec 0c             	sub    $0xc,%esp
80106c5d:	ff 75 f0             	pushl  -0x10(%ebp)
80106c60:	e8 ac ad ff ff       	call   80101a11 <ilock>
80106c65:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80106c68:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106c6d:	75 15                	jne    80106c84 <create+0xa9>
80106c6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c72:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106c76:	66 83 f8 02          	cmp    $0x2,%ax
80106c7a:	75 08                	jne    80106c84 <create+0xa9>
      return ip;
80106c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c7f:	e9 2b 01 00 00       	jmp    80106daf <create+0x1d4>
    iunlockput(ip);
80106c84:	83 ec 0c             	sub    $0xc,%esp
80106c87:	ff 75 f0             	pushl  -0x10(%ebp)
80106c8a:	e8 4e b0 ff ff       	call   80101cdd <iunlockput>
80106c8f:	83 c4 10             	add    $0x10,%esp
    return 0;
80106c92:	b8 00 00 00 00       	mov    $0x0,%eax
80106c97:	e9 13 01 00 00       	jmp    80106daf <create+0x1d4>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106c9c:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca3:	8b 00                	mov    (%eax),%eax
80106ca5:	83 ec 08             	sub    $0x8,%esp
80106ca8:	52                   	push   %edx
80106ca9:	50                   	push   %eax
80106caa:	e8 a1 aa ff ff       	call   80101750 <ialloc>
80106caf:	83 c4 10             	add    $0x10,%esp
80106cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106cb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106cb9:	75 0d                	jne    80106cc8 <create+0xed>
    panic("create: ialloc");
80106cbb:	83 ec 0c             	sub    $0xc,%esp
80106cbe:	68 07 a5 10 80       	push   $0x8010a507
80106cc3:	e8 cf 98 ff ff       	call   80100597 <panic>

  ilock(ip);
80106cc8:	83 ec 0c             	sub    $0xc,%esp
80106ccb:	ff 75 f0             	pushl  -0x10(%ebp)
80106cce:	e8 3e ad ff ff       	call   80101a11 <ilock>
80106cd3:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80106cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cd9:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80106cdd:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80106ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ce4:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80106ce8:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80106cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106cef:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80106cf5:	83 ec 0c             	sub    $0xc,%esp
80106cf8:	ff 75 f0             	pushl  -0x10(%ebp)
80106cfb:	e8 2b ab ff ff       	call   8010182b <iupdate>
80106d00:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106d03:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106d08:	75 6a                	jne    80106d74 <create+0x199>
    dp->nlink++;  // for ".."
80106d0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d0d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106d11:	83 c0 01             	add    $0x1,%eax
80106d14:	89 c2                	mov    %eax,%edx
80106d16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d19:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106d1d:	83 ec 0c             	sub    $0xc,%esp
80106d20:	ff 75 f4             	pushl  -0xc(%ebp)
80106d23:	e8 03 ab ff ff       	call   8010182b <iupdate>
80106d28:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106d2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d2e:	8b 40 04             	mov    0x4(%eax),%eax
80106d31:	83 ec 04             	sub    $0x4,%esp
80106d34:	50                   	push   %eax
80106d35:	68 e1 a4 10 80       	push   $0x8010a4e1
80106d3a:	ff 75 f0             	pushl  -0x10(%ebp)
80106d3d:	e8 14 b6 ff ff       	call   80102356 <dirlink>
80106d42:	83 c4 10             	add    $0x10,%esp
80106d45:	85 c0                	test   %eax,%eax
80106d47:	78 1e                	js     80106d67 <create+0x18c>
80106d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d4c:	8b 40 04             	mov    0x4(%eax),%eax
80106d4f:	83 ec 04             	sub    $0x4,%esp
80106d52:	50                   	push   %eax
80106d53:	68 e3 a4 10 80       	push   $0x8010a4e3
80106d58:	ff 75 f0             	pushl  -0x10(%ebp)
80106d5b:	e8 f6 b5 ff ff       	call   80102356 <dirlink>
80106d60:	83 c4 10             	add    $0x10,%esp
80106d63:	85 c0                	test   %eax,%eax
80106d65:	79 0d                	jns    80106d74 <create+0x199>
      panic("create dots");
80106d67:	83 ec 0c             	sub    $0xc,%esp
80106d6a:	68 16 a5 10 80       	push   $0x8010a516
80106d6f:	e8 23 98 ff ff       	call   80100597 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106d74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d77:	8b 40 04             	mov    0x4(%eax),%eax
80106d7a:	83 ec 04             	sub    $0x4,%esp
80106d7d:	50                   	push   %eax
80106d7e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106d81:	50                   	push   %eax
80106d82:	ff 75 f4             	pushl  -0xc(%ebp)
80106d85:	e8 cc b5 ff ff       	call   80102356 <dirlink>
80106d8a:	83 c4 10             	add    $0x10,%esp
80106d8d:	85 c0                	test   %eax,%eax
80106d8f:	79 0d                	jns    80106d9e <create+0x1c3>
    panic("create: dirlink");
80106d91:	83 ec 0c             	sub    $0xc,%esp
80106d94:	68 22 a5 10 80       	push   $0x8010a522
80106d99:	e8 f9 97 ff ff       	call   80100597 <panic>

  iunlockput(dp);
80106d9e:	83 ec 0c             	sub    $0xc,%esp
80106da1:	ff 75 f4             	pushl  -0xc(%ebp)
80106da4:	e8 34 af ff ff       	call   80101cdd <iunlockput>
80106da9:	83 c4 10             	add    $0x10,%esp

  return ip;
80106dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106daf:	c9                   	leave  
80106db0:	c3                   	ret    

80106db1 <sys_open>:

int
sys_open(void)
{
80106db1:	f3 0f 1e fb          	endbr32 
80106db5:	55                   	push   %ebp
80106db6:	89 e5                	mov    %esp,%ebp
80106db8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106dbb:	83 ec 08             	sub    $0x8,%esp
80106dbe:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106dc1:	50                   	push   %eax
80106dc2:	6a 00                	push   $0x0
80106dc4:	e8 b1 f6 ff ff       	call   8010647a <argstr>
80106dc9:	83 c4 10             	add    $0x10,%esp
80106dcc:	85 c0                	test   %eax,%eax
80106dce:	78 15                	js     80106de5 <sys_open+0x34>
80106dd0:	83 ec 08             	sub    $0x8,%esp
80106dd3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106dd6:	50                   	push   %eax
80106dd7:	6a 01                	push   $0x1
80106dd9:	e8 0f f6 ff ff       	call   801063ed <argint>
80106dde:	83 c4 10             	add    $0x10,%esp
80106de1:	85 c0                	test   %eax,%eax
80106de3:	79 0a                	jns    80106def <sys_open+0x3e>
    return -1;
80106de5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dea:	e9 61 01 00 00       	jmp    80106f50 <sys_open+0x19f>

  begin_op();
80106def:	e8 42 d0 ff ff       	call   80103e36 <begin_op>

  if(omode & O_CREATE){
80106df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106df7:	25 00 02 00 00       	and    $0x200,%eax
80106dfc:	85 c0                	test   %eax,%eax
80106dfe:	74 2a                	je     80106e2a <sys_open+0x79>
    ip = create(path, T_FILE, 0, 0);
80106e00:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e03:	6a 00                	push   $0x0
80106e05:	6a 00                	push   $0x0
80106e07:	6a 02                	push   $0x2
80106e09:	50                   	push   %eax
80106e0a:	e8 cc fd ff ff       	call   80106bdb <create>
80106e0f:	83 c4 10             	add    $0x10,%esp
80106e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106e15:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e19:	75 75                	jne    80106e90 <sys_open+0xdf>
      end_op();
80106e1b:	e8 a6 d0 ff ff       	call   80103ec6 <end_op>
      return -1;
80106e20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e25:	e9 26 01 00 00       	jmp    80106f50 <sys_open+0x19f>
    }
  } else {
    if((ip = namei(path)) == 0){
80106e2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106e2d:	83 ec 0c             	sub    $0xc,%esp
80106e30:	50                   	push   %eax
80106e31:	e8 c4 b7 ff ff       	call   801025fa <namei>
80106e36:	83 c4 10             	add    $0x10,%esp
80106e39:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106e3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106e40:	75 0f                	jne    80106e51 <sys_open+0xa0>
      end_op();
80106e42:	e8 7f d0 ff ff       	call   80103ec6 <end_op>
      return -1;
80106e47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e4c:	e9 ff 00 00 00       	jmp    80106f50 <sys_open+0x19f>
    }
    ilock(ip);
80106e51:	83 ec 0c             	sub    $0xc,%esp
80106e54:	ff 75 f4             	pushl  -0xc(%ebp)
80106e57:	e8 b5 ab ff ff       	call   80101a11 <ilock>
80106e5c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106e5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e62:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106e66:	66 83 f8 01          	cmp    $0x1,%ax
80106e6a:	75 24                	jne    80106e90 <sys_open+0xdf>
80106e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106e6f:	85 c0                	test   %eax,%eax
80106e71:	74 1d                	je     80106e90 <sys_open+0xdf>
      iunlockput(ip);
80106e73:	83 ec 0c             	sub    $0xc,%esp
80106e76:	ff 75 f4             	pushl  -0xc(%ebp)
80106e79:	e8 5f ae ff ff       	call   80101cdd <iunlockput>
80106e7e:	83 c4 10             	add    $0x10,%esp
      end_op();
80106e81:	e8 40 d0 ff ff       	call   80103ec6 <end_op>
      return -1;
80106e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8b:	e9 c0 00 00 00       	jmp    80106f50 <sys_open+0x19f>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106e90:	e8 69 a1 ff ff       	call   80100ffe <filealloc>
80106e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106e98:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106e9c:	74 17                	je     80106eb5 <sys_open+0x104>
80106e9e:	83 ec 0c             	sub    $0xc,%esp
80106ea1:	ff 75 f0             	pushl  -0x10(%ebp)
80106ea4:	e8 08 f7 ff ff       	call   801065b1 <fdalloc>
80106ea9:	83 c4 10             	add    $0x10,%esp
80106eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106eaf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106eb3:	79 2e                	jns    80106ee3 <sys_open+0x132>
    if(f)
80106eb5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106eb9:	74 0e                	je     80106ec9 <sys_open+0x118>
      fileclose(f);
80106ebb:	83 ec 0c             	sub    $0xc,%esp
80106ebe:	ff 75 f0             	pushl  -0x10(%ebp)
80106ec1:	e8 fe a1 ff ff       	call   801010c4 <fileclose>
80106ec6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106ec9:	83 ec 0c             	sub    $0xc,%esp
80106ecc:	ff 75 f4             	pushl  -0xc(%ebp)
80106ecf:	e8 09 ae ff ff       	call   80101cdd <iunlockput>
80106ed4:	83 c4 10             	add    $0x10,%esp
    end_op();
80106ed7:	e8 ea cf ff ff       	call   80103ec6 <end_op>
    return -1;
80106edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ee1:	eb 6d                	jmp    80106f50 <sys_open+0x19f>
  }
  iunlock(ip);
80106ee3:	83 ec 0c             	sub    $0xc,%esp
80106ee6:	ff 75 f4             	pushl  -0xc(%ebp)
80106ee9:	e8 85 ac ff ff       	call   80101b73 <iunlock>
80106eee:	83 c4 10             	add    $0x10,%esp
  end_op();
80106ef1:	e8 d0 cf ff ff       	call   80103ec6 <end_op>

  f->type = FD_INODE;
80106ef6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ef9:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106eff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f02:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f05:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106f08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f0b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f15:	83 e0 01             	and    $0x1,%eax
80106f18:	85 c0                	test   %eax,%eax
80106f1a:	0f 94 c0             	sete   %al
80106f1d:	89 c2                	mov    %eax,%edx
80106f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f22:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f28:	83 e0 01             	and    $0x1,%eax
80106f2b:	85 c0                	test   %eax,%eax
80106f2d:	75 0a                	jne    80106f39 <sys_open+0x188>
80106f2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106f32:	83 e0 02             	and    $0x2,%eax
80106f35:	85 c0                	test   %eax,%eax
80106f37:	74 07                	je     80106f40 <sys_open+0x18f>
80106f39:	b8 01 00 00 00       	mov    $0x1,%eax
80106f3e:	eb 05                	jmp    80106f45 <sys_open+0x194>
80106f40:	b8 00 00 00 00       	mov    $0x0,%eax
80106f45:	89 c2                	mov    %eax,%edx
80106f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f4a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106f50:	c9                   	leave  
80106f51:	c3                   	ret    

80106f52 <sys_mkdir>:

int
sys_mkdir(void)
{
80106f52:	f3 0f 1e fb          	endbr32 
80106f56:	55                   	push   %ebp
80106f57:	89 e5                	mov    %esp,%ebp
80106f59:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106f5c:	e8 d5 ce ff ff       	call   80103e36 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106f61:	83 ec 08             	sub    $0x8,%esp
80106f64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f67:	50                   	push   %eax
80106f68:	6a 00                	push   $0x0
80106f6a:	e8 0b f5 ff ff       	call   8010647a <argstr>
80106f6f:	83 c4 10             	add    $0x10,%esp
80106f72:	85 c0                	test   %eax,%eax
80106f74:	78 1b                	js     80106f91 <sys_mkdir+0x3f>
80106f76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f79:	6a 00                	push   $0x0
80106f7b:	6a 00                	push   $0x0
80106f7d:	6a 01                	push   $0x1
80106f7f:	50                   	push   %eax
80106f80:	e8 56 fc ff ff       	call   80106bdb <create>
80106f85:	83 c4 10             	add    $0x10,%esp
80106f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106f8b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106f8f:	75 0c                	jne    80106f9d <sys_mkdir+0x4b>
    end_op();
80106f91:	e8 30 cf ff ff       	call   80103ec6 <end_op>
    return -1;
80106f96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f9b:	eb 18                	jmp    80106fb5 <sys_mkdir+0x63>
  }
  iunlockput(ip);
80106f9d:	83 ec 0c             	sub    $0xc,%esp
80106fa0:	ff 75 f4             	pushl  -0xc(%ebp)
80106fa3:	e8 35 ad ff ff       	call   80101cdd <iunlockput>
80106fa8:	83 c4 10             	add    $0x10,%esp
  end_op();
80106fab:	e8 16 cf ff ff       	call   80103ec6 <end_op>
  return 0;
80106fb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fb5:	c9                   	leave  
80106fb6:	c3                   	ret    

80106fb7 <sys_mknod>:

int
sys_mknod(void)
{
80106fb7:	f3 0f 1e fb          	endbr32 
80106fbb:	55                   	push   %ebp
80106fbc:	89 e5                	mov    %esp,%ebp
80106fbe:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106fc1:	e8 70 ce ff ff       	call   80103e36 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
80106fc6:	83 ec 08             	sub    $0x8,%esp
80106fc9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106fcc:	50                   	push   %eax
80106fcd:	6a 00                	push   $0x0
80106fcf:	e8 a6 f4 ff ff       	call   8010647a <argstr>
80106fd4:	83 c4 10             	add    $0x10,%esp
80106fd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106fda:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106fde:	78 4f                	js     8010702f <sys_mknod+0x78>
     argint(1, &major) < 0 ||
80106fe0:	83 ec 08             	sub    $0x8,%esp
80106fe3:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106fe6:	50                   	push   %eax
80106fe7:	6a 01                	push   $0x1
80106fe9:	e8 ff f3 ff ff       	call   801063ed <argint>
80106fee:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
80106ff1:	85 c0                	test   %eax,%eax
80106ff3:	78 3a                	js     8010702f <sys_mknod+0x78>
     argint(2, &minor) < 0 ||
80106ff5:	83 ec 08             	sub    $0x8,%esp
80106ff8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106ffb:	50                   	push   %eax
80106ffc:	6a 02                	push   $0x2
80106ffe:	e8 ea f3 ff ff       	call   801063ed <argint>
80107003:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80107006:	85 c0                	test   %eax,%eax
80107008:	78 25                	js     8010702f <sys_mknod+0x78>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010700a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010700d:	0f bf c8             	movswl %ax,%ecx
80107010:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107013:	0f bf d0             	movswl %ax,%edx
80107016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107019:	51                   	push   %ecx
8010701a:	52                   	push   %edx
8010701b:	6a 03                	push   $0x3
8010701d:	50                   	push   %eax
8010701e:	e8 b8 fb ff ff       	call   80106bdb <create>
80107023:	83 c4 10             	add    $0x10,%esp
80107026:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
80107029:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010702d:	75 0c                	jne    8010703b <sys_mknod+0x84>
    end_op();
8010702f:	e8 92 ce ff ff       	call   80103ec6 <end_op>
    return -1;
80107034:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107039:	eb 18                	jmp    80107053 <sys_mknod+0x9c>
  }
  iunlockput(ip);
8010703b:	83 ec 0c             	sub    $0xc,%esp
8010703e:	ff 75 f0             	pushl  -0x10(%ebp)
80107041:	e8 97 ac ff ff       	call   80101cdd <iunlockput>
80107046:	83 c4 10             	add    $0x10,%esp
  end_op();
80107049:	e8 78 ce ff ff       	call   80103ec6 <end_op>
  return 0;
8010704e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107053:	c9                   	leave  
80107054:	c3                   	ret    

80107055 <sys_chdir>:

int
sys_chdir(void)
{
80107055:	f3 0f 1e fb          	endbr32 
80107059:	55                   	push   %ebp
8010705a:	89 e5                	mov    %esp,%ebp
8010705c:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010705f:	e8 d2 cd ff ff       	call   80103e36 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80107064:	83 ec 08             	sub    $0x8,%esp
80107067:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010706a:	50                   	push   %eax
8010706b:	6a 00                	push   $0x0
8010706d:	e8 08 f4 ff ff       	call   8010647a <argstr>
80107072:	83 c4 10             	add    $0x10,%esp
80107075:	85 c0                	test   %eax,%eax
80107077:	78 18                	js     80107091 <sys_chdir+0x3c>
80107079:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010707c:	83 ec 0c             	sub    $0xc,%esp
8010707f:	50                   	push   %eax
80107080:	e8 75 b5 ff ff       	call   801025fa <namei>
80107085:	83 c4 10             	add    $0x10,%esp
80107088:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010708b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010708f:	75 0c                	jne    8010709d <sys_chdir+0x48>
    end_op();
80107091:	e8 30 ce ff ff       	call   80103ec6 <end_op>
    return -1;
80107096:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010709b:	eb 6e                	jmp    8010710b <sys_chdir+0xb6>
  }
  ilock(ip);
8010709d:	83 ec 0c             	sub    $0xc,%esp
801070a0:	ff 75 f4             	pushl  -0xc(%ebp)
801070a3:	e8 69 a9 ff ff       	call   80101a11 <ilock>
801070a8:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
801070ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ae:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801070b2:	66 83 f8 01          	cmp    $0x1,%ax
801070b6:	74 1a                	je     801070d2 <sys_chdir+0x7d>
    iunlockput(ip);
801070b8:	83 ec 0c             	sub    $0xc,%esp
801070bb:	ff 75 f4             	pushl  -0xc(%ebp)
801070be:	e8 1a ac ff ff       	call   80101cdd <iunlockput>
801070c3:	83 c4 10             	add    $0x10,%esp
    end_op();
801070c6:	e8 fb cd ff ff       	call   80103ec6 <end_op>
    return -1;
801070cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070d0:	eb 39                	jmp    8010710b <sys_chdir+0xb6>
  }
  iunlock(ip);
801070d2:	83 ec 0c             	sub    $0xc,%esp
801070d5:	ff 75 f4             	pushl  -0xc(%ebp)
801070d8:	e8 96 aa ff ff       	call   80101b73 <iunlock>
801070dd:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801070e0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070e6:	8b 40 68             	mov    0x68(%eax),%eax
801070e9:	83 ec 0c             	sub    $0xc,%esp
801070ec:	50                   	push   %eax
801070ed:	e8 f7 aa ff ff       	call   80101be9 <iput>
801070f2:	83 c4 10             	add    $0x10,%esp
  end_op();
801070f5:	e8 cc cd ff ff       	call   80103ec6 <end_op>
  proc->cwd = ip;
801070fa:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107100:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107103:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80107106:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010710b:	c9                   	leave  
8010710c:	c3                   	ret    

8010710d <sys_exec>:

int
sys_exec(void)
{
8010710d:	f3 0f 1e fb          	endbr32 
80107111:	55                   	push   %ebp
80107112:	89 e5                	mov    %esp,%ebp
80107114:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010711a:	83 ec 08             	sub    $0x8,%esp
8010711d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107120:	50                   	push   %eax
80107121:	6a 00                	push   $0x0
80107123:	e8 52 f3 ff ff       	call   8010647a <argstr>
80107128:	83 c4 10             	add    $0x10,%esp
8010712b:	85 c0                	test   %eax,%eax
8010712d:	78 18                	js     80107147 <sys_exec+0x3a>
8010712f:	83 ec 08             	sub    $0x8,%esp
80107132:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107138:	50                   	push   %eax
80107139:	6a 01                	push   $0x1
8010713b:	e8 ad f2 ff ff       	call   801063ed <argint>
80107140:	83 c4 10             	add    $0x10,%esp
80107143:	85 c0                	test   %eax,%eax
80107145:	79 0a                	jns    80107151 <sys_exec+0x44>
    return -1;
80107147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010714c:	e9 c6 00 00 00       	jmp    80107217 <sys_exec+0x10a>
  }
  memset(argv, 0, sizeof(argv));
80107151:	83 ec 04             	sub    $0x4,%esp
80107154:	68 80 00 00 00       	push   $0x80
80107159:	6a 00                	push   $0x0
8010715b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80107161:	50                   	push   %eax
80107162:	e8 39 ef ff ff       	call   801060a0 <memset>
80107167:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010716a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107171:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107174:	83 f8 1f             	cmp    $0x1f,%eax
80107177:	76 0a                	jbe    80107183 <sys_exec+0x76>
      return -1;
80107179:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010717e:	e9 94 00 00 00       	jmp    80107217 <sys_exec+0x10a>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107183:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107186:	c1 e0 02             	shl    $0x2,%eax
80107189:	89 c2                	mov    %eax,%edx
8010718b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80107191:	01 c2                	add    %eax,%edx
80107193:	83 ec 08             	sub    $0x8,%esp
80107196:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010719c:	50                   	push   %eax
8010719d:	52                   	push   %edx
8010719e:	e8 a6 f1 ff ff       	call   80106349 <fetchint>
801071a3:	83 c4 10             	add    $0x10,%esp
801071a6:	85 c0                	test   %eax,%eax
801071a8:	79 07                	jns    801071b1 <sys_exec+0xa4>
      return -1;
801071aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071af:	eb 66                	jmp    80107217 <sys_exec+0x10a>
    if(uarg == 0){
801071b1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801071b7:	85 c0                	test   %eax,%eax
801071b9:	75 27                	jne    801071e2 <sys_exec+0xd5>
      argv[i] = 0;
801071bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071be:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801071c5:	00 00 00 00 
      break;
801071c9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801071ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071cd:	83 ec 08             	sub    $0x8,%esp
801071d0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801071d6:	52                   	push   %edx
801071d7:	50                   	push   %eax
801071d8:	e8 f7 99 ff ff       	call   80100bd4 <exec>
801071dd:	83 c4 10             	add    $0x10,%esp
801071e0:	eb 35                	jmp    80107217 <sys_exec+0x10a>
    if(fetchstr(uarg, &argv[i]) < 0)
801071e2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801071e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071eb:	c1 e2 02             	shl    $0x2,%edx
801071ee:	01 c2                	add    %eax,%edx
801071f0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801071f6:	83 ec 08             	sub    $0x8,%esp
801071f9:	52                   	push   %edx
801071fa:	50                   	push   %eax
801071fb:	e8 87 f1 ff ff       	call   80106387 <fetchstr>
80107200:	83 c4 10             	add    $0x10,%esp
80107203:	85 c0                	test   %eax,%eax
80107205:	79 07                	jns    8010720e <sys_exec+0x101>
      return -1;
80107207:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010720c:	eb 09                	jmp    80107217 <sys_exec+0x10a>
  for(i=0;; i++){
8010720e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80107212:	e9 5a ff ff ff       	jmp    80107171 <sys_exec+0x64>
}
80107217:	c9                   	leave  
80107218:	c3                   	ret    

80107219 <sys_pipe>:

int
sys_pipe(void)
{
80107219:	f3 0f 1e fb          	endbr32 
8010721d:	55                   	push   %ebp
8010721e:	89 e5                	mov    %esp,%ebp
80107220:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80107223:	83 ec 04             	sub    $0x4,%esp
80107226:	6a 08                	push   $0x8
80107228:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010722b:	50                   	push   %eax
8010722c:	6a 00                	push   $0x0
8010722e:	e8 e6 f1 ff ff       	call   80106419 <argptr>
80107233:	83 c4 10             	add    $0x10,%esp
80107236:	85 c0                	test   %eax,%eax
80107238:	79 0a                	jns    80107244 <sys_pipe+0x2b>
    return -1;
8010723a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010723f:	e9 af 00 00 00       	jmp    801072f3 <sys_pipe+0xda>
  if(pipealloc(&rf, &wf) < 0)
80107244:	83 ec 08             	sub    $0x8,%esp
80107247:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010724a:	50                   	push   %eax
8010724b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010724e:	50                   	push   %eax
8010724f:	e8 3c d7 ff ff       	call   80104990 <pipealloc>
80107254:	83 c4 10             	add    $0x10,%esp
80107257:	85 c0                	test   %eax,%eax
80107259:	79 0a                	jns    80107265 <sys_pipe+0x4c>
    return -1;
8010725b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107260:	e9 8e 00 00 00       	jmp    801072f3 <sys_pipe+0xda>
  fd0 = -1;
80107265:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010726c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010726f:	83 ec 0c             	sub    $0xc,%esp
80107272:	50                   	push   %eax
80107273:	e8 39 f3 ff ff       	call   801065b1 <fdalloc>
80107278:	83 c4 10             	add    $0x10,%esp
8010727b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010727e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107282:	78 18                	js     8010729c <sys_pipe+0x83>
80107284:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107287:	83 ec 0c             	sub    $0xc,%esp
8010728a:	50                   	push   %eax
8010728b:	e8 21 f3 ff ff       	call   801065b1 <fdalloc>
80107290:	83 c4 10             	add    $0x10,%esp
80107293:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107296:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010729a:	79 3f                	jns    801072db <sys_pipe+0xc2>
    if(fd0 >= 0)
8010729c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801072a0:	78 14                	js     801072b6 <sys_pipe+0x9d>
      proc->ofile[fd0] = 0;
801072a2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072ab:	83 c2 08             	add    $0x8,%edx
801072ae:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801072b5:	00 
    fileclose(rf);
801072b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801072b9:	83 ec 0c             	sub    $0xc,%esp
801072bc:	50                   	push   %eax
801072bd:	e8 02 9e ff ff       	call   801010c4 <fileclose>
801072c2:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801072c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072c8:	83 ec 0c             	sub    $0xc,%esp
801072cb:	50                   	push   %eax
801072cc:	e8 f3 9d ff ff       	call   801010c4 <fileclose>
801072d1:	83 c4 10             	add    $0x10,%esp
    return -1;
801072d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072d9:	eb 18                	jmp    801072f3 <sys_pipe+0xda>
  }
  fd[0] = fd0;
801072db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801072e1:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801072e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072e6:	8d 50 04             	lea    0x4(%eax),%edx
801072e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072ec:	89 02                	mov    %eax,(%edx)
  return 0;
801072ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072f3:	c9                   	leave  
801072f4:	c3                   	ret    

801072f5 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801072f5:	f3 0f 1e fb          	endbr32 
801072f9:	55                   	push   %ebp
801072fa:	89 e5                	mov    %esp,%ebp
801072fc:	83 ec 08             	sub    $0x8,%esp
  return fork();
801072ff:	e8 21 de ff ff       	call   80105125 <fork>
}
80107304:	c9                   	leave  
80107305:	c3                   	ret    

80107306 <sys_exit>:

int
sys_exit(void)
{
80107306:	f3 0f 1e fb          	endbr32 
8010730a:	55                   	push   %ebp
8010730b:	89 e5                	mov    %esp,%ebp
8010730d:	83 ec 08             	sub    $0x8,%esp
  exit();
80107310:	e8 f8 e0 ff ff       	call   8010540d <exit>
  return 0;  // not reached
80107315:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010731a:	c9                   	leave  
8010731b:	c3                   	ret    

8010731c <sys_wait>:

int
sys_wait(void)
{
8010731c:	f3 0f 1e fb          	endbr32 
80107320:	55                   	push   %ebp
80107321:	89 e5                	mov    %esp,%ebp
80107323:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107326:	e8 46 e2 ff ff       	call   80105571 <wait>
}
8010732b:	c9                   	leave  
8010732c:	c3                   	ret    

8010732d <sys_kill>:

int
sys_kill(void)
{
8010732d:	f3 0f 1e fb          	endbr32 
80107331:	55                   	push   %ebp
80107332:	89 e5                	mov    %esp,%ebp
80107334:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80107337:	83 ec 08             	sub    $0x8,%esp
8010733a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010733d:	50                   	push   %eax
8010733e:	6a 00                	push   $0x0
80107340:	e8 a8 f0 ff ff       	call   801063ed <argint>
80107345:	83 c4 10             	add    $0x10,%esp
80107348:	85 c0                	test   %eax,%eax
8010734a:	79 07                	jns    80107353 <sys_kill+0x26>
    return -1;
8010734c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107351:	eb 0f                	jmp    80107362 <sys_kill+0x35>
  return kill(pid);
80107353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107356:	83 ec 0c             	sub    $0xc,%esp
80107359:	50                   	push   %eax
8010735a:	e8 c8 e6 ff ff       	call   80105a27 <kill>
8010735f:	83 c4 10             	add    $0x10,%esp
}
80107362:	c9                   	leave  
80107363:	c3                   	ret    

80107364 <sys_getpid>:

int
sys_getpid(void)
{
80107364:	f3 0f 1e fb          	endbr32 
80107368:	55                   	push   %ebp
80107369:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010736b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107371:	8b 40 10             	mov    0x10(%eax),%eax
}
80107374:	5d                   	pop    %ebp
80107375:	c3                   	ret    

80107376 <sys_sbrk>:

int
sys_sbrk(void)
{
80107376:	f3 0f 1e fb          	endbr32 
8010737a:	55                   	push   %ebp
8010737b:	89 e5                	mov    %esp,%ebp
8010737d:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;
  if(argint(0, &n) < 0)
80107380:	83 ec 08             	sub    $0x8,%esp
80107383:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107386:	50                   	push   %eax
80107387:	6a 00                	push   $0x0
80107389:	e8 5f f0 ff ff       	call   801063ed <argint>
8010738e:	83 c4 10             	add    $0x10,%esp
80107391:	85 c0                	test   %eax,%eax
80107393:	79 07                	jns    8010739c <sys_sbrk+0x26>
    return -1;
80107395:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010739a:	eb 28                	jmp    801073c4 <sys_sbrk+0x4e>
  addr = proc->sz;
8010739c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801073a2:	8b 00                	mov    (%eax),%eax
801073a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801073a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801073aa:	83 ec 0c             	sub    $0xc,%esp
801073ad:	50                   	push   %eax
801073ae:	e8 cb dc ff ff       	call   8010507e <growproc>
801073b3:	83 c4 10             	add    $0x10,%esp
801073b6:	85 c0                	test   %eax,%eax
801073b8:	79 07                	jns    801073c1 <sys_sbrk+0x4b>
    return -1;
801073ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073bf:	eb 03                	jmp    801073c4 <sys_sbrk+0x4e>
  return addr;
801073c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801073c4:	c9                   	leave  
801073c5:	c3                   	ret    

801073c6 <sys_sleep>:

int
sys_sleep(void)
{
801073c6:	f3 0f 1e fb          	endbr32 
801073ca:	55                   	push   %ebp
801073cb:	89 e5                	mov    %esp,%ebp
801073cd:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801073d0:	83 ec 08             	sub    $0x8,%esp
801073d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801073d6:	50                   	push   %eax
801073d7:	6a 00                	push   $0x0
801073d9:	e8 0f f0 ff ff       	call   801063ed <argint>
801073de:	83 c4 10             	add    $0x10,%esp
801073e1:	85 c0                	test   %eax,%eax
801073e3:	79 07                	jns    801073ec <sys_sleep+0x26>
    return -1;
801073e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ea:	eb 77                	jmp    80107463 <sys_sleep+0x9d>
  acquire(&tickslock);
801073ec:	83 ec 0c             	sub    $0xc,%esp
801073ef:	68 a0 13 12 80       	push   $0x801213a0
801073f4:	e8 2b ea ff ff       	call   80105e24 <acquire>
801073f9:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801073fc:	a1 e0 1b 12 80       	mov    0x80121be0,%eax
80107401:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107404:	eb 39                	jmp    8010743f <sys_sleep+0x79>
    if(proc->killed){
80107406:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010740c:	8b 40 24             	mov    0x24(%eax),%eax
8010740f:	85 c0                	test   %eax,%eax
80107411:	74 17                	je     8010742a <sys_sleep+0x64>
      release(&tickslock);
80107413:	83 ec 0c             	sub    $0xc,%esp
80107416:	68 a0 13 12 80       	push   $0x801213a0
8010741b:	e8 6f ea ff ff       	call   80105e8f <release>
80107420:	83 c4 10             	add    $0x10,%esp
      return -1;
80107423:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107428:	eb 39                	jmp    80107463 <sys_sleep+0x9d>
    }
    sleep(&ticks, &tickslock);
8010742a:	83 ec 08             	sub    $0x8,%esp
8010742d:	68 a0 13 12 80       	push   $0x801213a0
80107432:	68 e0 1b 12 80       	push   $0x80121be0
80107437:	e8 b9 e4 ff ff       	call   801058f5 <sleep>
8010743c:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
8010743f:	a1 e0 1b 12 80       	mov    0x80121be0,%eax
80107444:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107447:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010744a:	39 d0                	cmp    %edx,%eax
8010744c:	72 b8                	jb     80107406 <sys_sleep+0x40>
  }
  release(&tickslock);
8010744e:	83 ec 0c             	sub    $0xc,%esp
80107451:	68 a0 13 12 80       	push   $0x801213a0
80107456:	e8 34 ea ff ff       	call   80105e8f <release>
8010745b:	83 c4 10             	add    $0x10,%esp
  return 0;
8010745e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107463:	c9                   	leave  
80107464:	c3                   	ret    

80107465 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80107465:	f3 0f 1e fb          	endbr32 
80107469:	55                   	push   %ebp
8010746a:	89 e5                	mov    %esp,%ebp
8010746c:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010746f:	83 ec 0c             	sub    $0xc,%esp
80107472:	68 a0 13 12 80       	push   $0x801213a0
80107477:	e8 a8 e9 ff ff       	call   80105e24 <acquire>
8010747c:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010747f:	a1 e0 1b 12 80       	mov    0x80121be0,%eax
80107484:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107487:	83 ec 0c             	sub    $0xc,%esp
8010748a:	68 a0 13 12 80       	push   $0x801213a0
8010748f:	e8 fb e9 ff ff       	call   80105e8f <release>
80107494:	83 c4 10             	add    $0x10,%esp
  return xticks;
80107497:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010749a:	c9                   	leave  
8010749b:	c3                   	ret    

8010749c <sys_printMem>:

int 
sys_printMem(void) 
{
8010749c:	f3 0f 1e fb          	endbr32 
801074a0:	55                   	push   %ebp
801074a1:	89 e5                	mov    %esp,%ebp
801074a3:	83 ec 08             	sub    $0x8,%esp
printMem();
801074a6:	e8 1e e8 ff ff       	call   80105cc9 <printMem>
return 1;
801074ab:	b8 01 00 00 00       	mov    $0x1,%eax
} 
801074b0:	c9                   	leave  
801074b1:	c3                   	ret    

801074b2 <outb>:
{
801074b2:	55                   	push   %ebp
801074b3:	89 e5                	mov    %esp,%ebp
801074b5:	83 ec 08             	sub    $0x8,%esp
801074b8:	8b 45 08             	mov    0x8(%ebp),%eax
801074bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801074be:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801074c2:	89 d0                	mov    %edx,%eax
801074c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801074c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801074cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801074cf:	ee                   	out    %al,(%dx)
}
801074d0:	90                   	nop
801074d1:	c9                   	leave  
801074d2:	c3                   	ret    

801074d3 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801074d3:	f3 0f 1e fb          	endbr32 
801074d7:	55                   	push   %ebp
801074d8:	89 e5                	mov    %esp,%ebp
801074da:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801074dd:	6a 34                	push   $0x34
801074df:	6a 43                	push   $0x43
801074e1:	e8 cc ff ff ff       	call   801074b2 <outb>
801074e6:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801074e9:	68 9c 00 00 00       	push   $0x9c
801074ee:	6a 40                	push   $0x40
801074f0:	e8 bd ff ff ff       	call   801074b2 <outb>
801074f5:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801074f8:	6a 2e                	push   $0x2e
801074fa:	6a 40                	push   $0x40
801074fc:	e8 b1 ff ff ff       	call   801074b2 <outb>
80107501:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80107504:	83 ec 0c             	sub    $0xc,%esp
80107507:	6a 00                	push   $0x0
80107509:	e8 64 d3 ff ff       	call   80104872 <picenable>
8010750e:	83 c4 10             	add    $0x10,%esp
}
80107511:	90                   	nop
80107512:	c9                   	leave  
80107513:	c3                   	ret    

80107514 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107514:	1e                   	push   %ds
  pushl %es
80107515:	06                   	push   %es
  pushl %fs
80107516:	0f a0                	push   %fs
  pushl %gs
80107518:	0f a8                	push   %gs
  pushal
8010751a:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010751b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010751f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107521:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80107523:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80107527:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80107529:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010752b:	54                   	push   %esp
  call trap
8010752c:	e8 df 01 00 00       	call   80107710 <trap>
  addl $4, %esp
80107531:	83 c4 04             	add    $0x4,%esp

80107534 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107534:	61                   	popa   
  popl %gs
80107535:	0f a9                	pop    %gs
  popl %fs
80107537:	0f a1                	pop    %fs
  popl %es
80107539:	07                   	pop    %es
  popl %ds
8010753a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010753b:	83 c4 08             	add    $0x8,%esp
  iret
8010753e:	cf                   	iret   

8010753f <lidt>:
{
8010753f:	55                   	push   %ebp
80107540:	89 e5                	mov    %esp,%ebp
80107542:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107545:	8b 45 0c             	mov    0xc(%ebp),%eax
80107548:	83 e8 01             	sub    $0x1,%eax
8010754b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010754f:	8b 45 08             	mov    0x8(%ebp),%eax
80107552:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107556:	8b 45 08             	mov    0x8(%ebp),%eax
80107559:	c1 e8 10             	shr    $0x10,%eax
8010755c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80107560:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107563:	0f 01 18             	lidtl  (%eax)
}
80107566:	90                   	nop
80107567:	c9                   	leave  
80107568:	c3                   	ret    

80107569 <rcr2>:

static inline uint
rcr2(void)
{
80107569:	55                   	push   %ebp
8010756a:	89 e5                	mov    %esp,%ebp
8010756c:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010756f:	0f 20 d0             	mov    %cr2,%eax
80107572:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107575:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107578:	c9                   	leave  
80107579:	c3                   	ret    

8010757a <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010757a:	f3 0f 1e fb          	endbr32 
8010757e:	55                   	push   %ebp
8010757f:	89 e5                	mov    %esp,%ebp
80107581:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80107584:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010758b:	e9 c3 00 00 00       	jmp    80107653 <tvinit+0xd9>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107593:	8b 04 85 9c d0 10 80 	mov    -0x7fef2f64(,%eax,4),%eax
8010759a:	89 c2                	mov    %eax,%edx
8010759c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010759f:	66 89 14 c5 e0 13 12 	mov    %dx,-0x7fedec20(,%eax,8)
801075a6:	80 
801075a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075aa:	66 c7 04 c5 e2 13 12 	movw   $0x8,-0x7fedec1e(,%eax,8)
801075b1:	80 08 00 
801075b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075b7:	0f b6 14 c5 e4 13 12 	movzbl -0x7fedec1c(,%eax,8),%edx
801075be:	80 
801075bf:	83 e2 e0             	and    $0xffffffe0,%edx
801075c2:	88 14 c5 e4 13 12 80 	mov    %dl,-0x7fedec1c(,%eax,8)
801075c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075cc:	0f b6 14 c5 e4 13 12 	movzbl -0x7fedec1c(,%eax,8),%edx
801075d3:	80 
801075d4:	83 e2 1f             	and    $0x1f,%edx
801075d7:	88 14 c5 e4 13 12 80 	mov    %dl,-0x7fedec1c(,%eax,8)
801075de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075e1:	0f b6 14 c5 e5 13 12 	movzbl -0x7fedec1b(,%eax,8),%edx
801075e8:	80 
801075e9:	83 e2 f0             	and    $0xfffffff0,%edx
801075ec:	83 ca 0e             	or     $0xe,%edx
801075ef:	88 14 c5 e5 13 12 80 	mov    %dl,-0x7fedec1b(,%eax,8)
801075f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075f9:	0f b6 14 c5 e5 13 12 	movzbl -0x7fedec1b(,%eax,8),%edx
80107600:	80 
80107601:	83 e2 ef             	and    $0xffffffef,%edx
80107604:	88 14 c5 e5 13 12 80 	mov    %dl,-0x7fedec1b(,%eax,8)
8010760b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010760e:	0f b6 14 c5 e5 13 12 	movzbl -0x7fedec1b(,%eax,8),%edx
80107615:	80 
80107616:	83 e2 9f             	and    $0xffffff9f,%edx
80107619:	88 14 c5 e5 13 12 80 	mov    %dl,-0x7fedec1b(,%eax,8)
80107620:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107623:	0f b6 14 c5 e5 13 12 	movzbl -0x7fedec1b(,%eax,8),%edx
8010762a:	80 
8010762b:	83 ca 80             	or     $0xffffff80,%edx
8010762e:	88 14 c5 e5 13 12 80 	mov    %dl,-0x7fedec1b(,%eax,8)
80107635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107638:	8b 04 85 9c d0 10 80 	mov    -0x7fef2f64(,%eax,4),%eax
8010763f:	c1 e8 10             	shr    $0x10,%eax
80107642:	89 c2                	mov    %eax,%edx
80107644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107647:	66 89 14 c5 e6 13 12 	mov    %dx,-0x7fedec1a(,%eax,8)
8010764e:	80 
  for(i = 0; i < 256; i++)
8010764f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107653:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010765a:	0f 8e 30 ff ff ff    	jle    80107590 <tvinit+0x16>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107660:	a1 9c d1 10 80       	mov    0x8010d19c,%eax
80107665:	66 a3 e0 15 12 80    	mov    %ax,0x801215e0
8010766b:	66 c7 05 e2 15 12 80 	movw   $0x8,0x801215e2
80107672:	08 00 
80107674:	0f b6 05 e4 15 12 80 	movzbl 0x801215e4,%eax
8010767b:	83 e0 e0             	and    $0xffffffe0,%eax
8010767e:	a2 e4 15 12 80       	mov    %al,0x801215e4
80107683:	0f b6 05 e4 15 12 80 	movzbl 0x801215e4,%eax
8010768a:	83 e0 1f             	and    $0x1f,%eax
8010768d:	a2 e4 15 12 80       	mov    %al,0x801215e4
80107692:	0f b6 05 e5 15 12 80 	movzbl 0x801215e5,%eax
80107699:	83 c8 0f             	or     $0xf,%eax
8010769c:	a2 e5 15 12 80       	mov    %al,0x801215e5
801076a1:	0f b6 05 e5 15 12 80 	movzbl 0x801215e5,%eax
801076a8:	83 e0 ef             	and    $0xffffffef,%eax
801076ab:	a2 e5 15 12 80       	mov    %al,0x801215e5
801076b0:	0f b6 05 e5 15 12 80 	movzbl 0x801215e5,%eax
801076b7:	83 c8 60             	or     $0x60,%eax
801076ba:	a2 e5 15 12 80       	mov    %al,0x801215e5
801076bf:	0f b6 05 e5 15 12 80 	movzbl 0x801215e5,%eax
801076c6:	83 c8 80             	or     $0xffffff80,%eax
801076c9:	a2 e5 15 12 80       	mov    %al,0x801215e5
801076ce:	a1 9c d1 10 80       	mov    0x8010d19c,%eax
801076d3:	c1 e8 10             	shr    $0x10,%eax
801076d6:	66 a3 e6 15 12 80    	mov    %ax,0x801215e6
  
  initlock(&tickslock, "time");
801076dc:	83 ec 08             	sub    $0x8,%esp
801076df:	68 34 a5 10 80       	push   $0x8010a534
801076e4:	68 a0 13 12 80       	push   $0x801213a0
801076e9:	e8 10 e7 ff ff       	call   80105dfe <initlock>
801076ee:	83 c4 10             	add    $0x10,%esp
}
801076f1:	90                   	nop
801076f2:	c9                   	leave  
801076f3:	c3                   	ret    

801076f4 <idtinit>:

void
idtinit(void)
{
801076f4:	f3 0f 1e fb          	endbr32 
801076f8:	55                   	push   %ebp
801076f9:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801076fb:	68 00 08 00 00       	push   $0x800
80107700:	68 e0 13 12 80       	push   $0x801213e0
80107705:	e8 35 fe ff ff       	call   8010753f <lidt>
8010770a:	83 c4 08             	add    $0x8,%esp
}
8010770d:	90                   	nop
8010770e:	c9                   	leave  
8010770f:	c3                   	ret    

80107710 <trap>:


//PAGEBREAK: 41
void trap(struct trapframe *tf){
80107710:	f3 0f 1e fb          	endbr32 
80107714:	55                   	push   %ebp
80107715:	89 e5                	mov    %esp,%ebp
80107717:	57                   	push   %edi
80107718:	56                   	push   %esi
80107719:	53                   	push   %ebx
8010771a:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
8010771d:	8b 45 08             	mov    0x8(%ebp),%eax
80107720:	8b 40 30             	mov    0x30(%eax),%eax
80107723:	83 f8 40             	cmp    $0x40,%eax
80107726:	75 3e                	jne    80107766 <trap+0x56>
    if(proc->killed)
80107728:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010772e:	8b 40 24             	mov    0x24(%eax),%eax
80107731:	85 c0                	test   %eax,%eax
80107733:	74 05                	je     8010773a <trap+0x2a>
      exit();
80107735:	e8 d3 dc ff ff       	call   8010540d <exit>
    proc->tf = tf;
8010773a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107740:	8b 55 08             	mov    0x8(%ebp),%edx
80107743:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107746:	e8 64 ed ff ff       	call   801064af <syscall>
    if(proc->killed)
8010774b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107751:	8b 40 24             	mov    0x24(%eax),%eax
80107754:	85 c0                	test   %eax,%eax
80107756:	0f 84 79 02 00 00    	je     801079d5 <trap+0x2c5>
      exit();
8010775c:	e8 ac dc ff ff       	call   8010540d <exit>
    return;
80107761:	e9 6f 02 00 00       	jmp    801079d5 <trap+0x2c5>
  }
  switch(tf->trapno){
80107766:	8b 45 08             	mov    0x8(%ebp),%eax
80107769:	8b 40 30             	mov    0x30(%eax),%eax
8010776c:	83 e8 0e             	sub    $0xe,%eax
8010776f:	83 f8 31             	cmp    $0x31,%eax
80107772:	0f 87 1a 01 00 00    	ja     80107892 <trap+0x182>
80107778:	8b 04 85 dc a5 10 80 	mov    -0x7fef5a24(,%eax,4),%eax
8010777f:	3e ff e0             	notrack jmp *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80107782:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107788:	0f b6 00             	movzbl (%eax),%eax
8010778b:	84 c0                	test   %al,%al
8010778d:	75 3d                	jne    801077cc <trap+0xbc>
      acquire(&tickslock);
8010778f:	83 ec 0c             	sub    $0xc,%esp
80107792:	68 a0 13 12 80       	push   $0x801213a0
80107797:	e8 88 e6 ff ff       	call   80105e24 <acquire>
8010779c:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010779f:	a1 e0 1b 12 80       	mov    0x80121be0,%eax
801077a4:	83 c0 01             	add    $0x1,%eax
801077a7:	a3 e0 1b 12 80       	mov    %eax,0x80121be0
      wakeup(&ticks);
801077ac:	83 ec 0c             	sub    $0xc,%esp
801077af:	68 e0 1b 12 80       	push   $0x80121be0
801077b4:	e8 33 e2 ff ff       	call   801059ec <wakeup>
801077b9:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801077bc:	83 ec 0c             	sub    $0xc,%esp
801077bf:	68 a0 13 12 80       	push   $0x801213a0
801077c4:	e8 c6 e6 ff ff       	call   80105e8f <release>
801077c9:	83 c4 10             	add    $0x10,%esp
      //#if LRU
         //defined in proc.c due to ptable usage
     // #endif
    }
    updateLRU();
801077cc:	e8 2c e3 ff ff       	call   80105afd <updateLRU>
    lapiceoi();
801077d1:	e8 14 c1 ff ff       	call   801038ea <lapiceoi>
    break;
801077d6:	e9 74 01 00 00       	jmp    8010794f <trap+0x23f>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801077db:	e8 8f b8 ff ff       	call   8010306f <ideintr>
    lapiceoi();
801077e0:	e8 05 c1 ff ff       	call   801038ea <lapiceoi>
    break;
801077e5:	e9 65 01 00 00       	jmp    8010794f <trap+0x23f>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801077ea:	e8 ea be ff ff       	call   801036d9 <kbdintr>
    lapiceoi();
801077ef:	e8 f6 c0 ff ff       	call   801038ea <lapiceoi>
    break;
801077f4:	e9 56 01 00 00       	jmp    8010794f <trap+0x23f>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801077f9:	e8 c6 03 00 00       	call   80107bc4 <uartintr>
    lapiceoi();
801077fe:	e8 e7 c0 ff ff       	call   801038ea <lapiceoi>
    break;
80107803:	e9 47 01 00 00       	jmp    8010794f <trap+0x23f>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107808:	8b 45 08             	mov    0x8(%ebp),%eax
8010780b:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010780e:	8b 45 08             	mov    0x8(%ebp),%eax
80107811:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107815:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80107818:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010781e:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107821:	0f b6 c0             	movzbl %al,%eax
80107824:	51                   	push   %ecx
80107825:	52                   	push   %edx
80107826:	50                   	push   %eax
80107827:	68 3c a5 10 80       	push   $0x8010a53c
8010782c:	e8 ad 8b ff ff       	call   801003de <cprintf>
80107831:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80107834:	e8 b1 c0 ff ff       	call   801038ea <lapiceoi>
    break;
80107839:	e9 11 01 00 00       	jmp    8010794f <trap+0x23f>


  case T_PGFLT:
    if (proc != 0 && (tf->cs&3) == 3 &&pageIsInFile(rcr2(), proc->pgdir)){
8010783e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107844:	85 c0                	test   %eax,%eax
80107846:	74 4a                	je     80107892 <trap+0x182>
80107848:	8b 45 08             	mov    0x8(%ebp),%eax
8010784b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010784f:	0f b7 c0             	movzwl %ax,%eax
80107852:	83 e0 03             	and    $0x3,%eax
80107855:	83 f8 03             	cmp    $0x3,%eax
80107858:	75 38                	jne    80107892 <trap+0x182>
8010785a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107860:	8b 58 04             	mov    0x4(%eax),%ebx
80107863:	e8 01 fd ff ff       	call   80107569 <rcr2>
80107868:	83 ec 08             	sub    $0x8,%esp
8010786b:	53                   	push   %ebx
8010786c:	50                   	push   %eax
8010786d:	e8 2e 19 00 00       	call   801091a0 <pageIsInFile>
80107872:	83 c4 10             	add    $0x10,%esp
80107875:	85 c0                	test   %eax,%eax
80107877:	74 19                	je     80107892 <trap+0x182>
      if (getPageFromFile(rcr2())){
80107879:	e8 eb fc ff ff       	call   80107569 <rcr2>
8010787e:	83 ec 0c             	sub    $0xc,%esp
80107881:	50                   	push   %eax
80107882:	e8 1b 1c 00 00       	call   801094a2 <getPageFromFile>
80107887:	83 c4 10             	add    $0x10,%esp
8010788a:	85 c0                	test   %eax,%eax
8010788c:	0f 85 bc 00 00 00    	jne    8010794e <trap+0x23e>
      }
    }
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80107892:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107898:	85 c0                	test   %eax,%eax
8010789a:	74 11                	je     801078ad <trap+0x19d>
8010789c:	8b 45 08             	mov    0x8(%ebp),%eax
8010789f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801078a3:	0f b7 c0             	movzwl %ax,%eax
801078a6:	83 e0 03             	and    $0x3,%eax
801078a9:	85 c0                	test   %eax,%eax
801078ab:	75 3f                	jne    801078ec <trap+0x1dc>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801078ad:	e8 b7 fc ff ff       	call   80107569 <rcr2>
801078b2:	8b 55 08             	mov    0x8(%ebp),%edx
801078b5:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801078b8:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801078bf:	0f b6 12             	movzbl (%edx),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801078c2:	0f b6 ca             	movzbl %dl,%ecx
801078c5:	8b 55 08             	mov    0x8(%ebp),%edx
801078c8:	8b 52 30             	mov    0x30(%edx),%edx
801078cb:	83 ec 0c             	sub    $0xc,%esp
801078ce:	50                   	push   %eax
801078cf:	53                   	push   %ebx
801078d0:	51                   	push   %ecx
801078d1:	52                   	push   %edx
801078d2:	68 60 a5 10 80       	push   $0x8010a560
801078d7:	e8 02 8b ff ff       	call   801003de <cprintf>
801078dc:	83 c4 20             	add    $0x20,%esp
      panic("trap");
801078df:	83 ec 0c             	sub    $0xc,%esp
801078e2:	68 92 a5 10 80       	push   $0x8010a592
801078e7:	e8 ab 8c ff ff       	call   80100597 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801078ec:	e8 78 fc ff ff       	call   80107569 <rcr2>
801078f1:	89 c2                	mov    %eax,%edx
801078f3:	8b 45 08             	mov    0x8(%ebp),%eax
801078f6:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801078f9:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801078ff:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107902:	0f b6 f0             	movzbl %al,%esi
80107905:	8b 45 08             	mov    0x8(%ebp),%eax
80107908:	8b 58 34             	mov    0x34(%eax),%ebx
8010790b:	8b 45 08             	mov    0x8(%ebp),%eax
8010790e:	8b 48 30             	mov    0x30(%eax),%ecx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80107911:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107917:	83 c0 6c             	add    $0x6c,%eax
8010791a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010791d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107923:	8b 40 10             	mov    0x10(%eax),%eax
80107926:	52                   	push   %edx
80107927:	57                   	push   %edi
80107928:	56                   	push   %esi
80107929:	53                   	push   %ebx
8010792a:	51                   	push   %ecx
8010792b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010792e:	50                   	push   %eax
8010792f:	68 98 a5 10 80       	push   $0x8010a598
80107934:	e8 a5 8a ff ff       	call   801003de <cprintf>
80107939:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
8010793c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107942:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107949:	eb 04                	jmp    8010794f <trap+0x23f>
    break;
8010794b:	90                   	nop
8010794c:	eb 01                	jmp    8010794f <trap+0x23f>
        break;
8010794e:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010794f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107955:	85 c0                	test   %eax,%eax
80107957:	74 24                	je     8010797d <trap+0x26d>
80107959:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010795f:	8b 40 24             	mov    0x24(%eax),%eax
80107962:	85 c0                	test   %eax,%eax
80107964:	74 17                	je     8010797d <trap+0x26d>
80107966:	8b 45 08             	mov    0x8(%ebp),%eax
80107969:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010796d:	0f b7 c0             	movzwl %ax,%eax
80107970:	83 e0 03             	and    $0x3,%eax
80107973:	83 f8 03             	cmp    $0x3,%eax
80107976:	75 05                	jne    8010797d <trap+0x26d>
    exit();
80107978:	e8 90 da ff ff       	call   8010540d <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
8010797d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107983:	85 c0                	test   %eax,%eax
80107985:	74 1e                	je     801079a5 <trap+0x295>
80107987:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010798d:	8b 40 0c             	mov    0xc(%eax),%eax
80107990:	83 f8 04             	cmp    $0x4,%eax
80107993:	75 10                	jne    801079a5 <trap+0x295>
80107995:	8b 45 08             	mov    0x8(%ebp),%eax
80107998:	8b 40 30             	mov    0x30(%eax),%eax
8010799b:	83 f8 20             	cmp    $0x20,%eax
8010799e:	75 05                	jne    801079a5 <trap+0x295>
    yield();
801079a0:	e8 c7 de ff ff       	call   8010586c <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
801079a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801079ab:	85 c0                	test   %eax,%eax
801079ad:	74 27                	je     801079d6 <trap+0x2c6>
801079af:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801079b5:	8b 40 24             	mov    0x24(%eax),%eax
801079b8:	85 c0                	test   %eax,%eax
801079ba:	74 1a                	je     801079d6 <trap+0x2c6>
801079bc:	8b 45 08             	mov    0x8(%ebp),%eax
801079bf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801079c3:	0f b7 c0             	movzwl %ax,%eax
801079c6:	83 e0 03             	and    $0x3,%eax
801079c9:	83 f8 03             	cmp    $0x3,%eax
801079cc:	75 08                	jne    801079d6 <trap+0x2c6>
    exit();
801079ce:	e8 3a da ff ff       	call   8010540d <exit>
801079d3:	eb 01                	jmp    801079d6 <trap+0x2c6>
    return;
801079d5:	90                   	nop
}
801079d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801079d9:	5b                   	pop    %ebx
801079da:	5e                   	pop    %esi
801079db:	5f                   	pop    %edi
801079dc:	5d                   	pop    %ebp
801079dd:	c3                   	ret    

801079de <inb>:
{
801079de:	55                   	push   %ebp
801079df:	89 e5                	mov    %esp,%ebp
801079e1:	83 ec 14             	sub    $0x14,%esp
801079e4:	8b 45 08             	mov    0x8(%ebp),%eax
801079e7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801079eb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801079ef:	89 c2                	mov    %eax,%edx
801079f1:	ec                   	in     (%dx),%al
801079f2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801079f5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801079f9:	c9                   	leave  
801079fa:	c3                   	ret    

801079fb <outb>:
{
801079fb:	55                   	push   %ebp
801079fc:	89 e5                	mov    %esp,%ebp
801079fe:	83 ec 08             	sub    $0x8,%esp
80107a01:	8b 45 08             	mov    0x8(%ebp),%eax
80107a04:	8b 55 0c             	mov    0xc(%ebp),%edx
80107a07:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107a0b:	89 d0                	mov    %edx,%eax
80107a0d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107a10:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107a14:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107a18:	ee                   	out    %al,(%dx)
}
80107a19:	90                   	nop
80107a1a:	c9                   	leave  
80107a1b:	c3                   	ret    

80107a1c <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107a1c:	f3 0f 1e fb          	endbr32 
80107a20:	55                   	push   %ebp
80107a21:	89 e5                	mov    %esp,%ebp
80107a23:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107a26:	6a 00                	push   $0x0
80107a28:	68 fa 03 00 00       	push   $0x3fa
80107a2d:	e8 c9 ff ff ff       	call   801079fb <outb>
80107a32:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107a35:	68 80 00 00 00       	push   $0x80
80107a3a:	68 fb 03 00 00       	push   $0x3fb
80107a3f:	e8 b7 ff ff ff       	call   801079fb <outb>
80107a44:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107a47:	6a 0c                	push   $0xc
80107a49:	68 f8 03 00 00       	push   $0x3f8
80107a4e:	e8 a8 ff ff ff       	call   801079fb <outb>
80107a53:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107a56:	6a 00                	push   $0x0
80107a58:	68 f9 03 00 00       	push   $0x3f9
80107a5d:	e8 99 ff ff ff       	call   801079fb <outb>
80107a62:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107a65:	6a 03                	push   $0x3
80107a67:	68 fb 03 00 00       	push   $0x3fb
80107a6c:	e8 8a ff ff ff       	call   801079fb <outb>
80107a71:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107a74:	6a 00                	push   $0x0
80107a76:	68 fc 03 00 00       	push   $0x3fc
80107a7b:	e8 7b ff ff ff       	call   801079fb <outb>
80107a80:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107a83:	6a 01                	push   $0x1
80107a85:	68 f9 03 00 00       	push   $0x3f9
80107a8a:	e8 6c ff ff ff       	call   801079fb <outb>
80107a8f:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107a92:	68 fd 03 00 00       	push   $0x3fd
80107a97:	e8 42 ff ff ff       	call   801079de <inb>
80107a9c:	83 c4 04             	add    $0x4,%esp
80107a9f:	3c ff                	cmp    $0xff,%al
80107aa1:	74 6e                	je     80107b11 <uartinit+0xf5>
    return;
  uart = 1;
80107aa3:	c7 05 50 d6 10 80 01 	movl   $0x1,0x8010d650
80107aaa:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107aad:	68 fa 03 00 00       	push   $0x3fa
80107ab2:	e8 27 ff ff ff       	call   801079de <inb>
80107ab7:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107aba:	68 f8 03 00 00       	push   $0x3f8
80107abf:	e8 1a ff ff ff       	call   801079de <inb>
80107ac4:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107ac7:	83 ec 0c             	sub    $0xc,%esp
80107aca:	6a 04                	push   $0x4
80107acc:	e8 a1 cd ff ff       	call   80104872 <picenable>
80107ad1:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107ad4:	83 ec 08             	sub    $0x8,%esp
80107ad7:	6a 00                	push   $0x0
80107ad9:	6a 04                	push   $0x4
80107adb:	e8 45 b8 ff ff       	call   80103325 <ioapicenable>
80107ae0:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107ae3:	c7 45 f4 a4 a6 10 80 	movl   $0x8010a6a4,-0xc(%ebp)
80107aea:	eb 19                	jmp    80107b05 <uartinit+0xe9>
    uartputc(*p);
80107aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aef:	0f b6 00             	movzbl (%eax),%eax
80107af2:	0f be c0             	movsbl %al,%eax
80107af5:	83 ec 0c             	sub    $0xc,%esp
80107af8:	50                   	push   %eax
80107af9:	e8 16 00 00 00       	call   80107b14 <uartputc>
80107afe:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80107b01:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b08:	0f b6 00             	movzbl (%eax),%eax
80107b0b:	84 c0                	test   %al,%al
80107b0d:	75 dd                	jne    80107aec <uartinit+0xd0>
80107b0f:	eb 01                	jmp    80107b12 <uartinit+0xf6>
    return;
80107b11:	90                   	nop
}
80107b12:	c9                   	leave  
80107b13:	c3                   	ret    

80107b14 <uartputc>:

void
uartputc(int c)
{
80107b14:	f3 0f 1e fb          	endbr32 
80107b18:	55                   	push   %ebp
80107b19:	89 e5                	mov    %esp,%ebp
80107b1b:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80107b1e:	a1 50 d6 10 80       	mov    0x8010d650,%eax
80107b23:	85 c0                	test   %eax,%eax
80107b25:	74 53                	je     80107b7a <uartputc+0x66>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b27:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107b2e:	eb 11                	jmp    80107b41 <uartputc+0x2d>
    microdelay(10);
80107b30:	83 ec 0c             	sub    $0xc,%esp
80107b33:	6a 0a                	push   $0xa
80107b35:	e8 cf bd ff ff       	call   80103909 <microdelay>
80107b3a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107b3d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107b41:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107b45:	7f 1a                	jg     80107b61 <uartputc+0x4d>
80107b47:	83 ec 0c             	sub    $0xc,%esp
80107b4a:	68 fd 03 00 00       	push   $0x3fd
80107b4f:	e8 8a fe ff ff       	call   801079de <inb>
80107b54:	83 c4 10             	add    $0x10,%esp
80107b57:	0f b6 c0             	movzbl %al,%eax
80107b5a:	83 e0 20             	and    $0x20,%eax
80107b5d:	85 c0                	test   %eax,%eax
80107b5f:	74 cf                	je     80107b30 <uartputc+0x1c>
  outb(COM1+0, c);
80107b61:	8b 45 08             	mov    0x8(%ebp),%eax
80107b64:	0f b6 c0             	movzbl %al,%eax
80107b67:	83 ec 08             	sub    $0x8,%esp
80107b6a:	50                   	push   %eax
80107b6b:	68 f8 03 00 00       	push   $0x3f8
80107b70:	e8 86 fe ff ff       	call   801079fb <outb>
80107b75:	83 c4 10             	add    $0x10,%esp
80107b78:	eb 01                	jmp    80107b7b <uartputc+0x67>
    return;
80107b7a:	90                   	nop
}
80107b7b:	c9                   	leave  
80107b7c:	c3                   	ret    

80107b7d <uartgetc>:

static int
uartgetc(void)
{
80107b7d:	f3 0f 1e fb          	endbr32 
80107b81:	55                   	push   %ebp
80107b82:	89 e5                	mov    %esp,%ebp
  if(!uart)
80107b84:	a1 50 d6 10 80       	mov    0x8010d650,%eax
80107b89:	85 c0                	test   %eax,%eax
80107b8b:	75 07                	jne    80107b94 <uartgetc+0x17>
    return -1;
80107b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b92:	eb 2e                	jmp    80107bc2 <uartgetc+0x45>
  if(!(inb(COM1+5) & 0x01))
80107b94:	68 fd 03 00 00       	push   $0x3fd
80107b99:	e8 40 fe ff ff       	call   801079de <inb>
80107b9e:	83 c4 04             	add    $0x4,%esp
80107ba1:	0f b6 c0             	movzbl %al,%eax
80107ba4:	83 e0 01             	and    $0x1,%eax
80107ba7:	85 c0                	test   %eax,%eax
80107ba9:	75 07                	jne    80107bb2 <uartgetc+0x35>
    return -1;
80107bab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107bb0:	eb 10                	jmp    80107bc2 <uartgetc+0x45>
  return inb(COM1+0);
80107bb2:	68 f8 03 00 00       	push   $0x3f8
80107bb7:	e8 22 fe ff ff       	call   801079de <inb>
80107bbc:	83 c4 04             	add    $0x4,%esp
80107bbf:	0f b6 c0             	movzbl %al,%eax
}
80107bc2:	c9                   	leave  
80107bc3:	c3                   	ret    

80107bc4 <uartintr>:

void
uartintr(void)
{
80107bc4:	f3 0f 1e fb          	endbr32 
80107bc8:	55                   	push   %ebp
80107bc9:	89 e5                	mov    %esp,%ebp
80107bcb:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107bce:	83 ec 0c             	sub    $0xc,%esp
80107bd1:	68 7d 7b 10 80       	push   $0x80107b7d
80107bd6:	e8 63 8c ff ff       	call   8010083e <consoleintr>
80107bdb:	83 c4 10             	add    $0x10,%esp
}
80107bde:	90                   	nop
80107bdf:	c9                   	leave  
80107be0:	c3                   	ret    

80107be1 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107be1:	6a 00                	push   $0x0
  pushl $0
80107be3:	6a 00                	push   $0x0
  jmp alltraps
80107be5:	e9 2a f9 ff ff       	jmp    80107514 <alltraps>

80107bea <vector1>:
.globl vector1
vector1:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $1
80107bec:	6a 01                	push   $0x1
  jmp alltraps
80107bee:	e9 21 f9 ff ff       	jmp    80107514 <alltraps>

80107bf3 <vector2>:
.globl vector2
vector2:
  pushl $0
80107bf3:	6a 00                	push   $0x0
  pushl $2
80107bf5:	6a 02                	push   $0x2
  jmp alltraps
80107bf7:	e9 18 f9 ff ff       	jmp    80107514 <alltraps>

80107bfc <vector3>:
.globl vector3
vector3:
  pushl $0
80107bfc:	6a 00                	push   $0x0
  pushl $3
80107bfe:	6a 03                	push   $0x3
  jmp alltraps
80107c00:	e9 0f f9 ff ff       	jmp    80107514 <alltraps>

80107c05 <vector4>:
.globl vector4
vector4:
  pushl $0
80107c05:	6a 00                	push   $0x0
  pushl $4
80107c07:	6a 04                	push   $0x4
  jmp alltraps
80107c09:	e9 06 f9 ff ff       	jmp    80107514 <alltraps>

80107c0e <vector5>:
.globl vector5
vector5:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $5
80107c10:	6a 05                	push   $0x5
  jmp alltraps
80107c12:	e9 fd f8 ff ff       	jmp    80107514 <alltraps>

80107c17 <vector6>:
.globl vector6
vector6:
  pushl $0
80107c17:	6a 00                	push   $0x0
  pushl $6
80107c19:	6a 06                	push   $0x6
  jmp alltraps
80107c1b:	e9 f4 f8 ff ff       	jmp    80107514 <alltraps>

80107c20 <vector7>:
.globl vector7
vector7:
  pushl $0
80107c20:	6a 00                	push   $0x0
  pushl $7
80107c22:	6a 07                	push   $0x7
  jmp alltraps
80107c24:	e9 eb f8 ff ff       	jmp    80107514 <alltraps>

80107c29 <vector8>:
.globl vector8
vector8:
  pushl $8
80107c29:	6a 08                	push   $0x8
  jmp alltraps
80107c2b:	e9 e4 f8 ff ff       	jmp    80107514 <alltraps>

80107c30 <vector9>:
.globl vector9
vector9:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $9
80107c32:	6a 09                	push   $0x9
  jmp alltraps
80107c34:	e9 db f8 ff ff       	jmp    80107514 <alltraps>

80107c39 <vector10>:
.globl vector10
vector10:
  pushl $10
80107c39:	6a 0a                	push   $0xa
  jmp alltraps
80107c3b:	e9 d4 f8 ff ff       	jmp    80107514 <alltraps>

80107c40 <vector11>:
.globl vector11
vector11:
  pushl $11
80107c40:	6a 0b                	push   $0xb
  jmp alltraps
80107c42:	e9 cd f8 ff ff       	jmp    80107514 <alltraps>

80107c47 <vector12>:
.globl vector12
vector12:
  pushl $12
80107c47:	6a 0c                	push   $0xc
  jmp alltraps
80107c49:	e9 c6 f8 ff ff       	jmp    80107514 <alltraps>

80107c4e <vector13>:
.globl vector13
vector13:
  pushl $13
80107c4e:	6a 0d                	push   $0xd
  jmp alltraps
80107c50:	e9 bf f8 ff ff       	jmp    80107514 <alltraps>

80107c55 <vector14>:
.globl vector14
vector14:
  pushl $14
80107c55:	6a 0e                	push   $0xe
  jmp alltraps
80107c57:	e9 b8 f8 ff ff       	jmp    80107514 <alltraps>

80107c5c <vector15>:
.globl vector15
vector15:
  pushl $0
80107c5c:	6a 00                	push   $0x0
  pushl $15
80107c5e:	6a 0f                	push   $0xf
  jmp alltraps
80107c60:	e9 af f8 ff ff       	jmp    80107514 <alltraps>

80107c65 <vector16>:
.globl vector16
vector16:
  pushl $0
80107c65:	6a 00                	push   $0x0
  pushl $16
80107c67:	6a 10                	push   $0x10
  jmp alltraps
80107c69:	e9 a6 f8 ff ff       	jmp    80107514 <alltraps>

80107c6e <vector17>:
.globl vector17
vector17:
  pushl $17
80107c6e:	6a 11                	push   $0x11
  jmp alltraps
80107c70:	e9 9f f8 ff ff       	jmp    80107514 <alltraps>

80107c75 <vector18>:
.globl vector18
vector18:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $18
80107c77:	6a 12                	push   $0x12
  jmp alltraps
80107c79:	e9 96 f8 ff ff       	jmp    80107514 <alltraps>

80107c7e <vector19>:
.globl vector19
vector19:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $19
80107c80:	6a 13                	push   $0x13
  jmp alltraps
80107c82:	e9 8d f8 ff ff       	jmp    80107514 <alltraps>

80107c87 <vector20>:
.globl vector20
vector20:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $20
80107c89:	6a 14                	push   $0x14
  jmp alltraps
80107c8b:	e9 84 f8 ff ff       	jmp    80107514 <alltraps>

80107c90 <vector21>:
.globl vector21
vector21:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $21
80107c92:	6a 15                	push   $0x15
  jmp alltraps
80107c94:	e9 7b f8 ff ff       	jmp    80107514 <alltraps>

80107c99 <vector22>:
.globl vector22
vector22:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $22
80107c9b:	6a 16                	push   $0x16
  jmp alltraps
80107c9d:	e9 72 f8 ff ff       	jmp    80107514 <alltraps>

80107ca2 <vector23>:
.globl vector23
vector23:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $23
80107ca4:	6a 17                	push   $0x17
  jmp alltraps
80107ca6:	e9 69 f8 ff ff       	jmp    80107514 <alltraps>

80107cab <vector24>:
.globl vector24
vector24:
  pushl $0
80107cab:	6a 00                	push   $0x0
  pushl $24
80107cad:	6a 18                	push   $0x18
  jmp alltraps
80107caf:	e9 60 f8 ff ff       	jmp    80107514 <alltraps>

80107cb4 <vector25>:
.globl vector25
vector25:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $25
80107cb6:	6a 19                	push   $0x19
  jmp alltraps
80107cb8:	e9 57 f8 ff ff       	jmp    80107514 <alltraps>

80107cbd <vector26>:
.globl vector26
vector26:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $26
80107cbf:	6a 1a                	push   $0x1a
  jmp alltraps
80107cc1:	e9 4e f8 ff ff       	jmp    80107514 <alltraps>

80107cc6 <vector27>:
.globl vector27
vector27:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $27
80107cc8:	6a 1b                	push   $0x1b
  jmp alltraps
80107cca:	e9 45 f8 ff ff       	jmp    80107514 <alltraps>

80107ccf <vector28>:
.globl vector28
vector28:
  pushl $0
80107ccf:	6a 00                	push   $0x0
  pushl $28
80107cd1:	6a 1c                	push   $0x1c
  jmp alltraps
80107cd3:	e9 3c f8 ff ff       	jmp    80107514 <alltraps>

80107cd8 <vector29>:
.globl vector29
vector29:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $29
80107cda:	6a 1d                	push   $0x1d
  jmp alltraps
80107cdc:	e9 33 f8 ff ff       	jmp    80107514 <alltraps>

80107ce1 <vector30>:
.globl vector30
vector30:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $30
80107ce3:	6a 1e                	push   $0x1e
  jmp alltraps
80107ce5:	e9 2a f8 ff ff       	jmp    80107514 <alltraps>

80107cea <vector31>:
.globl vector31
vector31:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $31
80107cec:	6a 1f                	push   $0x1f
  jmp alltraps
80107cee:	e9 21 f8 ff ff       	jmp    80107514 <alltraps>

80107cf3 <vector32>:
.globl vector32
vector32:
  pushl $0
80107cf3:	6a 00                	push   $0x0
  pushl $32
80107cf5:	6a 20                	push   $0x20
  jmp alltraps
80107cf7:	e9 18 f8 ff ff       	jmp    80107514 <alltraps>

80107cfc <vector33>:
.globl vector33
vector33:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $33
80107cfe:	6a 21                	push   $0x21
  jmp alltraps
80107d00:	e9 0f f8 ff ff       	jmp    80107514 <alltraps>

80107d05 <vector34>:
.globl vector34
vector34:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $34
80107d07:	6a 22                	push   $0x22
  jmp alltraps
80107d09:	e9 06 f8 ff ff       	jmp    80107514 <alltraps>

80107d0e <vector35>:
.globl vector35
vector35:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $35
80107d10:	6a 23                	push   $0x23
  jmp alltraps
80107d12:	e9 fd f7 ff ff       	jmp    80107514 <alltraps>

80107d17 <vector36>:
.globl vector36
vector36:
  pushl $0
80107d17:	6a 00                	push   $0x0
  pushl $36
80107d19:	6a 24                	push   $0x24
  jmp alltraps
80107d1b:	e9 f4 f7 ff ff       	jmp    80107514 <alltraps>

80107d20 <vector37>:
.globl vector37
vector37:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $37
80107d22:	6a 25                	push   $0x25
  jmp alltraps
80107d24:	e9 eb f7 ff ff       	jmp    80107514 <alltraps>

80107d29 <vector38>:
.globl vector38
vector38:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $38
80107d2b:	6a 26                	push   $0x26
  jmp alltraps
80107d2d:	e9 e2 f7 ff ff       	jmp    80107514 <alltraps>

80107d32 <vector39>:
.globl vector39
vector39:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $39
80107d34:	6a 27                	push   $0x27
  jmp alltraps
80107d36:	e9 d9 f7 ff ff       	jmp    80107514 <alltraps>

80107d3b <vector40>:
.globl vector40
vector40:
  pushl $0
80107d3b:	6a 00                	push   $0x0
  pushl $40
80107d3d:	6a 28                	push   $0x28
  jmp alltraps
80107d3f:	e9 d0 f7 ff ff       	jmp    80107514 <alltraps>

80107d44 <vector41>:
.globl vector41
vector41:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $41
80107d46:	6a 29                	push   $0x29
  jmp alltraps
80107d48:	e9 c7 f7 ff ff       	jmp    80107514 <alltraps>

80107d4d <vector42>:
.globl vector42
vector42:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $42
80107d4f:	6a 2a                	push   $0x2a
  jmp alltraps
80107d51:	e9 be f7 ff ff       	jmp    80107514 <alltraps>

80107d56 <vector43>:
.globl vector43
vector43:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $43
80107d58:	6a 2b                	push   $0x2b
  jmp alltraps
80107d5a:	e9 b5 f7 ff ff       	jmp    80107514 <alltraps>

80107d5f <vector44>:
.globl vector44
vector44:
  pushl $0
80107d5f:	6a 00                	push   $0x0
  pushl $44
80107d61:	6a 2c                	push   $0x2c
  jmp alltraps
80107d63:	e9 ac f7 ff ff       	jmp    80107514 <alltraps>

80107d68 <vector45>:
.globl vector45
vector45:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $45
80107d6a:	6a 2d                	push   $0x2d
  jmp alltraps
80107d6c:	e9 a3 f7 ff ff       	jmp    80107514 <alltraps>

80107d71 <vector46>:
.globl vector46
vector46:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $46
80107d73:	6a 2e                	push   $0x2e
  jmp alltraps
80107d75:	e9 9a f7 ff ff       	jmp    80107514 <alltraps>

80107d7a <vector47>:
.globl vector47
vector47:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $47
80107d7c:	6a 2f                	push   $0x2f
  jmp alltraps
80107d7e:	e9 91 f7 ff ff       	jmp    80107514 <alltraps>

80107d83 <vector48>:
.globl vector48
vector48:
  pushl $0
80107d83:	6a 00                	push   $0x0
  pushl $48
80107d85:	6a 30                	push   $0x30
  jmp alltraps
80107d87:	e9 88 f7 ff ff       	jmp    80107514 <alltraps>

80107d8c <vector49>:
.globl vector49
vector49:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $49
80107d8e:	6a 31                	push   $0x31
  jmp alltraps
80107d90:	e9 7f f7 ff ff       	jmp    80107514 <alltraps>

80107d95 <vector50>:
.globl vector50
vector50:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $50
80107d97:	6a 32                	push   $0x32
  jmp alltraps
80107d99:	e9 76 f7 ff ff       	jmp    80107514 <alltraps>

80107d9e <vector51>:
.globl vector51
vector51:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $51
80107da0:	6a 33                	push   $0x33
  jmp alltraps
80107da2:	e9 6d f7 ff ff       	jmp    80107514 <alltraps>

80107da7 <vector52>:
.globl vector52
vector52:
  pushl $0
80107da7:	6a 00                	push   $0x0
  pushl $52
80107da9:	6a 34                	push   $0x34
  jmp alltraps
80107dab:	e9 64 f7 ff ff       	jmp    80107514 <alltraps>

80107db0 <vector53>:
.globl vector53
vector53:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $53
80107db2:	6a 35                	push   $0x35
  jmp alltraps
80107db4:	e9 5b f7 ff ff       	jmp    80107514 <alltraps>

80107db9 <vector54>:
.globl vector54
vector54:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $54
80107dbb:	6a 36                	push   $0x36
  jmp alltraps
80107dbd:	e9 52 f7 ff ff       	jmp    80107514 <alltraps>

80107dc2 <vector55>:
.globl vector55
vector55:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $55
80107dc4:	6a 37                	push   $0x37
  jmp alltraps
80107dc6:	e9 49 f7 ff ff       	jmp    80107514 <alltraps>

80107dcb <vector56>:
.globl vector56
vector56:
  pushl $0
80107dcb:	6a 00                	push   $0x0
  pushl $56
80107dcd:	6a 38                	push   $0x38
  jmp alltraps
80107dcf:	e9 40 f7 ff ff       	jmp    80107514 <alltraps>

80107dd4 <vector57>:
.globl vector57
vector57:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $57
80107dd6:	6a 39                	push   $0x39
  jmp alltraps
80107dd8:	e9 37 f7 ff ff       	jmp    80107514 <alltraps>

80107ddd <vector58>:
.globl vector58
vector58:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $58
80107ddf:	6a 3a                	push   $0x3a
  jmp alltraps
80107de1:	e9 2e f7 ff ff       	jmp    80107514 <alltraps>

80107de6 <vector59>:
.globl vector59
vector59:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $59
80107de8:	6a 3b                	push   $0x3b
  jmp alltraps
80107dea:	e9 25 f7 ff ff       	jmp    80107514 <alltraps>

80107def <vector60>:
.globl vector60
vector60:
  pushl $0
80107def:	6a 00                	push   $0x0
  pushl $60
80107df1:	6a 3c                	push   $0x3c
  jmp alltraps
80107df3:	e9 1c f7 ff ff       	jmp    80107514 <alltraps>

80107df8 <vector61>:
.globl vector61
vector61:
  pushl $0
80107df8:	6a 00                	push   $0x0
  pushl $61
80107dfa:	6a 3d                	push   $0x3d
  jmp alltraps
80107dfc:	e9 13 f7 ff ff       	jmp    80107514 <alltraps>

80107e01 <vector62>:
.globl vector62
vector62:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $62
80107e03:	6a 3e                	push   $0x3e
  jmp alltraps
80107e05:	e9 0a f7 ff ff       	jmp    80107514 <alltraps>

80107e0a <vector63>:
.globl vector63
vector63:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $63
80107e0c:	6a 3f                	push   $0x3f
  jmp alltraps
80107e0e:	e9 01 f7 ff ff       	jmp    80107514 <alltraps>

80107e13 <vector64>:
.globl vector64
vector64:
  pushl $0
80107e13:	6a 00                	push   $0x0
  pushl $64
80107e15:	6a 40                	push   $0x40
  jmp alltraps
80107e17:	e9 f8 f6 ff ff       	jmp    80107514 <alltraps>

80107e1c <vector65>:
.globl vector65
vector65:
  pushl $0
80107e1c:	6a 00                	push   $0x0
  pushl $65
80107e1e:	6a 41                	push   $0x41
  jmp alltraps
80107e20:	e9 ef f6 ff ff       	jmp    80107514 <alltraps>

80107e25 <vector66>:
.globl vector66
vector66:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $66
80107e27:	6a 42                	push   $0x42
  jmp alltraps
80107e29:	e9 e6 f6 ff ff       	jmp    80107514 <alltraps>

80107e2e <vector67>:
.globl vector67
vector67:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $67
80107e30:	6a 43                	push   $0x43
  jmp alltraps
80107e32:	e9 dd f6 ff ff       	jmp    80107514 <alltraps>

80107e37 <vector68>:
.globl vector68
vector68:
  pushl $0
80107e37:	6a 00                	push   $0x0
  pushl $68
80107e39:	6a 44                	push   $0x44
  jmp alltraps
80107e3b:	e9 d4 f6 ff ff       	jmp    80107514 <alltraps>

80107e40 <vector69>:
.globl vector69
vector69:
  pushl $0
80107e40:	6a 00                	push   $0x0
  pushl $69
80107e42:	6a 45                	push   $0x45
  jmp alltraps
80107e44:	e9 cb f6 ff ff       	jmp    80107514 <alltraps>

80107e49 <vector70>:
.globl vector70
vector70:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $70
80107e4b:	6a 46                	push   $0x46
  jmp alltraps
80107e4d:	e9 c2 f6 ff ff       	jmp    80107514 <alltraps>

80107e52 <vector71>:
.globl vector71
vector71:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $71
80107e54:	6a 47                	push   $0x47
  jmp alltraps
80107e56:	e9 b9 f6 ff ff       	jmp    80107514 <alltraps>

80107e5b <vector72>:
.globl vector72
vector72:
  pushl $0
80107e5b:	6a 00                	push   $0x0
  pushl $72
80107e5d:	6a 48                	push   $0x48
  jmp alltraps
80107e5f:	e9 b0 f6 ff ff       	jmp    80107514 <alltraps>

80107e64 <vector73>:
.globl vector73
vector73:
  pushl $0
80107e64:	6a 00                	push   $0x0
  pushl $73
80107e66:	6a 49                	push   $0x49
  jmp alltraps
80107e68:	e9 a7 f6 ff ff       	jmp    80107514 <alltraps>

80107e6d <vector74>:
.globl vector74
vector74:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $74
80107e6f:	6a 4a                	push   $0x4a
  jmp alltraps
80107e71:	e9 9e f6 ff ff       	jmp    80107514 <alltraps>

80107e76 <vector75>:
.globl vector75
vector75:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $75
80107e78:	6a 4b                	push   $0x4b
  jmp alltraps
80107e7a:	e9 95 f6 ff ff       	jmp    80107514 <alltraps>

80107e7f <vector76>:
.globl vector76
vector76:
  pushl $0
80107e7f:	6a 00                	push   $0x0
  pushl $76
80107e81:	6a 4c                	push   $0x4c
  jmp alltraps
80107e83:	e9 8c f6 ff ff       	jmp    80107514 <alltraps>

80107e88 <vector77>:
.globl vector77
vector77:
  pushl $0
80107e88:	6a 00                	push   $0x0
  pushl $77
80107e8a:	6a 4d                	push   $0x4d
  jmp alltraps
80107e8c:	e9 83 f6 ff ff       	jmp    80107514 <alltraps>

80107e91 <vector78>:
.globl vector78
vector78:
  pushl $0
80107e91:	6a 00                	push   $0x0
  pushl $78
80107e93:	6a 4e                	push   $0x4e
  jmp alltraps
80107e95:	e9 7a f6 ff ff       	jmp    80107514 <alltraps>

80107e9a <vector79>:
.globl vector79
vector79:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $79
80107e9c:	6a 4f                	push   $0x4f
  jmp alltraps
80107e9e:	e9 71 f6 ff ff       	jmp    80107514 <alltraps>

80107ea3 <vector80>:
.globl vector80
vector80:
  pushl $0
80107ea3:	6a 00                	push   $0x0
  pushl $80
80107ea5:	6a 50                	push   $0x50
  jmp alltraps
80107ea7:	e9 68 f6 ff ff       	jmp    80107514 <alltraps>

80107eac <vector81>:
.globl vector81
vector81:
  pushl $0
80107eac:	6a 00                	push   $0x0
  pushl $81
80107eae:	6a 51                	push   $0x51
  jmp alltraps
80107eb0:	e9 5f f6 ff ff       	jmp    80107514 <alltraps>

80107eb5 <vector82>:
.globl vector82
vector82:
  pushl $0
80107eb5:	6a 00                	push   $0x0
  pushl $82
80107eb7:	6a 52                	push   $0x52
  jmp alltraps
80107eb9:	e9 56 f6 ff ff       	jmp    80107514 <alltraps>

80107ebe <vector83>:
.globl vector83
vector83:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $83
80107ec0:	6a 53                	push   $0x53
  jmp alltraps
80107ec2:	e9 4d f6 ff ff       	jmp    80107514 <alltraps>

80107ec7 <vector84>:
.globl vector84
vector84:
  pushl $0
80107ec7:	6a 00                	push   $0x0
  pushl $84
80107ec9:	6a 54                	push   $0x54
  jmp alltraps
80107ecb:	e9 44 f6 ff ff       	jmp    80107514 <alltraps>

80107ed0 <vector85>:
.globl vector85
vector85:
  pushl $0
80107ed0:	6a 00                	push   $0x0
  pushl $85
80107ed2:	6a 55                	push   $0x55
  jmp alltraps
80107ed4:	e9 3b f6 ff ff       	jmp    80107514 <alltraps>

80107ed9 <vector86>:
.globl vector86
vector86:
  pushl $0
80107ed9:	6a 00                	push   $0x0
  pushl $86
80107edb:	6a 56                	push   $0x56
  jmp alltraps
80107edd:	e9 32 f6 ff ff       	jmp    80107514 <alltraps>

80107ee2 <vector87>:
.globl vector87
vector87:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $87
80107ee4:	6a 57                	push   $0x57
  jmp alltraps
80107ee6:	e9 29 f6 ff ff       	jmp    80107514 <alltraps>

80107eeb <vector88>:
.globl vector88
vector88:
  pushl $0
80107eeb:	6a 00                	push   $0x0
  pushl $88
80107eed:	6a 58                	push   $0x58
  jmp alltraps
80107eef:	e9 20 f6 ff ff       	jmp    80107514 <alltraps>

80107ef4 <vector89>:
.globl vector89
vector89:
  pushl $0
80107ef4:	6a 00                	push   $0x0
  pushl $89
80107ef6:	6a 59                	push   $0x59
  jmp alltraps
80107ef8:	e9 17 f6 ff ff       	jmp    80107514 <alltraps>

80107efd <vector90>:
.globl vector90
vector90:
  pushl $0
80107efd:	6a 00                	push   $0x0
  pushl $90
80107eff:	6a 5a                	push   $0x5a
  jmp alltraps
80107f01:	e9 0e f6 ff ff       	jmp    80107514 <alltraps>

80107f06 <vector91>:
.globl vector91
vector91:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $91
80107f08:	6a 5b                	push   $0x5b
  jmp alltraps
80107f0a:	e9 05 f6 ff ff       	jmp    80107514 <alltraps>

80107f0f <vector92>:
.globl vector92
vector92:
  pushl $0
80107f0f:	6a 00                	push   $0x0
  pushl $92
80107f11:	6a 5c                	push   $0x5c
  jmp alltraps
80107f13:	e9 fc f5 ff ff       	jmp    80107514 <alltraps>

80107f18 <vector93>:
.globl vector93
vector93:
  pushl $0
80107f18:	6a 00                	push   $0x0
  pushl $93
80107f1a:	6a 5d                	push   $0x5d
  jmp alltraps
80107f1c:	e9 f3 f5 ff ff       	jmp    80107514 <alltraps>

80107f21 <vector94>:
.globl vector94
vector94:
  pushl $0
80107f21:	6a 00                	push   $0x0
  pushl $94
80107f23:	6a 5e                	push   $0x5e
  jmp alltraps
80107f25:	e9 ea f5 ff ff       	jmp    80107514 <alltraps>

80107f2a <vector95>:
.globl vector95
vector95:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $95
80107f2c:	6a 5f                	push   $0x5f
  jmp alltraps
80107f2e:	e9 e1 f5 ff ff       	jmp    80107514 <alltraps>

80107f33 <vector96>:
.globl vector96
vector96:
  pushl $0
80107f33:	6a 00                	push   $0x0
  pushl $96
80107f35:	6a 60                	push   $0x60
  jmp alltraps
80107f37:	e9 d8 f5 ff ff       	jmp    80107514 <alltraps>

80107f3c <vector97>:
.globl vector97
vector97:
  pushl $0
80107f3c:	6a 00                	push   $0x0
  pushl $97
80107f3e:	6a 61                	push   $0x61
  jmp alltraps
80107f40:	e9 cf f5 ff ff       	jmp    80107514 <alltraps>

80107f45 <vector98>:
.globl vector98
vector98:
  pushl $0
80107f45:	6a 00                	push   $0x0
  pushl $98
80107f47:	6a 62                	push   $0x62
  jmp alltraps
80107f49:	e9 c6 f5 ff ff       	jmp    80107514 <alltraps>

80107f4e <vector99>:
.globl vector99
vector99:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $99
80107f50:	6a 63                	push   $0x63
  jmp alltraps
80107f52:	e9 bd f5 ff ff       	jmp    80107514 <alltraps>

80107f57 <vector100>:
.globl vector100
vector100:
  pushl $0
80107f57:	6a 00                	push   $0x0
  pushl $100
80107f59:	6a 64                	push   $0x64
  jmp alltraps
80107f5b:	e9 b4 f5 ff ff       	jmp    80107514 <alltraps>

80107f60 <vector101>:
.globl vector101
vector101:
  pushl $0
80107f60:	6a 00                	push   $0x0
  pushl $101
80107f62:	6a 65                	push   $0x65
  jmp alltraps
80107f64:	e9 ab f5 ff ff       	jmp    80107514 <alltraps>

80107f69 <vector102>:
.globl vector102
vector102:
  pushl $0
80107f69:	6a 00                	push   $0x0
  pushl $102
80107f6b:	6a 66                	push   $0x66
  jmp alltraps
80107f6d:	e9 a2 f5 ff ff       	jmp    80107514 <alltraps>

80107f72 <vector103>:
.globl vector103
vector103:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $103
80107f74:	6a 67                	push   $0x67
  jmp alltraps
80107f76:	e9 99 f5 ff ff       	jmp    80107514 <alltraps>

80107f7b <vector104>:
.globl vector104
vector104:
  pushl $0
80107f7b:	6a 00                	push   $0x0
  pushl $104
80107f7d:	6a 68                	push   $0x68
  jmp alltraps
80107f7f:	e9 90 f5 ff ff       	jmp    80107514 <alltraps>

80107f84 <vector105>:
.globl vector105
vector105:
  pushl $0
80107f84:	6a 00                	push   $0x0
  pushl $105
80107f86:	6a 69                	push   $0x69
  jmp alltraps
80107f88:	e9 87 f5 ff ff       	jmp    80107514 <alltraps>

80107f8d <vector106>:
.globl vector106
vector106:
  pushl $0
80107f8d:	6a 00                	push   $0x0
  pushl $106
80107f8f:	6a 6a                	push   $0x6a
  jmp alltraps
80107f91:	e9 7e f5 ff ff       	jmp    80107514 <alltraps>

80107f96 <vector107>:
.globl vector107
vector107:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $107
80107f98:	6a 6b                	push   $0x6b
  jmp alltraps
80107f9a:	e9 75 f5 ff ff       	jmp    80107514 <alltraps>

80107f9f <vector108>:
.globl vector108
vector108:
  pushl $0
80107f9f:	6a 00                	push   $0x0
  pushl $108
80107fa1:	6a 6c                	push   $0x6c
  jmp alltraps
80107fa3:	e9 6c f5 ff ff       	jmp    80107514 <alltraps>

80107fa8 <vector109>:
.globl vector109
vector109:
  pushl $0
80107fa8:	6a 00                	push   $0x0
  pushl $109
80107faa:	6a 6d                	push   $0x6d
  jmp alltraps
80107fac:	e9 63 f5 ff ff       	jmp    80107514 <alltraps>

80107fb1 <vector110>:
.globl vector110
vector110:
  pushl $0
80107fb1:	6a 00                	push   $0x0
  pushl $110
80107fb3:	6a 6e                	push   $0x6e
  jmp alltraps
80107fb5:	e9 5a f5 ff ff       	jmp    80107514 <alltraps>

80107fba <vector111>:
.globl vector111
vector111:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $111
80107fbc:	6a 6f                	push   $0x6f
  jmp alltraps
80107fbe:	e9 51 f5 ff ff       	jmp    80107514 <alltraps>

80107fc3 <vector112>:
.globl vector112
vector112:
  pushl $0
80107fc3:	6a 00                	push   $0x0
  pushl $112
80107fc5:	6a 70                	push   $0x70
  jmp alltraps
80107fc7:	e9 48 f5 ff ff       	jmp    80107514 <alltraps>

80107fcc <vector113>:
.globl vector113
vector113:
  pushl $0
80107fcc:	6a 00                	push   $0x0
  pushl $113
80107fce:	6a 71                	push   $0x71
  jmp alltraps
80107fd0:	e9 3f f5 ff ff       	jmp    80107514 <alltraps>

80107fd5 <vector114>:
.globl vector114
vector114:
  pushl $0
80107fd5:	6a 00                	push   $0x0
  pushl $114
80107fd7:	6a 72                	push   $0x72
  jmp alltraps
80107fd9:	e9 36 f5 ff ff       	jmp    80107514 <alltraps>

80107fde <vector115>:
.globl vector115
vector115:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $115
80107fe0:	6a 73                	push   $0x73
  jmp alltraps
80107fe2:	e9 2d f5 ff ff       	jmp    80107514 <alltraps>

80107fe7 <vector116>:
.globl vector116
vector116:
  pushl $0
80107fe7:	6a 00                	push   $0x0
  pushl $116
80107fe9:	6a 74                	push   $0x74
  jmp alltraps
80107feb:	e9 24 f5 ff ff       	jmp    80107514 <alltraps>

80107ff0 <vector117>:
.globl vector117
vector117:
  pushl $0
80107ff0:	6a 00                	push   $0x0
  pushl $117
80107ff2:	6a 75                	push   $0x75
  jmp alltraps
80107ff4:	e9 1b f5 ff ff       	jmp    80107514 <alltraps>

80107ff9 <vector118>:
.globl vector118
vector118:
  pushl $0
80107ff9:	6a 00                	push   $0x0
  pushl $118
80107ffb:	6a 76                	push   $0x76
  jmp alltraps
80107ffd:	e9 12 f5 ff ff       	jmp    80107514 <alltraps>

80108002 <vector119>:
.globl vector119
vector119:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $119
80108004:	6a 77                	push   $0x77
  jmp alltraps
80108006:	e9 09 f5 ff ff       	jmp    80107514 <alltraps>

8010800b <vector120>:
.globl vector120
vector120:
  pushl $0
8010800b:	6a 00                	push   $0x0
  pushl $120
8010800d:	6a 78                	push   $0x78
  jmp alltraps
8010800f:	e9 00 f5 ff ff       	jmp    80107514 <alltraps>

80108014 <vector121>:
.globl vector121
vector121:
  pushl $0
80108014:	6a 00                	push   $0x0
  pushl $121
80108016:	6a 79                	push   $0x79
  jmp alltraps
80108018:	e9 f7 f4 ff ff       	jmp    80107514 <alltraps>

8010801d <vector122>:
.globl vector122
vector122:
  pushl $0
8010801d:	6a 00                	push   $0x0
  pushl $122
8010801f:	6a 7a                	push   $0x7a
  jmp alltraps
80108021:	e9 ee f4 ff ff       	jmp    80107514 <alltraps>

80108026 <vector123>:
.globl vector123
vector123:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $123
80108028:	6a 7b                	push   $0x7b
  jmp alltraps
8010802a:	e9 e5 f4 ff ff       	jmp    80107514 <alltraps>

8010802f <vector124>:
.globl vector124
vector124:
  pushl $0
8010802f:	6a 00                	push   $0x0
  pushl $124
80108031:	6a 7c                	push   $0x7c
  jmp alltraps
80108033:	e9 dc f4 ff ff       	jmp    80107514 <alltraps>

80108038 <vector125>:
.globl vector125
vector125:
  pushl $0
80108038:	6a 00                	push   $0x0
  pushl $125
8010803a:	6a 7d                	push   $0x7d
  jmp alltraps
8010803c:	e9 d3 f4 ff ff       	jmp    80107514 <alltraps>

80108041 <vector126>:
.globl vector126
vector126:
  pushl $0
80108041:	6a 00                	push   $0x0
  pushl $126
80108043:	6a 7e                	push   $0x7e
  jmp alltraps
80108045:	e9 ca f4 ff ff       	jmp    80107514 <alltraps>

8010804a <vector127>:
.globl vector127
vector127:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $127
8010804c:	6a 7f                	push   $0x7f
  jmp alltraps
8010804e:	e9 c1 f4 ff ff       	jmp    80107514 <alltraps>

80108053 <vector128>:
.globl vector128
vector128:
  pushl $0
80108053:	6a 00                	push   $0x0
  pushl $128
80108055:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010805a:	e9 b5 f4 ff ff       	jmp    80107514 <alltraps>

8010805f <vector129>:
.globl vector129
vector129:
  pushl $0
8010805f:	6a 00                	push   $0x0
  pushl $129
80108061:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80108066:	e9 a9 f4 ff ff       	jmp    80107514 <alltraps>

8010806b <vector130>:
.globl vector130
vector130:
  pushl $0
8010806b:	6a 00                	push   $0x0
  pushl $130
8010806d:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80108072:	e9 9d f4 ff ff       	jmp    80107514 <alltraps>

80108077 <vector131>:
.globl vector131
vector131:
  pushl $0
80108077:	6a 00                	push   $0x0
  pushl $131
80108079:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010807e:	e9 91 f4 ff ff       	jmp    80107514 <alltraps>

80108083 <vector132>:
.globl vector132
vector132:
  pushl $0
80108083:	6a 00                	push   $0x0
  pushl $132
80108085:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010808a:	e9 85 f4 ff ff       	jmp    80107514 <alltraps>

8010808f <vector133>:
.globl vector133
vector133:
  pushl $0
8010808f:	6a 00                	push   $0x0
  pushl $133
80108091:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80108096:	e9 79 f4 ff ff       	jmp    80107514 <alltraps>

8010809b <vector134>:
.globl vector134
vector134:
  pushl $0
8010809b:	6a 00                	push   $0x0
  pushl $134
8010809d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801080a2:	e9 6d f4 ff ff       	jmp    80107514 <alltraps>

801080a7 <vector135>:
.globl vector135
vector135:
  pushl $0
801080a7:	6a 00                	push   $0x0
  pushl $135
801080a9:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801080ae:	e9 61 f4 ff ff       	jmp    80107514 <alltraps>

801080b3 <vector136>:
.globl vector136
vector136:
  pushl $0
801080b3:	6a 00                	push   $0x0
  pushl $136
801080b5:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801080ba:	e9 55 f4 ff ff       	jmp    80107514 <alltraps>

801080bf <vector137>:
.globl vector137
vector137:
  pushl $0
801080bf:	6a 00                	push   $0x0
  pushl $137
801080c1:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801080c6:	e9 49 f4 ff ff       	jmp    80107514 <alltraps>

801080cb <vector138>:
.globl vector138
vector138:
  pushl $0
801080cb:	6a 00                	push   $0x0
  pushl $138
801080cd:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801080d2:	e9 3d f4 ff ff       	jmp    80107514 <alltraps>

801080d7 <vector139>:
.globl vector139
vector139:
  pushl $0
801080d7:	6a 00                	push   $0x0
  pushl $139
801080d9:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801080de:	e9 31 f4 ff ff       	jmp    80107514 <alltraps>

801080e3 <vector140>:
.globl vector140
vector140:
  pushl $0
801080e3:	6a 00                	push   $0x0
  pushl $140
801080e5:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801080ea:	e9 25 f4 ff ff       	jmp    80107514 <alltraps>

801080ef <vector141>:
.globl vector141
vector141:
  pushl $0
801080ef:	6a 00                	push   $0x0
  pushl $141
801080f1:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801080f6:	e9 19 f4 ff ff       	jmp    80107514 <alltraps>

801080fb <vector142>:
.globl vector142
vector142:
  pushl $0
801080fb:	6a 00                	push   $0x0
  pushl $142
801080fd:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80108102:	e9 0d f4 ff ff       	jmp    80107514 <alltraps>

80108107 <vector143>:
.globl vector143
vector143:
  pushl $0
80108107:	6a 00                	push   $0x0
  pushl $143
80108109:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010810e:	e9 01 f4 ff ff       	jmp    80107514 <alltraps>

80108113 <vector144>:
.globl vector144
vector144:
  pushl $0
80108113:	6a 00                	push   $0x0
  pushl $144
80108115:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010811a:	e9 f5 f3 ff ff       	jmp    80107514 <alltraps>

8010811f <vector145>:
.globl vector145
vector145:
  pushl $0
8010811f:	6a 00                	push   $0x0
  pushl $145
80108121:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80108126:	e9 e9 f3 ff ff       	jmp    80107514 <alltraps>

8010812b <vector146>:
.globl vector146
vector146:
  pushl $0
8010812b:	6a 00                	push   $0x0
  pushl $146
8010812d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80108132:	e9 dd f3 ff ff       	jmp    80107514 <alltraps>

80108137 <vector147>:
.globl vector147
vector147:
  pushl $0
80108137:	6a 00                	push   $0x0
  pushl $147
80108139:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010813e:	e9 d1 f3 ff ff       	jmp    80107514 <alltraps>

80108143 <vector148>:
.globl vector148
vector148:
  pushl $0
80108143:	6a 00                	push   $0x0
  pushl $148
80108145:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010814a:	e9 c5 f3 ff ff       	jmp    80107514 <alltraps>

8010814f <vector149>:
.globl vector149
vector149:
  pushl $0
8010814f:	6a 00                	push   $0x0
  pushl $149
80108151:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80108156:	e9 b9 f3 ff ff       	jmp    80107514 <alltraps>

8010815b <vector150>:
.globl vector150
vector150:
  pushl $0
8010815b:	6a 00                	push   $0x0
  pushl $150
8010815d:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80108162:	e9 ad f3 ff ff       	jmp    80107514 <alltraps>

80108167 <vector151>:
.globl vector151
vector151:
  pushl $0
80108167:	6a 00                	push   $0x0
  pushl $151
80108169:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010816e:	e9 a1 f3 ff ff       	jmp    80107514 <alltraps>

80108173 <vector152>:
.globl vector152
vector152:
  pushl $0
80108173:	6a 00                	push   $0x0
  pushl $152
80108175:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010817a:	e9 95 f3 ff ff       	jmp    80107514 <alltraps>

8010817f <vector153>:
.globl vector153
vector153:
  pushl $0
8010817f:	6a 00                	push   $0x0
  pushl $153
80108181:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80108186:	e9 89 f3 ff ff       	jmp    80107514 <alltraps>

8010818b <vector154>:
.globl vector154
vector154:
  pushl $0
8010818b:	6a 00                	push   $0x0
  pushl $154
8010818d:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80108192:	e9 7d f3 ff ff       	jmp    80107514 <alltraps>

80108197 <vector155>:
.globl vector155
vector155:
  pushl $0
80108197:	6a 00                	push   $0x0
  pushl $155
80108199:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010819e:	e9 71 f3 ff ff       	jmp    80107514 <alltraps>

801081a3 <vector156>:
.globl vector156
vector156:
  pushl $0
801081a3:	6a 00                	push   $0x0
  pushl $156
801081a5:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801081aa:	e9 65 f3 ff ff       	jmp    80107514 <alltraps>

801081af <vector157>:
.globl vector157
vector157:
  pushl $0
801081af:	6a 00                	push   $0x0
  pushl $157
801081b1:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801081b6:	e9 59 f3 ff ff       	jmp    80107514 <alltraps>

801081bb <vector158>:
.globl vector158
vector158:
  pushl $0
801081bb:	6a 00                	push   $0x0
  pushl $158
801081bd:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801081c2:	e9 4d f3 ff ff       	jmp    80107514 <alltraps>

801081c7 <vector159>:
.globl vector159
vector159:
  pushl $0
801081c7:	6a 00                	push   $0x0
  pushl $159
801081c9:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801081ce:	e9 41 f3 ff ff       	jmp    80107514 <alltraps>

801081d3 <vector160>:
.globl vector160
vector160:
  pushl $0
801081d3:	6a 00                	push   $0x0
  pushl $160
801081d5:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801081da:	e9 35 f3 ff ff       	jmp    80107514 <alltraps>

801081df <vector161>:
.globl vector161
vector161:
  pushl $0
801081df:	6a 00                	push   $0x0
  pushl $161
801081e1:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801081e6:	e9 29 f3 ff ff       	jmp    80107514 <alltraps>

801081eb <vector162>:
.globl vector162
vector162:
  pushl $0
801081eb:	6a 00                	push   $0x0
  pushl $162
801081ed:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801081f2:	e9 1d f3 ff ff       	jmp    80107514 <alltraps>

801081f7 <vector163>:
.globl vector163
vector163:
  pushl $0
801081f7:	6a 00                	push   $0x0
  pushl $163
801081f9:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801081fe:	e9 11 f3 ff ff       	jmp    80107514 <alltraps>

80108203 <vector164>:
.globl vector164
vector164:
  pushl $0
80108203:	6a 00                	push   $0x0
  pushl $164
80108205:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010820a:	e9 05 f3 ff ff       	jmp    80107514 <alltraps>

8010820f <vector165>:
.globl vector165
vector165:
  pushl $0
8010820f:	6a 00                	push   $0x0
  pushl $165
80108211:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108216:	e9 f9 f2 ff ff       	jmp    80107514 <alltraps>

8010821b <vector166>:
.globl vector166
vector166:
  pushl $0
8010821b:	6a 00                	push   $0x0
  pushl $166
8010821d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80108222:	e9 ed f2 ff ff       	jmp    80107514 <alltraps>

80108227 <vector167>:
.globl vector167
vector167:
  pushl $0
80108227:	6a 00                	push   $0x0
  pushl $167
80108229:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010822e:	e9 e1 f2 ff ff       	jmp    80107514 <alltraps>

80108233 <vector168>:
.globl vector168
vector168:
  pushl $0
80108233:	6a 00                	push   $0x0
  pushl $168
80108235:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010823a:	e9 d5 f2 ff ff       	jmp    80107514 <alltraps>

8010823f <vector169>:
.globl vector169
vector169:
  pushl $0
8010823f:	6a 00                	push   $0x0
  pushl $169
80108241:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80108246:	e9 c9 f2 ff ff       	jmp    80107514 <alltraps>

8010824b <vector170>:
.globl vector170
vector170:
  pushl $0
8010824b:	6a 00                	push   $0x0
  pushl $170
8010824d:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80108252:	e9 bd f2 ff ff       	jmp    80107514 <alltraps>

80108257 <vector171>:
.globl vector171
vector171:
  pushl $0
80108257:	6a 00                	push   $0x0
  pushl $171
80108259:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010825e:	e9 b1 f2 ff ff       	jmp    80107514 <alltraps>

80108263 <vector172>:
.globl vector172
vector172:
  pushl $0
80108263:	6a 00                	push   $0x0
  pushl $172
80108265:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010826a:	e9 a5 f2 ff ff       	jmp    80107514 <alltraps>

8010826f <vector173>:
.globl vector173
vector173:
  pushl $0
8010826f:	6a 00                	push   $0x0
  pushl $173
80108271:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108276:	e9 99 f2 ff ff       	jmp    80107514 <alltraps>

8010827b <vector174>:
.globl vector174
vector174:
  pushl $0
8010827b:	6a 00                	push   $0x0
  pushl $174
8010827d:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108282:	e9 8d f2 ff ff       	jmp    80107514 <alltraps>

80108287 <vector175>:
.globl vector175
vector175:
  pushl $0
80108287:	6a 00                	push   $0x0
  pushl $175
80108289:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010828e:	e9 81 f2 ff ff       	jmp    80107514 <alltraps>

80108293 <vector176>:
.globl vector176
vector176:
  pushl $0
80108293:	6a 00                	push   $0x0
  pushl $176
80108295:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010829a:	e9 75 f2 ff ff       	jmp    80107514 <alltraps>

8010829f <vector177>:
.globl vector177
vector177:
  pushl $0
8010829f:	6a 00                	push   $0x0
  pushl $177
801082a1:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801082a6:	e9 69 f2 ff ff       	jmp    80107514 <alltraps>

801082ab <vector178>:
.globl vector178
vector178:
  pushl $0
801082ab:	6a 00                	push   $0x0
  pushl $178
801082ad:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801082b2:	e9 5d f2 ff ff       	jmp    80107514 <alltraps>

801082b7 <vector179>:
.globl vector179
vector179:
  pushl $0
801082b7:	6a 00                	push   $0x0
  pushl $179
801082b9:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801082be:	e9 51 f2 ff ff       	jmp    80107514 <alltraps>

801082c3 <vector180>:
.globl vector180
vector180:
  pushl $0
801082c3:	6a 00                	push   $0x0
  pushl $180
801082c5:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801082ca:	e9 45 f2 ff ff       	jmp    80107514 <alltraps>

801082cf <vector181>:
.globl vector181
vector181:
  pushl $0
801082cf:	6a 00                	push   $0x0
  pushl $181
801082d1:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801082d6:	e9 39 f2 ff ff       	jmp    80107514 <alltraps>

801082db <vector182>:
.globl vector182
vector182:
  pushl $0
801082db:	6a 00                	push   $0x0
  pushl $182
801082dd:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801082e2:	e9 2d f2 ff ff       	jmp    80107514 <alltraps>

801082e7 <vector183>:
.globl vector183
vector183:
  pushl $0
801082e7:	6a 00                	push   $0x0
  pushl $183
801082e9:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801082ee:	e9 21 f2 ff ff       	jmp    80107514 <alltraps>

801082f3 <vector184>:
.globl vector184
vector184:
  pushl $0
801082f3:	6a 00                	push   $0x0
  pushl $184
801082f5:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801082fa:	e9 15 f2 ff ff       	jmp    80107514 <alltraps>

801082ff <vector185>:
.globl vector185
vector185:
  pushl $0
801082ff:	6a 00                	push   $0x0
  pushl $185
80108301:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108306:	e9 09 f2 ff ff       	jmp    80107514 <alltraps>

8010830b <vector186>:
.globl vector186
vector186:
  pushl $0
8010830b:	6a 00                	push   $0x0
  pushl $186
8010830d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108312:	e9 fd f1 ff ff       	jmp    80107514 <alltraps>

80108317 <vector187>:
.globl vector187
vector187:
  pushl $0
80108317:	6a 00                	push   $0x0
  pushl $187
80108319:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010831e:	e9 f1 f1 ff ff       	jmp    80107514 <alltraps>

80108323 <vector188>:
.globl vector188
vector188:
  pushl $0
80108323:	6a 00                	push   $0x0
  pushl $188
80108325:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010832a:	e9 e5 f1 ff ff       	jmp    80107514 <alltraps>

8010832f <vector189>:
.globl vector189
vector189:
  pushl $0
8010832f:	6a 00                	push   $0x0
  pushl $189
80108331:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80108336:	e9 d9 f1 ff ff       	jmp    80107514 <alltraps>

8010833b <vector190>:
.globl vector190
vector190:
  pushl $0
8010833b:	6a 00                	push   $0x0
  pushl $190
8010833d:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108342:	e9 cd f1 ff ff       	jmp    80107514 <alltraps>

80108347 <vector191>:
.globl vector191
vector191:
  pushl $0
80108347:	6a 00                	push   $0x0
  pushl $191
80108349:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010834e:	e9 c1 f1 ff ff       	jmp    80107514 <alltraps>

80108353 <vector192>:
.globl vector192
vector192:
  pushl $0
80108353:	6a 00                	push   $0x0
  pushl $192
80108355:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010835a:	e9 b5 f1 ff ff       	jmp    80107514 <alltraps>

8010835f <vector193>:
.globl vector193
vector193:
  pushl $0
8010835f:	6a 00                	push   $0x0
  pushl $193
80108361:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80108366:	e9 a9 f1 ff ff       	jmp    80107514 <alltraps>

8010836b <vector194>:
.globl vector194
vector194:
  pushl $0
8010836b:	6a 00                	push   $0x0
  pushl $194
8010836d:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108372:	e9 9d f1 ff ff       	jmp    80107514 <alltraps>

80108377 <vector195>:
.globl vector195
vector195:
  pushl $0
80108377:	6a 00                	push   $0x0
  pushl $195
80108379:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010837e:	e9 91 f1 ff ff       	jmp    80107514 <alltraps>

80108383 <vector196>:
.globl vector196
vector196:
  pushl $0
80108383:	6a 00                	push   $0x0
  pushl $196
80108385:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010838a:	e9 85 f1 ff ff       	jmp    80107514 <alltraps>

8010838f <vector197>:
.globl vector197
vector197:
  pushl $0
8010838f:	6a 00                	push   $0x0
  pushl $197
80108391:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108396:	e9 79 f1 ff ff       	jmp    80107514 <alltraps>

8010839b <vector198>:
.globl vector198
vector198:
  pushl $0
8010839b:	6a 00                	push   $0x0
  pushl $198
8010839d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801083a2:	e9 6d f1 ff ff       	jmp    80107514 <alltraps>

801083a7 <vector199>:
.globl vector199
vector199:
  pushl $0
801083a7:	6a 00                	push   $0x0
  pushl $199
801083a9:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801083ae:	e9 61 f1 ff ff       	jmp    80107514 <alltraps>

801083b3 <vector200>:
.globl vector200
vector200:
  pushl $0
801083b3:	6a 00                	push   $0x0
  pushl $200
801083b5:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801083ba:	e9 55 f1 ff ff       	jmp    80107514 <alltraps>

801083bf <vector201>:
.globl vector201
vector201:
  pushl $0
801083bf:	6a 00                	push   $0x0
  pushl $201
801083c1:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801083c6:	e9 49 f1 ff ff       	jmp    80107514 <alltraps>

801083cb <vector202>:
.globl vector202
vector202:
  pushl $0
801083cb:	6a 00                	push   $0x0
  pushl $202
801083cd:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801083d2:	e9 3d f1 ff ff       	jmp    80107514 <alltraps>

801083d7 <vector203>:
.globl vector203
vector203:
  pushl $0
801083d7:	6a 00                	push   $0x0
  pushl $203
801083d9:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801083de:	e9 31 f1 ff ff       	jmp    80107514 <alltraps>

801083e3 <vector204>:
.globl vector204
vector204:
  pushl $0
801083e3:	6a 00                	push   $0x0
  pushl $204
801083e5:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801083ea:	e9 25 f1 ff ff       	jmp    80107514 <alltraps>

801083ef <vector205>:
.globl vector205
vector205:
  pushl $0
801083ef:	6a 00                	push   $0x0
  pushl $205
801083f1:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801083f6:	e9 19 f1 ff ff       	jmp    80107514 <alltraps>

801083fb <vector206>:
.globl vector206
vector206:
  pushl $0
801083fb:	6a 00                	push   $0x0
  pushl $206
801083fd:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108402:	e9 0d f1 ff ff       	jmp    80107514 <alltraps>

80108407 <vector207>:
.globl vector207
vector207:
  pushl $0
80108407:	6a 00                	push   $0x0
  pushl $207
80108409:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
8010840e:	e9 01 f1 ff ff       	jmp    80107514 <alltraps>

80108413 <vector208>:
.globl vector208
vector208:
  pushl $0
80108413:	6a 00                	push   $0x0
  pushl $208
80108415:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
8010841a:	e9 f5 f0 ff ff       	jmp    80107514 <alltraps>

8010841f <vector209>:
.globl vector209
vector209:
  pushl $0
8010841f:	6a 00                	push   $0x0
  pushl $209
80108421:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108426:	e9 e9 f0 ff ff       	jmp    80107514 <alltraps>

8010842b <vector210>:
.globl vector210
vector210:
  pushl $0
8010842b:	6a 00                	push   $0x0
  pushl $210
8010842d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108432:	e9 dd f0 ff ff       	jmp    80107514 <alltraps>

80108437 <vector211>:
.globl vector211
vector211:
  pushl $0
80108437:	6a 00                	push   $0x0
  pushl $211
80108439:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010843e:	e9 d1 f0 ff ff       	jmp    80107514 <alltraps>

80108443 <vector212>:
.globl vector212
vector212:
  pushl $0
80108443:	6a 00                	push   $0x0
  pushl $212
80108445:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010844a:	e9 c5 f0 ff ff       	jmp    80107514 <alltraps>

8010844f <vector213>:
.globl vector213
vector213:
  pushl $0
8010844f:	6a 00                	push   $0x0
  pushl $213
80108451:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80108456:	e9 b9 f0 ff ff       	jmp    80107514 <alltraps>

8010845b <vector214>:
.globl vector214
vector214:
  pushl $0
8010845b:	6a 00                	push   $0x0
  pushl $214
8010845d:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80108462:	e9 ad f0 ff ff       	jmp    80107514 <alltraps>

80108467 <vector215>:
.globl vector215
vector215:
  pushl $0
80108467:	6a 00                	push   $0x0
  pushl $215
80108469:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010846e:	e9 a1 f0 ff ff       	jmp    80107514 <alltraps>

80108473 <vector216>:
.globl vector216
vector216:
  pushl $0
80108473:	6a 00                	push   $0x0
  pushl $216
80108475:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010847a:	e9 95 f0 ff ff       	jmp    80107514 <alltraps>

8010847f <vector217>:
.globl vector217
vector217:
  pushl $0
8010847f:	6a 00                	push   $0x0
  pushl $217
80108481:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108486:	e9 89 f0 ff ff       	jmp    80107514 <alltraps>

8010848b <vector218>:
.globl vector218
vector218:
  pushl $0
8010848b:	6a 00                	push   $0x0
  pushl $218
8010848d:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108492:	e9 7d f0 ff ff       	jmp    80107514 <alltraps>

80108497 <vector219>:
.globl vector219
vector219:
  pushl $0
80108497:	6a 00                	push   $0x0
  pushl $219
80108499:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010849e:	e9 71 f0 ff ff       	jmp    80107514 <alltraps>

801084a3 <vector220>:
.globl vector220
vector220:
  pushl $0
801084a3:	6a 00                	push   $0x0
  pushl $220
801084a5:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801084aa:	e9 65 f0 ff ff       	jmp    80107514 <alltraps>

801084af <vector221>:
.globl vector221
vector221:
  pushl $0
801084af:	6a 00                	push   $0x0
  pushl $221
801084b1:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801084b6:	e9 59 f0 ff ff       	jmp    80107514 <alltraps>

801084bb <vector222>:
.globl vector222
vector222:
  pushl $0
801084bb:	6a 00                	push   $0x0
  pushl $222
801084bd:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801084c2:	e9 4d f0 ff ff       	jmp    80107514 <alltraps>

801084c7 <vector223>:
.globl vector223
vector223:
  pushl $0
801084c7:	6a 00                	push   $0x0
  pushl $223
801084c9:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801084ce:	e9 41 f0 ff ff       	jmp    80107514 <alltraps>

801084d3 <vector224>:
.globl vector224
vector224:
  pushl $0
801084d3:	6a 00                	push   $0x0
  pushl $224
801084d5:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801084da:	e9 35 f0 ff ff       	jmp    80107514 <alltraps>

801084df <vector225>:
.globl vector225
vector225:
  pushl $0
801084df:	6a 00                	push   $0x0
  pushl $225
801084e1:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801084e6:	e9 29 f0 ff ff       	jmp    80107514 <alltraps>

801084eb <vector226>:
.globl vector226
vector226:
  pushl $0
801084eb:	6a 00                	push   $0x0
  pushl $226
801084ed:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801084f2:	e9 1d f0 ff ff       	jmp    80107514 <alltraps>

801084f7 <vector227>:
.globl vector227
vector227:
  pushl $0
801084f7:	6a 00                	push   $0x0
  pushl $227
801084f9:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801084fe:	e9 11 f0 ff ff       	jmp    80107514 <alltraps>

80108503 <vector228>:
.globl vector228
vector228:
  pushl $0
80108503:	6a 00                	push   $0x0
  pushl $228
80108505:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010850a:	e9 05 f0 ff ff       	jmp    80107514 <alltraps>

8010850f <vector229>:
.globl vector229
vector229:
  pushl $0
8010850f:	6a 00                	push   $0x0
  pushl $229
80108511:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108516:	e9 f9 ef ff ff       	jmp    80107514 <alltraps>

8010851b <vector230>:
.globl vector230
vector230:
  pushl $0
8010851b:	6a 00                	push   $0x0
  pushl $230
8010851d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108522:	e9 ed ef ff ff       	jmp    80107514 <alltraps>

80108527 <vector231>:
.globl vector231
vector231:
  pushl $0
80108527:	6a 00                	push   $0x0
  pushl $231
80108529:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010852e:	e9 e1 ef ff ff       	jmp    80107514 <alltraps>

80108533 <vector232>:
.globl vector232
vector232:
  pushl $0
80108533:	6a 00                	push   $0x0
  pushl $232
80108535:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010853a:	e9 d5 ef ff ff       	jmp    80107514 <alltraps>

8010853f <vector233>:
.globl vector233
vector233:
  pushl $0
8010853f:	6a 00                	push   $0x0
  pushl $233
80108541:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80108546:	e9 c9 ef ff ff       	jmp    80107514 <alltraps>

8010854b <vector234>:
.globl vector234
vector234:
  pushl $0
8010854b:	6a 00                	push   $0x0
  pushl $234
8010854d:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80108552:	e9 bd ef ff ff       	jmp    80107514 <alltraps>

80108557 <vector235>:
.globl vector235
vector235:
  pushl $0
80108557:	6a 00                	push   $0x0
  pushl $235
80108559:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010855e:	e9 b1 ef ff ff       	jmp    80107514 <alltraps>

80108563 <vector236>:
.globl vector236
vector236:
  pushl $0
80108563:	6a 00                	push   $0x0
  pushl $236
80108565:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010856a:	e9 a5 ef ff ff       	jmp    80107514 <alltraps>

8010856f <vector237>:
.globl vector237
vector237:
  pushl $0
8010856f:	6a 00                	push   $0x0
  pushl $237
80108571:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108576:	e9 99 ef ff ff       	jmp    80107514 <alltraps>

8010857b <vector238>:
.globl vector238
vector238:
  pushl $0
8010857b:	6a 00                	push   $0x0
  pushl $238
8010857d:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108582:	e9 8d ef ff ff       	jmp    80107514 <alltraps>

80108587 <vector239>:
.globl vector239
vector239:
  pushl $0
80108587:	6a 00                	push   $0x0
  pushl $239
80108589:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010858e:	e9 81 ef ff ff       	jmp    80107514 <alltraps>

80108593 <vector240>:
.globl vector240
vector240:
  pushl $0
80108593:	6a 00                	push   $0x0
  pushl $240
80108595:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010859a:	e9 75 ef ff ff       	jmp    80107514 <alltraps>

8010859f <vector241>:
.globl vector241
vector241:
  pushl $0
8010859f:	6a 00                	push   $0x0
  pushl $241
801085a1:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801085a6:	e9 69 ef ff ff       	jmp    80107514 <alltraps>

801085ab <vector242>:
.globl vector242
vector242:
  pushl $0
801085ab:	6a 00                	push   $0x0
  pushl $242
801085ad:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801085b2:	e9 5d ef ff ff       	jmp    80107514 <alltraps>

801085b7 <vector243>:
.globl vector243
vector243:
  pushl $0
801085b7:	6a 00                	push   $0x0
  pushl $243
801085b9:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801085be:	e9 51 ef ff ff       	jmp    80107514 <alltraps>

801085c3 <vector244>:
.globl vector244
vector244:
  pushl $0
801085c3:	6a 00                	push   $0x0
  pushl $244
801085c5:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801085ca:	e9 45 ef ff ff       	jmp    80107514 <alltraps>

801085cf <vector245>:
.globl vector245
vector245:
  pushl $0
801085cf:	6a 00                	push   $0x0
  pushl $245
801085d1:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801085d6:	e9 39 ef ff ff       	jmp    80107514 <alltraps>

801085db <vector246>:
.globl vector246
vector246:
  pushl $0
801085db:	6a 00                	push   $0x0
  pushl $246
801085dd:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801085e2:	e9 2d ef ff ff       	jmp    80107514 <alltraps>

801085e7 <vector247>:
.globl vector247
vector247:
  pushl $0
801085e7:	6a 00                	push   $0x0
  pushl $247
801085e9:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801085ee:	e9 21 ef ff ff       	jmp    80107514 <alltraps>

801085f3 <vector248>:
.globl vector248
vector248:
  pushl $0
801085f3:	6a 00                	push   $0x0
  pushl $248
801085f5:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801085fa:	e9 15 ef ff ff       	jmp    80107514 <alltraps>

801085ff <vector249>:
.globl vector249
vector249:
  pushl $0
801085ff:	6a 00                	push   $0x0
  pushl $249
80108601:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108606:	e9 09 ef ff ff       	jmp    80107514 <alltraps>

8010860b <vector250>:
.globl vector250
vector250:
  pushl $0
8010860b:	6a 00                	push   $0x0
  pushl $250
8010860d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108612:	e9 fd ee ff ff       	jmp    80107514 <alltraps>

80108617 <vector251>:
.globl vector251
vector251:
  pushl $0
80108617:	6a 00                	push   $0x0
  pushl $251
80108619:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010861e:	e9 f1 ee ff ff       	jmp    80107514 <alltraps>

80108623 <vector252>:
.globl vector252
vector252:
  pushl $0
80108623:	6a 00                	push   $0x0
  pushl $252
80108625:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010862a:	e9 e5 ee ff ff       	jmp    80107514 <alltraps>

8010862f <vector253>:
.globl vector253
vector253:
  pushl $0
8010862f:	6a 00                	push   $0x0
  pushl $253
80108631:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80108636:	e9 d9 ee ff ff       	jmp    80107514 <alltraps>

8010863b <vector254>:
.globl vector254
vector254:
  pushl $0
8010863b:	6a 00                	push   $0x0
  pushl $254
8010863d:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108642:	e9 cd ee ff ff       	jmp    80107514 <alltraps>

80108647 <vector255>:
.globl vector255
vector255:
  pushl $0
80108647:	6a 00                	push   $0x0
  pushl $255
80108649:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010864e:	e9 c1 ee ff ff       	jmp    80107514 <alltraps>

80108653 <lgdt>:
{
80108653:	55                   	push   %ebp
80108654:	89 e5                	mov    %esp,%ebp
80108656:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80108659:	8b 45 0c             	mov    0xc(%ebp),%eax
8010865c:	83 e8 01             	sub    $0x1,%eax
8010865f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108663:	8b 45 08             	mov    0x8(%ebp),%eax
80108666:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010866a:	8b 45 08             	mov    0x8(%ebp),%eax
8010866d:	c1 e8 10             	shr    $0x10,%eax
80108670:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80108674:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108677:	0f 01 10             	lgdtl  (%eax)
}
8010867a:	90                   	nop
8010867b:	c9                   	leave  
8010867c:	c3                   	ret    

8010867d <ltr>:
{
8010867d:	55                   	push   %ebp
8010867e:	89 e5                	mov    %esp,%ebp
80108680:	83 ec 04             	sub    $0x4,%esp
80108683:	8b 45 08             	mov    0x8(%ebp),%eax
80108686:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010868a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010868e:	0f 00 d8             	ltr    %ax
}
80108691:	90                   	nop
80108692:	c9                   	leave  
80108693:	c3                   	ret    

80108694 <loadgs>:
{
80108694:	55                   	push   %ebp
80108695:	89 e5                	mov    %esp,%ebp
80108697:	83 ec 04             	sub    $0x4,%esp
8010869a:	8b 45 08             	mov    0x8(%ebp),%eax
8010869d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
801086a1:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
801086a5:	8e e8                	mov    %eax,%gs
}
801086a7:	90                   	nop
801086a8:	c9                   	leave  
801086a9:	c3                   	ret    

801086aa <lcr3>:

static inline void
lcr3(uint val) 
{
801086aa:	55                   	push   %ebp
801086ab:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801086ad:	8b 45 08             	mov    0x8(%ebp),%eax
801086b0:	0f 22 d8             	mov    %eax,%cr3
}
801086b3:	90                   	nop
801086b4:	5d                   	pop    %ebp
801086b5:	c3                   	ret    

801086b6 <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
801086b6:	55                   	push   %ebp
801086b7:	89 e5                	mov    %esp,%ebp
801086b9:	8b 45 08             	mov    0x8(%ebp),%eax
801086bc:	05 00 00 00 80       	add    $0x80000000,%eax
801086c1:	5d                   	pop    %ebp
801086c2:	c3                   	ret    

801086c3 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801086c3:	55                   	push   %ebp
801086c4:	89 e5                	mov    %esp,%ebp
801086c6:	8b 45 08             	mov    0x8(%ebp),%eax
801086c9:	05 00 00 00 80       	add    $0x80000000,%eax
801086ce:	5d                   	pop    %ebp
801086cf:	c3                   	ret    

801086d0 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801086d0:	f3 0f 1e fb          	endbr32 
801086d4:	55                   	push   %ebp
801086d5:	89 e5                	mov    %esp,%ebp
801086d7:	53                   	push   %ebx
801086d8:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801086db:	e8 ad b1 ff ff       	call   8010388d <cpunum>
801086e0:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801086e6:	05 60 53 11 80       	add    $0x80115360,%eax
801086eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801086ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f1:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801086f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fa:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108703:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010870e:	83 e2 f0             	and    $0xfffffff0,%edx
80108711:	83 ca 0a             	or     $0xa,%edx
80108714:	88 50 7d             	mov    %dl,0x7d(%eax)
80108717:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871a:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010871e:	83 ca 10             	or     $0x10,%edx
80108721:	88 50 7d             	mov    %dl,0x7d(%eax)
80108724:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108727:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
8010872b:	83 e2 9f             	and    $0xffffff9f,%edx
8010872e:	88 50 7d             	mov    %dl,0x7d(%eax)
80108731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108734:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80108738:	83 ca 80             	or     $0xffffff80,%edx
8010873b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010873e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108741:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108745:	83 ca 0f             	or     $0xf,%edx
80108748:	88 50 7e             	mov    %dl,0x7e(%eax)
8010874b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108752:	83 e2 ef             	and    $0xffffffef,%edx
80108755:	88 50 7e             	mov    %dl,0x7e(%eax)
80108758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010875f:	83 e2 df             	and    $0xffffffdf,%edx
80108762:	88 50 7e             	mov    %dl,0x7e(%eax)
80108765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108768:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010876c:	83 ca 40             	or     $0x40,%edx
8010876f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108772:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108775:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108779:	83 ca 80             	or     $0xffffff80,%edx
8010877c:	88 50 7e             	mov    %dl,0x7e(%eax)
8010877f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108782:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108789:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80108790:	ff ff 
80108792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108795:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010879c:	00 00 
8010879e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a1:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801087a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ab:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087b2:	83 e2 f0             	and    $0xfffffff0,%edx
801087b5:	83 ca 02             	or     $0x2,%edx
801087b8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087c8:	83 ca 10             	or     $0x10,%edx
801087cb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087db:	83 e2 9f             	and    $0xffffff9f,%edx
801087de:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e7:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801087ee:	83 ca 80             	or     $0xffffff80,%edx
801087f1:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801087f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087fa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108801:	83 ca 0f             	or     $0xf,%edx
80108804:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010880a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010880d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108814:	83 e2 ef             	and    $0xffffffef,%edx
80108817:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010881d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108820:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80108827:	83 e2 df             	and    $0xffffffdf,%edx
8010882a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108833:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010883a:	83 ca 40             	or     $0x40,%edx
8010883d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108846:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010884d:	83 ca 80             	or     $0xffffff80,%edx
80108850:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108859:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108860:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108863:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010886a:	ff ff 
8010886c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010886f:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108876:	00 00 
80108878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887b:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108882:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108885:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010888c:	83 e2 f0             	and    $0xfffffff0,%edx
8010888f:	83 ca 0a             	or     $0xa,%edx
80108892:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108898:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010889b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088a2:	83 ca 10             	or     $0x10,%edx
801088a5:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ae:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088b5:	83 ca 60             	or     $0x60,%edx
801088b8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c1:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
801088c8:	83 ca 80             	or     $0xffffff80,%edx
801088cb:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801088d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088db:	83 ca 0f             	or     $0xf,%edx
801088de:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801088ee:	83 e2 ef             	and    $0xffffffef,%edx
801088f1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801088f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fa:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108901:	83 e2 df             	and    $0xffffffdf,%edx
80108904:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010890a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108914:	83 ca 40             	or     $0x40,%edx
80108917:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010891d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108920:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108927:	83 ca 80             	or     $0xffffff80,%edx
8010892a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108933:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010893a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010893d:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80108944:	ff ff 
80108946:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108949:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80108950:	00 00 
80108952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108955:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010895c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108966:	83 e2 f0             	and    $0xfffffff0,%edx
80108969:	83 ca 02             	or     $0x2,%edx
8010896c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108975:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010897c:	83 ca 10             	or     $0x10,%edx
8010897f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108985:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108988:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010898f:	83 ca 60             	or     $0x60,%edx
80108992:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108998:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899b:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801089a2:	83 ca 80             	or     $0xffffff80,%edx
801089a5:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
801089ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ae:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089b5:	83 ca 0f             	or     $0xf,%edx
801089b8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089c8:	83 e2 ef             	and    $0xffffffef,%edx
801089cb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089db:	83 e2 df             	and    $0xffffffdf,%edx
801089de:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801089ee:	83 ca 40             	or     $0x40,%edx
801089f1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801089f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089fa:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108a01:	83 ca 80             	or     $0xffffff80,%edx
80108a04:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0d:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80108a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a17:	05 b4 00 00 00       	add    $0xb4,%eax
80108a1c:	89 c3                	mov    %eax,%ebx
80108a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a21:	05 b4 00 00 00       	add    $0xb4,%eax
80108a26:	c1 e8 10             	shr    $0x10,%eax
80108a29:	89 c2                	mov    %eax,%edx
80108a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a2e:	05 b4 00 00 00       	add    $0xb4,%eax
80108a33:	c1 e8 18             	shr    $0x18,%eax
80108a36:	89 c1                	mov    %eax,%ecx
80108a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3b:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80108a42:	00 00 
80108a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a47:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80108a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a51:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5a:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a61:	83 e2 f0             	and    $0xfffffff0,%edx
80108a64:	83 ca 02             	or     $0x2,%edx
80108a67:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a70:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a77:	83 ca 10             	or     $0x10,%edx
80108a7a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a83:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a8a:	83 e2 9f             	and    $0xffffff9f,%edx
80108a8d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108a93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a96:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108a9d:	83 ca 80             	or     $0xffffff80,%edx
80108aa0:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa9:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ab0:	83 e2 f0             	and    $0xfffffff0,%edx
80108ab3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108abc:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ac3:	83 e2 ef             	and    $0xffffffef,%edx
80108ac6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108acf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ad6:	83 e2 df             	and    $0xffffffdf,%edx
80108ad9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ae2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108ae9:	83 ca 40             	or     $0x40,%edx
80108aec:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af5:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108afc:	83 ca 80             	or     $0xffffff80,%edx
80108aff:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b08:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80108b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b11:	83 c0 70             	add    $0x70,%eax
80108b14:	83 ec 08             	sub    $0x8,%esp
80108b17:	6a 38                	push   $0x38
80108b19:	50                   	push   %eax
80108b1a:	e8 34 fb ff ff       	call   80108653 <lgdt>
80108b1f:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80108b22:	83 ec 0c             	sub    $0xc,%esp
80108b25:	6a 18                	push   $0x18
80108b27:	e8 68 fb ff ff       	call   80108694 <loadgs>
80108b2c:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80108b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b32:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80108b38:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80108b3f:	00 00 00 00 
}
80108b43:	90                   	nop
80108b44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108b47:	c9                   	leave  
80108b48:	c3                   	ret    

80108b49 <walkpgdir>:

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address (in u.m) va.  If alloc!=0,
// create any required page table pages.
static pte_t * walkpgdir(pde_t *pgdir, const void *va, int alloc){
80108b49:	f3 0f 1e fb          	endbr32 
80108b4d:	55                   	push   %ebp
80108b4e:	89 e5                	mov    %esp,%ebp
80108b50:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)]; //PDE index in page directory (0 to 1023 + FLAGS)
80108b53:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b56:	c1 e8 16             	shr    $0x16,%eax
80108b59:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b60:	8b 45 08             	mov    0x8(%ebp),%eax
80108b63:	01 d0                	add    %edx,%eax
80108b65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){      //Present bit is on in PDE
80108b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b6b:	8b 00                	mov    (%eax),%eax
80108b6d:	83 e0 01             	and    $0x1,%eax
80108b70:	85 c0                	test   %eax,%eax
80108b72:	74 18                	je     80108b8c <walkpgdir+0x43>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde)); //pgtab = virtual address to beginning of page table
80108b74:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b77:	8b 00                	mov    (%eax),%eax
80108b79:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b7e:	50                   	push   %eax
80108b7f:	e8 3f fb ff ff       	call   801086c3 <p2v>
80108b84:	83 c4 04             	add    $0x4,%esp
80108b87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b8a:	eb 48                	jmp    80108bd4 <walkpgdir+0x8b>

  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0) //if alloc != 0, try to create new page table
80108b8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108b90:	74 0e                	je     80108ba0 <walkpgdir+0x57>
80108b92:	e8 6c a9 ff ff       	call   80103503 <kalloc>
80108b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108b9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108b9e:	75 07                	jne    80108ba7 <walkpgdir+0x5e>
      return 0; //page table (PDE) doesn't exist or kalloc failed
80108ba0:	b8 00 00 00 00       	mov    $0x0,%eax
80108ba5:	eb 44                	jmp    80108beb <walkpgdir+0xa2>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, pageSize);
80108ba7:	83 ec 04             	sub    $0x4,%esp
80108baa:	68 00 10 00 00       	push   $0x1000
80108baf:	6a 00                	push   $0x0
80108bb1:	ff 75 f4             	pushl  -0xc(%ebp)
80108bb4:	e8 e7 d4 ff ff       	call   801060a0 <memset>
80108bb9:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U; //link PDE to the new page table
80108bbc:	83 ec 0c             	sub    $0xc,%esp
80108bbf:	ff 75 f4             	pushl  -0xc(%ebp)
80108bc2:	e8 ef fa ff ff       	call   801086b6 <v2p>
80108bc7:	83 c4 10             	add    $0x10,%esp
80108bca:	83 c8 07             	or     $0x7,%eax
80108bcd:	89 c2                	mov    %eax,%edx
80108bcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bd2:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)]; //return PTE in page table which corresponse to va address
80108bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bd7:	c1 e8 0c             	shr    $0xc,%eax
80108bda:	25 ff 03 00 00       	and    $0x3ff,%eax
80108bdf:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be9:	01 d0                	add    %edx,%eax
}
80108beb:	c9                   	leave  
80108bec:	c3                   	ret    

80108bed <mappages>:


// Create PTEs for virtual addresses starting at va (va in U.M) that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm){
80108bed:	f3 0f 1e fb          	endbr32 
80108bf1:	55                   	push   %ebp
80108bf2:	89 e5                	mov    %esp,%ebp
80108bf4:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80108bf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bfa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108c02:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c05:	8b 45 10             	mov    0x10(%ebp),%eax
80108c08:	01 d0                	add    %edx,%eax
80108c0a:	83 e8 01             	sub    $0x1,%eax
80108c0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108c15:	83 ec 04             	sub    $0x4,%esp
80108c18:	6a 01                	push   $0x1
80108c1a:	ff 75 f4             	pushl  -0xc(%ebp)
80108c1d:	ff 75 08             	pushl  0x8(%ebp)
80108c20:	e8 24 ff ff ff       	call   80108b49 <walkpgdir>
80108c25:	83 c4 10             	add    $0x10,%esp
80108c28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c2f:	75 07                	jne    80108c38 <mappages+0x4b>
      return -1;
80108c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c36:	eb 47                	jmp    80108c7f <mappages+0x92>
    if(*pte & PTE_P)
80108c38:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c3b:	8b 00                	mov    (%eax),%eax
80108c3d:	83 e0 01             	and    $0x1,%eax
80108c40:	85 c0                	test   %eax,%eax
80108c42:	74 0d                	je     80108c51 <mappages+0x64>
      panic("remap");         //PTE was already initialized for some reason
80108c44:	83 ec 0c             	sub    $0xc,%esp
80108c47:	68 ac a6 10 80       	push   $0x8010a6ac
80108c4c:	e8 46 79 ff ff       	call   80100597 <panic>
    *pte = pa | perm | PTE_P; //adds page physical address, flags, present bit
80108c51:	8b 45 18             	mov    0x18(%ebp),%eax
80108c54:	0b 45 14             	or     0x14(%ebp),%eax
80108c57:	83 c8 01             	or     $0x1,%eax
80108c5a:	89 c2                	mov    %eax,%edx
80108c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c5f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c64:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c67:	74 10                	je     80108c79 <mappages+0x8c>
      break;
    a += pageSize;
80108c69:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += pageSize;
80108c70:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108c77:	eb 9c                	jmp    80108c15 <mappages+0x28>
      break;
80108c79:	90                   	nop
  }
  return 0;
80108c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c7f:	c9                   	leave  
80108c80:	c3                   	ret    

80108c81 <setupkvm>:
 { (void*)data,     V2P(data),     PHYSTOP,   PTE_W}, // kern data+memory
 { (void*)DEVSPACE, DEVSPACE,      0,         PTE_W}, // more devices
};

// Set up kernel part of a page table.
pde_t* setupkvm(void){
80108c81:	f3 0f 1e fb          	endbr32 
80108c85:	55                   	push   %ebp
80108c86:	89 e5                	mov    %esp,%ebp
80108c88:	53                   	push   %ebx
80108c89:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108c8c:	e8 72 a8 ff ff       	call   80103503 <kalloc>
80108c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c98:	75 0a                	jne    80108ca4 <setupkvm+0x23>
    return 0;
80108c9a:	b8 00 00 00 00       	mov    $0x0,%eax
80108c9f:	e9 8e 00 00 00       	jmp    80108d32 <setupkvm+0xb1>
  memset(pgdir, 0, pageSize);
80108ca4:	83 ec 04             	sub    $0x4,%esp
80108ca7:	68 00 10 00 00       	push   $0x1000
80108cac:	6a 00                	push   $0x0
80108cae:	ff 75 f0             	pushl  -0x10(%ebp)
80108cb1:	e8 ea d3 ff ff       	call   801060a0 <memset>
80108cb6:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80108cb9:	83 ec 0c             	sub    $0xc,%esp
80108cbc:	68 00 00 00 0e       	push   $0xe000000
80108cc1:	e8 fd f9 ff ff       	call   801086c3 <p2v>
80108cc6:	83 c4 10             	add    $0x10,%esp
80108cc9:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108cce:	76 0d                	jbe    80108cdd <setupkvm+0x5c>
    panic("PHYSTOP too high");
80108cd0:	83 ec 0c             	sub    $0xc,%esp
80108cd3:	68 b2 a6 10 80       	push   $0x8010a6b2
80108cd8:	e8 ba 78 ff ff       	call   80100597 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++){
80108cdd:	c7 45 f4 a0 d4 10 80 	movl   $0x8010d4a0,-0xc(%ebp)
80108ce4:	eb 40                	jmp    80108d26 <setupkvm+0xa5>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, (uint)k->phys_start, k->perm) < 0)
80108ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ce9:	8b 48 0c             	mov    0xc(%eax),%ecx
80108cec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cef:	8b 50 04             	mov    0x4(%eax),%edx
80108cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf5:	8b 58 08             	mov    0x8(%eax),%ebx
80108cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cfb:	8b 40 04             	mov    0x4(%eax),%eax
80108cfe:	29 c3                	sub    %eax,%ebx
80108d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d03:	8b 00                	mov    (%eax),%eax
80108d05:	83 ec 0c             	sub    $0xc,%esp
80108d08:	51                   	push   %ecx
80108d09:	52                   	push   %edx
80108d0a:	53                   	push   %ebx
80108d0b:	50                   	push   %eax
80108d0c:	ff 75 f0             	pushl  -0x10(%ebp)
80108d0f:	e8 d9 fe ff ff       	call   80108bed <mappages>
80108d14:	83 c4 20             	add    $0x20,%esp
80108d17:	85 c0                	test   %eax,%eax
80108d19:	79 07                	jns    80108d22 <setupkvm+0xa1>
      return 0;
80108d1b:	b8 00 00 00 00       	mov    $0x0,%eax
80108d20:	eb 10                	jmp    80108d32 <setupkvm+0xb1>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++){
80108d22:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108d26:	81 7d f4 e0 d4 10 80 	cmpl   $0x8010d4e0,-0xc(%ebp)
80108d2d:	72 b7                	jb     80108ce6 <setupkvm+0x65>
  }
  return pgdir;
80108d2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108d32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d35:	c9                   	leave  
80108d36:	c3                   	ret    

80108d37 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108d37:	f3 0f 1e fb          	endbr32 
80108d3b:	55                   	push   %ebp
80108d3c:	89 e5                	mov    %esp,%ebp
80108d3e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108d41:	e8 3b ff ff ff       	call   80108c81 <setupkvm>
80108d46:	a3 38 1c 12 80       	mov    %eax,0x80121c38
  switchkvm();
80108d4b:	e8 03 00 00 00       	call   80108d53 <switchkvm>
}
80108d50:	90                   	nop
80108d51:	c9                   	leave  
80108d52:	c3                   	ret    

80108d53 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108d53:	f3 0f 1e fb          	endbr32 
80108d57:	55                   	push   %ebp
80108d58:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108d5a:	a1 38 1c 12 80       	mov    0x80121c38,%eax
80108d5f:	50                   	push   %eax
80108d60:	e8 51 f9 ff ff       	call   801086b6 <v2p>
80108d65:	83 c4 04             	add    $0x4,%esp
80108d68:	50                   	push   %eax
80108d69:	e8 3c f9 ff ff       	call   801086aa <lcr3>
80108d6e:	83 c4 04             	add    $0x4,%esp
}
80108d71:	90                   	nop
80108d72:	c9                   	leave  
80108d73:	c3                   	ret    

80108d74 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108d74:	f3 0f 1e fb          	endbr32 
80108d78:	55                   	push   %ebp
80108d79:	89 e5                	mov    %esp,%ebp
80108d7b:	56                   	push   %esi
80108d7c:	53                   	push   %ebx
  pushcli();
80108d7d:	e8 10 d2 ff ff       	call   80105f92 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108d82:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108d88:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d8f:	83 c2 08             	add    $0x8,%edx
80108d92:	89 d6                	mov    %edx,%esi
80108d94:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108d9b:	83 c2 08             	add    $0x8,%edx
80108d9e:	c1 ea 10             	shr    $0x10,%edx
80108da1:	89 d3                	mov    %edx,%ebx
80108da3:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108daa:	83 c2 08             	add    $0x8,%edx
80108dad:	c1 ea 18             	shr    $0x18,%edx
80108db0:	89 d1                	mov    %edx,%ecx
80108db2:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80108db9:	67 00 
80108dbb:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108dc2:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108dc8:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108dcf:	83 e2 f0             	and    $0xfffffff0,%edx
80108dd2:	83 ca 09             	or     $0x9,%edx
80108dd5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108ddb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108de2:	83 ca 10             	or     $0x10,%edx
80108de5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108deb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108df2:	83 e2 9f             	and    $0xffffff9f,%edx
80108df5:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108dfb:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e02:	83 ca 80             	or     $0xffffff80,%edx
80108e05:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108e0b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e12:	83 e2 f0             	and    $0xfffffff0,%edx
80108e15:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e1b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e22:	83 e2 ef             	and    $0xffffffef,%edx
80108e25:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e2b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e32:	83 e2 df             	and    $0xffffffdf,%edx
80108e35:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e3b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e42:	83 ca 40             	or     $0x40,%edx
80108e45:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e4b:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108e52:	83 e2 7f             	and    $0x7f,%edx
80108e55:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108e5b:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108e61:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e67:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108e6e:	83 e2 ef             	and    $0xffffffef,%edx
80108e71:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108e77:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e7d:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108e83:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80108e89:	8b 40 08             	mov    0x8(%eax),%eax
80108e8c:	89 c2                	mov    %eax,%edx
80108e8e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108e94:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108e9a:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108e9d:	83 ec 0c             	sub    $0xc,%esp
80108ea0:	6a 30                	push   $0x30
80108ea2:	e8 d6 f7 ff ff       	call   8010867d <ltr>
80108ea7:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80108eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80108ead:	8b 40 04             	mov    0x4(%eax),%eax
80108eb0:	85 c0                	test   %eax,%eax
80108eb2:	75 0d                	jne    80108ec1 <switchuvm+0x14d>
    panic("switchuvm: no pgdir");
80108eb4:	83 ec 0c             	sub    $0xc,%esp
80108eb7:	68 c3 a6 10 80       	push   $0x8010a6c3
80108ebc:	e8 d6 76 ff ff       	call   80100597 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ec4:	8b 40 04             	mov    0x4(%eax),%eax
80108ec7:	83 ec 0c             	sub    $0xc,%esp
80108eca:	50                   	push   %eax
80108ecb:	e8 e6 f7 ff ff       	call   801086b6 <v2p>
80108ed0:	83 c4 10             	add    $0x10,%esp
80108ed3:	83 ec 0c             	sub    $0xc,%esp
80108ed6:	50                   	push   %eax
80108ed7:	e8 ce f7 ff ff       	call   801086aa <lcr3>
80108edc:	83 c4 10             	add    $0x10,%esp
  popcli();
80108edf:	e8 f7 d0 ff ff       	call   80105fdb <popcli>
}
80108ee4:	90                   	nop
80108ee5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80108ee8:	5b                   	pop    %ebx
80108ee9:	5e                   	pop    %esi
80108eea:	5d                   	pop    %ebp
80108eeb:	c3                   	ret    

80108eec <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108eec:	f3 0f 1e fb          	endbr32 
80108ef0:	55                   	push   %ebp
80108ef1:	89 e5                	mov    %esp,%ebp
80108ef3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= pageSize)
80108ef6:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108efd:	76 0d                	jbe    80108f0c <inituvm+0x20>
    panic("inituvm: more than a page");
80108eff:	83 ec 0c             	sub    $0xc,%esp
80108f02:	68 d7 a6 10 80       	push   $0x8010a6d7
80108f07:	e8 8b 76 ff ff       	call   80100597 <panic>
  mem = kalloc();
80108f0c:	e8 f2 a5 ff ff       	call   80103503 <kalloc>
80108f11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, pageSize);
80108f14:	83 ec 04             	sub    $0x4,%esp
80108f17:	68 00 10 00 00       	push   $0x1000
80108f1c:	6a 00                	push   $0x0
80108f1e:	ff 75 f4             	pushl  -0xc(%ebp)
80108f21:	e8 7a d1 ff ff       	call   801060a0 <memset>
80108f26:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, pageSize, v2p(mem), PTE_W|PTE_U);
80108f29:	83 ec 0c             	sub    $0xc,%esp
80108f2c:	ff 75 f4             	pushl  -0xc(%ebp)
80108f2f:	e8 82 f7 ff ff       	call   801086b6 <v2p>
80108f34:	83 c4 10             	add    $0x10,%esp
80108f37:	83 ec 0c             	sub    $0xc,%esp
80108f3a:	6a 06                	push   $0x6
80108f3c:	50                   	push   %eax
80108f3d:	68 00 10 00 00       	push   $0x1000
80108f42:	6a 00                	push   $0x0
80108f44:	ff 75 08             	pushl  0x8(%ebp)
80108f47:	e8 a1 fc ff ff       	call   80108bed <mappages>
80108f4c:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108f4f:	83 ec 04             	sub    $0x4,%esp
80108f52:	ff 75 10             	pushl  0x10(%ebp)
80108f55:	ff 75 0c             	pushl  0xc(%ebp)
80108f58:	ff 75 f4             	pushl  -0xc(%ebp)
80108f5b:	e8 07 d2 ff ff       	call   80106167 <memmove>
80108f60:	83 c4 10             	add    $0x10,%esp
}
80108f63:	90                   	nop
80108f64:	c9                   	leave  
80108f65:	c3                   	ret    

80108f66 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108f66:	f3 0f 1e fb          	endbr32 
80108f6a:	55                   	push   %ebp
80108f6b:	89 e5                	mov    %esp,%ebp
80108f6d:	53                   	push   %ebx
80108f6e:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % pageSize != 0)
80108f71:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f74:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f79:	85 c0                	test   %eax,%eax
80108f7b:	74 0d                	je     80108f8a <loaduvm+0x24>
    panic("loaduvm: addr must be page aligned");
80108f7d:	83 ec 0c             	sub    $0xc,%esp
80108f80:	68 f4 a6 10 80       	push   $0x8010a6f4
80108f85:	e8 0d 76 ff ff       	call   80100597 <panic>
  for(i = 0; i < sz; i += pageSize){
80108f8a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f91:	e9 95 00 00 00       	jmp    8010902b <loaduvm+0xc5>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108f96:	8b 55 0c             	mov    0xc(%ebp),%edx
80108f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f9c:	01 d0                	add    %edx,%eax
80108f9e:	83 ec 04             	sub    $0x4,%esp
80108fa1:	6a 00                	push   $0x0
80108fa3:	50                   	push   %eax
80108fa4:	ff 75 08             	pushl  0x8(%ebp)
80108fa7:	e8 9d fb ff ff       	call   80108b49 <walkpgdir>
80108fac:	83 c4 10             	add    $0x10,%esp
80108faf:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108fb2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108fb6:	75 0d                	jne    80108fc5 <loaduvm+0x5f>
      panic("loaduvm: address should exist");
80108fb8:	83 ec 0c             	sub    $0xc,%esp
80108fbb:	68 17 a7 10 80       	push   $0x8010a717
80108fc0:	e8 d2 75 ff ff       	call   80100597 <panic>
    pa = PTE_ADDR(*pte);
80108fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fc8:	8b 00                	mov    (%eax),%eax
80108fca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108fcf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < pageSize)
80108fd2:	8b 45 18             	mov    0x18(%ebp),%eax
80108fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108fd8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108fdd:	77 0b                	ja     80108fea <loaduvm+0x84>
      n = sz - i;
80108fdf:	8b 45 18             	mov    0x18(%ebp),%eax
80108fe2:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108fe8:	eb 07                	jmp    80108ff1 <loaduvm+0x8b>
    else
      n = pageSize;
80108fea:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
80108ff1:	8b 55 14             	mov    0x14(%ebp),%edx
80108ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff7:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108ffa:	83 ec 0c             	sub    $0xc,%esp
80108ffd:	ff 75 e8             	pushl  -0x18(%ebp)
80109000:	e8 be f6 ff ff       	call   801086c3 <p2v>
80109005:	83 c4 10             	add    $0x10,%esp
80109008:	ff 75 f0             	pushl  -0x10(%ebp)
8010900b:	53                   	push   %ebx
8010900c:	50                   	push   %eax
8010900d:	ff 75 10             	pushl  0x10(%ebp)
80109010:	e8 81 8f ff ff       	call   80101f96 <readi>
80109015:	83 c4 10             	add    $0x10,%esp
80109018:	39 45 f0             	cmp    %eax,-0x10(%ebp)
8010901b:	74 07                	je     80109024 <loaduvm+0xbe>
      return -1;
8010901d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109022:	eb 18                	jmp    8010903c <loaduvm+0xd6>
  for(i = 0; i < sz; i += pageSize){
80109024:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010902b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010902e:	3b 45 18             	cmp    0x18(%ebp),%eax
80109031:	0f 82 5f ff ff ff    	jb     80108f96 <loaduvm+0x30>
  }
  return 0;
80109037:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010903c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010903f:	c9                   	leave  
80109040:	c3                   	ret    

80109041 <getPagePAddr>:

int getPagePAddr(int userPageVAddr, pde_t * pgdir){
80109041:	f3 0f 1e fb          	endbr32 
80109045:	55                   	push   %ebp
80109046:	89 e5                	mov    %esp,%ebp
80109048:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, (int*)userPageVAddr, 0);
8010904b:	8b 45 08             	mov    0x8(%ebp),%eax
8010904e:	83 ec 04             	sub    $0x4,%esp
80109051:	6a 00                	push   $0x0
80109053:	50                   	push   %eax
80109054:	ff 75 0c             	pushl  0xc(%ebp)
80109057:	e8 ed fa ff ff       	call   80108b49 <walkpgdir>
8010905c:	83 c4 10             	add    $0x10,%esp
8010905f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!pte) //uninitialized page table
80109062:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109066:	75 07                	jne    8010906f <getPagePAddr+0x2e>
    return -1;
80109068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010906d:	eb 0a                	jmp    80109079 <getPagePAddr+0x38>
  return PTE_ADDR(*pte);
8010906f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109072:	8b 00                	mov    (%eax),%eax
80109074:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
80109079:	c9                   	leave  
8010907a:	c3                   	ret    

8010907b <fixPagedOutPTE>:

void fixPagedOutPTE(int userPageVAddr, pde_t * pgdir){
8010907b:	f3 0f 1e fb          	endbr32 
8010907f:	55                   	push   %ebp
80109080:	89 e5                	mov    %esp,%ebp
80109082:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, (int*)userPageVAddr, 0);
80109085:	8b 45 08             	mov    0x8(%ebp),%eax
80109088:	83 ec 04             	sub    $0x4,%esp
8010908b:	6a 00                	push   $0x0
8010908d:	50                   	push   %eax
8010908e:	ff 75 0c             	pushl  0xc(%ebp)
80109091:	e8 b3 fa ff ff       	call   80108b49 <walkpgdir>
80109096:	83 c4 10             	add    $0x10,%esp
80109099:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!pte)
8010909c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801090a0:	75 0d                	jne    801090af <fixPagedOutPTE+0x34>
    panic("PTE of swapped page is missing");
801090a2:	83 ec 0c             	sub    $0xc,%esp
801090a5:	68 38 a7 10 80       	push   $0x8010a738
801090aa:	e8 e8 74 ff ff       	call   80100597 <panic>
  *pte |= PTE_PG;
801090af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090b2:	8b 00                	mov    (%eax),%eax
801090b4:	80 cc 02             	or     $0x2,%ah
801090b7:	89 c2                	mov    %eax,%edx
801090b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090bc:	89 10                	mov    %edx,(%eax)
  *pte &= ~PTE_P;
801090be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c1:	8b 00                	mov    (%eax),%eax
801090c3:	83 e0 fe             	and    $0xfffffffe,%eax
801090c6:	89 c2                	mov    %eax,%edx
801090c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090cb:	89 10                	mov    %edx,(%eax)
  *pte &= PTE_FLAGS(*pte); //clear junk physical address
801090cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090d0:	8b 00                	mov    (%eax),%eax
801090d2:	25 ff 0f 00 00       	and    $0xfff,%eax
801090d7:	89 c2                	mov    %eax,%edx
801090d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090dc:	89 10                	mov    %edx,(%eax)
  lcr3(v2p(proc->pgdir)); //refresh CR3 register
801090de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801090e4:	8b 40 04             	mov    0x4(%eax),%eax
801090e7:	83 ec 0c             	sub    $0xc,%esp
801090ea:	50                   	push   %eax
801090eb:	e8 c6 f5 ff ff       	call   801086b6 <v2p>
801090f0:	83 c4 10             	add    $0x10,%esp
801090f3:	83 ec 0c             	sub    $0xc,%esp
801090f6:	50                   	push   %eax
801090f7:	e8 ae f5 ff ff       	call   801086aa <lcr3>
801090fc:	83 c4 10             	add    $0x10,%esp
}
801090ff:	90                   	nop
80109100:	c9                   	leave  
80109101:	c3                   	ret    

80109102 <fixPagedInPTE>:

//This method cannot be replaced with mappages because mappages cannot turn off PTE_PG bit
void fixPagedInPTE(int userPageVAddr, int pagePAddr, pde_t * pgdir){
80109102:	f3 0f 1e fb          	endbr32 
80109106:	55                   	push   %ebp
80109107:	89 e5                	mov    %esp,%ebp
80109109:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, (int*)userPageVAddr, 0);
8010910c:	8b 45 08             	mov    0x8(%ebp),%eax
8010910f:	83 ec 04             	sub    $0x4,%esp
80109112:	6a 00                	push   $0x0
80109114:	50                   	push   %eax
80109115:	ff 75 10             	pushl  0x10(%ebp)
80109118:	e8 2c fa ff ff       	call   80108b49 <walkpgdir>
8010911d:	83 c4 10             	add    $0x10,%esp
80109120:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (!pte)
80109123:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109127:	75 0d                	jne    80109136 <fixPagedInPTE+0x34>
    panic("PTE of swapped page is missing");
80109129:	83 ec 0c             	sub    $0xc,%esp
8010912c:	68 38 a7 10 80       	push   $0x8010a738
80109131:	e8 61 74 ff ff       	call   80100597 <panic>
  if (*pte & PTE_P)
80109136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109139:	8b 00                	mov    (%eax),%eax
8010913b:	83 e0 01             	and    $0x1,%eax
8010913e:	85 c0                	test   %eax,%eax
80109140:	74 0d                	je     8010914f <fixPagedInPTE+0x4d>
  	panic("PAGE IN REMAP!");
80109142:	83 ec 0c             	sub    $0xc,%esp
80109145:	68 57 a7 10 80       	push   $0x8010a757
8010914a:	e8 48 74 ff ff       	call   80100597 <panic>
  *pte |= PTE_P | PTE_W | PTE_U;      //Turn on needed bits
8010914f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109152:	8b 00                	mov    (%eax),%eax
80109154:	83 c8 07             	or     $0x7,%eax
80109157:	89 c2                	mov    %eax,%edx
80109159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915c:	89 10                	mov    %edx,(%eax)
  *pte &= ~PTE_PG;    								//Turn off inFile bit
8010915e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109161:	8b 00                	mov    (%eax),%eax
80109163:	80 e4 fd             	and    $0xfd,%ah
80109166:	89 c2                	mov    %eax,%edx
80109168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010916b:	89 10                	mov    %edx,(%eax)
  *pte |= pagePAddr;  								//Map PTE to the new Page
8010916d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109170:	8b 10                	mov    (%eax),%edx
80109172:	8b 45 0c             	mov    0xc(%ebp),%eax
80109175:	09 c2                	or     %eax,%edx
80109177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010917a:	89 10                	mov    %edx,(%eax)
  lcr3(v2p(proc->pgdir)); //refresh CR3 register
8010917c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109182:	8b 40 04             	mov    0x4(%eax),%eax
80109185:	83 ec 0c             	sub    $0xc,%esp
80109188:	50                   	push   %eax
80109189:	e8 28 f5 ff ff       	call   801086b6 <v2p>
8010918e:	83 c4 10             	add    $0x10,%esp
80109191:	83 ec 0c             	sub    $0xc,%esp
80109194:	50                   	push   %eax
80109195:	e8 10 f5 ff ff       	call   801086aa <lcr3>
8010919a:	83 c4 10             	add    $0x10,%esp
}
8010919d:	90                   	nop
8010919e:	c9                   	leave  
8010919f:	c3                   	ret    

801091a0 <pageIsInFile>:

int pageIsInFile(int userPageVAddr, pde_t * pgdir) {
801091a0:	f3 0f 1e fb          	endbr32 
801091a4:	55                   	push   %ebp
801091a5:	89 e5                	mov    %esp,%ebp
801091a7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  pte = walkpgdir(pgdir, (char *)userPageVAddr, 0);
801091aa:	8b 45 08             	mov    0x8(%ebp),%eax
801091ad:	83 ec 04             	sub    $0x4,%esp
801091b0:	6a 00                	push   $0x0
801091b2:	50                   	push   %eax
801091b3:	ff 75 0c             	pushl  0xc(%ebp)
801091b6:	e8 8e f9 ff ff       	call   80108b49 <walkpgdir>
801091bb:	83 c4 10             	add    $0x10,%esp
801091be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  return (*pte & PTE_PG); //PAGE IS IN FILE
801091c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091c4:	8b 00                	mov    (%eax),%eax
801091c6:	25 00 02 00 00       	and    $0x200,%eax
}
801091cb:	c9                   	leave  
801091cc:	c3                   	ret    

801091cd <getFIFO>:




  int getFIFO(){
801091cd:	f3 0f 1e fb          	endbr32 
801091d1:	55                   	push   %ebp
801091d2:	89 e5                	mov    %esp,%ebp
801091d4:	83 ec 10             	sub    $0x10,%esp

    int pageNumber;
    uint Order = 0xFFFFFFFF;
801091d7:	c7 45 f8 ff ff ff ff 	movl   $0xffffffff,-0x8(%ebp)
    pageNumber = -1;
801091de:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%ebp)

    for (int i = 0; i < allPhysicalPages; i++) {
801091e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801091ec:	eb 6e                	jmp    8010925c <getFIFO+0x8f>
      if (proc->memController[i].state == USED && proc->memController[i].Order <= Order){
801091ee:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801091f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091f8:	89 d0                	mov    %edx,%eax
801091fa:	c1 e0 02             	shl    $0x2,%eax
801091fd:	01 d0                	add    %edx,%eax
801091ff:	c1 e0 02             	shl    $0x2,%eax
80109202:	01 c8                	add    %ecx,%eax
80109204:	05 b4 01 00 00       	add    $0x1b4,%eax
80109209:	8b 00                	mov    (%eax),%eax
8010920b:	83 f8 01             	cmp    $0x1,%eax
8010920e:	75 48                	jne    80109258 <getFIFO+0x8b>
80109210:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109217:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010921a:	89 d0                	mov    %edx,%eax
8010921c:	c1 e0 02             	shl    $0x2,%eax
8010921f:	01 d0                	add    %edx,%eax
80109221:	c1 e0 02             	shl    $0x2,%eax
80109224:	01 c8                	add    %ecx,%eax
80109226:	05 c4 01 00 00       	add    $0x1c4,%eax
8010922b:	8b 00                	mov    (%eax),%eax
8010922d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109230:	72 26                	jb     80109258 <getFIFO+0x8b>
        pageNumber = i;
80109232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109235:	89 45 fc             	mov    %eax,-0x4(%ebp)
        Order = proc->memController[i].Order;
80109238:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010923f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109242:	89 d0                	mov    %edx,%eax
80109244:	c1 e0 02             	shl    $0x2,%eax
80109247:	01 d0                	add    %edx,%eax
80109249:	c1 e0 02             	shl    $0x2,%eax
8010924c:	01 c8                	add    %ecx,%eax
8010924e:	05 c4 01 00 00       	add    $0x1c4,%eax
80109253:	8b 00                	mov    (%eax),%eax
80109255:	89 45 f8             	mov    %eax,-0x8(%ebp)
    for (int i = 0; i < allPhysicalPages; i++) {
80109258:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010925c:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
80109260:	7e 8c                	jle    801091ee <getFIFO+0x21>
      }
    }
    return pageNumber;
80109262:	8b 45 fc             	mov    -0x4(%ebp),%eax
  }
80109265:	c9                   	leave  
80109266:	c3                   	ret    

80109267 <getLRU>:


int getLRU(){
80109267:	f3 0f 1e fb          	endbr32 
8010926b:	55                   	push   %ebp
8010926c:	89 e5                	mov    %esp,%ebp
8010926e:	83 ec 10             	sub    $0x10,%esp

  int pageNumber = -1;
80109271:	c7 45 fc ff ff ff ff 	movl   $0xffffffff,-0x4(%ebp)
  uint leastAccessed = 0xffffffff, Order = 0xffffffff;
80109278:	c7 45 f8 ff ff ff ff 	movl   $0xffffffff,-0x8(%ebp)
8010927f:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)

  for (int i = 0; i < allPhysicalPages; i++) {
80109286:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010928d:	e9 b4 00 00 00       	jmp    80109346 <getLRU+0xdf>
    if (proc->memController[i].state == USED && proc->memController[i].accessNumber <= leastAccessed && proc->memController[i].Order < Order) {
80109292:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109299:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010929c:	89 d0                	mov    %edx,%eax
8010929e:	c1 e0 02             	shl    $0x2,%eax
801092a1:	01 d0                	add    %edx,%eax
801092a3:	c1 e0 02             	shl    $0x2,%eax
801092a6:	01 c8                	add    %ecx,%eax
801092a8:	05 b4 01 00 00       	add    $0x1b4,%eax
801092ad:	8b 00                	mov    (%eax),%eax
801092af:	83 f8 01             	cmp    $0x1,%eax
801092b2:	0f 85 8a 00 00 00    	jne    80109342 <getLRU+0xdb>
801092b8:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801092bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092c2:	89 d0                	mov    %edx,%eax
801092c4:	c1 e0 02             	shl    $0x2,%eax
801092c7:	01 d0                	add    %edx,%eax
801092c9:	c1 e0 02             	shl    $0x2,%eax
801092cc:	01 c8                	add    %ecx,%eax
801092ce:	05 c0 01 00 00       	add    $0x1c0,%eax
801092d3:	8b 00                	mov    (%eax),%eax
801092d5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801092d8:	72 68                	jb     80109342 <getLRU+0xdb>
801092da:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801092e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
801092e4:	89 d0                	mov    %edx,%eax
801092e6:	c1 e0 02             	shl    $0x2,%eax
801092e9:	01 d0                	add    %edx,%eax
801092eb:	c1 e0 02             	shl    $0x2,%eax
801092ee:	01 c8                	add    %ecx,%eax
801092f0:	05 c4 01 00 00       	add    $0x1c4,%eax
801092f5:	8b 00                	mov    (%eax),%eax
801092f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801092fa:	76 46                	jbe    80109342 <getLRU+0xdb>
          leastAccessed = proc->memController[i].accessNumber;
801092fc:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109303:	8b 55 f0             	mov    -0x10(%ebp),%edx
80109306:	89 d0                	mov    %edx,%eax
80109308:	c1 e0 02             	shl    $0x2,%eax
8010930b:	01 d0                	add    %edx,%eax
8010930d:	c1 e0 02             	shl    $0x2,%eax
80109310:	01 c8                	add    %ecx,%eax
80109312:	05 c0 01 00 00       	add    $0x1c0,%eax
80109317:	8b 00                	mov    (%eax),%eax
80109319:	89 45 f8             	mov    %eax,-0x8(%ebp)
          pageNumber = i;      
8010931c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010931f:	89 45 fc             	mov    %eax,-0x4(%ebp)
          Order = proc->memController[i].Order;
80109322:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109329:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010932c:	89 d0                	mov    %edx,%eax
8010932e:	c1 e0 02             	shl    $0x2,%eax
80109331:	01 d0                	add    %edx,%eax
80109333:	c1 e0 02             	shl    $0x2,%eax
80109336:	01 c8                	add    %ecx,%eax
80109338:	05 c4 01 00 00       	add    $0x1c4,%eax
8010933d:	8b 00                	mov    (%eax),%eax
8010933f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for (int i = 0; i < allPhysicalPages; i++) {
80109342:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109346:	83 7d f0 0e          	cmpl   $0xe,-0x10(%ebp)
8010934a:	0f 8e 42 ff ff ff    	jle    80109292 <getLRU+0x2b>
    }
  }
  return pageNumber;
80109350:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109353:	c9                   	leave  
80109354:	c3                   	ret    

80109355 <pageToReplace>:
//}
     //proc->whynot = pageIndex;
    //printMem();
  //proc->ramCtrlr[pageIndex].accessCount++;

int pageToReplace(){
80109355:	f3 0f 1e fb          	endbr32 
80109359:	55                   	push   %ebp
8010935a:	89 e5                	mov    %esp,%ebp

   //If FIFO use: return getFIFO();
   //If LRU use: return getLRU();
  return getLRU();
8010935c:	e8 06 ff ff ff       	call   80109267 <getLRU>
  //return getFIFO();
  panic("No Paging Mechanism Selected!!!");
}
80109361:	5d                   	pop    %ebp
80109362:	c3                   	ret    

80109363 <updateAccessNumber>:

void updateAccessNumber(struct proc * p){
80109363:	f3 0f 1e fb          	endbr32 
80109367:	55                   	push   %ebp
80109368:	89 e5                	mov    %esp,%ebp
8010936a:	53                   	push   %ebx
8010936b:	83 ec 14             	sub    $0x14,%esp

  pte_t * pte;
  for (int i = 0; i < allPhysicalPages; i++) {
8010936e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109375:	e9 bc 00 00 00       	jmp    80109436 <updateAccessNumber+0xd3>
    if (p->memController[i].state == USED){
8010937a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010937d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109380:	89 d0                	mov    %edx,%eax
80109382:	c1 e0 02             	shl    $0x2,%eax
80109385:	01 d0                	add    %edx,%eax
80109387:	c1 e0 02             	shl    $0x2,%eax
8010938a:	01 c8                	add    %ecx,%eax
8010938c:	05 b4 01 00 00       	add    $0x1b4,%eax
80109391:	8b 00                	mov    (%eax),%eax
80109393:	83 f8 01             	cmp    $0x1,%eax
80109396:	0f 85 96 00 00 00    	jne    80109432 <updateAccessNumber+0xcf>
      pte = walkpgdir(p->memController[i].pageDir, (char*)p->memController[i].myPageVirtualAddress,0);
8010939c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010939f:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093a2:	89 d0                	mov    %edx,%eax
801093a4:	c1 e0 02             	shl    $0x2,%eax
801093a7:	01 d0                	add    %edx,%eax
801093a9:	c1 e0 02             	shl    $0x2,%eax
801093ac:	01 c8                	add    %ecx,%eax
801093ae:	05 bc 01 00 00       	add    $0x1bc,%eax
801093b3:	8b 00                	mov    (%eax),%eax
801093b5:	89 c3                	mov    %eax,%ebx
801093b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801093ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093bd:	89 d0                	mov    %edx,%eax
801093bf:	c1 e0 02             	shl    $0x2,%eax
801093c2:	01 d0                	add    %edx,%eax
801093c4:	c1 e0 02             	shl    $0x2,%eax
801093c7:	01 c8                	add    %ecx,%eax
801093c9:	05 b8 01 00 00       	add    $0x1b8,%eax
801093ce:	8b 00                	mov    (%eax),%eax
801093d0:	83 ec 04             	sub    $0x4,%esp
801093d3:	6a 00                	push   $0x0
801093d5:	53                   	push   %ebx
801093d6:	50                   	push   %eax
801093d7:	e8 6d f7 ff ff       	call   80108b49 <walkpgdir>
801093dc:	83 c4 10             	add    $0x10,%esp
801093df:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if (*pte & PTE_A) {
801093e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093e5:	8b 00                	mov    (%eax),%eax
801093e7:	83 e0 20             	and    $0x20,%eax
801093ea:	85 c0                	test   %eax,%eax
801093ec:	74 44                	je     80109432 <updateAccessNumber+0xcf>
        *pte &= ~PTE_A; // turn off PTE_A flag
801093ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093f1:	8b 00                	mov    (%eax),%eax
801093f3:	83 e0 df             	and    $0xffffffdf,%eax
801093f6:	89 c2                	mov    %eax,%edx
801093f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801093fb:	89 10                	mov    %edx,(%eax)
         p->memController[i].accessNumber++;
801093fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
80109400:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109403:	89 d0                	mov    %edx,%eax
80109405:	c1 e0 02             	shl    $0x2,%eax
80109408:	01 d0                	add    %edx,%eax
8010940a:	c1 e0 02             	shl    $0x2,%eax
8010940d:	01 c8                	add    %ecx,%eax
8010940f:	05 c0 01 00 00       	add    $0x1c0,%eax
80109414:	8b 00                	mov    (%eax),%eax
80109416:	8d 48 01             	lea    0x1(%eax),%ecx
80109419:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010941c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010941f:	89 d0                	mov    %edx,%eax
80109421:	c1 e0 02             	shl    $0x2,%eax
80109424:	01 d0                	add    %edx,%eax
80109426:	c1 e0 02             	shl    $0x2,%eax
80109429:	01 d8                	add    %ebx,%eax
8010942b:	05 c0 01 00 00       	add    $0x1c0,%eax
80109430:	89 08                	mov    %ecx,(%eax)
  for (int i = 0; i < allPhysicalPages; i++) {
80109432:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109436:	83 7d f4 0e          	cmpl   $0xe,-0xc(%ebp)
8010943a:	0f 8e 3a ff ff ff    	jle    8010937a <updateAccessNumber+0x17>
      }
    } 
  }
}
80109440:	90                   	nop
80109441:	90                   	nop
80109442:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109445:	c9                   	leave  
80109446:	c3                   	ret    

80109447 <getFreeRamCtrlrIndex>:

int getFreeRamCtrlrIndex() {
80109447:	f3 0f 1e fb          	endbr32 
8010944b:	55                   	push   %ebp
8010944c:	89 e5                	mov    %esp,%ebp
8010944e:	83 ec 10             	sub    $0x10,%esp
  if (proc == 0)
80109451:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109457:	85 c0                	test   %eax,%eax
80109459:	75 07                	jne    80109462 <getFreeRamCtrlrIndex+0x1b>
    return -1;
8010945b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109460:	eb 3e                	jmp    801094a0 <getFreeRamCtrlrIndex+0x59>
  int i;
  for (i = 0; i < allPhysicalPages; i++) {
80109462:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109469:	eb 2a                	jmp    80109495 <getFreeRamCtrlrIndex+0x4e>
    if (proc->memController[i].state == NOTUSED)
8010946b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109472:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109475:	89 d0                	mov    %edx,%eax
80109477:	c1 e0 02             	shl    $0x2,%eax
8010947a:	01 d0                	add    %edx,%eax
8010947c:	c1 e0 02             	shl    $0x2,%eax
8010947f:	01 c8                	add    %ecx,%eax
80109481:	05 b4 01 00 00       	add    $0x1b4,%eax
80109486:	8b 00                	mov    (%eax),%eax
80109488:	85 c0                	test   %eax,%eax
8010948a:	75 05                	jne    80109491 <getFreeRamCtrlrIndex+0x4a>
      return i;
8010948c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010948f:	eb 0f                	jmp    801094a0 <getFreeRamCtrlrIndex+0x59>
  for (i = 0; i < allPhysicalPages; i++) {
80109491:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80109495:	83 7d fc 0e          	cmpl   $0xe,-0x4(%ebp)
80109499:	7e d0                	jle    8010946b <getFreeRamCtrlrIndex+0x24>
  }
  return -1; //NO ROOM IN RAMCTRLR
8010949b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801094a0:	c9                   	leave  
801094a1:	c3                   	ret    

801094a2 <getPageFromFile>:

static char buff[pageSize]; //buffer used to store swapped page in getPageFromFile method

int getPageFromFile(int cr2){
801094a2:	f3 0f 1e fb          	endbr32 
801094a6:	55                   	push   %ebp
801094a7:	89 e5                	mov    %esp,%ebp
801094a9:	53                   	push   %ebx
801094aa:	83 ec 34             	sub    $0x34,%esp
  proc->faultCounter++;
801094ad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094b3:	8b 50 7c             	mov    0x7c(%eax),%edx
801094b6:	83 c2 01             	add    $0x1,%edx
801094b9:	89 50 7c             	mov    %edx,0x7c(%eax)
  int userPageVAddr = PGROUNDDOWN(cr2);
801094bc:	8b 45 08             	mov    0x8(%ebp),%eax
801094bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801094c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  char * newPg = kalloc();
801094c7:	e8 37 a0 ff ff       	call   80103503 <kalloc>
801094cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memset(newPg, 0, pageSize);
801094cf:	83 ec 04             	sub    $0x4,%esp
801094d2:	68 00 10 00 00       	push   $0x1000
801094d7:	6a 00                	push   $0x0
801094d9:	ff 75 f0             	pushl  -0x10(%ebp)
801094dc:	e8 bf cb ff ff       	call   801060a0 <memset>
801094e1:	83 c4 10             	add    $0x10,%esp
  int outIndex = getFreeRamCtrlrIndex();
801094e4:	e8 5e ff ff ff       	call   80109447 <getFreeRamCtrlrIndex>
801094e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  lcr3(v2p(proc->pgdir)); //refresh CR3 register
801094ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801094f2:	8b 40 04             	mov    0x4(%eax),%eax
801094f5:	83 ec 0c             	sub    $0xc,%esp
801094f8:	50                   	push   %eax
801094f9:	e8 b8 f1 ff ff       	call   801086b6 <v2p>
801094fe:	83 c4 10             	add    $0x10,%esp
80109501:	83 ec 0c             	sub    $0xc,%esp
80109504:	50                   	push   %eax
80109505:	e8 a0 f1 ff ff       	call   801086aa <lcr3>
8010950a:	83 c4 10             	add    $0x10,%esp
  if (outIndex >= 0) { //Free location in RamCtrlr is available, no need for swapping
8010950d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109511:	78 4a                	js     8010955d <getPageFromFile+0xbb>
    fixPagedInPTE(userPageVAddr, v2p(newPg), proc->pgdir);
80109513:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109519:	8b 58 04             	mov    0x4(%eax),%ebx
8010951c:	83 ec 0c             	sub    $0xc,%esp
8010951f:	ff 75 f0             	pushl  -0x10(%ebp)
80109522:	e8 8f f1 ff ff       	call   801086b6 <v2p>
80109527:	83 c4 10             	add    $0x10,%esp
8010952a:	83 ec 04             	sub    $0x4,%esp
8010952d:	53                   	push   %ebx
8010952e:	50                   	push   %eax
8010952f:	ff 75 f4             	pushl  -0xc(%ebp)
80109532:	e8 cb fb ff ff       	call   80109102 <fixPagedInPTE>
80109537:	83 c4 10             	add    $0x10,%esp
    readPageFromFile(proc, outIndex, userPageVAddr, (char*)userPageVAddr);
8010953a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010953d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109543:	52                   	push   %edx
80109544:	ff 75 f4             	pushl  -0xc(%ebp)
80109547:	ff 75 ec             	pushl  -0x14(%ebp)
8010954a:	50                   	push   %eax
8010954b:	e8 72 95 ff ff       	call   80102ac2 <readPageFromFile>
80109550:	83 c4 10             	add    $0x10,%esp
    return 1; //Operation was successful
80109553:	b8 01 00 00 00       	mov    $0x1,%eax
80109558:	e9 19 01 00 00       	jmp    80109676 <getPageFromFile+0x1d4>
  }
  proc->countOfPagedOut++;
8010955d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109563:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80109569:	83 c2 01             	add    $0x1,%edx
8010956c:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //If reached here - Swapping is needed.
  outIndex = pageToReplace(); //select a page to swap to file
80109572:	e8 de fd ff ff       	call   80109355 <pageToReplace>
80109577:	89 45 ec             	mov    %eax,-0x14(%ebp)
 
  struct pagecontroller outPage = proc->memController[outIndex];
8010957a:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109581:	8b 55 ec             	mov    -0x14(%ebp),%edx
80109584:	89 d0                	mov    %edx,%eax
80109586:	c1 e0 02             	shl    $0x2,%eax
80109589:	01 d0                	add    %edx,%eax
8010958b:	c1 e0 02             	shl    $0x2,%eax
8010958e:	01 c8                	add    %ecx,%eax
80109590:	05 b0 01 00 00       	add    $0x1b0,%eax
80109595:	8b 50 04             	mov    0x4(%eax),%edx
80109598:	89 55 d0             	mov    %edx,-0x30(%ebp)
8010959b:	8b 50 08             	mov    0x8(%eax),%edx
8010959e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801095a1:	8b 50 0c             	mov    0xc(%eax),%edx
801095a4:	89 55 d8             	mov    %edx,-0x28(%ebp)
801095a7:	8b 50 10             	mov    0x10(%eax),%edx
801095aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
801095ad:	8b 40 14             	mov    0x14(%eax),%eax
801095b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  fixPagedInPTE(userPageVAddr, v2p(newPg), proc->pgdir);
801095b3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095b9:	8b 58 04             	mov    0x4(%eax),%ebx
801095bc:	83 ec 0c             	sub    $0xc,%esp
801095bf:	ff 75 f0             	pushl  -0x10(%ebp)
801095c2:	e8 ef f0 ff ff       	call   801086b6 <v2p>
801095c7:	83 c4 10             	add    $0x10,%esp
801095ca:	83 ec 04             	sub    $0x4,%esp
801095cd:	53                   	push   %ebx
801095ce:	50                   	push   %eax
801095cf:	ff 75 f4             	pushl  -0xc(%ebp)
801095d2:	e8 2b fb ff ff       	call   80109102 <fixPagedInPTE>
801095d7:	83 c4 10             	add    $0x10,%esp
  readPageFromFile(proc, outIndex, userPageVAddr, buff); //automatically adds to ramctrlr
801095da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801095e0:	68 60 d6 10 80       	push   $0x8010d660
801095e5:	ff 75 f4             	pushl  -0xc(%ebp)
801095e8:	ff 75 ec             	pushl  -0x14(%ebp)
801095eb:	50                   	push   %eax
801095ec:	e8 d1 94 ff ff       	call   80102ac2 <readPageFromFile>
801095f1:	83 c4 10             	add    $0x10,%esp
  int outPagePAddr = getPagePAddr(outPage.myPageVirtualAddress, outPage.pageDir);
801095f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801095f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801095fa:	83 ec 08             	sub    $0x8,%esp
801095fd:	50                   	push   %eax
801095fe:	52                   	push   %edx
801095ff:	e8 3d fa ff ff       	call   80109041 <getPagePAddr>
80109604:	83 c4 10             	add    $0x10,%esp
80109607:	89 45 e8             	mov    %eax,-0x18(%ebp)
  memmove(newPg, buff, pageSize);
8010960a:	83 ec 04             	sub    $0x4,%esp
8010960d:	68 00 10 00 00       	push   $0x1000
80109612:	68 60 d6 10 80       	push   $0x8010d660
80109617:	ff 75 f0             	pushl  -0x10(%ebp)
8010961a:	e8 48 cb ff ff       	call   80106167 <memmove>
8010961f:	83 c4 10             	add    $0x10,%esp
  writePageToFile(proc, outPage.myPageVirtualAddress, outPage.pageDir);
80109622:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80109625:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109628:	89 c1                	mov    %eax,%ecx
8010962a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109630:	83 ec 04             	sub    $0x4,%esp
80109633:	52                   	push   %edx
80109634:	51                   	push   %ecx
80109635:	50                   	push   %eax
80109636:	e8 a6 93 ff ff       	call   801029e1 <writePageToFile>
8010963b:	83 c4 10             	add    $0x10,%esp
  fixPagedOutPTE(outPage.myPageVirtualAddress, outPage.pageDir);
8010963e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109641:	8b 55 d8             	mov    -0x28(%ebp),%edx
80109644:	83 ec 08             	sub    $0x8,%esp
80109647:	50                   	push   %eax
80109648:	52                   	push   %edx
80109649:	e8 2d fa ff ff       	call   8010907b <fixPagedOutPTE>
8010964e:	83 c4 10             	add    $0x10,%esp
  char *v = p2v(outPagePAddr);
80109651:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109654:	83 ec 0c             	sub    $0xc,%esp
80109657:	50                   	push   %eax
80109658:	e8 66 f0 ff ff       	call   801086c3 <p2v>
8010965d:	83 c4 10             	add    $0x10,%esp
80109660:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  kfree(v); //free swapped page
80109663:	83 ec 0c             	sub    $0xc,%esp
80109666:	ff 75 e4             	pushl  -0x1c(%ebp)
80109669:	e8 e7 9d ff ff       	call   80103455 <kfree>
8010966e:	83 c4 10             	add    $0x10,%esp
  return 1;
80109671:	b8 01 00 00 00       	mov    $0x1,%eax
}
80109676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109679:	c9                   	leave  
8010967a:	c3                   	ret    

8010967b <addToRamCtrlr>:

int addToRamCtrlr(pde_t *pgdir, uint userPageVAddr) {
8010967b:	f3 0f 1e fb          	endbr32 
8010967f:	55                   	push   %ebp
80109680:	89 e5                	mov    %esp,%ebp
80109682:	53                   	push   %ebx
80109683:	83 ec 10             	sub    $0x10,%esp
  int freeLocation = getFreeRamCtrlrIndex();
80109686:	e8 bc fd ff ff       	call   80109447 <getFreeRamCtrlrIndex>
8010968b:	89 45 f8             	mov    %eax,-0x8(%ebp)
  proc->memController[freeLocation].state = USED;
8010968e:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109695:	8b 55 f8             	mov    -0x8(%ebp),%edx
80109698:	89 d0                	mov    %edx,%eax
8010969a:	c1 e0 02             	shl    $0x2,%eax
8010969d:	01 d0                	add    %edx,%eax
8010969f:	c1 e0 02             	shl    $0x2,%eax
801096a2:	01 c8                	add    %ecx,%eax
801096a4:	05 b4 01 00 00       	add    $0x1b4,%eax
801096a9:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  proc->memController[freeLocation].pageDir = pgdir;
801096af:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801096b6:	8b 55 f8             	mov    -0x8(%ebp),%edx
801096b9:	89 d0                	mov    %edx,%eax
801096bb:	c1 e0 02             	shl    $0x2,%eax
801096be:	01 d0                	add    %edx,%eax
801096c0:	c1 e0 02             	shl    $0x2,%eax
801096c3:	01 c8                	add    %ecx,%eax
801096c5:	8d 90 b8 01 00 00    	lea    0x1b8(%eax),%edx
801096cb:	8b 45 08             	mov    0x8(%ebp),%eax
801096ce:	89 02                	mov    %eax,(%edx)
  proc->memController[freeLocation].myPageVirtualAddress = userPageVAddr;
801096d0:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801096d7:	8b 55 f8             	mov    -0x8(%ebp),%edx
801096da:	89 d0                	mov    %edx,%eax
801096dc:	c1 e0 02             	shl    $0x2,%eax
801096df:	01 d0                	add    %edx,%eax
801096e1:	c1 e0 02             	shl    $0x2,%eax
801096e4:	01 c8                	add    %ecx,%eax
801096e6:	8d 90 bc 01 00 00    	lea    0x1bc(%eax),%edx
801096ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ef:	89 02                	mov    %eax,(%edx)
  proc->memController[freeLocation].Order = proc->loadOrderCounter++;
801096f1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801096f7:	8b 90 e0 02 00 00    	mov    0x2e0(%eax),%edx
801096fd:	8d 4a 01             	lea    0x1(%edx),%ecx
80109700:	89 88 e0 02 00 00    	mov    %ecx,0x2e0(%eax)
80109706:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
8010970d:	8b 4d f8             	mov    -0x8(%ebp),%ecx
80109710:	89 c8                	mov    %ecx,%eax
80109712:	c1 e0 02             	shl    $0x2,%eax
80109715:	01 c8                	add    %ecx,%eax
80109717:	c1 e0 02             	shl    $0x2,%eax
8010971a:	01 d8                	add    %ebx,%eax
8010971c:	05 c4 01 00 00       	add    $0x1c4,%eax
80109721:	89 10                	mov    %edx,(%eax)
  proc->memController[freeLocation].accessNumber = 0;
80109723:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010972a:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010972d:	89 d0                	mov    %edx,%eax
8010972f:	c1 e0 02             	shl    $0x2,%eax
80109732:	01 d0                	add    %edx,%eax
80109734:	c1 e0 02             	shl    $0x2,%eax
80109737:	01 c8                	add    %ecx,%eax
80109739:	05 c0 01 00 00       	add    $0x1c0,%eax
8010973e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  return freeLocation;
80109744:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80109747:	83 c4 10             	add    $0x10,%esp
8010974a:	5b                   	pop    %ebx
8010974b:	5d                   	pop    %ebp
8010974c:	c3                   	ret    

8010974d <swap>:


void swap(pde_t *pgdir, uint userPageVAddr){
8010974d:	f3 0f 1e fb          	endbr32 
80109751:	55                   	push   %ebp
80109752:	89 e5                	mov    %esp,%ebp
80109754:	53                   	push   %ebx
80109755:	83 ec 14             	sub    $0x14,%esp
  proc->countOfPagedOut++;
80109758:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010975e:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80109764:	83 c2 01             	add    $0x1,%edx
80109767:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  int outIndex = pageToReplace();
8010976d:	e8 e3 fb ff ff       	call   80109355 <pageToReplace>
80109772:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int outPagePAddr = getPagePAddr(proc->memController[outIndex].myPageVirtualAddress, proc->memController[outIndex].pageDir);
80109775:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
8010977c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010977f:	89 d0                	mov    %edx,%eax
80109781:	c1 e0 02             	shl    $0x2,%eax
80109784:	01 d0                	add    %edx,%eax
80109786:	c1 e0 02             	shl    $0x2,%eax
80109789:	01 c8                	add    %ecx,%eax
8010978b:	05 b8 01 00 00       	add    $0x1b8,%eax
80109790:	8b 08                	mov    (%eax),%ecx
80109792:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109799:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010979c:	89 d0                	mov    %edx,%eax
8010979e:	c1 e0 02             	shl    $0x2,%eax
801097a1:	01 d0                	add    %edx,%eax
801097a3:	c1 e0 02             	shl    $0x2,%eax
801097a6:	01 d8                	add    %ebx,%eax
801097a8:	05 bc 01 00 00       	add    $0x1bc,%eax
801097ad:	8b 00                	mov    (%eax),%eax
801097af:	83 ec 08             	sub    $0x8,%esp
801097b2:	51                   	push   %ecx
801097b3:	50                   	push   %eax
801097b4:	e8 88 f8 ff ff       	call   80109041 <getPagePAddr>
801097b9:	83 c4 10             	add    $0x10,%esp
801097bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  writePageToFile(proc, proc->memController[outIndex].myPageVirtualAddress, proc->memController[outIndex].pageDir);
801097bf:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
801097c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097c9:	89 d0                	mov    %edx,%eax
801097cb:	c1 e0 02             	shl    $0x2,%eax
801097ce:	01 d0                	add    %edx,%eax
801097d0:	c1 e0 02             	shl    $0x2,%eax
801097d3:	01 c8                	add    %ecx,%eax
801097d5:	05 b8 01 00 00       	add    $0x1b8,%eax
801097da:	8b 08                	mov    (%eax),%ecx
801097dc:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
801097e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801097e6:	89 d0                	mov    %edx,%eax
801097e8:	c1 e0 02             	shl    $0x2,%eax
801097eb:	01 d0                	add    %edx,%eax
801097ed:	c1 e0 02             	shl    $0x2,%eax
801097f0:	01 d8                	add    %ebx,%eax
801097f2:	05 bc 01 00 00       	add    $0x1bc,%eax
801097f7:	8b 00                	mov    (%eax),%eax
801097f9:	89 c2                	mov    %eax,%edx
801097fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109801:	83 ec 04             	sub    $0x4,%esp
80109804:	51                   	push   %ecx
80109805:	52                   	push   %edx
80109806:	50                   	push   %eax
80109807:	e8 d5 91 ff ff       	call   801029e1 <writePageToFile>
8010980c:	83 c4 10             	add    $0x10,%esp
  char *v = p2v(outPagePAddr);
8010980f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109812:	83 ec 0c             	sub    $0xc,%esp
80109815:	50                   	push   %eax
80109816:	e8 a8 ee ff ff       	call   801086c3 <p2v>
8010981b:	83 c4 10             	add    $0x10,%esp
8010981e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  kfree(v); //free swapped page
80109821:	83 ec 0c             	sub    $0xc,%esp
80109824:	ff 75 ec             	pushl  -0x14(%ebp)
80109827:	e8 29 9c ff ff       	call   80103455 <kfree>
8010982c:	83 c4 10             	add    $0x10,%esp
  proc->memController[outIndex].state = NOTUSED;
8010982f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109836:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109839:	89 d0                	mov    %edx,%eax
8010983b:	c1 e0 02             	shl    $0x2,%eax
8010983e:	01 d0                	add    %edx,%eax
80109840:	c1 e0 02             	shl    $0x2,%eax
80109843:	01 c8                	add    %ecx,%eax
80109845:	05 b4 01 00 00       	add    $0x1b4,%eax
8010984a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  fixPagedOutPTE(proc->memController[outIndex].myPageVirtualAddress, proc->memController[outIndex].pageDir);
80109850:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109857:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010985a:	89 d0                	mov    %edx,%eax
8010985c:	c1 e0 02             	shl    $0x2,%eax
8010985f:	01 d0                	add    %edx,%eax
80109861:	c1 e0 02             	shl    $0x2,%eax
80109864:	01 c8                	add    %ecx,%eax
80109866:	05 b8 01 00 00       	add    $0x1b8,%eax
8010986b:	8b 08                	mov    (%eax),%ecx
8010986d:	65 8b 1d 04 00 00 00 	mov    %gs:0x4,%ebx
80109874:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109877:	89 d0                	mov    %edx,%eax
80109879:	c1 e0 02             	shl    $0x2,%eax
8010987c:	01 d0                	add    %edx,%eax
8010987e:	c1 e0 02             	shl    $0x2,%eax
80109881:	01 d8                	add    %ebx,%eax
80109883:	05 bc 01 00 00       	add    $0x1bc,%eax
80109888:	8b 00                	mov    (%eax),%eax
8010988a:	83 ec 08             	sub    $0x8,%esp
8010988d:	51                   	push   %ecx
8010988e:	50                   	push   %eax
8010988f:	e8 e7 f7 ff ff       	call   8010907b <fixPagedOutPTE>
80109894:	83 c4 10             	add    $0x10,%esp
  addToRamCtrlr(pgdir, userPageVAddr);
80109897:	83 ec 08             	sub    $0x8,%esp
8010989a:	ff 75 0c             	pushl  0xc(%ebp)
8010989d:	ff 75 08             	pushl  0x8(%ebp)
801098a0:	e8 d6 fd ff ff       	call   8010967b <addToRamCtrlr>
801098a5:	83 c4 10             	add    $0x10,%esp
  
 // proc->ramCtrlr[freeLocation].accessCount++;
}
801098a8:	90                   	nop
801098a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801098ac:	c9                   	leave  
801098ad:	c3                   	ret    

801098ae <isNONEpolicy>:


int isNONEpolicy(){
801098ae:	f3 0f 1e fb          	endbr32 
801098b2:	55                   	push   %ebp
801098b3:	89 e5                	mov    %esp,%ebp
	//#if NONE
	//	return 1;
	//#endif
	return 0;
801098b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801098ba:	5d                   	pop    %ebp
801098bb:	c3                   	ret    

801098bc <allocuvm>:
// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int allocuvm(pde_t *pgdir, uint oldsz, uint newsz){
801098bc:	f3 0f 1e fb          	endbr32 
801098c0:	55                   	push   %ebp
801098c1:	89 e5                	mov    %esp,%ebp
801098c3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;
  if(newsz >= KERNBASE)
801098c6:	8b 45 10             	mov    0x10(%ebp),%eax
801098c9:	85 c0                	test   %eax,%eax
801098cb:	79 0a                	jns    801098d7 <allocuvm+0x1b>
    return 0;
801098cd:	b8 00 00 00 00       	mov    $0x0,%eax
801098d2:	e9 5e 01 00 00       	jmp    80109a35 <allocuvm+0x179>
  if(newsz < oldsz)
801098d7:	8b 45 10             	mov    0x10(%ebp),%eax
801098da:	3b 45 0c             	cmp    0xc(%ebp),%eax
801098dd:	73 08                	jae    801098e7 <allocuvm+0x2b>
    return oldsz;
801098df:	8b 45 0c             	mov    0xc(%ebp),%eax
801098e2:	e9 4e 01 00 00       	jmp    80109a35 <allocuvm+0x179>

  if (!isNONEpolicy()){
801098e7:	e8 c2 ff ff ff       	call   801098ae <isNONEpolicy>
801098ec:	85 c0                	test   %eax,%eax
801098ee:	75 44                	jne    80109934 <allocuvm+0x78>
     if (PGROUNDUP(newsz)/pageSize > maxNumberOfPages && proc->pid > 2) {
801098f0:	8b 45 10             	mov    0x10(%ebp),%eax
801098f3:	05 ff 0f 00 00       	add    $0xfff,%eax
801098f8:	c1 e8 0c             	shr    $0xc,%eax
801098fb:	83 f8 1e             	cmp    $0x1e,%eax
801098fe:	76 34                	jbe    80109934 <allocuvm+0x78>
80109900:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109906:	8b 40 10             	mov    0x10(%eax),%eax
80109909:	83 f8 02             	cmp    $0x2,%eax
8010990c:	7e 26                	jle    80109934 <allocuvm+0x78>
		    cprintf("proc is too big\n", PGROUNDUP(newsz)/pageSize);
8010990e:	8b 45 10             	mov    0x10(%ebp),%eax
80109911:	05 ff 0f 00 00       	add    $0xfff,%eax
80109916:	c1 e8 0c             	shr    $0xc,%eax
80109919:	83 ec 08             	sub    $0x8,%esp
8010991c:	50                   	push   %eax
8010991d:	68 66 a7 10 80       	push   $0x8010a766
80109922:	e8 b7 6a ff ff       	call   801003de <cprintf>
80109927:	83 c4 10             	add    $0x10,%esp
		    return 0;
8010992a:	b8 00 00 00 00       	mov    $0x0,%eax
8010992f:	e9 01 01 00 00       	jmp    80109a35 <allocuvm+0x179>
		  }
	}

  a = PGROUNDUP(oldsz);
80109934:	8b 45 0c             	mov    0xc(%ebp),%eax
80109937:	05 ff 0f 00 00       	add    $0xfff,%eax
8010993c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109941:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i = 0; //debugging
80109944:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(; a < newsz; a += pageSize){
8010994b:	e9 d6 00 00 00       	jmp    80109a26 <allocuvm+0x16a>
    mem = kalloc();
80109950:	e8 ae 9b ff ff       	call   80103503 <kalloc>
80109955:	89 45 ec             	mov    %eax,-0x14(%ebp)
    i++;
80109958:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if(mem == 0){
8010995c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109960:	75 2e                	jne    80109990 <allocuvm+0xd4>
      cprintf("allocuvm out of memory\n");
80109962:	83 ec 0c             	sub    $0xc,%esp
80109965:	68 77 a7 10 80       	push   $0x8010a777
8010996a:	e8 6f 6a ff ff       	call   801003de <cprintf>
8010996f:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80109972:	83 ec 04             	sub    $0x4,%esp
80109975:	ff 75 0c             	pushl  0xc(%ebp)
80109978:	ff 75 10             	pushl  0x10(%ebp)
8010997b:	ff 75 08             	pushl  0x8(%ebp)
8010997e:	e8 34 02 00 00       	call   80109bb7 <deallocuvm>
80109983:	83 c4 10             	add    $0x10,%esp
      return 0;
80109986:	b8 00 00 00 00       	mov    $0x0,%eax
8010998b:	e9 a5 00 00 00       	jmp    80109a35 <allocuvm+0x179>
    }
    memset(mem, 0, pageSize);
80109990:	83 ec 04             	sub    $0x4,%esp
80109993:	68 00 10 00 00       	push   $0x1000
80109998:	6a 00                	push   $0x0
8010999a:	ff 75 ec             	pushl  -0x14(%ebp)
8010999d:	e8 fe c6 ff ff       	call   801060a0 <memset>
801099a2:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, pageSize, v2p(mem), PTE_W|PTE_U);
801099a5:	83 ec 0c             	sub    $0xc,%esp
801099a8:	ff 75 ec             	pushl  -0x14(%ebp)
801099ab:	e8 06 ed ff ff       	call   801086b6 <v2p>
801099b0:	83 c4 10             	add    $0x10,%esp
801099b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801099b6:	83 ec 0c             	sub    $0xc,%esp
801099b9:	6a 06                	push   $0x6
801099bb:	50                   	push   %eax
801099bc:	68 00 10 00 00       	push   $0x1000
801099c1:	52                   	push   %edx
801099c2:	ff 75 08             	pushl  0x8(%ebp)
801099c5:	e8 23 f2 ff ff       	call   80108bed <mappages>
801099ca:	83 c4 20             	add    $0x20,%esp
    if (!isNONEpolicy() && proc->pid > 2){
801099cd:	e8 dc fe ff ff       	call   801098ae <isNONEpolicy>
801099d2:	85 c0                	test   %eax,%eax
801099d4:	75 49                	jne    80109a1f <allocuvm+0x163>
801099d6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801099dc:	8b 40 10             	mov    0x10(%eax),%eax
801099df:	83 f8 02             	cmp    $0x2,%eax
801099e2:	7e 3b                	jle    80109a1f <allocuvm+0x163>
      if (PGROUNDUP(oldsz)/pageSize + i > allPhysicalPages)
801099e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801099e7:	05 ff 0f 00 00       	add    $0xfff,%eax
801099ec:	c1 e8 0c             	shr    $0xc,%eax
801099ef:	89 c2                	mov    %eax,%edx
801099f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f4:	01 d0                	add    %edx,%eax
801099f6:	83 f8 0f             	cmp    $0xf,%eax
801099f9:	76 13                	jbe    80109a0e <allocuvm+0x152>
        swap(pgdir, a);
801099fb:	83 ec 08             	sub    $0x8,%esp
801099fe:	ff 75 f4             	pushl  -0xc(%ebp)
80109a01:	ff 75 08             	pushl  0x8(%ebp)
80109a04:	e8 44 fd ff ff       	call   8010974d <swap>
80109a09:	83 c4 10             	add    $0x10,%esp
80109a0c:	eb 11                	jmp    80109a1f <allocuvm+0x163>
      else //there's room
        addToRamCtrlr(pgdir, a);
80109a0e:	83 ec 08             	sub    $0x8,%esp
80109a11:	ff 75 f4             	pushl  -0xc(%ebp)
80109a14:	ff 75 08             	pushl  0x8(%ebp)
80109a17:	e8 5f fc ff ff       	call   8010967b <addToRamCtrlr>
80109a1c:	83 c4 10             	add    $0x10,%esp
  for(; a < newsz; a += pageSize){
80109a1f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109a29:	3b 45 10             	cmp    0x10(%ebp),%eax
80109a2c:	0f 82 1e ff ff ff    	jb     80109950 <allocuvm+0x94>
	  }
  }
  return newsz;
80109a32:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109a35:	c9                   	leave  
80109a36:	c3                   	ret    

80109a37 <removeFromRamCtrlr>:


//This must use userVaddress+pgdir addresses!
//(The proc has identical vAddresses on different page directories until exec finish executing)
void removeFromRamCtrlr(uint userPageVAddr, pde_t *pgdir){
80109a37:	f3 0f 1e fb          	endbr32 
80109a3b:	55                   	push   %ebp
80109a3c:	89 e5                	mov    %esp,%ebp
80109a3e:	83 ec 10             	sub    $0x10,%esp
  if (proc == 0)
80109a41:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109a47:	85 c0                	test   %eax,%eax
80109a49:	0f 84 a5 00 00 00    	je     80109af4 <removeFromRamCtrlr+0xbd>
    return;
  int i;
  for (i = 0; i < allPhysicalPages; i++) {
80109a4f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109a56:	e9 8d 00 00 00       	jmp    80109ae8 <removeFromRamCtrlr+0xb1>
    if (proc->memController[i].state == USED 
80109a5b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109a62:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109a65:	89 d0                	mov    %edx,%eax
80109a67:	c1 e0 02             	shl    $0x2,%eax
80109a6a:	01 d0                	add    %edx,%eax
80109a6c:	c1 e0 02             	shl    $0x2,%eax
80109a6f:	01 c8                	add    %ecx,%eax
80109a71:	05 b4 01 00 00       	add    $0x1b4,%eax
80109a76:	8b 00                	mov    (%eax),%eax
80109a78:	83 f8 01             	cmp    $0x1,%eax
80109a7b:	75 67                	jne    80109ae4 <removeFromRamCtrlr+0xad>
        && proc->memController[i].myPageVirtualAddress == userPageVAddr
80109a7d:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109a84:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109a87:	89 d0                	mov    %edx,%eax
80109a89:	c1 e0 02             	shl    $0x2,%eax
80109a8c:	01 d0                	add    %edx,%eax
80109a8e:	c1 e0 02             	shl    $0x2,%eax
80109a91:	01 c8                	add    %ecx,%eax
80109a93:	05 bc 01 00 00       	add    $0x1bc,%eax
80109a98:	8b 00                	mov    (%eax),%eax
80109a9a:	39 45 08             	cmp    %eax,0x8(%ebp)
80109a9d:	75 45                	jne    80109ae4 <removeFromRamCtrlr+0xad>
        && proc->memController[i].pageDir == pgdir){
80109a9f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109aa6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109aa9:	89 d0                	mov    %edx,%eax
80109aab:	c1 e0 02             	shl    $0x2,%eax
80109aae:	01 d0                	add    %edx,%eax
80109ab0:	c1 e0 02             	shl    $0x2,%eax
80109ab3:	01 c8                	add    %ecx,%eax
80109ab5:	05 b8 01 00 00       	add    $0x1b8,%eax
80109aba:	8b 00                	mov    (%eax),%eax
80109abc:	39 45 0c             	cmp    %eax,0xc(%ebp)
80109abf:	75 23                	jne    80109ae4 <removeFromRamCtrlr+0xad>
      proc->memController[i].state = NOTUSED;
80109ac1:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109ac8:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109acb:	89 d0                	mov    %edx,%eax
80109acd:	c1 e0 02             	shl    $0x2,%eax
80109ad0:	01 d0                	add    %edx,%eax
80109ad2:	c1 e0 02             	shl    $0x2,%eax
80109ad5:	01 c8                	add    %ecx,%eax
80109ad7:	05 b4 01 00 00       	add    $0x1b4,%eax
80109adc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      return;
80109ae2:	eb 11                	jmp    80109af5 <removeFromRamCtrlr+0xbe>
  for (i = 0; i < allPhysicalPages; i++) {
80109ae4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80109ae8:	83 7d fc 0e          	cmpl   $0xe,-0x4(%ebp)
80109aec:	0f 8e 69 ff ff ff    	jle    80109a5b <removeFromRamCtrlr+0x24>
80109af2:	eb 01                	jmp    80109af5 <removeFromRamCtrlr+0xbe>
    return;
80109af4:	90                   	nop
    }
  }
}
80109af5:	c9                   	leave  
80109af6:	c3                   	ret    

80109af7 <removeFromFileCtrlr>:

void removeFromFileCtrlr(uint userPageVAddr, pde_t *pgdir){
80109af7:	f3 0f 1e fb          	endbr32 
80109afb:	55                   	push   %ebp
80109afc:	89 e5                	mov    %esp,%ebp
80109afe:	83 ec 10             	sub    $0x10,%esp
  if (proc == 0)
80109b01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80109b07:	85 c0                	test   %eax,%eax
80109b09:	0f 84 a5 00 00 00    	je     80109bb4 <removeFromFileCtrlr+0xbd>
    return;
  int i;
  for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++) {
80109b0f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109b16:	e9 8d 00 00 00       	jmp    80109ba8 <removeFromFileCtrlr+0xb1>
    if (proc->fileCtrlr[i].state == USED 
80109b1b:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109b22:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109b25:	89 d0                	mov    %edx,%eax
80109b27:	c1 e0 02             	shl    $0x2,%eax
80109b2a:	01 d0                	add    %edx,%eax
80109b2c:	c1 e0 02             	shl    $0x2,%eax
80109b2f:	01 c8                	add    %ecx,%eax
80109b31:	05 88 00 00 00       	add    $0x88,%eax
80109b36:	8b 00                	mov    (%eax),%eax
80109b38:	83 f8 01             	cmp    $0x1,%eax
80109b3b:	75 67                	jne    80109ba4 <removeFromFileCtrlr+0xad>
        && proc->fileCtrlr[i].myPageVirtualAddress == userPageVAddr
80109b3d:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109b44:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109b47:	89 d0                	mov    %edx,%eax
80109b49:	c1 e0 02             	shl    $0x2,%eax
80109b4c:	01 d0                	add    %edx,%eax
80109b4e:	c1 e0 02             	shl    $0x2,%eax
80109b51:	01 c8                	add    %ecx,%eax
80109b53:	05 90 00 00 00       	add    $0x90,%eax
80109b58:	8b 00                	mov    (%eax),%eax
80109b5a:	39 45 08             	cmp    %eax,0x8(%ebp)
80109b5d:	75 45                	jne    80109ba4 <removeFromFileCtrlr+0xad>
        && proc->fileCtrlr[i].pageDir == pgdir){
80109b5f:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109b66:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109b69:	89 d0                	mov    %edx,%eax
80109b6b:	c1 e0 02             	shl    $0x2,%eax
80109b6e:	01 d0                	add    %edx,%eax
80109b70:	c1 e0 02             	shl    $0x2,%eax
80109b73:	01 c8                	add    %ecx,%eax
80109b75:	05 8c 00 00 00       	add    $0x8c,%eax
80109b7a:	8b 00                	mov    (%eax),%eax
80109b7c:	39 45 0c             	cmp    %eax,0xc(%ebp)
80109b7f:	75 23                	jne    80109ba4 <removeFromFileCtrlr+0xad>
      proc->fileCtrlr[i].state = NOTUSED;
80109b81:	65 8b 0d 04 00 00 00 	mov    %gs:0x4,%ecx
80109b88:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109b8b:	89 d0                	mov    %edx,%eax
80109b8d:	c1 e0 02             	shl    $0x2,%eax
80109b90:	01 d0                	add    %edx,%eax
80109b92:	c1 e0 02             	shl    $0x2,%eax
80109b95:	01 c8                	add    %ecx,%eax
80109b97:	05 88 00 00 00       	add    $0x88,%eax
80109b9c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      return;
80109ba2:	eb 11                	jmp    80109bb5 <removeFromFileCtrlr+0xbe>
  for (i = 0; i < maxNumberOfPages-allPhysicalPages; i++) {
80109ba4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80109ba8:	83 7d fc 0e          	cmpl   $0xe,-0x4(%ebp)
80109bac:	0f 8e 69 ff ff ff    	jle    80109b1b <removeFromFileCtrlr+0x24>
80109bb2:	eb 01                	jmp    80109bb5 <removeFromFileCtrlr+0xbe>
    return;
80109bb4:	90                   	nop
    }
  }
}
80109bb5:	c9                   	leave  
80109bb6:	c3                   	ret    

80109bb7 <deallocuvm>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int deallocuvm(pde_t *pgdir, uint oldsz, uint newsz){
80109bb7:	f3 0f 1e fb          	endbr32 
80109bbb:	55                   	push   %ebp
80109bbc:	89 e5                	mov    %esp,%ebp
80109bbe:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80109bc1:	8b 45 10             	mov    0x10(%ebp),%eax
80109bc4:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109bc7:	72 08                	jb     80109bd1 <deallocuvm+0x1a>
    return oldsz;
80109bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80109bcc:	e9 ca 00 00 00       	jmp    80109c9b <deallocuvm+0xe4>

  a = PGROUNDUP(newsz);
80109bd1:	8b 45 10             	mov    0x10(%ebp),%eax
80109bd4:	05 ff 0f 00 00       	add    $0xfff,%eax
80109bd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109bde:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i = 0; //debugging
80109be1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(; a  < oldsz; a += pageSize){
80109be8:	e9 9f 00 00 00       	jmp    80109c8c <deallocuvm+0xd5>
    pte = walkpgdir(pgdir, (char*)a, 0);
80109bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109bf0:	83 ec 04             	sub    $0x4,%esp
80109bf3:	6a 00                	push   $0x0
80109bf5:	50                   	push   %eax
80109bf6:	ff 75 08             	pushl  0x8(%ebp)
80109bf9:	e8 4b ef ff ff       	call   80108b49 <walkpgdir>
80109bfe:	83 c4 10             	add    $0x10,%esp
80109c01:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(!pte) //uninitialized page table
80109c04:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109c08:	75 09                	jne    80109c13 <deallocuvm+0x5c>
      a += (NPTENTRIES - 1) * pageSize; //jump to next page table
80109c0a:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80109c11:	eb 72                	jmp    80109c85 <deallocuvm+0xce>
    else if((*pte & PTE_P) != 0){     //page table exists and page is present
80109c13:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c16:	8b 00                	mov    (%eax),%eax
80109c18:	83 e0 01             	and    $0x1,%eax
80109c1b:	85 c0                	test   %eax,%eax
80109c1d:	74 66                	je     80109c85 <deallocuvm+0xce>
      pa = PTE_ADDR(*pte);            //pa = beginning of page physical address
80109c1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c22:	8b 00                	mov    (%eax),%eax
80109c24:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109c29:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(pa == 0)
80109c2c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109c30:	75 0d                	jne    80109c3f <deallocuvm+0x88>
        panic("kfree");
80109c32:	83 ec 0c             	sub    $0xc,%esp
80109c35:	68 8f a7 10 80       	push   $0x8010a78f
80109c3a:	e8 58 69 ff ff       	call   80100597 <panic>
      char *v = p2v(pa);
80109c3f:	83 ec 0c             	sub    $0xc,%esp
80109c42:	ff 75 e8             	pushl  -0x18(%ebp)
80109c45:	e8 79 ea ff ff       	call   801086c3 <p2v>
80109c4a:	83 c4 10             	add    $0x10,%esp
80109c4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      kfree(v); //free page
80109c50:	83 ec 0c             	sub    $0xc,%esp
80109c53:	ff 75 e4             	pushl  -0x1c(%ebp)
80109c56:	e8 fa 97 ff ff       	call   80103455 <kfree>
80109c5b:	83 c4 10             	add    $0x10,%esp
      if (!isNONEpolicy())
80109c5e:	e8 4b fc ff ff       	call   801098ae <isNONEpolicy>
80109c63:	85 c0                	test   %eax,%eax
80109c65:	75 11                	jne    80109c78 <deallocuvm+0xc1>
      	removeFromRamCtrlr(a, pgdir);
80109c67:	83 ec 08             	sub    $0x8,%esp
80109c6a:	ff 75 08             	pushl  0x8(%ebp)
80109c6d:	ff 75 f4             	pushl  -0xc(%ebp)
80109c70:	e8 c2 fd ff ff       	call   80109a37 <removeFromRamCtrlr>
80109c75:	83 c4 10             	add    $0x10,%esp
    
      i++;
80109c78:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
      *pte = 0;
80109c7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += pageSize){
80109c85:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c8f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109c92:	0f 82 55 ff ff ff    	jb     80109bed <deallocuvm+0x36>
    }
  }
  return newsz;
80109c98:	8b 45 10             	mov    0x10(%ebp),%eax
}
80109c9b:	c9                   	leave  
80109c9c:	c3                   	ret    

80109c9d <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void freevm(pde_t *pgdir){
80109c9d:	f3 0f 1e fb          	endbr32 
80109ca1:	55                   	push   %ebp
80109ca2:	89 e5                	mov    %esp,%ebp
80109ca4:	83 ec 18             	sub    $0x18,%esp
  uint i;
  if(pgdir == 0)
80109ca7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80109cab:	75 0d                	jne    80109cba <freevm+0x1d>
    panic("freevm: no pgdir");
80109cad:	83 ec 0c             	sub    $0xc,%esp
80109cb0:	68 95 a7 10 80       	push   $0x8010a795
80109cb5:	e8 dd 68 ff ff       	call   80100597 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80109cba:	83 ec 04             	sub    $0x4,%esp
80109cbd:	6a 00                	push   $0x0
80109cbf:	68 00 00 00 80       	push   $0x80000000
80109cc4:	ff 75 08             	pushl  0x8(%ebp)
80109cc7:	e8 eb fe ff ff       	call   80109bb7 <deallocuvm>
80109ccc:	83 c4 10             	add    $0x10,%esp
  int j = 0;
80109ccf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; i < NPDENTRIES; i++){
80109cd6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109cdd:	eb 53                	jmp    80109d32 <freevm+0x95>
    if(pgdir[i] & PTE_P){ //PDE exists
80109cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109ce2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ce9:	8b 45 08             	mov    0x8(%ebp),%eax
80109cec:	01 d0                	add    %edx,%eax
80109cee:	8b 00                	mov    (%eax),%eax
80109cf0:	83 e0 01             	and    $0x1,%eax
80109cf3:	85 c0                	test   %eax,%eax
80109cf5:	74 37                	je     80109d2e <freevm+0x91>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80109cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109cfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109d01:	8b 45 08             	mov    0x8(%ebp),%eax
80109d04:	01 d0                	add    %edx,%eax
80109d06:	8b 00                	mov    (%eax),%eax
80109d08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109d0d:	83 ec 0c             	sub    $0xc,%esp
80109d10:	50                   	push   %eax
80109d11:	e8 ad e9 ff ff       	call   801086c3 <p2v>
80109d16:	83 c4 10             	add    $0x10,%esp
80109d19:	89 45 ec             	mov    %eax,-0x14(%ebp)
      kfree(v); //free page table
80109d1c:	83 ec 0c             	sub    $0xc,%esp
80109d1f:	ff 75 ec             	pushl  -0x14(%ebp)
80109d22:	e8 2e 97 ff ff       	call   80103455 <kfree>
80109d27:	83 c4 10             	add    $0x10,%esp
      j++;
80109d2a:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
  for(i = 0; i < NPDENTRIES; i++){
80109d2e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80109d32:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80109d39:	76 a4                	jbe    80109cdf <freevm+0x42>
    }
  }
  kfree((char*)pgdir); //free page directory
80109d3b:	83 ec 0c             	sub    $0xc,%esp
80109d3e:	ff 75 08             	pushl  0x8(%ebp)
80109d41:	e8 0f 97 ff ff       	call   80103455 <kfree>
80109d46:	83 c4 10             	add    $0x10,%esp
}
80109d49:	90                   	nop
80109d4a:	c9                   	leave  
80109d4b:	c3                   	ret    

80109d4c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80109d4c:	f3 0f 1e fb          	endbr32 
80109d50:	55                   	push   %ebp
80109d51:	89 e5                	mov    %esp,%ebp
80109d53:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109d56:	83 ec 04             	sub    $0x4,%esp
80109d59:	6a 00                	push   $0x0
80109d5b:	ff 75 0c             	pushl  0xc(%ebp)
80109d5e:	ff 75 08             	pushl  0x8(%ebp)
80109d61:	e8 e3 ed ff ff       	call   80108b49 <walkpgdir>
80109d66:	83 c4 10             	add    $0x10,%esp
80109d69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80109d6c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109d70:	75 0d                	jne    80109d7f <clearpteu+0x33>
    panic("clearpteu");
80109d72:	83 ec 0c             	sub    $0xc,%esp
80109d75:	68 a6 a7 10 80       	push   $0x8010a7a6
80109d7a:	e8 18 68 ff ff       	call   80100597 <panic>
  *pte &= ~PTE_U;
80109d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d82:	8b 00                	mov    (%eax),%eax
80109d84:	83 e0 fb             	and    $0xfffffffb,%eax
80109d87:	89 c2                	mov    %eax,%edx
80109d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109d8c:	89 10                	mov    %edx,(%eax)
}
80109d8e:	90                   	nop
80109d8f:	c9                   	leave  
80109d90:	c3                   	ret    

80109d91 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t* copyuvm(pde_t *pgdir, uint sz){
80109d91:	f3 0f 1e fb          	endbr32 
80109d95:	55                   	push   %ebp
80109d96:	89 e5                	mov    %esp,%ebp
80109d98:	53                   	push   %ebx
80109d99:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80109d9c:	e8 e0 ee ff ff       	call   80108c81 <setupkvm>
80109da1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80109da4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109da8:	75 0a                	jne    80109db4 <copyuvm+0x23>
    return 0;
80109daa:	b8 00 00 00 00       	mov    $0x0,%eax
80109daf:	e9 26 01 00 00       	jmp    80109eda <copyuvm+0x149>
  int j = 0;
80109db4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; i < sz; i += pageSize){
80109dbb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109dc2:	e9 eb 00 00 00       	jmp    80109eb2 <copyuvm+0x121>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109dca:	83 ec 04             	sub    $0x4,%esp
80109dcd:	6a 00                	push   $0x0
80109dcf:	50                   	push   %eax
80109dd0:	ff 75 08             	pushl  0x8(%ebp)
80109dd3:	e8 71 ed ff ff       	call   80108b49 <walkpgdir>
80109dd8:	83 c4 10             	add    $0x10,%esp
80109ddb:	89 45 e8             	mov    %eax,-0x18(%ebp)
80109dde:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109de2:	75 0d                	jne    80109df1 <copyuvm+0x60>
      panic("copyuvm: pte should exist");
80109de4:	83 ec 0c             	sub    $0xc,%esp
80109de7:	68 b0 a7 10 80       	push   $0x8010a7b0
80109dec:	e8 a6 67 ff ff       	call   80100597 <panic>
    if (*pte & PTE_PG){
80109df1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109df4:	8b 00                	mov    (%eax),%eax
80109df6:	25 00 02 00 00       	and    $0x200,%eax
80109dfb:	85 c0                	test   %eax,%eax
80109dfd:	74 17                	je     80109e16 <copyuvm+0x85>
    	fixPagedOutPTE(i, d);
80109dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e02:	83 ec 08             	sub    $0x8,%esp
80109e05:	ff 75 ec             	pushl  -0x14(%ebp)
80109e08:	50                   	push   %eax
80109e09:	e8 6d f2 ff ff       	call   8010907b <fixPagedOutPTE>
80109e0e:	83 c4 10             	add    $0x10,%esp
    	continue;
80109e11:	e9 95 00 00 00       	jmp    80109eab <copyuvm+0x11a>
    }

    if(!(*pte & PTE_P))
80109e16:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e19:	8b 00                	mov    (%eax),%eax
80109e1b:	83 e0 01             	and    $0x1,%eax
80109e1e:	85 c0                	test   %eax,%eax
80109e20:	75 0d                	jne    80109e2f <copyuvm+0x9e>
      panic("copyuvm: page not present");
80109e22:	83 ec 0c             	sub    $0xc,%esp
80109e25:	68 ca a7 10 80       	push   $0x8010a7ca
80109e2a:	e8 68 67 ff ff       	call   80100597 <panic>
    pa = PTE_ADDR(*pte);
80109e2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e32:	8b 00                	mov    (%eax),%eax
80109e34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109e39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    flags = PTE_FLAGS(*pte);
80109e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e3f:	8b 00                	mov    (%eax),%eax
80109e41:	25 ff 0f 00 00       	and    $0xfff,%eax
80109e46:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80109e49:	e8 b5 96 ff ff       	call   80103503 <kalloc>
80109e4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80109e51:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80109e55:	74 6c                	je     80109ec3 <copyuvm+0x132>
      goto bad;
    memmove(mem, (char*)p2v(pa), pageSize);
80109e57:	83 ec 0c             	sub    $0xc,%esp
80109e5a:	ff 75 e4             	pushl  -0x1c(%ebp)
80109e5d:	e8 61 e8 ff ff       	call   801086c3 <p2v>
80109e62:	83 c4 10             	add    $0x10,%esp
80109e65:	83 ec 04             	sub    $0x4,%esp
80109e68:	68 00 10 00 00       	push   $0x1000
80109e6d:	50                   	push   %eax
80109e6e:	ff 75 dc             	pushl  -0x24(%ebp)
80109e71:	e8 f1 c2 ff ff       	call   80106167 <memmove>
80109e76:	83 c4 10             	add    $0x10,%esp
    j++;
80109e79:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
    if(mappages(d, (void*)i, pageSize, v2p(mem), flags) < 0)
80109e7d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80109e80:	83 ec 0c             	sub    $0xc,%esp
80109e83:	ff 75 dc             	pushl  -0x24(%ebp)
80109e86:	e8 2b e8 ff ff       	call   801086b6 <v2p>
80109e8b:	83 c4 10             	add    $0x10,%esp
80109e8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e91:	83 ec 0c             	sub    $0xc,%esp
80109e94:	53                   	push   %ebx
80109e95:	50                   	push   %eax
80109e96:	68 00 10 00 00       	push   $0x1000
80109e9b:	52                   	push   %edx
80109e9c:	ff 75 ec             	pushl  -0x14(%ebp)
80109e9f:	e8 49 ed ff ff       	call   80108bed <mappages>
80109ea4:	83 c4 20             	add    $0x20,%esp
80109ea7:	85 c0                	test   %eax,%eax
80109ea9:	78 1b                	js     80109ec6 <copyuvm+0x135>
  for(i = 0; i < sz; i += pageSize){
80109eab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109eb5:	3b 45 0c             	cmp    0xc(%ebp),%eax
80109eb8:	0f 82 09 ff ff ff    	jb     80109dc7 <copyuvm+0x36>
      goto bad;
  }
  return d;
80109ebe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ec1:	eb 17                	jmp    80109eda <copyuvm+0x149>
      goto bad;
80109ec3:	90                   	nop
80109ec4:	eb 01                	jmp    80109ec7 <copyuvm+0x136>
      goto bad;
80109ec6:	90                   	nop

bad:
  freevm(d);
80109ec7:	83 ec 0c             	sub    $0xc,%esp
80109eca:	ff 75 ec             	pushl  -0x14(%ebp)
80109ecd:	e8 cb fd ff ff       	call   80109c9d <freevm>
80109ed2:	83 c4 10             	add    $0x10,%esp
  return 0;
80109ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109eda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109edd:	c9                   	leave  
80109ede:	c3                   	ret    

80109edf <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109edf:	f3 0f 1e fb          	endbr32 
80109ee3:	55                   	push   %ebp
80109ee4:	89 e5                	mov    %esp,%ebp
80109ee6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109ee9:	83 ec 04             	sub    $0x4,%esp
80109eec:	6a 00                	push   $0x0
80109eee:	ff 75 0c             	pushl  0xc(%ebp)
80109ef1:	ff 75 08             	pushl  0x8(%ebp)
80109ef4:	e8 50 ec ff ff       	call   80108b49 <walkpgdir>
80109ef9:	83 c4 10             	add    $0x10,%esp
80109efc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f02:	8b 00                	mov    (%eax),%eax
80109f04:	83 e0 01             	and    $0x1,%eax
80109f07:	85 c0                	test   %eax,%eax
80109f09:	75 07                	jne    80109f12 <uva2ka+0x33>
    return 0;
80109f0b:	b8 00 00 00 00       	mov    $0x0,%eax
80109f10:	eb 2a                	jmp    80109f3c <uva2ka+0x5d>
  if((*pte & PTE_U) == 0)
80109f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f15:	8b 00                	mov    (%eax),%eax
80109f17:	83 e0 04             	and    $0x4,%eax
80109f1a:	85 c0                	test   %eax,%eax
80109f1c:	75 07                	jne    80109f25 <uva2ka+0x46>
    return 0;
80109f1e:	b8 00 00 00 00       	mov    $0x0,%eax
80109f23:	eb 17                	jmp    80109f3c <uva2ka+0x5d>
  return (char*)p2v(PTE_ADDR(*pte));
80109f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f28:	8b 00                	mov    (%eax),%eax
80109f2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f2f:	83 ec 0c             	sub    $0xc,%esp
80109f32:	50                   	push   %eax
80109f33:	e8 8b e7 ff ff       	call   801086c3 <p2v>
80109f38:	83 c4 10             	add    $0x10,%esp
80109f3b:	90                   	nop
}
80109f3c:	c9                   	leave  
80109f3d:	c3                   	ret    

80109f3e <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109f3e:	f3 0f 1e fb          	endbr32 
80109f42:	55                   	push   %ebp
80109f43:	89 e5                	mov    %esp,%ebp
80109f45:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109f48:	8b 45 10             	mov    0x10(%ebp),%eax
80109f4b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109f4e:	eb 7f                	jmp    80109fcf <copyout+0x91>
    va0 = (uint)PGROUNDDOWN(va);
80109f50:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f53:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109f58:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f5e:	83 ec 08             	sub    $0x8,%esp
80109f61:	50                   	push   %eax
80109f62:	ff 75 08             	pushl  0x8(%ebp)
80109f65:	e8 75 ff ff ff       	call   80109edf <uva2ka>
80109f6a:	83 c4 10             	add    $0x10,%esp
80109f6d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109f70:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80109f74:	75 07                	jne    80109f7d <copyout+0x3f>
      return -1;
80109f76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109f7b:	eb 61                	jmp    80109fde <copyout+0xa0>
    n = pageSize - (va - va0);
80109f7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109f80:	2b 45 0c             	sub    0xc(%ebp),%eax
80109f83:	05 00 10 00 00       	add    $0x1000,%eax
80109f88:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80109f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f8e:	3b 45 14             	cmp    0x14(%ebp),%eax
80109f91:	76 06                	jbe    80109f99 <copyout+0x5b>
      n = len;
80109f93:	8b 45 14             	mov    0x14(%ebp),%eax
80109f96:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80109f99:	8b 45 0c             	mov    0xc(%ebp),%eax
80109f9c:	2b 45 ec             	sub    -0x14(%ebp),%eax
80109f9f:	89 c2                	mov    %eax,%edx
80109fa1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109fa4:	01 d0                	add    %edx,%eax
80109fa6:	83 ec 04             	sub    $0x4,%esp
80109fa9:	ff 75 f0             	pushl  -0x10(%ebp)
80109fac:	ff 75 f4             	pushl  -0xc(%ebp)
80109faf:	50                   	push   %eax
80109fb0:	e8 b2 c1 ff ff       	call   80106167 <memmove>
80109fb5:	83 c4 10             	add    $0x10,%esp
    len -= n;
80109fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fbb:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109fc1:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + pageSize;
80109fc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109fc7:	05 00 10 00 00       	add    $0x1000,%eax
80109fcc:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80109fcf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109fd3:	0f 85 77 ff ff ff    	jne    80109f50 <copyout+0x12>
  }
  return 0;
80109fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109fde:	c9                   	leave  
80109fdf:	c3                   	ret    
