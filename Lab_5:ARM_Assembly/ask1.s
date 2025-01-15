.text
.global _start
.extern printf
.extern scanf
.extern strlen

_start:
loop:
        ldr r0, =print_str
        ldr r1, =inp_message
        bl printf

        ldr r0, =input
        ldr r1, =buffer
        bl scanf

        ldr r0, =newline_format
        mov r1, #0              // Dummy variable για να καταναλώσουμε το newline
        bl scanf

        ldr r0, =buffer
        bl strlen
        mov r2, r0

        // Έλεγχος αν το μήκος είναι 1 και αν το string είναι 'q' ή 'Q'
        cmp r2, #1
        bne continue_program    // Αν το μήκος δεν είναι 1, συνέχισε κανονικά

        ldr r1, =buffer
        ldrb r0, [r1]           // Φόρτωσε το πρώτο χαρακτήρα του input
        cmp r0, #113            // Σύγκριση με 'q' (ASCII 113)
        beq exit
        cmp r0, #81             // Σύγκριση με 'Q' (ASCII 81)
        beq exit

continue_program:
        bl transform_string

        ldr r0, =print_str
        ldr r1, =out_message
        bl printf

        ldr r0, =print_str
        ldr r1, =buffer
        bl printf

        ldr r0, =print_str
        ldr r1, =newline
        bl printf

        b loop
exit:
        ldr r0, =print_str
        ldr r1, =exit_message
        bl printf

        mov r0, #0
        mov r7, #1
        swi 0

transform_string:
        push {lr}
        ldr r1, =buffer         // Αρχικοποίησε έναν δείκτη στην αρχή του buffer
transform_loop:                 // Για κάθε iteration
        ldrb r0, [r1], #1       // Φέρε το στοιχείο που αντιστοιχεί στον δείκτη
                                // και μετάφερε τον δείκτη στο επόμενο
        cmp r0, #0              // Αν είναι null τελείωσε η επεξεργασία
        beq transform_end       // Έλεγχος για το αν το στοιχείο είναι γράμμα, αριθμός ή κάτι άλλο
        cmp r0, #48             // ASCII 48 = '0'
        blt transform_loop
        cmp r0, #57             // ASCII 57 = '9'
        ble digit

        cmp r0, #65             // ASCII 65 = 'A'
        blt transform_loop
        cmp r0, #90             // ASCII 90 = 'Z'
        ble to_lower_case

        cmp r0, #97             // ASCII 97 = 'a'
        blt transform_loop
        cmp r0, #122            // ASCII 122 = 'z'
        ble to_upper_case
        b transform_loop
to_lower_case:                  // Αν είναι κεφαλαίο
        add r0, r0, #32         // μετάτρεψέ το σε μικρό (διαφορά ASCII = 32)
        b store
to_upper_case:                  // Αν είναι μικρό
        sub r0, r0, #32         // μετάτρεψε το σε κεφαλαίο
        b store
digit:                          // Αν είναι αριθμός
        cmp r0, #53             // μεγαλύτερος ή ίσος του 5
        blt add_five
        sub r0, r0, #5          // αφαίρεσε 5
        b store
add_five:                       // αλλιώς
        add r0, r0, #5          // πρόσθεσε 5
store:
        strb r0, [r1, #-1]      // Αποθήκευσε το στοιχείο στην προηγούμενη θέση του δείκτη
        b transform_loop        // Επανάλαβε
transform_end:
        pop {lr}
        bx lr

.data
        buffer: .space 33
        buffer_end: .word buffer+33
        inp_message: .asciz "Input a string of up to 32 chars long: "
        out_message: .asciz "Result is: "
        exit_message: .asciz "Exiting...\n"
        print_str: .asciz "%s\0"
        newline_format: .asciz "%*c"
        newline: .asciz "\n"
        input: .asciz "%32[^\n]%*[^\n]" // Διάβασε μέχρι 32 χαρακτήρες από την είσοδο, εξαιρώντας οποιοδήποτε newline
.end
