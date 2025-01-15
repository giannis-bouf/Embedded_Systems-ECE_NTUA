.text
.align 4
.global strlen
.type strlen, %function

strlen:
        push {ip, lr}
        mov r1, r0
        mov r0, #0         // Μετρητής χαρακτήρων
loop:
        ldrb r2, [r1], #1  // Τρέχων στοιχείο του buffer
        cmp r2, #0         // Αν φτάσαμε στο τέλος του string
        beq end            // Έξοδος
        add r0, r0, #1     // Διαφορετικά, αυξάνουμε τον μετρητή κατά 1
        b loop             // Συνεχίζουμε στον επόμενο χαρακτήρα
end:
        pop {ip, lr}
        bx lr
.text
.align 4
.global strcpy
.type strcpy, %function

strcpy:
        push {ip, lr}
copy:
        ldrb r2, [r1], #1  // Φορτώνουμε το τρέχων στοιχείο του input buffer
        strb r2, [r0], #1  // Το αντιγράφουμε στο αντίστοιχο στοιχείο του destination buffer
        cmp r2, #0         // Αν δεν φτάσαμε στο τέλος
        bne copy           // Προχώρησε στο επόμενο στοιχείο
        pop {ip, lr}
        bx lr
.text
.align 4
.global strcmp
.type strcmp, %function

strcmp:
        push {ip, lr}
compare:
        ldrb r2, [r0], #1
        ldrb r3, [r1], #1
        cmp r2, r3       // Συγκρίνουμε τους 2 τρέχοντες χαρακτήρες
        bne not_equal    // Δεν είναι ίσοι
        cmp r2, #0       // Ελέγχουμε εάν φτάσαμε στο τέλος του 1ου string
        beq equal        // Δεν υπάρχει άλλος χαρακτήρας για σύγκριση
        b compare        // Διαφορετικά συνεχίζουμε
not_equal:
        sub r0, r2, r3   // Η διαφορά των strings θα είναι αρνητική εάν r3 > r2
                         // Θετική εάν r3 < r2
        b done
equal:
        mov r0, #0       // Επιστρέφουμε 0 στην περίτπωση που τα strings είναι ίσα
done:
        pop {ip, lr}
        bx lr
.text
.align 4
.global strcat
.type strcat, %function

strcat:
        push {ip, lr}
find_string_end:            // Διατρέχουμε το πρώτο string μέχρι να φτάσουμε στο '\0'
        ldrb r2, [r0]
        cmp r2, #0
        beq concat_loop
        add r0, r0, #1
        b find_string_end
concat_loop:
        ldrb r3, [r1]      // Ο τρέχων χαρακτήρας του δεύτερου string που θέλουμε να αντιγράψουμε
        strb r3, [r0]      // Τον αντιγράφουμε στην κατάλληλη θέση
        cmp r3, #0         // Αν δεν φτάσαμε στο τέλος του δεύτερου string
        beq fin
        add r1, r1, #1     // Αυξάνουμε τους δείκτες
        add r0, r0, #1
        b concat_loop      // Και συνεχίζουμε με τον επόμενο χαρακτήρα
fin:
        pop {ip, lr}
        bx lr