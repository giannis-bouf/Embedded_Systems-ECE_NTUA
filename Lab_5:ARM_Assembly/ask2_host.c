#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <errno.h>

// Κάθε φορά μπορεί να αλλάζει το όνομα του αρχείου
#define SERIAL_PORT "/dev/pts/3" // Εικονική σειριακή θύρα
#define MAX_STRING_LEN 66

// Συνάρτηση για τον καθαρισμό της σειριακής θύρας
void clear_serial_port(int fd) {
    char ch;

    // Διαβάζουμε και αγνοούμε όλα τα δεδομένα στη σειριακή θύρα
    while (read(fd, &ch, 1) > 0) {}

    printf("Serial port cleared.\n");
}

// Συνάρτηση για ρύθμιση παραμέτρων σειριακής θύρας
void setup_serial_port(int fd) {
    struct termios options;
    
    // Αρχικοποίηση όλων των πεδίων σε μηδενικές τιμές
    memset(&options, 0, sizeof(options));

    options.c_cflag = B9600 | CS8 | CREAD | CLOCAL; // Baudrate, 8 bit χαρακτήρες, ενεργοποίηση ανάγνωσης και τοπικής επικοινωνίας
    options.c_cc[VMIN] = 1;

    // Εφαρμογή των νέων ρυθμίσεων
    if (tcsetattr(fd, TCSANOW, &options) < 0) {
        perror("tcsetattr failed");
        exit(1);
    }

    /*
    // Εκτύπωση της δομής options, ώστε να βρούμε τις τιμές των πεδίων
    printf("Serial Port Configuration:\n");

    // Εκτύπωση των πεδίων της δομής
    printf("c_iflag: %d\n", options.c_iflag);
    printf("c_oflag: %d\n", options.c_oflag);
    printf("c_cflag: %d\n", options.c_cflag);
    printf("c_lflag: %d\n", options.c_lflag);
    printf("c_line: %d\n", options.c_line);
    printf("c_cc[VMIN]: %d\n", options.c_cc[VMIN]);
    // Εκτύπωση άλλων c_cc, αν χρειάζεται
    printf("c_cc contents:\n");
    // Εκτύπωση όλων των στοιχείων του πίνακα c_cc
    for (int i = 0; i < NCCS; i++) {
        printf("c_cc[%d]: %d\n", i, options.c_cc[i]);
    }

    // Baud rates
    printf("Input baud rate: %d\n", options.c_ispeed);
    printf("Output baud rate: %d\n", options.c_ospeed);
    */
}

// Συνάρτηση για αποστολή δεδομένων στη σειριακή θύρα
void send_data(int fd, const char *data) {
    ssize_t wr;
    int cur=0, len=strlen(data);
    do {
        wr = write(fd, data+cur, 1);
	//printf("Sending '%s'", data+cur);
	if (wr < 0) {
	   perror("Write to serial port failed");
           exit(1);
        }
	cur += wr;
    }
    while (cur < len);
    printf("Wrote to serial port succesfully...\n");
}

// Συνάρτηση για λήψη δεδομένων από τη σειριακή θύρα
void receive_data(int fd, char *buffer) {

    ssize_t bytes_read = read(fd, buffer, 4);
    if (bytes_read < 0) {
        perror("Read from serial port failed");
        exit(1);
    }
    
    if (buffer[0] == '\0') {
    	// buffer[0] = χαρακτήρας, buffer[1-2] = συχνότητα
    	for (int i=1; i<4; i++)
	    buffer[i-1] = buffer[i];
    }
    buffer[3] = '\n';
    buffer[4] = '\0'; // Διασφάλιση ότι το string τελειώνει
}

void format_output(char *b1, char *b2) {
    char *start;
    // Αν η συχνότητα είναι μονοψήφια, χρειαζόμαστε μόνο το δεύτερο ψηφίο
    if (b2[1] != '0') start = b2+1;
    else start = b2+2;

    // Αλλάζουμε το _ με τον χαρακτήρα που επιστράφηκε
    b1[31] = b2[0];
    strcat(b1, start);
}

int main() {
    int serial_fd;
    char input_string[MAX_STRING_LEN];
    char result[5];
    char response[] = "Character with max frequency: '_', Count: "; // Θα αποθηκεύσει την απάντηση από το guest

    // Άνοιγμα της σειριακής θύρας
    serial_fd = open(SERIAL_PORT, O_RDWR | O_NOCTTY | O_NDELAY);
    if (serial_fd < 0) {
        perror("Failed to open serial port");
        exit(1);
    }

    // Καθαρισμός της σειριακής θύρας
    clear_serial_port(serial_fd);

    // Ρύθμιση παραμέτρων της σειριακής θύρας
    setup_serial_port(serial_fd);

    // Διαβάζουμε το string από τον χρήστη
    printf("Enter a string (up to 64 characters): ");
    fgets(input_string, MAX_STRING_LEN, stdin);
    size_t len = strlen(input_string);

    // Αν το τελευταίο χαρακτήρας ΔΕΝ είναι '\n', το string ήταν πολύ μεγάλο
    // Στο μέγεθος του string προσμετράται και το '\n'
    if (len == MAX_STRING_LEN - 1 && input_string[len - 1] != '\n') {
	fprintf(stderr, "Input exceeds %d characters or invalid input.\n", MAX_STRING_LEN-2);

        // Άδειασμα του buffer εισόδου για αποφυγή περαιτέρω προβλημάτων
        int c;
        while ((c = getchar()) != '\n' && c != EOF);

        return 1;
    }

    // Αποστολή του string στο guest μέσω της σειριακής θύρας
    send_data(serial_fd, input_string);

    sleep(2);

    // Λήψη της απάντησης από το guest
    receive_data(serial_fd, result);
    
    format_output(response, result);
    // Εμφάνιση της απάντησης
    printf("Response from guest: %s", response);

    // Κλείσιμο της σειριακής θύρας
    close(serial_fd);

    return 0;
}
