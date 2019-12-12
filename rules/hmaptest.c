#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/errno.h>

#include "hmap.h"

struct {
    char* key;
    char* value;
} testdata[10] = {{"foo.h", "bar/baz/foo.h"},
                  {"bam.h", "baz/bar/bam.h"},
                  {"package/bam.h", "some/weird/long/path/something.h"},
                  {"another/header.h", "short/foo.h"},
                  {0, 0}};

int verifyTestData(HeaderMap* hmap) {
    int rc = 0;
    for (unsigned i = 0; testdata[i].key != NULL; ++i) {
        char* value = NULL;
        if (hmap_findEntry(hmap, testdata[i].key, &value)) {
            printf("FAILED TO FIND %s\n", testdata[i].key);
            rc = 1;
            continue;
        }
        if (!value) {
            printf("FAILED TO FETCH VALUE for %s\n", testdata[i].key);
            rc = 1;
            continue;
        }
        if (strcmp(value, testdata[i].value)) {
            printf("Value doesn't match for key '%s':\nWANT: %s\n GOT: %s\n",
                   testdata[i].key, testdata[i].value, value);
            rc = 1;
            free(value);
            continue;
        }
        printf("Verifying '%s' -> '%s' OK\n", testdata[i].key, value);
        free(value);
    }
    return rc;
}

int addTestData(HeaderMap* hmap) {
    int rc = 0;
    for (unsigned i = 0; testdata[i].key != NULL; ++i) {
        printf("Adding '%s' -> '%s'\n", testdata[i].key, testdata[i].value);
        rc |= hmap_addEntry(hmap, testdata[i].key, testdata[i].value);
    }
    return rc;
}

void dump(char* path) {
    HeaderMap* hmap = hmap_open(path, "r");
    if (!hmap) {
        fprintf(stderr, "hmap failed for '%s': %s\n", path, strerror(errno));
    }
    hmap_dump(hmap);
    hmap_close(hmap);
}

int main(int ac, char** av) {
    int rc = 0;
    HeaderMap* hmap = hmap_new(10);
    rc = addTestData(hmap);
    if (verifyTestData(hmap)) {
        printf("FAILED:\n");
        hmap_dump(hmap);
        rc = 1;
    }
    char* path = "hmap-test.hmap";
    printf("Saving hmap filel to %s\n", path);
    hmap_save(hmap, path);
    hmap_free(hmap);

    // now read it again
    printf("Reading hmap file again\n");
    hmap = hmap_open(path, "r");
    if (verifyTestData(hmap)) {
        printf("FAILED READING AGAIN:\n");
        hmap_dump(hmap);
        rc = 1;
    }
    hmap_dump(hmap);
    hmap_close(hmap);
    return rc;
}
