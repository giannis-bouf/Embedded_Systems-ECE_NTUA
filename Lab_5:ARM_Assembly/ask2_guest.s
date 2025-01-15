.section .data
serial_port: .asciz "/dev/ttyAMA0" // Όνομα της σειριακής θύρας
buffer:      .space 64             // Buffer για το string που θα λάβει
char:        .space 1              // Buffer για τον χαρακτήρα που θα διαβάζει
num:         .space 2              // Buffer για τον αριθμό που θα γυρνάμε
msg_open:    .asciz "Serial port opened (fd = %d)...\n"
msg_conf:    .asciz "Serial port configured...\n"
msg_wait:    .asciz "Waiting for input from serial port...\n"
msg_result:  .asciz "Sending result...\n"
msg_close:   .asciz "Closing serial port...\n"
msg_error:   .asciz "Error encountered, exiting...\n"
print_str:   .asciz "%s\0"
newline:     .asciz "\n"
flags:       .word 0x00000902
options:  .word 0x00000000 /* c_iflag */
	  .word 0x00000000 /* c_oflag */
	  .word 0x000008bd /* c_cflag */
	  .word 0x00000000 /* c_lflag */
	  .byte 0x00 /* c_line */
	  .word 0x00000000 /* c_cc[0-3] */
	  .word 0x00010000 /* c_cc[4-7] */
	  .word 0x00000000 /* c_cc[8-11] */
  	  .word 0x00000000 /* c_cc[12-15] */
	  .word 0x00000000 /* c_cc[16-19] */
	  .word 0x00000000 /* c_cc[20-23] */
	  .word 0x00000000 /* c_cc[24-27] */
	  .word 0x00000000 /* c_cc[28-31] */
	  .byte 0x00 /* padding */
	  .hword 0x0000 /* padding */
	  .word 0x00000000 /* c_ispeed */
	  .word 0x00000000 /* c_ospeed */

.section .text
.global _start

.extern open
.extern tcsetattr
.extern write
.extern close
.extern printf
.extern exit

_start:
    // Άνοιγμα σειριακής θύρας (open)
    ldr r0, =serial_port        // Διεύθυνση ονόματος συσκευής
    ldr r2, =flags
    ldr r1, [r2]
    bl open                     // Κλήση open
    cmp r0, #0                  // Έλεγχος για αποτυχία ανοίγματος
    blt error_exit
    mov r8, r0                  // Αποθήκευση του file descriptor
    
    ldr r0, =msg_open
    mov r1, r8
    bl printf

    mov r0, r8           // Φόρτωσε τον file descriptor
    mov r1, #0
    ldr r2, =options     // Φόρτωσε τη διεύθυνση του struct termios
    bl tcsetattr
    
    ldr r0, =print_str
    ldr r1, =msg_conf
    bl printf

    // Ανάγνωση string από σειριακή θύρα (read)
    mov r5, #0                  // Μετρητής χαρακτήρων
    ldr r9, =1000000            // "Χρονόμετρο"
read_char:
    mov r3, #0                  // Αρχικοποίηση μετρητή μηνύματος
read_loop:
    mov r0, r8                  // File descriptor
    ldr r1, =char               // Διεύθυνση buffer
    mov r2, #1                  // Μέγιστο μήκος
    mov r7, #3                  // Κλήση read
    swi 0
    cmp r0, #1                  // Έλεγχος αν διαβάστηκαν δεδομένα
    beq to_string
 
    // Αυξάνουμε τον μετρητή
    add r3, r3, #1              
    cmp r3, r9                  // Ελέγχουμε αν έφτασε η ώρα για εκτύπωση
    bne read_loop               // Αν όχι, συνέχισε να περιμένεις

    // Εκτύπωση μηνύματος
    ldr r0, =print_str
    ldr r1, =msg_wait           // Φορτώνουμε τη διεύθυνση του μηνύματος
    bl printf                   // Εκτύπωση με χρήση printf
    b read_char    

to_string:
    ldr r0, =char               
    ldrb r1, [r0]                
    cmp r1, #10                 // Αν λάβαμε '/n', τελείωσε το string
    beq calculate

                                // Αποθηκεύουμε τον χαρακτήρα στην θέση
    ldr r2, =buffer             // που δείχνει ο δείκτης στον buffer 
    strb r1, [r2, r5]            // που αποθηκεύουμε το string  
    add r5, r5, #1              // Μεταφέρουμε τον δείκτη στην επομένη θέση
    b read_char                 // Επαναλαμβάνουμε
 
