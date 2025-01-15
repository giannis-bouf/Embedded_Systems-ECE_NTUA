#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <errno.h>

// Ο αριθμός του system call (αντικαταστήστε τον αν είναι διαφορετικός)
#ifndef __NR_sys_greetk
#define __NR_sys_greetk 386
#endif

int main() {
    // Κλήση του system call
    long result = syscall(__NR_sys_greetk);

    if (result == -1) {
        // Αν υπάρχει σφάλμα, εκτυπώστε τον κωδικό και την περιγραφή του
        perror("syscall sys_greetk failed");
        return 1;
    }

    printf("System call sys_greetk executed successfully, result: %ld\n", result);
    return 0;
}
