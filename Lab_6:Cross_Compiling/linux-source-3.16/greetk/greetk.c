#include <linux/kernel.h>

asmlinkage long sys_greetk(void) {
    printk(KERN_INFO "Greeting from kernel and team no 12\n");
    return 0;
}
