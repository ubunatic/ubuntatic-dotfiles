//usr/bin/gcc -o /tmp/reset-usb.out "$0" && sudo /tmp/reset-usb.out $@; exit $?
#include <stdio.h>
#include <fcntl.h>  // import open
#include <unistd.h> // import close
#include <errno.h>
#include <sys/ioctl.h>
#include <linux/usbdevice_fs.h>

int main(int argc, char **argv) {
	if(argc < 2) {
		printf("error: missing filename argument\n");
		return 1;
	}
	int fd, ok;
	const char *filename;
	filename = argv[1];
	fd = open(filename, O_WRONLY);
	if( fd < 0 ) {
		printf("error: opening %s failed (error number: %d)\n", filename, errno);
		return errno;
	}
	ok = ioctl(fd, USBDEVFS_RESET, 0);
	if (ok < 0) {
		printf("error: %s reset failed (error number: %d)\n", filename, errno);
		close(fd);
		return errno;
	}
	printf("ok: %s reset successful (return code:  %d)\n", filename, ok);
	close(fd);
	return 0;
}