calculate:
    ldr r2, =buffer
    mov r1, #0
    str r1, [r2, r5]            // Αποθήκευση του '/0' στο τέλος του string

    bl find_max_freq

    // Γράφουμε στην σειριακή θύρα τον χαρακτήρα που έχουμε ως αποτέλεσμα
    ldr r1, =char
    strb r2, [r1]

    mov r0, r8
    ldr r1, =char
    mov r2, #1
    mov r7, #4
    swi 0

    // Μετατρέπουμε την συχνότητα του αποτελέσματος σε string    
    cmp r3, #10                 // Αν freq < 10
    bge db_dig
    ldr r1, =num                
    mov r2, #48                  
    strb r2, [r1]               // Αποθηκεύουμε στο πρώτο στοιχείο το '0'
    add r3, r3, #48
    strb r3, [r1, #1]           // Αποθηκεύουμε στο δεύτερο στοιχείο το freq + '0'
    b write
                                // Αλλιώς
db_dig:
    mov r2, #0                  // πηλίκο
divide:
    add r2, r2, #1              // Αυξάνουμε το πηλίκο κατά 1
    sub r3, r3, #10             // Μειώνουμε την συχνότητα κατά μία δεκάδα
    cmp r3, #10                 // Αν freq >= 10, συνεχίζουμε
    bge divide
                                // Στο τέλος, r3 = υπόλοιπο
    ldr r1, =num
    add r2, r2, #48             
    strb r2, [r1]               // Αποθηκεύουμε στο πρώτο στοιχείο το πηλίκο + '0'
    add r3, r3, #48
    strb r3, [r1, #1]           // Αποθηκεύουμε στο δεύτερο στοιχείο το υπόλοιπο + '0'

write:
    mov r0, r8
    ldr r1, =num                // Φόρτωσε τη διεύθυνση του κατάλληλου buffer
    mov r2, #2                  // Μέχρι 2 ψηφία, καθώς input <= 64. Άρα, freq <= 64
    mov r7, #4
    swi 0
    

    // Κλείσιμο σειριακής θύρας (close)
    mov r0, r8                  // File descriptor
    bl close                    // Κλήση close
    ldr r0, =msg_close
    bl printf

    // Τερματισμός (exit)
    mov r0, #0                  // Κωδικός εξόδου
    bl exit                     // Κλήση exit

error_exit:
    ldr r0, =print_str
    ldr r1, =msg_error
    bl printf

    mov r0, #1                  // Κωδικός εξόδου (σφάλμα)
    bl exit                     // Κλήση exit




// Function    

find_max_freq:
    ldr r0, =buffer
    mov r1, r0

    mov r2, #0                       // Αρχικοποιούμε τον χαρακτήρα
    mov r3, #0                       // Αρχικοποιούμε την μέγιστη συχνότητα
max_freq:
    ldrb r4, [r0], #1                // Φορτώνουμε τον επόμενο χαρακτήρα
    tst r4, r4                       // Ελέγχουμε αν φτάσαμε στο τέλος
    beq exit_freq
    cmp r4, #32                      // Αν ο τρέχων χαρακτήρας είναι ' '
    beq max_freq                     // συνεχίζουμε παρακάτω

    mov r5, #0                       // Αρχικοποιούμε συχνότητα χαρακτήρα
    mov r6, r1                       // Ελέγχουμε τον buffer από την αρχή
iter:
    ldrb r7, [r6], #1
    tst r7, r7                       // Ελέγχουμε αν φτάσαμε στο τέλος
    beq finish

    cmp r7, r4                       // Ελέγχουμε αν βρήκαμε τον χαρακκτήρα
    bne iter                         // Αν ναι
    add r5, r5, #1                   // cur_freq += 1
    b iter                           // Συνεχίζουμε
finish:                              // Όταν φτάσουμε στο τέλος
    cmp r5, r3                       // Ελέγχουμε αν cur_freq < max_freq
    blt continue_freq                // Αν όχι
    cmp r5, r3                       // Ελέγχουμε αν cur_freq=max_freq
    bne refresh                      // Αν ναι
    cmp r2, r4                       // Ελέγχουμε αν ascii(cur_c)<ascii(max_c)
    blt continue_freq
refresh:                             // Ανανεώνουμε τις τιμές των αποτελεσμάτων
    mov r2, r4
    mov r3, r5
continue_freq:
    b max_freq
exit_freq:
    bx lr
